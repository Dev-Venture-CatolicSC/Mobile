import 'package:dev_venture/screens/theme_demo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('true/false question validates answer and allows retry', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(MaterialApp(home: const ThemeDemoPage()));
    expect(
      find.text('Flutter é um framework criado pelo Google?'),
      findsOneWidget,
    );
    expect(find.text('Acertos'), findsOneWidget);
    expect(find.text('Tentativas'), findsOneWidget);

    // Tap the wrong answer and verify the feedback and retry button.
    await tester.ensureVisible(find.text('Falso'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Falso'));
    await tester.pumpAndSettle();

    expect(find.text('Incorreto. Tente novamente.'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    // Tap again (should be no-op since already answered) and verify attempts didn't increase.
    await tester.ensureVisible(find.text('Falso'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Falso'));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);

    // Retry and then tap the correct answer.
    await tester.ensureVisible(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Verdadeiro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Verdadeiro'));
    await tester.pumpAndSettle();

    expect(find.text('Correto! Você acertou a questão.'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });
}
