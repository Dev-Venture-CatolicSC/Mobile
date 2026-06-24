import 'package:flutter/material.dart';

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
        title: Text("Dev Venture"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(iconTheme),
            tooltip: 'Tema: ${widget.themeMode.name}',
            onPressed: widget.onThemeChanged,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.outline, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.2),
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
                  Container(
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
                ],
              ),
            ),

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
            Text(
              "RECENTES",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // LISTA DE RECENTES
            ListTile(
              title: const Text("> Widgets Customizados"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              title: const Text("> Configuração Cloud Firestore"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrilhaCard(
    String title,
    String subtitle,
    double progress,
    ThemeData theme,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/activities');
        },
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
