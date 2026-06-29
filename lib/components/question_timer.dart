import 'dart:async';
import 'package:flutter/material.dart';

class QuestionTimer extends StatefulWidget {
  final int durationInSeconds;
  final VoidCallback onTimeExpired;

  const QuestionTimer({
    super.key,
    required this.durationInSeconds,
    required this.onTimeExpired,
  });

  @override
  State<QuestionTimer> createState() => QuestionTimerState();
}

class QuestionTimerState extends State<QuestionTimer>
    with WidgetsBindingObserver {
  Timer? _timer;
  DateTime? _endTime;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _iniciarTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  void _iniciarTimer() {
    setState(() {
      _isExpired = false;
      _endTime = DateTime.now().add(
        Duration(seconds: widget.durationInSeconds),
      );
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 0) {
        _timer?.cancel();
        if (!_isExpired) {
          setState(() => _isExpired = true);
          widget.onTimeExpired();
        }
      } else {
        setState(() {});
      }
    });
  }

  int get _timeLeft {
    if (_endTime == null) return 0;
    final remaining = _endTime!.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  void resetTimer() {
    _iniciarTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int minutes = _timeLeft ~/ 60;
    int seconds = _timeLeft % 60;
    String timeString =
        "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";

    bool isUrgent = _timeLeft <= 5 && !_isExpired;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _isExpired
            ? Colors.red.shade100
            : (isUrgent ? Colors.orange.shade100 : Colors.blue.shade50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isExpired
              ? Colors.red
              : (isUrgent ? Colors.orange : Colors.blue),
        ),
      ),
      child: Text(
        _isExpired ? "00:00 - Tempo Esgotado" : timeString,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: _isExpired
              ? Colors.red
              : (isUrgent ? Colors.orange.shade900 : Colors.blue.shade900),
        ),
      ),
    );
  }
}
