import 'package:flutter/material.dart';

class CustomDialog {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    bool modal = false,
  }) async {
    return showDialog(
      context: context,

      // true = fecha fora
      // false = não fecha fora
      barrierDismissible: !modal,

      builder: (context) {
        final theme = Theme.of(context);

        return AlertDialog(
          title: Text(title, style: theme.textTheme.titleLarge),

          content: Text(message, style: theme.textTheme.bodyMedium),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}
