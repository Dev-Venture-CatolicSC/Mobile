import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../models/user_model.dart';
import '../providers/atomic_operations_provider.dart';

class AtomicOperationsDemoPage extends StatefulWidget {
  const AtomicOperationsDemoPage({super.key});

  @override
  State<AtomicOperationsDemoPage> createState() =>
      _AtomicOperationsDemoPageState();
}

class _AtomicOperationsDemoPageState extends State<AtomicOperationsDemoPage> {
  late final AtomicOperationsProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = AtomicOperationsProvider();
    _provider.refreshUser();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _provider,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('G4-N2-04 · Operações Atômicas'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _InfoCard(
                title: 'Transactions',
                description:
                    'Usadas quando a gravação depende de leituras prévias. '
                    'Ex.: concluir atividade, somar pontos e atualizar nível.',
              ),
              const SizedBox(height: 12),
              _InfoCard(
                title: 'Batched Writes',
                description:
                    'Usadas quando várias gravações devem acontecer juntas, '
                    'sem depender de leitura prévia. Ex.: perfil + progresso.',
              ),
              const SizedBox(height: 24),
              _UserStatusCard(user: _provider.user),
              const SizedBox(height: 16),
              _ActionButton(
                label: '1. Criar perfil demo (Batch)',
                icon: Icons.person_add_alt_1,
                loading: _provider.loading,
                onPressed: _provider.createUserProfile,
              ),
              _ActionButton(
                label: '2. Salvar atividades demo (Batch)',
                icon: Icons.library_add,
                loading: _provider.loading,
                onPressed: _provider.saveDemoActivities,
              ),
              _ActionButton(
                label: '3. Concluir próxima atividade (Transaction)',
                icon: Icons.check_circle_outline,
                loading: _provider.loading,
                onPressed: _provider.completeNextActivity,
              ),
              _ActionButton(
                label: '4. Remover atividades demo (Batch)',
                icon: Icons.delete_outline,
                loading: _provider.loading,
                onPressed: _provider.deleteDemoActivities,
              ),
              const SizedBox(height: 16),
              if (_provider.message != null)
                _FeedbackBanner(
                  message: _provider.message!,
                  isError: false,
                ),
              if (_provider.error != null)
                _FeedbackBanner(
                  message: _provider.error!,
                  isError: true,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(description),
          ],
        ),
      ),
    );
  }
}

class _UserStatusCard extends StatelessWidget {
  const _UserStatusCard({required this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Nenhum perfil demo encontrado'),
          subtitle: Text('Execute o passo 1 para criar o perfil no Firestore.'),
        ),
      );
    }

    return Card(
      child: ListTile(
        leading: const Icon(Icons.emoji_events_outlined),
        title: Text(user.nome),
        subtitle: Text(
          'Pontos: ${user.points} · Nível: ${_levelLabel(user.level)}',
        ),
      ),
    );
  }

  String _levelLabel(UserLevels level) {
    switch (level) {
      case UserLevels.junior:
        return 'Junior';
      case UserLevels.pleno:
        return 'Pleno';
      case UserLevels.senior:
        return 'Senior';
    }
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FilledButton.icon(
        onPressed: loading ? null : onPressed,
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(label),
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isError
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message),
      ),
    );
  }
}
