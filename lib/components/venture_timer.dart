import 'dart:async';
import 'package:flutter/material.dart';

class VentureTimer extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback? onFinished;
  final TextStyle? style;
  final double? fontSize;

  const VentureTimer({
    super.key,
    required this.initialSeconds,
    this.onFinished,
    this.style,
    this.fontSize,
  });

  @override
  State<VentureTimer> createState() => _VentureTimerState();
}

class _VentureTimerState extends State<VentureTimer>
    with WidgetsBindingObserver {
  late final ValueNotifier<int> _secondsNotifier;
  Timer? _timer;
  DateTime? _backgroundTimestamp;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _secondsNotifier = ValueNotifier<int>(widget.initialSeconds);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsNotifier.value > 0) {
        _secondsNotifier.value--;
      } else {
        _stopTimer();
        widget.onFinished?.call();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Salva o momento em que o app foi para background
      _backgroundTimestamp = DateTime.now();
    } else if (state == AppLifecycleState.resumed &&
        _backgroundTimestamp != null) {
      // Calcula quanto tempo passou e subtrai do notifier
      final gap = DateTime.now().difference(_backgroundTimestamp!).inSeconds;
      final remaining = _secondsNotifier.value - gap;

      _secondsNotifier.value = remaining > 0 ? remaining : 0;

      if (_secondsNotifier.value == 0) {
        widget.onFinished?.call();
        _stopTimer();
      }
    }
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final defaultColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.primary
        : theme.colorScheme.primary;

    return ValueListenableBuilder<int>(
      valueListenable: _secondsNotifier,
      builder: (context, seconds, _) {
        return Text(
          _formatDuration(seconds),
          style: (widget.style ?? theme.textTheme.displayMedium)?.copyWith(
            color: defaultColor,
            fontSize: widget.fontSize,
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    _secondsNotifier.dispose();
    super.dispose();
  }
}
