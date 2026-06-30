import 'package:flutter/material.dart';

class DropTargetZone extends StatefulWidget {
  final Function(String) onAccept;

  const DropTargetZone({super.key, required this.onAccept});

  @override
  State<DropTargetZone> createState() => _DropTargetZoneState();
}

class _DropTargetZoneState extends State<DropTargetZone> {
  String? acceptedData;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onAccept: (data) {
        setState(() => acceptedData = data);
        widget.onAccept(data);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          height: 100,
          width: 200,
          decoration: BoxDecoration(
            border: Border.all(color: candidateData.isNotEmpty ? Colors.green : Colors.blue),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(acceptedData ?? "Solte aqui"),
          ),
        );
      },
    );
  }
}