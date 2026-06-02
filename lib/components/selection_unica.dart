import 'package:flutter/material.dart';

class SelectionUnica extends StatefulWidget {
  final List<String> options;
  final Function(String) onChanged;

  const SelectionUnica({
    super.key,
    required this.options,
    required this.onChanged,
  });

  @override
  State<SelectionUnica> createState() => _SelectionUnicaState();
}

class _SelectionUnicaState extends State<SelectionUnica> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.options.map((option) {
        return Card(
          child: RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: selectedOption,
            onChanged: (value) {
              setState(() {
                selectedOption = value;
              });

              widget.onChanged(value!);
            },
          ),
        );
      }).toList(),
    );
  }
}
