import 'package:flutter/widgets.dart';
import 'performance_tracker.dart';

/// Mede o tempo até o 1º frame de cada tela e registra no
/// [PerformanceTracker] como `nav_<tipo>_<rota>`. Registre uma vez em
/// `MaterialApp(navigatorObservers: [PerfNavigatorObserver()])`.
class PerfNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _measure('push', route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _measure('pop', previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _measure('replace', newRoute);
  }

  void _measure(String type, Route<dynamic>? route) {
    if (route == null) return;
    final name = route.settings.name ?? route.runtimeType.toString();
    final span = PerformanceTracker.instance.start('nav_${type}_$name');
    WidgetsBinding.instance.addPostFrameCallback((_) => span.stop());
  }
}