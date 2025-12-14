import 'package:flutter/material.dart';

enum TransactionStatus { lunas, pending, proses, batal, unknown }

extension TransactionStatusExtension on TransactionStatus {
  String get value {
    switch (this) {
      case TransactionStatus.lunas:
        return 'lunas';
      case TransactionStatus.pending:
        return 'pending';
      case TransactionStatus.proses:
        return 'proses';
      case TransactionStatus.batal:
        return 'batal';
      case TransactionStatus.unknown:
        return 'unknown';
    }
  }

  Color get color {
    switch (this) {
      case TransactionStatus.lunas:
        return Colors.green;
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.proses:
        return Colors.blue;
      case TransactionStatus.batal:
        return Colors.red;
      case TransactionStatus.unknown:
        return Colors.grey;
    }
  }
}
