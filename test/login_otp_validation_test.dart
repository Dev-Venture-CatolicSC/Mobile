import 'package:dev_venture/providers/auth_provider.dart';
import 'package:dev_venture/screens/login_screen.dart';
import 'package:dev_venture/screens/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('valida e-mail e senha obrigatórios no login', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Informe seu e-mail.'), findsOneWidget);
    expect(find.text('Informe sua senha.'), findsOneWidget);
  });

  testWidgets('valida formato de e-mail no login', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.enterText(find.byType(TextFormField).first, 'email-invalido');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Digite um e-mail válido.'), findsOneWidget);
  });

  testWidgets('valida OTP com 6 dígitos numéricos', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: OtpScreen(authProvider: AuthProvider())),
    );

    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    expect(find.text('Informe o código OTP.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '123');
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('Digite um código numérico de 6 dígitos.'), findsOneWidget);
  });
}
