import 'package:core/core.dart';

// SummaryRow accepts a dynamic transaction payload (entity or model)
class SummaryRow extends StatelessWidget {
  final dynamic tx;

  const SummaryRow({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final total =
        (tx.totalAmount ?? (tx is Map ? tx['totalAmount'] : 0)) as num;
    final paid = (tx.paidAmount ?? (tx is Map ? tx['paidAmount'] : 0)) as num;
    final change =
        (tx.changeMoney ?? (tx is Map ? tx['changeMoney'] : 0)) as num;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              formatRupiah(
                total.toDouble(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bayar',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              formatRupiah(
                paid.toDouble(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Kembalian',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              formatRupiah(
                change.toDouble(),
              ),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
