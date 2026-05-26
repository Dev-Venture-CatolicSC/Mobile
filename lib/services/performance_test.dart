class PerformanceTest {

  void runTest() {

    final stopwatch = Stopwatch()..start();

    // Simula alguma ação do app
    for (int i = 0; i < 1000000; i++) {}

    stopwatch.stop();

    print(
      'Tempo de resposta: ${stopwatch.elapsedMilliseconds} ms',
    );
  }
}