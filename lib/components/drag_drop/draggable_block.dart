import 'package:flutter/material.dart';
import 'drag_item.dart';

class DraggableBlock extends StatelessWidget {
  final DragItem item;
  final Color color;

  const DraggableBlock({super.key, required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    return Draggable<DragItem>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: _buildBox(color, item.label.toUpperCase()),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildBox(Colors.grey, item.label),
      ),
      child: _buildBox(color, item.label),
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
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
