import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';

class TransactionDetailCard extends ConsumerWidget {
  final TransactionDetailEntity item;

  const TransactionDetailCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(transactionPosViewModelProvider.notifier);
    final products = viewModel.cachedProducts;
    final prod = products.firstWhere((p) => p.id == item.productId,
        orElse: () => ProductEntity(id: item.productId ?? 0));

    final doubleQty = prod.qty ?? 0.0;

    Color? nameColor;
    Widget? stockWarning;
    if (doubleQty <= 5) {
      nameColor = Colors.red;
      final remaining = doubleQty.toInt();
      stockWarning = Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          children: [
            const Icon(Icons.error_outline, size: 14, color: Colors.red),
            const SizedBox(width: 4),
            Text('Stok rendah — $remaining tersisa',
                style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ),
      );
    } else if (doubleQty <= 10) {
      nameColor = AppColors.sbOrange;
      final remaining = doubleQty.toInt();
      stockWarning = Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 14, color: AppColors.sbOrange),
            const SizedBox(width: 4),
            Text('Stok menipis — $remaining tersisa',
                style:
                    const TextStyle(color: AppColors.sbOrange, fontSize: 12)),
          ],
        ),
      );
    }

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
                    Row(children: [
                      Expanded(
                        child: Text(
                          item.productName ?? '-',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: nameColor ?? AppColors.gray700,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.packetId != null)
                        Tooltip(
                          message: 'Item dari paket',
                          child: Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.sbBlue.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.inventory_2,
                                    size: 12, color: AppColors.sbBlue),
                                SizedBox(width: 6),
                                Text(
                                  'Paket',
                                  style: TextStyle(
                                    color: AppColors.sbBlue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ]),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '${item.qty ?? 0} x Rp ${formatRupiah((item.productPrice ?? 0).toDouble())}',
                          style: const TextStyle(
                            color: AppColors.gray600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (stockWarning != null) stockWarning,
                      ],
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
