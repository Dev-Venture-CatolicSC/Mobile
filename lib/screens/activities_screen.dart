import 'package:flutter/material.dart';
import 'package:dev_venture/components/custom_dialog.dart';

class ActivitiesScreen extends StatelessWidget {
  ActivitiesScreen({super.key});

  final List<Map<String, dynamic>> activities = [
    {
      "title": "Implementar Login",
      "description": "Tela de autenticação",
      "status": "Concluído",
      "icon": Icons.check_circle_rounded,
      "color": Colors.green,
      "type": DialogType.success,
      "detail":
          "Atividade concluída com sucesso! Você implementou a tela de autenticação completa.",
    },
    {
      "title": "Criar Home",
      "description": "Tela principal do app",
      "status": "Em andamento",
      "icon": Icons.access_time_rounded,
      "color": Colors.orange,
      "type": DialogType.warning,
      "detail":
          "Atividade em andamento. Continue desenvolvendo a tela principal do aplicativo.",
    },
    {
      "title": "Configurar Firebase",
      "description": "Integração com banco",
      "status": "Pendente",
      "icon": Icons.error_rounded,
      "color": Colors.red,
      "type": DialogType.error,
      "detail":
          "Atividade pendente. Configure a integração com o Firebase para continuar.",
    },
  ];

  Color _chipBackground(String status, BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (status) {
      case 'Concluído':
        return Colors.green.withValues(alpha: 0.12);
      case 'Em andamento':
        return Colors.orange.withValues(alpha: 0.12);
      default:
        return scheme.errorContainer.withValues(alpha: 0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Atividades"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Ajuda',
            onPressed: () => CustomDialog.show(
              context: context,
              title: 'Lista de Atividades',
              message:
                  'Aqui você acompanha o status de cada atividade da trilha. Toque em uma atividade para ver detalhes ou segure para opções.',
              type: DialogType.info,
            ),
          ),
        ],
      ),
      body: activities.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhuma atividade disponível.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: activities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final activity = activities[index];

                return Card(
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => CustomDialog.show(
                      context: context,
                      title: activity["title"],
                      message: activity["detail"],
                      type: activity["type"],
                    ),
                    onLongPress: () async {
                      if (activity["status"] == "Concluído") {
                        CustomDialog.show(
                          context: context,
                          title: 'Já concluído',
                          message:
                              '${activity["title"]} já foi marcado como concluído.',
                          type: DialogType.success,
                        );
                        return;
                      }

                      final confirmar = await CustomDialog.confirm(
                        context: context,
                        title: 'Marcar como concluído?',
                        message:
                            'Deseja marcar "${activity["title"]}" como concluída?',
                        confirmLabel: 'Marcar',
                        cancelLabel: 'Cancelar',
                        type: DialogType.confirm,
                      );

                      if (!context.mounted) return;

                      if (confirmar) {
                        CustomDialog.show(
                          context: context,
                          title: 'Atividade concluída!',
                          message:
                              '"${activity["title"]}" foi marcada como concluída.',
                          type: DialogType.success,
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: (activity["color"] as Color).withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              activity["icon"],
                              color: activity["color"],
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity["title"],
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  activity["description"],
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _chipBackground(
                                      activity["status"],
                                      context,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    activity["status"],
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: activity["color"],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
