import 'package:flutter/material.dart';

class PaymentMethodUiModel {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  const PaymentMethodUiModel({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

// Dummy list of payment methods used by the UI
final List<PaymentMethodUiModel> paymentMethodList = [
  const PaymentMethodUiModel(
    id: 'cash',
    label: 'Tunai',
    icon: Icons.money,
    color: Colors.blue,
  ),
  const PaymentMethodUiModel(
    id: 'qris',
    label: 'QRIS',
    icon: Icons.qr_code,
    color: Colors.purple,
  ),
  const PaymentMethodUiModel(
    id: 'transfer',
    label: 'Transfer',
    icon: Icons.credit_card,
    color: Colors.teal,
  ),
];
