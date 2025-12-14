import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
// import 'package:logging/logging.dart';
// final _helpersLogger = Logger('helpers');

IconData getIconData(String? iconName) {
  final name = (iconName ?? '').toLowerCase().trim();

  // 🔍 Mapping berdasarkan nama umum
  switch (name) {
    case 'restaurant':
    case 'makan':
    case 'dinein':
      return Icons.restaurant;
    case 'shopping_bag':
    case 'bungkus':
    case 'takeaway':
    case 'takeout':
      return Icons.shopping_bag_outlined;
    case 'delivery':
    case 'antar':
    case 'gofood':
    case 'grab':
      return Icons.delivery_dining;
    case 'fastfood':
    case 'snack':
      return Icons.fastfood;
    case 'local_mall':
    case 'toko':
      return Icons.local_mall;
    case 'room_service':
      return Icons.room_service;
    case 'kitchen':
      return Icons.kitchen;
    case 'store':
      return Icons.store;
    case 'shopping_cart':
      return Icons.shopping_cart;
    default:
      return Icons.help_outline; // fallback aman
  }
}

String formatRupiah(double amount) {
  final formatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  return formatter.format(amount);
}

/// Pastikan map hanya berisi nilai yang didukung sqflite (num, String, Uint8List).
/// - Konversi DateTime ke string ISO
/// - Konversi bool ke integer (1/0)
/// - Encode Map/Iterable ke string JSON
/// - Hapus key dengan nilai null agar tidak memasukkan `Null` ke sqflite
Map<String, dynamic> sanitizeForDb(Map<String, dynamic> src) {
  final out = <String, dynamic>{};
  // Keep a shallow copy for debug logging (disabled to avoid unused warnings)
  // final before = Map<String, dynamic>.from(src);

  src.forEach((key, value) {
    // drop nulls
    if (value == null) return;
    // drop empty trimmed strings
    if (value is String && value.trim().isEmpty) return;
    // drop empty collections
    if (value is Iterable && value.isEmpty) return;
    if (value is Map && value.isEmpty) return;

    if (value is DateTime) {
      out[key] = value.toIso8601String();
    } else if (value is bool) {
      out[key] = value ? 1 : 0;
    } else if (value is num || value is String || value is Uint8List) {
      out[key] = value;
    } else if (value is Map || value is Iterable) {
      try {
        out[key] = jsonEncode(value);
      } catch (_) {
        out[key] = value.toString();
      }
    } else {
      // fallback to string representation
      out[key] = value.toString();
    }
  });

  // debug logging of sanitization
  // _helpersLogger.fine('sanitizeForDb before: $before');
  // _helpersLogger.fine('sanitizeForDb after: $out');
  return out;
}

/// Extension untuk memformat DateTime ke string format "Hari, dd MMMM yyyy HH:mm" dalam bahasa Indonesia.
extension DateTimeReadableId on DateTime {
  String dateTimeReadable() {
    // Format: "Hari, dd MMMM yyyy HH:mm" dalam bahasa Indonesia
    try {
      final formatter = DateFormat('EEEE, dd MMMM yyyy HH:mm', 'id_ID');
      return formatter.format(this);
    } catch (e) {
      // In unit tests intl locale data may not be initialized. Fallback
      // to a simple ISO-like format to avoid throwing during widget tests.
      final fallback = DateFormat('yyyy-MM-dd HH:mm');
      return fallback.format(this);
    }
  }
}

extension DateTimeDisplay on DateTime {
  /// Returns a compact localized date time string in format `dd/MM/yyyy HH:mm`.
  String toDisplayDateTime() {
    final d = this;
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$min';
  }
}

