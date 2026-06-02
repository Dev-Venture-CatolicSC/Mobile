import 'package:flutter/material.dart';

class MultiSelection extends StatefulWidget {
  final List<String> labels;
  final Function(List<String> selecionados) onChange;

  const MultiSelection({
    super.key,
    required this.labels,
    required this.onChange,
  });

  @override
  State<MultiSelection> createState() => _MultiSelectionState();
}

class _MultiSelectionState extends State<MultiSelection> {
  final List<String> selecionados = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var label in widget.labels)
          CheckboxListTile(
            title: Text(label),
            controlAffinity: ListTileControlAffinity.leading,
            value: selecionados.contains(label),
            onChanged: (bool? marcado) {
              setState(() {
                if (marcado == true) {
                  selecionados.add(label);
                } else {
                  selecionados.remove(label);
                }
              });

              widget.onChange(List.from(selecionados));
            },
          ),
      ],
    );
  }
}
