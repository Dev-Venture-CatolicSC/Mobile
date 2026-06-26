import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  // Ícone e cor da medalha para os 3 primeiros
  IconData _medalIcon(int posicao) {
    switch (posicao) {
      case 1:
        return Icons.emoji_events_rounded;
      case 2:
        return Icons.military_tech_rounded;
      case 3:
        return Icons.workspace_premium_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  Color _medalColor(int posicao, BuildContext context) {
    switch (posicao) {
      case 1:
        return const Color(0xFFFFD700); // Ouro
      case 2:
        return const Color(0xFFC0C0C0); // Prata
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking Global'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .orderBy('pontuacao', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 56,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ocorreu um erro ao carregar o ranking.',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.leaderboard_rounded,
                    size: 56,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhum jogador no ranking ainda.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final posicao = index + 1;
              final nome = data['nome'] ?? 'Jogador Anônimo';
              final pontuacao = data['pontuacao'] ?? 0;
              final isTop3 = posicao <= 3;

              return Card(
                elevation: isTop3 ? 3 : 1,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: isTop3
                      ? BorderSide(
                          color: _medalColor(
                            posicao,
                            context,
                          ).withValues(alpha: 0.5),
                          width: 1.5,
                        )
                      : BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Posição / medalha
                      SizedBox(
                        width: 40,
                        child: isTop3
                            ? Icon(
                                _medalIcon(posicao),
                                color: _medalColor(posicao, context),
                                size: 30,
                              )
                            : Text(
                                '$posicao°',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                      ),
                      const SizedBox(width: 12),
                      // Avatar com iniciais
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isTop3
                            ? _medalColor(
                                posicao,
                                context,
                              ).withValues(alpha: 0.15)
                            : theme.colorScheme.surfaceContainerHigh,
                        child: Text(
                          nome.isNotEmpty ? nome[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: isTop3
                                ? _medalColor(posicao, context)
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Nome
                      Expanded(
                        child: Text(
                          nome,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: isTop3
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Pontuação
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isTop3
                              ? _medalColor(
                                  posicao,
                                  context,
                                ).withValues(alpha: 0.12)
                              : theme.colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$pontuacao pts',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: isTop3
                                ? _medalColor(posicao, context)
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
