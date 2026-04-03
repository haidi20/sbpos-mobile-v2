import 'package:flutter/foundation.dart';

@immutable
class ReceiptPrinterConfig {
  final bool autoPrint;
  final bool printLogo;
  final String paperWidth;
  final String? printerName;
  final bool isConnected;

  const ReceiptPrinterConfig({
    required this.autoPrint,
    required this.printLogo,
    required this.paperWidth,
    required this.printerName,
    required this.isConnected,
  });
}

@immutable
class ReceiptPrintLine {
  final String label;
  final String? value;
  final bool emphasize;

  const ReceiptPrintLine({
    required this.label,
    this.value,
    this.emphasize = false,
  });
}

@immutable
class ReceiptPrintJob {
  final String title;
  final List<ReceiptPrintLine> lines;
  final String? footer;

  const ReceiptPrintJob({
    required this.title,
    required this.lines,
    this.footer,
  });
}

@immutable
class ReceiptPrintResult {
  final bool isSuccess;
  final String message;

  const ReceiptPrintResult._({
    required this.isSuccess,
    required this.message,
  });

  const ReceiptPrintResult.success(String message)
      : this._(isSuccess: true, message: message);

  const ReceiptPrintResult.failure(String message)
      : this._(isSuccess: false, message: message);
}

abstract class PrinterFacade {
  Future<void> syncConfig(ReceiptPrinterConfig config);

  Future<ReceiptPrintResult> printTestReceipt();

  Future<ReceiptPrintResult> printReceipt(ReceiptPrintJob job);
}
