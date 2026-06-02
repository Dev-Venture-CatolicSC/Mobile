import 'package:dev_venture/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:dev_venture/theme/dark_theme.dart';
import 'package:dev_venture/theme/light_theme.dart';
import 'package:dev_venture/screens/theme_demo.dart';
import 'package:dev_venture/screens/activities_screen.dart';
import 'package:dev_venture/screens/cadastro_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _onThemeChange() {
    setState(() {
      if (_themeMode == ThemeMode.system) {
        _themeMode = ThemeMode.light;
      } else if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system; // Do dark, volta para o sistema
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dev Venture',
      theme: AppLightTheme.theme,
      darkTheme: AppDarkTheme.theme,
      themeMode: _themeMode,

      // TELA INICIAL
      home: const CadastroScreen(),

      // ROTAS
      routes: {
        '/home': (context) =>
            HomeScreen(onThemeChanged: _onThemeChange, themeMode: _themeMode),
        '/activities': (context) => ActivitiesScreen(),
        '/theme-demo': (context) => const ThemeDemoPage(),
      },
    );
  }
}
