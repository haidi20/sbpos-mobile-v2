import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

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
