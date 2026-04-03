import 'package:flutter/material.dart';
import 'package:core/domain/facades/printer.facade.dart';

class ReceiptPreviewSheet extends StatefulWidget {
  const ReceiptPreviewSheet({
    super.key,
    required this.job,
    required this.onConfirmPrint,
  });

  final ReceiptPrintJob job;
  final Future<ReceiptPrintResult> Function() onConfirmPrint;

  static Future<ReceiptPrintResult?> show(
    BuildContext context, {
    required ReceiptPrintJob job,
    required Future<ReceiptPrintResult> Function() onConfirmPrint,
  }) {
    return showModalBottomSheet<ReceiptPrintResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: ReceiptPreviewSheet(
            job: job,
            onConfirmPrint: onConfirmPrint,
          ),
        );
      },
    );
  }

  @override
  State<ReceiptPreviewSheet> createState() => _ReceiptPreviewSheetState();
}

class _ReceiptPreviewSheetState extends State<ReceiptPreviewSheet> {
  bool _isPrinting = false;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFF6F7FB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Preview Struk',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _isPrinting
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tinjau isi struk sebelum dicetak ke printer.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.job.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Divider(color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      ...widget.job.lines.map(_buildLine),
                      if (widget.job.footer != null &&
                          widget.job.footer!.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Divider(color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          widget.job.footer!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isPrinting
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Kembali'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isPrinting ? null : _handleConfirmPrint,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isPrinting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Cetak Sekarang'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLine(ReceiptPrintLine line) {
    final textStyle = TextStyle(
      fontSize: 14,
      fontWeight: line.emphasize ? FontWeight.bold : FontWeight.w500,
      color: line.emphasize ? Colors.black87 : Colors.grey.shade800,
    );

    if (line.value == null || line.value!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(line.label, style: textStyle),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              line.label,
              style: textStyle,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              line.value!,
              textAlign: TextAlign.right,
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleConfirmPrint() async {
    setState(() {
      _isPrinting = true;
    });

    final result = await widget.onConfirmPrint();
    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(result);
  }
}
