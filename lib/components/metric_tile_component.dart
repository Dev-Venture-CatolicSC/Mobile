import 'package:flutter/material.dart';

class MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: accent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}
