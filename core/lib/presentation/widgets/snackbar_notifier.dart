import 'package:flutter_riverpod/flutter_riverpod.dart';

class SnackbarMessage {
  final String message;
  final SnackbarType type;

  SnackbarMessage(this.message, {this.type = SnackbarType.info});

  factory SnackbarMessage.success(String message) =>
      SnackbarMessage(message, type: SnackbarType.success);

  factory SnackbarMessage.error(String message) =>
      SnackbarMessage(message, type: SnackbarType.error);

  factory SnackbarMessage.warning(String message) =>
      SnackbarMessage(message, type: SnackbarType.warning);
}

enum SnackbarType {
  success,
  error,
  warning,
  info,
}

/// Notifier yang menyimpan pesan snackbar terbaru
class SnackbarNotifier extends StateNotifier<SnackbarMessage?> {
  SnackbarNotifier() : super(null);

  void showMessage(SnackbarMessage message) {
    state = message;
    // Opsional: auto-clear setelah beberapa detik
    // Tapi di sini kita biarkan UI yang handle clear-nya setelah tampil
  }

  void clear() {
    state = null;
  }
}

/// Provider Riverpod
final snackbarProvider =
    StateNotifierProvider<SnackbarNotifier, SnackbarMessage?>(
  (ref) => SnackbarNotifier(),
);
