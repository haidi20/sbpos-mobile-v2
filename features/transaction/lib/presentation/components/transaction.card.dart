import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/presentation/widgets/dashed_line_painter.dart';

class TransactionCard extends StatelessWidget {
  final TransactionEntity tx;
  final VoidCallback onTap;

  const TransactionCard({
    super.key,
    required this.tx,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final transaction = tx;
    final sequence = transaction.sequenceNumber.toString();
    final dateString = transaction.date.toDisplayDateTime();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(width: 1, color: AppColors.gray100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
                _PaymentMethod(tx: transaction),
                const SizedBox(width: 16),
                Expanded(
                  child: _OrderInfo(
                    sequence: sequence,
                    dateString: dateString,
                    category: transaction.categoryOrder ?? '-',
                  ),
                ),
                _AmountStatus(tx: transaction),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CustomPaint(
                painter: DashedLinePainter(color: AppColors.gray200),
                size: Size(double.infinity, 1),
              ),
            ),
            _FooterRow(totalQty: transaction.totalQty),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethod extends StatelessWidget {
  final TransactionEntity tx;
  const _PaymentMethod({required this.tx});

  @override
  Widget build(BuildContext context) {
    final paymentMethod = tx.paymentMethod ?? '';
    final isQris = paymentMethod.toUpperCase() == 'QRIS';
    final color = isQris ? AppColors.sbBlue : AppColors.sbOrange;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(isQris ? Icons.qr_code_2 : Icons.credit_card,
          color: color, size: 24),
    );
  }
}

class _OrderInfo extends StatelessWidget {
  final String sequence;
  final String dateString;
  final String category;
  const _OrderInfo(
      {required this.sequence,
      required this.dateString,
      required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order #$sequence',
          style: const TextStyle(
              fontSize: 16,
              color: AppColors.gray700,
              fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.calendar_today,
                size: 12, color: AppColors.gray500),
            const SizedBox(width: 4),
            Text(dateString,
                style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child:
                  CircleAvatar(radius: 2, backgroundColor: AppColors.gray300),
            ),
            Text(category,
                style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
          ],
        ),
      ],
    );
  }
}

class _AmountStatus extends StatelessWidget {
  final TransactionEntity tx;
  const _AmountStatus({required this.tx});

  @override
  Widget build(BuildContext context) {
    final total = tx.totalAmount.toDouble();
    final isPending = tx.status == TransactionStatus.pending;
    final statusColor = isPending ? AppColors.sbOrange : AppColors.sbBlue;
    final statusValue = tx.status.name.toUpperCase();
    final isSynced = (tx.idServer != null) || (tx.syncedAt != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          formatRupiah(total),
          style: const TextStyle(
            fontSize: 18,
            color: AppColors.sbBlue,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
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
            const SizedBox(width: 8),
            Icon(
              isSynced ? Icons.done_all : Icons.check,
              size: 14,
              color: isSynced ? AppColors.sbBlue : AppColors.gray400,
            ),
          ],
        ),
      ],
    );
  }
}

class _FooterRow extends StatelessWidget {
  final int totalQty;
  const _FooterRow({required this.totalQty});

  @override
  Widget build(BuildContext context) {
    return Row(
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
        const Row(
          children: [
            Text(
              'Lihat Detail',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
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
    );
  }
}
