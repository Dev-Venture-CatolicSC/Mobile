import 'dart:developer' as developer;

/// SLA de tempo de resposta exigido pelo RNF (G4-N3-01): 2s.
const Duration kDefaultSla = Duration(seconds: 2);

/// Medição em andamento. Chame [stop] quando a ação terminar.
class PerfSpan {
  final String action;
  final Stopwatch _sw = Stopwatch()..start();
  final developer.TimelineTask _task;
  bool _stopped = false;

  PerfSpan._(this.action, this._task);

  void stop() {
    if (_stopped) return;
    _stopped = true;
    _sw.stop();
    _task.finish();
    PerformanceTracker.instance._record(action, _sw.elapsedMilliseconds);
  }
}

/// Cronometra ações nomeadas contra o SLA (padrão 2s). Loga no canal `perf`
/// e na Timeline do DevTools. Use em modo `--profile` (debug distorce o tempo).
class PerformanceTracker {
  PerformanceTracker._();
  static final PerformanceTracker instance = PerformanceTracker._();

  /// Limite aceitável por ação.
  Duration sla = kDefaultSla;

  // action -> durações medidas (ms)
  final Map<String, List<int>> _samples = {};

  /// Inicia uma medição manual: `start('x')` ... `span.stop()`.
  PerfSpan start(String action) =>
      PerfSpan._(action, developer.TimelineTask()..start(action));

  /// Mede uma operação assíncrona.
  Future<T> trackAsync<T>(String action, Future<T> Function() body) async {
    final span = start(action);
    try {
      return await body();
    } finally {
      span.stop();
    }
  }

  void _record(String action, int ms) {
    _samples.putIfAbsent(action, () => []).add(ms);
    final over = ms > sla.inMilliseconds;
    developer.log(
      '$action: ${ms}ms${over ? ' (> SLA)' : ''}',
      name: 'perf',
      level: over ? 900 : 700,
    );
  }

  /// Relatório agregado, pronto pra colar no documento de evidências.
  String reportText() {
    if (_samples.isEmpty) return 'Nenhuma medição registrada.';
    final b =
        StringBuffer('=== Tempo de ações (SLA ${sla.inMilliseconds}ms) ===\n');
    _samples.forEach((action, list) {
      final n = list.length;
      final avg = list.reduce((a, c) => a + c) / n;
      final max = list.reduce((a, c) => a > c ? a : c);
      final over = list.where((d) => d > sla.inMilliseconds).length;
      b.writeln('$action  |  n=$n  média=${avg.toStringAsFixed(0)}ms  '
          'máx=${max}ms  > SLA=${(over * 100 / n).toStringAsFixed(0)}%');
    });
    return b.toString();
  }
}