import 'package:flutter/material.dart';

class DraggableBlock extends StatelessWidget {
  final String label;
  final Color color;

  const DraggableBlock({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: label,
      feedback: Material(
        color: Colors.transparent,
        child: _buildBox(color, label.toUpperCase()),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _buildBox(Colors.grey, label)),
      child: _buildBox(color, label),
    );
  }

  Widget _buildBox(Color color, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}