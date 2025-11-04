// lib/core/utils/helpers/base_error_helper.dart

import 'package:core/core.dart';

mixin BaseErrorHelper {
  /// Mengembalikan pesan error dalam bentuk String
  String mapErrorToMessage(dynamic error) {
    if (error is BadRequestException) {
      return error.message.toString();
    } else if (error is FetchDataException) {
      return error.message.toString();
    } else if (error is ApiNotRespondingException) {
      return 'Server tidak merespon. Silakan coba lagi nanti.';
    } else if (error is SomethingDataException) {
      // Anda bisa log ini, tapi jangan print di production
      // print(error.message);
      return error.message.toString();
    } else {
      return 'Terjadi kesalahan tidak dikenal.';
    }
  }

  /// Opsi: jika tetap ingin punya helper untuk tampilkan error,
  /// tapi harus lewat callback
  void handleErrorWithCallback(
    dynamic error,
    void Function(String message) onErrorMessage,
  ) {
    final message = mapErrorToMessage(error);
    if (message.isNotEmpty) {
      onErrorMessage(message);
    }
  }
}
