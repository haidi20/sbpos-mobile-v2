import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';

class TransactionDetailCard extends StatelessWidget {
  final TransactionDetailEntity item;

  const TransactionDetailCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
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
                        color: AppColors.gray700,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.qty ?? 0} x Rp ${formatRupiah((item.productPrice ?? 0).toDouble())}',
                      style: const TextStyle(
                        color: AppColors.gray600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatRupiah((item.subtotal ?? 0).toDouble()),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          // Divider menggunakan warna yang sangat terang (seperti border-gray-50)
          const Divider(color: AppColors.gray100, thickness: 1, height: 16),
        ],
      ),
    );
  }
}
