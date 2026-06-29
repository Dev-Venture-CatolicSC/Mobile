import 'package:flutter/material.dart';

class ActivitiesScreen extends StatelessWidget {
  ActivitiesScreen({super.key});

  final List<Map<String, dynamic>> activities = [
    {
      "title": "Implementar Login",
      "description": "Tela de autenticação",
      "status": "Concluído",
      "icon": Icons.check_circle,
      "color": Colors.green,
    },
    {
      "title": "Criar Home",
      "description": "Tela principal do app",
      "status": "Em andamento",
      "icon": Icons.access_time,
      "color": Colors.orange,
    },
    {
      "title": "Configurar Firebase",
      "description": "Integração com banco",
      "status": "Pendente",
      "icon": Icons.error,
      "color": Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Atividades"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];

            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Atividade '${activity["title"]}' selecionada.",
                      ),
                    ),
                  );
                },
                leading: Icon(
                  activity["icon"],
                  color: activity["color"],
                  size: 32,
                ),
                title: Text(
                  activity["title"],
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity["description"],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      activity["status"],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: activity["color"],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
