import 'package:core/core.dart';
import 'package:transaction/data/models/transaction_model.dart';
import 'package:transaction/presentation/widgets/dashed_line_painter.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel tx;
  final VoidCallback onTap;

  const TransactionCard({
    required this.tx,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isQris = (tx.paymentMethod ?? '').toUpperCase() == 'QRIS';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Payment
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isQris ? Colors.blue.shade50 : Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isQris ? Icons.receipt_long : Icons.credit_card,
                    color: isQris ? AppColors.sbBlue : Colors.green.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Order Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${tx.sequenceNumber}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            (tx.date ?? '-').toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: CircleAvatar(
                                radius: 2,
                                backgroundColor: Colors.grey.shade300),
                          ),
                          Text(
                            tx.categoryOrder ?? '-',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Amount & Status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatRupiah(tx.totalAmount?.toDouble() ?? 0.0),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.sbBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Success',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Dashed Line Separator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: CustomPaint(
                painter: DashedLinePainter(color: Colors.grey.shade200),
                size: const Size(double.infinity, 1),
              ),
            ),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.description_outlined,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      '${tx.totalQty ?? 0} Item',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Text(
                      'Lihat Detail',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.sbOrange,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.sbOrange,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
