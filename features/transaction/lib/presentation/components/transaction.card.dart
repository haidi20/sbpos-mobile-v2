import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/data/models/transaction.model.dart';
import 'package:transaction/presentation/widgets/dashed_line_painter.dart';

class TransactionCard extends StatelessWidget {
  // Accept either TransactionEntity or TransactionModel for compatibility.
  final dynamic tx;
  final VoidCallback onTap;

  const TransactionCard({
    super.key,
    required this.tx,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Normalize input: accept TransactionEntity or TransactionModel
    final TransactionEntity entity = tx is TransactionEntity
        ? tx
        : TransactionEntity.fromModel(tx as TransactionModel);

    final sequenceNumber = entity.sequenceNumber.toString();
    final DateTime date = entity.date;

    final String paymentMethod = entity.paymentMethod ?? '';
    final String category = entity.categoryOrder ?? 'Umum';
    final double totalAmount = entity.totalAmount.toDouble();
    final int totalQty = entity.totalQty;

    // status is an enum on the entity; convert to display string
    final String statusValue = entity.status.name.toUpperCase();

    final bool isQris = paymentMethod.toUpperCase() == 'QRIS';
    final bool isPending = entity.status == TransactionStatus.pending;

    final Color statusColor = isPending ? AppColors.sbOrange : AppColors.sbBlue;
    final Color iconColor = isQris ? AppColors.sbBlue : AppColors.sbOrange;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, // DOMINAN PUTIH
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            width: 1,
            color: AppColors.gray100,
          ), // Border tipis
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04), // Shadow lebih halus
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Payment (Aksen Warna)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    // Warna icon yang sangat muda
                    color: iconColor.withOpacity(0.08),
                    // Bentuk kotak lebih modern
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isQris ? Icons.qr_code_2 : Icons.credit_card,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Order Info & Amount (Expanded)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Number
                      Text(
                        'Order #$sequenceNumber',
                        style: const TextStyle(
                          fontSize: 16, // Sedikit lebih besar untuk hierarki
                          color: AppColors.gray700,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Date & Category (Metadata)
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: AppColors.gray500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM yyyy, HH:mm').format(date),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.gray500,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: CircleAvatar(
                              radius: 2,
                              backgroundColor: AppColors.gray300,
                            ),
                          ),
                          Text(
                            category,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.gray500,
                            ),
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
                    // Amount (Paling Menonjol)
                    Text(
                      formatRupiah(totalAmount),
                      style: const TextStyle(
                        fontSize: 18, // Paling besar
                        color: AppColors.sbBlue, // Aksen Biru
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Status Badge (Aksen Warna)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1), // Background tipis
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        statusValue,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Dashed Line Separator
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CustomPaint(
                painter: DashedLinePainter(color: AppColors.gray200),
                size: Size(double.infinity, 1),
              ),
            ),

            // Footer (Total Item & Detail Link)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 14,
                      color: AppColors.gray500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$totalQty Item',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
                // Lihat Detail (Aksen Oranye)
                const Row(
                  children: [
                    Text(
                      'Lihat Detail',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.sbOrange,
                      ), // Aksen Oranye
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
