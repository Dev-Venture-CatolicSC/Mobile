import 'package:dev_venture/components/dialogs-modal-notmodal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dev_venture/screens/activities_screen.dart';
import 'package:dev_venture/providers/atividade_provider.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  final ThemeMode themeMode;

  const HomeScreen({
    super.key,
    required this.onThemeChanged,
    required this.themeMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _trilhas = [
    {
      "title": "Dart",
      "description": "Domine a sintaxe fundamental, coleções...",
      "progress": 0.7,
    },
    {
      "title": "Flutter",
      "description": "Desenvolva interfaces de alta performance...",
      "progress": 0.4,
    },
    {
      "title": "Firebase",
      "description": "Integre autenticação e banco de dados...",
      "progress": 0.2,
    },
    {
      "title": "Android",
      "description": "Configuração de ambiente para desenvolvimento Android...",
      "progress": 0.67,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Carrega os dados reais do Firestore assim que a tela monta.
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarAtividades());
  }

  void _carregarAtividades() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<AtividadeProvider>().carregarDados(uid);
    }
  }

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData iconTheme;
    if (widget.themeMode == ThemeMode.system) {
      iconTheme = Icons.brightness_auto;
    } else if (widget.themeMode == ThemeMode.light) {
      iconTheme = Icons.wb_sunny;
    } else {
      iconTheme = Icons.nightlight_round;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dev Venture"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Sobre o app',
            onPressed: () => CustomDialog.show(
              context: context,
              title: 'Dev Venture',
              message:
                  'Plataforma de trilhas de aprendizado para desenvolvedores. Versão 1.0.0.',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.leaderboard),
            tooltip: 'Ranking',
            onPressed: () {
              Navigator.pushNamed(context, '/ranking');
            },
          ),
          IconButton(
            icon: Icon(iconTheme),
            tooltip: 'Tema: ${widget.themeMode.name}',
            onPressed: widget.onThemeChanged,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _carregarAtividades(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CARD DO PERFIL
              GestureDetector(
                onTap: () => CustomDialog.show(
                  context: context,
                  title: 'Nome Aluno',
                  message:
                      'Nível 14 - ARQUIMAGO\nPlano: Pleno\n\nEm breve você poderá editar seu perfil.',
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outline,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "NA",
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Nome Aluno",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Nível 14 - ARQUIMAGO",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => CustomDialog.show(
                          context: context,
                          title: 'Plano Pleno',
                          message:
                              'Você está no plano Pleno. Acesso completo a todas as trilhas e atividades.',
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Pleno",
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ATIVIDADE DO DIA (dado real do Firestore)
              Text(
                "ATIVIDADE DO DIA",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildAtividadeDoDia(theme),

              const SizedBox(height: 30),
              Text(
                "DASHBOARD DE TRILHAS",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Continue sua jornada acadêmica...",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 15),

              // CARDS DAS TRILHAS
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _trilhas.length,
                itemBuilder: (context, index) {
                  final trilha = _trilhas[index];
                  return _buildTrilhaCard(
                    trilha['title'],
                    trilha['description'],
                    trilha['progress'],
                    theme,
                  );
                },
              ),

              const SizedBox(height: 20),

              // HISTÓRICO DE PONTUAÇÃO (dado real do Firestore)
              Text(
                "HISTÓRICO DE PONTUAÇÃO",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _buildHistoricoPontuacao(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAtividadeDoDia(ThemeData theme) {
    return Consumer<AtividadeProvider>(
      builder: (context, provider, _) {
        if (provider.carregando) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.erro != null) {
          return Card(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                provider.erro!,
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
          );
        }

        final atividade = provider.atividadeDoDia;

        if (atividade == null) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.event_available,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Nenhuma atividade marcada para hoje.",
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            leading: Icon(
              atividade.concluida ? Icons.check_circle : Icons.bolt,
              color: atividade.concluida
                  ? Colors.green
                  : theme.colorScheme.primary,
              size: 36,
            ),
            title: Text(
              atividade.titulo,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              atividade.descricao,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              "+${atividade.pontos} pts",
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoricoPontuacao(ThemeData theme) {
    return Consumer<AtividadeProvider>(
      builder: (context, provider, _) {
        if (provider.carregando) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.historico.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "Você ainda não concluiu nenhuma atividade.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return Column(
          children: provider.historico.map((atividade) {
            return ListTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: Text(atividade.titulo),
              subtitle: Text(_formatarData(atividade.data)),
              trailing: Text(
                "+${atividade.pontosGanhos} pts",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () => CustomDialog.show(
                context: context,
                title: atividade.titulo,
                message:
                    '${atividade.descricao}\n\nPontos ganhos: ${atividade.pontosGanhos}',
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTrilhaCard(
    String title,
    String subtitle,
    double progress,
    ThemeData theme,
  ) {
    final int percent = (progress * 100).round();

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ActivitiesScreen()),
          );
        },
        onLongPress: () => CustomDialog.show(
          context: context,
          title: title,
          message: '$subtitle\n\nProgresso atual: $percent%',
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.code,
                  color: theme.colorScheme.primary,
                  size: 40,
                ),
                title: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                color: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.primaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
