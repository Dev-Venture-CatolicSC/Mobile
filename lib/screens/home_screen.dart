import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dev_venture/screens/activities_screen.dart';
import 'package:dev_venture/components/custom_dialog.dart';
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

  // Título de seção padronizado
  Widget _sectionTitle(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData iconTheme;
    if (widget.themeMode == ThemeMode.system) {
      iconTheme = Icons.brightness_auto_rounded;
    } else if (widget.themeMode == ThemeMode.light) {
      iconTheme = Icons.wb_sunny_rounded;
    } else {
      iconTheme = Icons.nightlight_round;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dev Venture"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Sobre o app',
            onPressed: () => CustomDialog.show(
              context: context,
              title: 'Dev Venture',
              message:
                  'Plataforma de trilhas de aprendizado para desenvolvedores. Versão 1.0.0.',
              type: DialogType.info,
            ),
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
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CARD DO PERFIL
              _buildPerfilCard(theme),

              const SizedBox(height: 28),
              _sectionTitle('ATIVIDADE DO DIA', theme),
              _buildAtividadeDoDia(theme),

              const SizedBox(height: 28),
              _sectionTitle('DASHBOARD DE TRILHAS', theme),
              Text(
                "Continue sua jornada acadêmica...",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
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

              const SizedBox(height: 28),
              _sectionTitle('HISTÓRICO DE PONTUAÇÃO', theme),
              _buildHistoricoPontuacao(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerfilCard(ThemeData theme) {
    return GestureDetector(
      onTap: () => CustomDialog.show(
        context: context,
        title: 'Nome Aluno',
        message:
            'Nível 14 - ARQUIMAGO\nPlano: Pleno\n\nEm breve você poderá editar seu perfil.',
        type: DialogType.info,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primaryContainer,
                border: Border.all(color: theme.colorScheme.primary, width: 2),
              ),
              child: Center(
                child: Text(
                  "NA",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nome Aluno",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Nível 14 — ARQUIMAGO",
                    style: theme.textTheme.bodySmall?.copyWith(
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
                type: DialogType.success,
              ),
              child: Chip(
                label: const Text('Pleno'),
                labelStyle: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                backgroundColor: theme.colorScheme.primaryContainer,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
              ),
            ),
          ],
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
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
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Nenhuma atividade marcada para hoje.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: atividade.concluida
                    ? Colors.green.withValues(alpha: 0.12)
                    : theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                atividade.concluida
                    ? Icons.check_circle_rounded
                    : Icons.bolt_rounded,
                color: atividade.concluida
                    ? Colors.green
                    : theme.colorScheme.primary,
                size: 26,
              ),
            ),
            title: Text(
              atividade.titulo,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              atividade.descricao,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "+${atividade.pontos} pts",
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
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
          return Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.star_border_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Você ainda não concluiu nenhuma atividade.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: provider.historico.map((atividade) {
              final isLast = atividade == provider.historico.last;
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 28,
                    ),
                    title: Text(
                      atividade.titulo,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      _formatarData(atividade.data),
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: Text(
                      "+${atividade.pontosGanhos} pts",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () => CustomDialog.show(
                      context: context,
                      title: atividade.titulo,
                      message:
                          '${atividade.descricao}\n\nPontos ganhos: ${atividade.pontosGanhos}',
                      type: DialogType.success,
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: theme.colorScheme.outlineVariant,
                    ),
                ],
              );
            }).toList(),
          ),
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
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ActivitiesScreen()),
        ),
        onLongPress: () => CustomDialog.show(
          context: context,
          title: title,
          message: '$subtitle\n\nProgresso atual: $percent%',
          type: percent == 100
              ? DialogType.success
              : percent >= 50
              ? DialogType.info
              : DialogType.warning,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.code_rounded,
                  color: theme.colorScheme.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$percent%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        color: theme.colorScheme.primary,
                        backgroundColor: theme.colorScheme.primaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
