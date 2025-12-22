import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/presentation/widgets/dashed_line_painter.dart';

class TransactionHistoryCard extends StatelessWidget {
  final TransactionEntity transaction;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const TransactionHistoryCard({
    super.key,
    required this.transaction,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final sequence = transaction.sequenceNumber.toString();
    final dateString = transaction.date.toDisplayDateTime();

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
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
                _PaymentMethod(transaction: transaction),
                const SizedBox(width: 16),
                Expanded(
                  child: _OrderInfo(
                    sequence: sequence,
                    dateString: dateString,
                    category: transaction.categoryOrder ?? '-',
                  ),
                ),
                _AmountStatus(transaction: transaction),
              ],
            ),
            const SizedBox(height: 8),
            // Status row placed under PaymentMethod and OrderInfo as a single line
            _StatusRow(transaction: transaction),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: SizedBox(
                height: 1,
                width: double.infinity,
                child: CustomPaint(
                  painter: DashedLinePainter(color: AppColors.gray200),
                ),
              ),
            ),
            _FooterRow(
                transaction: transaction, totalQty: transaction.totalQty),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethod extends StatelessWidget {
  final TransactionEntity transaction;
  const _PaymentMethod({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final paymentMethod = transaction.paymentMethod ?? '';
    final isQris = paymentMethod.toUpperCase() == 'QRIS';
    final color = isQris ? AppColors.sbBlue : AppColors.sbOrange;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        isQris ? Icons.qr_code_2 : Icons.credit_card,
        color: color,
        size: 24,
      ),
    );
  }
}

class _OrderInfo extends StatelessWidget {
  final String sequence;
  final String category;
  final String dateString;

  const _OrderInfo({
    required this.sequence,
    required this.dateString,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pesanan #$sequence',
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.gray700,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.calendar_today,
                size: 12, color: AppColors.gray500),
            const SizedBox(width: 4),
            Text(
              dateString,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.gray500,
              ),
            ),
            // const Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 6),
            //   child: CircleAvatar(
            //     radius: 2,
            //     backgroundColor: AppColors.gray300,
            //   ),
            // ),
            // Text(
            //   category,
            //   style: const TextStyle(
            //     fontSize: 12,
            //     color: AppColors.gray500,
            //   ),
            // ),
          ],
        ),
      ],
    );
  }
}

class _AmountStatus extends StatelessWidget {
  final TransactionEntity transaction;
  const _AmountStatus({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final total = transaction.totalAmount.toDouble();
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
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  final TransactionEntity transaction;
  const _StatusRow({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isPaid = transaction.isPaid;
    final paidAmount = transaction.paidAmount ?? 0;
    final isPending = transaction.status == TransactionStatus.pending;
    final statusColor = isPending ? AppColors.gray500 : AppColors.sbBlue;
    final statusValue = transaction.status.name.toUpperCase();

    return Row(
      children: [
        // Left side: status badge and optional LUNAS badge
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusValue,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
              if (isPaid) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'LUNAS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Right side: paid amount aligned to the right
        if (isPaid)
          Text(
            'Dibayar: ${formatRupiah(paidAmount.toDouble())}',
            style: const TextStyle(fontSize: 12, color: AppColors.gray600),
          ),
      ],
    );
  }
}

class _FooterRow extends StatelessWidget {
  final int totalQty;
  final TransactionEntity transaction;
  const _FooterRow({required this.transaction, required this.totalQty});

  @override
  Widget build(BuildContext context) {
    final isSynced =
        (transaction.idServer != null) || (transaction.syncedAt != null);
    final theme = Theme.of(context);
    final syncColor =
        isSynced ? theme.colorScheme.primary : theme.colorScheme.secondary;
    final syncIcon = isSynced ? Icons.done_all : Icons.access_time;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              syncIcon,
              size: 14,
              color: syncColor,
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.shopping_bag_outlined,
              size: 14,
              color: AppColors.gray500,
            ),
            const SizedBox(width: 6),
            Text(
              '$totalQty ${totalQty == 1 ? 'Item' : 'Items'}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              'Lihat',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.secondary,
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: theme.colorScheme.secondary,
            ),
          ],
        ),
      ],
    );
  }
}
