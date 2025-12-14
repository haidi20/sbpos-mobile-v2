import 'package:flutter/widgets.dart';

// di sarankan gemini bahwa ini adalah view model, bukan entity
// karena ini hanya digunakan di layer presentasi
// dan tidak di simpan di database atau di layer domain

class OrderTypeItemUiModel {
  final String id;
  final String label;
  final IconData icon;
  final bool selected;

  OrderTypeItemUiModel({
    required this.id,
    required this.label,
    required this.icon,
    required this.selected,
  });
}
