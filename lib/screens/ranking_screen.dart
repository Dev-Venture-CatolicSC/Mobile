import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RankingScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  final ThemeMode themeMode;

  const RankingScreen({
    super.key,
    required this.onThemeChanged,
    required this.themeMode,
  });

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
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
        title: const Text('Ranking Global'),
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

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .orderBy('pontuacao', descending: true)
            .snapshots(),

        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Ocorreu um erro ao carregar o ranking.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Nenhum jogador encontrado no ranking.'),
            );
          }

          final List<DocumentSnapshot> documentos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documentos.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data =
                  documentos[index].data() as Map<String, dynamic>;

              String nomeJogador = data['nome'] ?? 'Jogador Anônimo';
              int pontuacao = data['pontuacao'] ?? 0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}º')),
                  title: Text(
                    nomeJogador,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    '$pontuacao pts',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
