import 'dart:ui' show FrameTiming;
import 'package:flutter/scheduler.dart';

/// Orçamento por frame: ~16,7ms a 60Hz, ~8,3ms a 120Hz.
const Duration kFrameBudget60Hz = Duration(microseconds: 16667);
const Duration kFrameBudget120Hz = Duration(microseconds: 8333);

/// Conta frames que estouram o orçamento ("jank") — critério "sem
/// travamentos" da G4-N3-01. Rode em `--profile` (debug distorce o tempo).
class FrameMonitor {
  FrameMonitor._();
  static final FrameMonitor instance = FrameMonitor._();

  /// Acima disso, o frame conta como jank. Para 120Hz use kFrameBudget120Hz.
  Duration frameBudget = kFrameBudget60Hz;

  bool _running = false;
  int _totalFrames = 0;
  int _jankyFrames = 0;
  Duration _worst = Duration.zero;

  int get totalFrames => _totalFrames;
  int get jankyFrames => _jankyFrames;
  double get jankRate => _totalFrames == 0 ? 0 : _jankyFrames / _totalFrames;
  Duration get worstFrame => _worst;

  /// Começa a observar os frames (idempotente). Chame no `main()`.
  void start() {
    if (_running) return;
    _running = true;
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
  }

  void stop() {
    if (!_running) return;
    _running = false;
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
  }

  /// Zera os contadores (útil pra medir um fluxo isolado).
  void reset() {
    _totalFrames = 0;
    _jankyFrames = 0;
    _worst = Duration.zero;
  }

  void _onTimings(List<FrameTiming> timings) {
    for (final t in timings) {
      final total = t.totalSpan;
      _totalFrames++;
      if (total > frameBudget) _jankyFrames++;
      if (total > _worst) _worst = total;
    }
  }

  /// Relatório pronto pra colar no documento de evidências.
  String reportText() {
    if (_totalFrames == 0) return 'Nenhum frame medido.';
    final budgetMs = (frameBudget.inMicroseconds / 1000).toStringAsFixed(1);
    return '=== Frames (orçamento ${budgetMs}ms) ===\n'
        'Total: $_totalFrames | jank: $_jankyFrames '
        '(${(jankRate * 100).toStringAsFixed(1)}%) | '
        'pior frame: ${_worst.inMilliseconds}ms';
  }
}