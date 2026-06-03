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

class QuestionTimerState extends State<QuestionTimer> {
  Timer? _timer;
  late int _timeLeft;

  @override
  void initState() {
    super.initState();
    _iniciarTimer();
  }

  void _iniciarTimer() {
    _timeLeft = widget.durationInSeconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
        widget.onTimeExpired();
      }
    });
  }

  //
  void resetTimer() {
    _timer?.cancel();
    _iniciarTimer();
  }

  @override
  void dispose() {
    // É obrigatório cancelar o timer quando sair da tela para não gastar memória
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Formata o tempo para exibir no formato MM:SS
    String minutes = (_timeLeft ~/ 60).toString().padLeft(2, '0');
    String seconds = (_timeLeft % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        // Muda a cor para vermelho se faltar 5 segundos ou menos
        color: _timeLeft <= 5 ? Colors.redAccent : Colors.blueAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$minutes:$seconds',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
