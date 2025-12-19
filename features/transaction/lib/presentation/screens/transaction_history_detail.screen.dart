// ignore_for_file: prefer_const_constructors

import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
// detail_info.card not used by the full fields grid; kept imports minimal
import 'package:transaction/presentation/components/summary_row.card.dart';
import 'package:transaction/presentation/widgets/dashed_line_painter.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';

class TransactionHistoryDetailScreen extends StatelessWidget {
  final TransactionEntity tx;
  final List<TransactionDetailEntity> details;

  const TransactionHistoryDetailScreen(
      {super.key, required this.tx, required this.details});

  @override
  Widget build(BuildContext context) {
    final notes = tx.notes ?? '';
    final dateString = tx.date.toDisplayDateTime();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      child: Column(
        children: [
          _TransactionDetailHeader(tx: tx, dateString: dateString),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TransactionFullFieldsGrid(tx: tx),
                  const SizedBox(height: 24),
                  const Text(
                    'Rincian Item',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _TransactionDetailItemsList(details: details),
                  const SizedBox(height: 24),
                  TransactionSummaryCard(tx: tx),
                  if (notes.isNotEmpty && notes != '-') ...[
                    const SizedBox(height: 16),
                    _TransactionNotes(notes: notes),
                  ],
                  const SizedBox(height: 24),
                  _TransactionActions(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Extracted widgets for testability ---
class _TransactionDetailHeader extends StatelessWidget {
  final TransactionEntity tx;
  final String dateString;

  const _TransactionDetailHeader({required this.tx, required this.dateString});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade100,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Detail Transaksi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(children: [
                // Sequence number: tappable to copy
                GestureDetector(
                  onTap: () {
                    final messenger = ScaffoldMessenger.of(context);
                    Clipboard.setData(
                            ClipboardData(text: tx.sequenceNumber.toString()))
                        .then((_) {
                      messenger.showSnackBar(const SnackBar(
                          content: Text('Nomor order disalin ke clipboard')));
                    });
                  },
                  child: Text(
                    '#${tx.sequenceNumber}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: tx.statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: tx.statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    tx.statusValue,
                    style: TextStyle(
                      color: tx.statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ])
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.sbBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Total Pembayaran',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatRupiah(tx.totalAmount.toDouble()),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.sbBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// `_TransactionDetailInfoGrid` has been replaced by
// `_TransactionFullFieldsGrid`. Kept intentionally removed to avoid
// duplicate UI implementations.

/// Full grid presenting all `TransactionEntity` fields in a responsive layout.
class _TransactionFullFieldsGrid extends StatelessWidget {
  final TransactionEntity tx;

  const _TransactionFullFieldsGrid({required this.tx});

  Widget _label(String t) => Text(
        t,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
      );

  Widget _valueWidget(String v) => Text(
        v,
        style: const TextStyle(
            fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600),
        overflow: TextOverflow.ellipsis,
      );

  // helper previously used for formatted dates; removed because unused

  @override
  Widget build(BuildContext context) {
    // Build pairs of label + value for all fields
    final items = <MapEntry<String, Widget>>[
      // MapEntry('ID', _valueWidget(tx.id?.toString() ?? '-')),
      // MapEntry('Server ID', _valueWidget(tx.idServer?.toString() ?? '-')),
      // MapEntry('Shift', _valueWidget(tx.shiftId?.toString() ?? '-')),
      // MapEntry('Synced At', _valueWidget(_dateOrDash(tx.syncedAt))),
      // MapEntry('Outlet', _valueWidget(tx.outletId.toString())),
      MapEntry('No. Order', _valueWidget('#${tx.sequenceNumber}')),
      // MapEntry('OrderType ID', _valueWidget(tx.orderTypeId.toString())),
      MapEntry('Kategori', _valueWidget(tx.categoryOrder ?? '-')),
      // MapEntry('Kasir (User)', _valueWidget(tx.userId?.toString() ?? '-')),
      MapEntry('Metode Bayar',
          _valueWidget(_friendlyPaymentLabel(tx.paymentMethod))),
      MapEntry('Tanggal', _valueWidget(tx.date.toDisplayDate())),
      MapEntry('Jam', _valueWidget(tx.date.toDisplayTime())),
      // MapEntry('Catatan', _valueWidget(tx.notes ?? '-')),
      MapEntry(
          'Total (Rp)', _valueWidget(formatRupiah(tx.totalAmount.toDouble()))),
      MapEntry('Jumlah Item', _valueWidget(tx.totalQty.toString())),
      MapEntry(
        'Terbayar (Rp)',
        _valueWidget(
          tx.isPaid ? formatRupiah((tx.paidAmount ?? 0).toDouble()) : '-',
        ),
      ),
      MapEntry('Kembalian (Rp)',
          _valueWidget(formatRupiah(tx.changeMoney.toDouble()))),
      MapEntry('Lunas', _valueWidget(tx.isPaid ? 'Ya' : 'Belum')),
      MapEntry('Status', _valueWidget(tx.statusValue)),
      // MapEntry('OTP Batal', _valueWidget(tx.cancelationOtp ?? '-')),
      MapEntry('Alasan Batal', _valueWidget(tx.cancelationReason ?? '-')),
      MapEntry('Ojol Provider', _valueWidget(tx.ojolProvider ?? '-')),
      // MapEntry('Created', _valueWidget(_dateOrDash(tx.createdAt))),
      // MapEntry('Updated', _valueWidget(_dateOrDash(tx.updatedAt))),
      // MapEntry('Deleted', _valueWidget(_dateOrDash(tx.deletedAt))),
      // MapEntry(
      //     'Details Count', _valueWidget((tx.details?.length ?? 0).toString())),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      // target up to 3 columns, with minimal spacing
      const gap = 12.0;
      const maxCols = 3;
      final itemWidth = (constraints.maxWidth - gap * (maxCols - 1)) / maxCols;

      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: items.map((e) {
          return SizedBox(
            width: itemWidth.clamp(160.0, constraints.maxWidth),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label(e.key),
                  const SizedBox(height: 6),
                  e.value,
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

class _TransactionDetailItemsList extends StatelessWidget {
  final List<TransactionDetailEntity> details;

  const _TransactionDetailItemsList({required this.details});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: details.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName ?? '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.qty ?? 0} x ${formatRupiah((item.productPrice ?? 0).toDouble())}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatRupiah((item.subtotal ?? 0).toDouble()),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// Helper to render friendlier payment method labels
String _friendlyPaymentLabel(String? raw) {
  if (raw == null) return '-';
  final v = raw.toLowerCase();
  if (v.contains('cash') || v == 'tunai') return 'Tunai';
  if (v.contains('qris')) return 'QRIS';
  if (v.contains('transfer') || v.contains('card')) return 'Transfer';
  return raw;
}

class TransactionSummaryCard extends StatelessWidget {
  final TransactionEntity tx;

  const TransactionSummaryCard({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SummaryRowCard(
            label: 'Subtotal',
            value: formatRupiah(tx.totalAmount.toDouble()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: CustomPaint(
              painter: DashedLinePainter(color: Colors.grey.shade300),
              size: const Size(double.infinity, 1),
            ),
          ),
          SummaryRowCard(
            label: 'Bayar (${tx.paymentMethod ?? '-'})',
            value: formatRupiah((tx.paidAmount ?? 0).toDouble()),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kembalian',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                formatRupiah(tx.changeMoney.toDouble()),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.sbBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransactionNotes extends StatelessWidget {
  final String notes;

  const _TransactionNotes({required this.notes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Catatan:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            notes,
            style: TextStyle(
              fontSize: 13,
              color: Colors.orange.shade900,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionActions extends StatelessWidget {
  const _TransactionActions();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
