import 'package:dev_venture/components/drag_drop/draggable_block.dart';
import 'package:dev_venture/components/drag_drop/drop_target_zone.dart';
import 'package:dev_venture/components/input_text.dart';
import 'package:dev_venture/components/metric_tile_component.dart';
import 'package:dev_venture/components/multi_selection.dart';
import 'package:dev_venture/components/selection_unica.dart';
import 'package:dev_venture/components/text_field.dart';
import 'package:dev_venture/components/true_false_question.dart';
import 'package:dev_venture/components/venture_timer.dart';
import 'package:flutter/material.dart';

class ThemeDemoPage extends StatefulWidget {
  const ThemeDemoPage({super.key});

  @override
  State<ThemeDemoPage> createState() => _ThemeDemoPageState();
}

class _ThemeDemoPageState extends State<ThemeDemoPage> {
  final _customTextFieldController = TextEditingController();
  final _customInputTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _handleOnFormSubmit() {
    if (_formKey.currentState!.validate()) {
      print("Valor do Textfield custom: ${_customTextFieldController.text}");
      print("Valor do inputText custom: ${_customInputTextController.text}");
    }
  }

  void _handleOnMultiSelectChange(List<String> selections) {
    for (String str in selections) {
      print("Selected: $str");
    }
  }

  int _score = 0;
  int _attempts = 0;

  void _onAnswered(bool isCorrect) {
    setState(() {
      _attempts++;
      if (isCorrect) {
        _score++;
      }
    });
  }

  bool _switchValue = true;
  bool _checkboxValue = false;
  int _radioValue = 0;
  double _sliderValue = 40;
  int _navIndex = 0;
  bool _chipSelected = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Theme components demo')),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Typography', style: theme.textTheme.titleLarge),
              SizedBox(height: 8),
              Text(
                'Headline: ${theme.textTheme.headlineSmall?.fontSize ?? ''}',
                style: theme.textTheme.headlineSmall,
              ),
              SizedBox(height: 16),

              Row(
                children: [
                  ElevatedButton(
                    onPressed: _handleOnFormSubmit,
                    child: const Text('Elevated'),
                  ),
                  SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Outlined'),
                  ),
                  SizedBox(width: 8),
                  TextButton(onPressed: () {}, child: const Text('Text')),
                ],
              ),

              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(Icons.info),
                        title: Text('Card Title'),
                        subtitle: Text(
                          'Card subtitle to show surface styling.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text('Form inputs'),
                    SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'TextField',
                        hintText: 'Placeholder',
                      ),
                    ),
                    SizedBox(height: 12),
                    CustomTextField(
                      hintText: "Custom Text Field",
                      labelText: "Custom Header",
                      controller: _customTextFieldController,
                    ),
                    SizedBox(height: 12),
                    CustomInputText(
                      label: "Custom Input Text",
                      controller: _customInputTextController,
                      hintText: "This is hint Text",
                      isPassword: true,
                      validator: (str) {
                        print("Str: $str");
                        return "Que retorno é esse";
                      },
                    ),
                    SizedBox(height: 12),
                    //Exemplo de uso de componente próprio
                    VentureTimer(
                      initialSeconds: 20,
                      onFinished: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const AlertDialog(
                              title: Text("Timer Has Finished"),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              MultiSelection(
                labels: [
                  "Item 1",
                  "Item 2",
                  "Item 3",
                  "Item 4",
                  "Item 5",
                  "Item 6",
                  "Item 7",
                  "Item 8",
                  "Item 9",
                ],
                onChange: _handleOnMultiSelectChange,
              ),
              SelectionUnica(
                options: ["opcção 1", "opcção 2", "opcção 3"],
                onChanged: (value) {},
              ),

              DraggableBlock(
                label: "Bloco de Teste 1",
                color: Color(0xFF6200EE),
              ),
              DropTargetZone(
                onAccept: (data) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Você soltou o: $data')),
                  );
                },
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                MetricTile(
                                  label: 'Acertos',
                                  value: _score.toString(),
                                  accent: theme.colorScheme.primary,
                                ),
                                MetricTile(
                                  label: 'Tentativas',
                                  value: _attempts.toString(),
                                  accent: theme.colorScheme.secondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      TrueFalseQuestion(
                        question: 'Flutter é um framework criado pelo Google?',
                        correctAnswer: true,
                        onAnswered: _onAnswered,
                      ),
                    ],
                  ),
                ),
              ),

              SwitchListTile(
                title: const Text('Switch'),
                value: _switchValue,
                onChanged: (v) => setState(() => _switchValue = v),
              ),

              CheckboxListTile(
                title: const Text('Checkbox'),
                value: _checkboxValue,
                onChanged: (v) => setState(() => _checkboxValue = v ?? false),
              ),

              Column(
                children: List.generate(
                  3,
                  (i) => RadioListTile<int>(
                    title: Text('Option ${i + 1}'),
                    value: i,
                    groupValue: _radioValue,
                    onChanged: (v) => setState(() => _radioValue = v ?? 0),
                  ),
                ),
              ),

              SizedBox(height: 12),
              Row(
                children: [
                  const Text('Slider:'),
                  Expanded(
                    child: Slider(
                      value: _sliderValue,
                      min: 0,
                      max: 100,
                      divisions: 10,
                      label: _sliderValue.round().toString(),
                      onChanged: (v) => setState(() => _sliderValue = v),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  const Chip(label: Text('Default Chip')),
                  ActionChip(label: const Text('Action'), onPressed: () {}),
                  ChoiceChip(
                    label: const Text('Choice'),
                    selected: _chipSelected,
                    onSelected: (s) => setState(() => _chipSelected = s),
                  ),
                  FilterChip(
                    label: const Text('Filter'),
                    selected: _chipSelected,
                    onSelected: (s) => setState(() => _chipSelected = s),
                  ),
                ],
              ),

              SizedBox(height: 16),
              const Text('Lists & Tiles'),
              SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('List item'),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ),

              SizedBox(height: 16),
              const Text('Misc'),
              SizedBox(height: 8),
              Row(
                children: [
                  FloatingActionButton.small(
                    onPressed: () {},
                    child: const Icon(Icons.edit),
                  ),
                  SizedBox(width: 12),
                  const Chip(
                    label: Text('Badge-like'),
                    avatar: CircleAvatar(child: Text('3')),
                  ),
                ],
              ),

              SizedBox(height: 24),

              DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(icon: Icon(Icons.code), text: 'Tab1'),
                        Tab(icon: Icon(Icons.desktop_mac), text: 'Tab2'),
                      ],
                    ),
                    SizedBox(
                      height: 120,
                      child: TabBarView(
                        children: [
                          Center(
                            child: Text(
                              'Tab 1 content',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Center(
                            child: Text(
                              'Tab 2 content',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
