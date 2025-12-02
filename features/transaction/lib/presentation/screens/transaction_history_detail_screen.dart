import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/presentation/components/detail_info_card.dart';
import 'package:transaction/presentation/components/summary_row_card.dart';
import 'package:transaction/presentation/widgets/dashed_line_painter.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';

class TransactionHistoryDetailScreen extends StatelessWidget {
  final TransactionEntity tx;
  final List<TransactionDetailEntity> details;

  const TransactionHistoryDetailScreen({
    super.key,
    required this.tx,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    final notes = tx.notes ?? '';
    final dateString =
        '${tx.date.day}/${tx.date.month}/${tx.date.year} ${tx.date.hour.toString().padLeft(2, '0')}:${tx.date.minute.toString().padLeft(2, '0')}';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            24,
          ),
        ),
      ),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      child: Column(
        children: [
          // Handle & Header
          Container(
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
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle),
                        child: Icon(Icons.close,
                            size: 20, color: Colors.grey.shade600),
                      ),
                    ),
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
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      DetailInfoCard(
                        icon: Icons.receipt,
                        label: 'No. Order',
                        value: '#${tx.sequenceNumber}',
                      ),
                      DetailInfoCard(
                        icon: Icons.access_time,
                        label: 'Tanggal',
                        value: dateString,
                      ),
                      DetailInfoCard(
                        icon: Icons.person_outline,
                        label: 'Kasir (ID)',
                        value: tx.userId != null ? 'User #${tx.userId}' : '-',
                      ),
                      DetailInfoCard(
                        icon: Icons.store_outlined,
                        label: 'Warehouse',
                        value: 'WH-${tx.warehouseId}',
                      ),
                      DetailInfoCard(
                        icon: Icons.category_outlined,
                        label: 'Tipe Order',
                        value: tx.categoryOrder ?? '-',
                      ),
                      DetailInfoCard(
                        icon: Icons.payments_outlined,
                        label: 'Metode Bayar',
                        value: tx.paymentMethod ?? '-',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Rincian Item',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Items List
                  ...((details).map((item) {
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
                  }).toList()),

                  const SizedBox(height: 24),

                  // Summary Card
                  _buildSummaryCard(tx),
                  // Notes
                  if (notes.isNotEmpty && notes != '-') ...[
                    const SizedBox(height: 16),
                    Container(
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
                    ),
                  ],

                  const SizedBox(height: 24),
                  // Print Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.sbBlue),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Cetak Struk',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.sbBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(TransactionEntity tx) {
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
              size: const Size(
                double.infinity,
                1,
              ),
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
