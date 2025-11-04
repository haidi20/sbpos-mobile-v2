// lib/core/presentation/widgets/message_snackbar.dart

import 'package:flutter/material.dart';

void showSuccessSnackBar(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.green.shade600,
      duration: const Duration(seconds: 2),
    ),
  );
}

void showErrorSnackBar(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.red.shade600,
      duration: const Duration(seconds: 3),
    ),
  );
}

void showWarningSnackBar(BuildContext context, String message) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: TextStyle(color: Colors.yellow.shade900)),
      backgroundColor: Colors.yellow.shade50,
      duration: const Duration(seconds: 3),
    ),
  );
}
