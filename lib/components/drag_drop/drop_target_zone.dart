import 'package:flutter/material.dart';
import 'drag_item.dart';

class DropTargetZone extends StatelessWidget {
  final String title;
  final List<DragItem> items;
  final Function(DragTargetDetails<DragItem>) onAccept;

  const DropTargetZone({
    super.key,
    required this.title,
    required this.items,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<DragItem>(
      onAcceptWithDetails: (details) => onAccept(details),
      builder: (context, candidateData, rejectedData) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty
                ? Colors.blue.withValues(alpha: 0.2)
                : Colors.transparent,
            border: Border.all(
              color: candidateData.isNotEmpty ? Colors.blue : Colors.grey,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ...items.map((i) => Text(i.label)).toList(),
            ],
          ),
        );
      },
    );
  }
}
