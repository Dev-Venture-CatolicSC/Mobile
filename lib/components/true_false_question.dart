import 'package:flutter/material.dart';

class TrueFalseQuestion extends StatefulWidget {
  final String question;
  final bool correctAnswer;
  final ValueChanged<bool>? onAnswered;

  const TrueFalseQuestion({
    super.key,
    required this.question,
    required this.correctAnswer,
    this.onAnswered,
  });

  @override
  State<TrueFalseQuestion> createState() => _TrueFalseQuestionState();
}

class _TrueFalseQuestionState extends State<TrueFalseQuestion> {
  bool? _selectedAnswer;
  bool _answered = false;

  void _selectAnswer(bool answer) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = answer;
      _answered = true;
    });

    widget.onAnswered?.call(answer == widget.correctAnswer);
  }

  void _retry() {
    setState(() {
      _selectedAnswer = null;
      _answered = false;
    });
  }

  Color _optionColor(BuildContext context, bool answer) {
    final scheme = Theme.of(context).colorScheme;

    if (!_answered) {
      return scheme.surface;
    }

    if (answer == widget.correctAnswer) {
      return scheme.primaryContainer;
    }

    if (answer == _selectedAnswer) {
      return scheme.errorContainer;
    }

    return scheme.surface;
  }

  Color _optionBorderColor(BuildContext context, bool answer) {
    final scheme = Theme.of(context).colorScheme;

    if (!_answered) {
      return scheme.outlineVariant;
    }

    if (answer == widget.correctAnswer) {
      return scheme.primary;
    }

    if (answer == _selectedAnswer) {
      return scheme.error;
    }

    return scheme.outlineVariant;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bool? isCorrect = _answered
        ? _selectedAnswer == widget.correctAnswer
        : null;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.question,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            _buildOptionButton(
              context: context,
              label: 'Verdadeiro',
              answer: true,
            ),
            const SizedBox(height: 12),
            _buildOptionButton(context: context, label: 'Falso', answer: false),
            if (_answered) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isCorrect == true
                      ? scheme.primaryContainer
                      : scheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCorrect == true ? Icons.check_circle : Icons.error,
                      color: isCorrect == true
                          ? scheme.onPrimaryContainer
                          : scheme.onErrorContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isCorrect == true
                            ? 'Correto! Você acertou a questão.'
                            : 'Incorreto. Tente novamente.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isCorrect == true
                              ? scheme.onPrimaryContainer
                              : scheme.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isCorrect == false) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _retry,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required String label,
    required bool answer,
  }) {
    return Semantics(
      button: true,
      selected: _answered && _selectedAnswer == answer,
      child: InkWell(
        onTap: _answered ? null : () => _selectAnswer(answer),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: _optionColor(context, answer),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _optionBorderColor(context, answer),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
