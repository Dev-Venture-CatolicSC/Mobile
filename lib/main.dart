import 'package:dev_venture/firebase_options.dart';
import 'package:dev_venture/providers/atividade_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dev_venture/screens/home_screen.dart';
import 'package:dev_venture/theme/dark_theme.dart';
import 'package:dev_venture/theme/light_theme.dart';
import 'package:dev_venture/screens/theme_demo.dart';
import 'package:dev_venture/screens/activities_screen.dart';
import 'package:dev_venture/screens/cadastro_screen.dart';
import 'package:dev_venture/screens/login_screen.dart';
import 'package:dev_venture/screens/ranking_screen.dart';
import 'package:dev_venture/utils/performance/frame_monitor.dart';
import 'package:dev_venture/utils/performance/perf_navigator_observer.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FrameMonitor.instance.start();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
        _themeMode = ThemeMode.system;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AtividadeProvider(),
      child: MaterialApp(
        title: 'Dev Venture',
        theme: AppLightTheme.theme,
        darkTheme: AppDarkTheme.theme,
        themeMode: _themeMode,

        // Mede o tempo de abertura de cada tela
        navigatorObservers: [PerfNavigatorObserver()],

        // TELA INICIAL
        home: const CadastroScreen(),

        // ROTAS
        routes: {
          '/login': (context) => const LoginScreen(),
          '/cadastro': (context) => const CadastroScreen(),
          '/home': (context) =>
              HomeScreen(onThemeChanged: _onThemeChange, themeMode: _themeMode),
          '/activities': (context) => ActivitiesScreen(),
          '/ranking': (context) => RankingScreen(
            onThemeChanged: _onThemeChange,
            themeMode: _themeMode,
          ),
          '/theme-demo': (context) => const ThemeDemoPage(),
        },
      ),
    );
  }
}
