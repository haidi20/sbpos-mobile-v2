import 'package:core/utils/theme.dart';
import 'package:flutter/material.dart';

Future<DateTime?> dateWidget({
  required BuildContext context,
  required TextEditingController inputController,
}) {
  return showDatePicker(
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary:
                AppSetting.primaryColor, // Warna untuk tanggal yang dipilih
            onSurface: Colors.black, // Warna teks default
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppSetting.primaryColor, // Warna tombol navigasi
            ),
          ),
        ),
        child: child!,
      );
    },
    context: context,
    initialDate: _getInitialDate(
      inputController: inputController,
    ),
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
  );
}

DateTime _getInitialDate({
  required TextEditingController inputController,
}) {
  if (inputController.text.isNotEmpty) {
    try {
      final dateParts = inputController.text.split('-');
      if (dateParts.length == 3) {
        final formattedDate = "${dateParts[2]}-${dateParts[1]}-${dateParts[0]}";
        return DateTime.parse(formattedDate);
      }
    } catch (e) {
      return DateTime.now(); // Jika parsing gagal, gunakan tanggal sekarang
    }
  }
  return DateTime.now(); // Jika controller kosong, gunakan tanggal sekarang
}
