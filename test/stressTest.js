const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const fs = require("fs");
const path = require("path");

// ─── CONFIGURAÇÃO ──────────────────────────────────────────────────────────────
const SERVICE_ACCOUNT_PATH = path.join(__dirname, "serviceAccount.json");
const NUM_USERS = 35;
const COLLECTION = "stress_test_devventure";
// ───────────────────────────────────────────────────────────────────────────────

if (!fs.existsSync(SERVICE_ACCOUNT_PATH)) {
  console.error("\n❌ ERRO: serviceAccount.json não encontrado!");
  process.exit(1);
}

const serviceAccount = require(SERVICE_ACCOUNT_PATH);
initializeApp({ credential: cert(serviceAccount) });
const db = getFirestore();

const results = {
  writes: { success: 0, fail: 0, times: [] },
  reads: { success: 0, fail: 0, times: [] },
  transactions: { success: 0, fail: 0, times: [] },
  startTime: null,
  endTime: null,
};

function log(msg) { console.log(`[${new Date().toISOString()}] ${msg}`); }
function avg(arr) { return arr.length ? Math.round(arr.reduce((a, b) => a + b, 0) / arr.length) : 0; }
function max(arr) { return arr.length ? Math.max(...arr) : 0; }
function min(arr) { return arr.length ? Math.min(...arr) : 0; }

async function simulateWrite(userId) {
  const t0 = Date.now();
  try {
    await db.collection(COLLECTION).doc(`user_${userId}`).set({
      userId,
      pontos: Math.floor(Math.random() * 1000),
      nivel: Math.floor(Math.random() * 10) + 1,
      ultimoAcesso: FieldValue.serverTimestamp(),
      tipo: ["presence", "score", "activity_answer"][userId % 3],
    });
    results.writes.success++;
    results.writes.times.push(Date.now() - t0);
  } catch (e) {
    results.writes.fail++;
    log(`❌ Erro escrita user_${userId}: ${e.message}`);
  }
}

async function simulateRead(userId) {
  const t0 = Date.now();
  try {
    const targetId = Math.floor(Math.random() * NUM_USERS) + 1;
    await db.collection(COLLECTION).doc(`user_${targetId}`).get();
    results.reads.success++;
    results.reads.times.push(Date.now() - t0);
  } catch (e) {
    results.reads.fail++;
    log(`❌ Erro leitura user_${userId}: ${e.message}`);
  }
}

async function simulateTransaction(userId) {
  const t0 = Date.now();
  const docRef = db.collection(COLLECTION).doc(`user_${userId}`);
  try {
    await db.runTransaction(async (transaction) => {
      const doc = await transaction.get(docRef);
      const pontosAtuais = doc.exists ? (doc.data().pontos || 0) : 0;
      transaction.set(docRef, {
        userId,
        pontos: pontosAtuais + 10,
        ultimaTransacao: FieldValue.serverTimestamp(),
        contagemTransacoes: FieldValue.increment(1),
      }, { merge: true });
    });
    results.transactions.success++;
    results.transactions.times.push(Date.now() - t0);
  } catch (e) {
    results.transactions.fail++;
    log(`❌ Erro transação user_${userId}: ${e.message}`);
  }
}

function printReport() {
  const duration = ((results.endTime - results.startTime) / 1000).toFixed(2);
  const totalOps = NUM_USERS * 3;
  const totalSucc = results.writes.success + results.reads.success + results.transactions.success;
  const successRate = ((totalSucc / totalOps) * 100).toFixed(1);

  console.log("\n╔══════════════════════════════════════════════════════════════╗");
  console.log("║         DEVVENTURE — RELATÓRIO DE STRESS TEST               ║");
  console.log("╚══════════════════════════════════════════════════════════════╝");
  console.log(`\n📅 Data/Hora : ${new Date().toLocaleString("pt-BR")}`);
  console.log(`⏱  Duração   : ${duration}s`);
  console.log(`👥 Usuários  : ${NUM_USERS} simultâneos`);
  console.log(`📦 Operações : ${totalOps} total\n`);
  console.log("┌──────────────────┬──────────┬──────────┬────────┬────────┬────────┐");
  console.log("│ Operação         │ Sucesso  │  Falha   │ Avg ms │ Min ms │ Max ms │");
  console.log("├──────────────────┼──────────┼──────────┼────────┼────────┼────────┤");

  const ops = [
    ["Escrita (write)", results.writes],
    ["Leitura (read)", results.reads],
    ["Transação (atomic)", results.transactions],
  ];

  for (const [label, r] of ops) {
    console.log(`│ ${label.padEnd(16)} │  ${String(r.success).padStart(6)}  │  ${String(r.fail).padStart(6)}  │ ${String(avg(r.times)).padStart(6)} │ ${String(min(r.times)).padStart(6)} │ ${String(max(r.times)).padStart(6)} │`);
  }

  console.log("└──────────────────┴──────────┴──────────┴────────┴────────┴────────┘");
  console.log(`\n✅ Taxa de sucesso : ${successRate}%`);

  const totalFails = results.writes.fail + results.reads.fail + results.transactions.fail;
  if (totalFails === 0) {
    console.log("🏆 RESULTADO: APROVADO — Nenhuma falha detectada sob carga concorrente.");
  } else {
    console.log(`⚠️  RESULTADO: ${totalFails} falha(s) detectada(s).`);
  }

  const report = {
    data: new Date().toISOString(),
    duracaoSegundos: parseFloat(duration),
    usuariosSimulados: NUM_USERS,
    totalOperacoes: totalOps,
    taxaSucesso: `${successRate}%`,
    escritas: { sucesso: results.writes.success, falha: results.writes.fail, avgMs: avg(results.writes.times) },
    leituras: { sucesso: results.reads.success, falha: results.reads.fail, avgMs: avg(results.reads.times) },
    transacoes: { sucesso: results.transactions.success, falha: results.transactions.fail, avgMs: avg(results.transactions.times) },
    aprovado: totalFails === 0,
  };

  fs.writeFileSync(path.join(__dirname, "resultado_stress_test.json"), JSON.stringify(report, null, 2));
  console.log("\n💾 Relatório salvo em: resultado_stress_test.json\n");
}

async function main() {
  log(`🚀 Iniciando stress test com ${NUM_USERS} usuários simultâneos...`);
  results.startTime = Date.now();

  log("📝 FASE 1: Escritas simultâneas...");
  await Promise.all(Array.from({ length: NUM_USERS }, (_, i) => simulateWrite(i + 1)));
  log(`   ✔ ${results.writes.success}/${NUM_USERS} escritas concluídas`);

  log("📖 FASE 2: Leituras simultâneas...");
  await Promise.all(Array.from({ length: NUM_USERS }, (_, i) => simulateRead(i + 1)));
  log(`   ✔ ${results.reads.success}/${NUM_USERS} leituras concluídas`);

  log("🔄 FASE 3: Transações atômicas simultâneas...");
  await Promise.all(Array.from({ length: NUM_USERS }, (_, i) => simulateTransaction(i + 1)));
  log(`   ✔ ${results.transactions.success}/${NUM_USERS} transações concluídas`);

  results.endTime = Date.now();
  printReport();
  process.exit(0);
}

main().catch((err) => {
  console.error("\n💥 Erro fatal:", err.message);
  process.exit(1);
});