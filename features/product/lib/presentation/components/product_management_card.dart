import 'package:core/core.dart';
import 'package:product/domain/entities/product_entity.dart';

class ProductManagementCard extends StatelessWidget {
  final bool isActive;
  final ProductEntity product;
  final Color sbBlue = AppColors.sbBlue;
  final Color sbOrange = AppColors.sbOrange;

  const ProductManagementCard({
    super.key,
    required this.product,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Status Stripe
            Container(
              width: 4,
              height: double.infinity,
              color: isActive ? Colors.green : Colors.grey.shade300,
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Image
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade100,
                        image: DecorationImage(
                          image: NetworkImage(product.image ?? ''),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            product.name ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatRupiah(product.price ?? 0),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: sbOrange),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.green.shade50
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              isActive ? 'Aktif' : 'Non-Aktif',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? Colors.green.shade600
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Actions
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _actionButton(
                          icon: Icons.edit_outlined,
                          color: sbBlue,
                          bgColor: Colors.blue.shade50,
                          onTap: () {},
                        ),
                        const SizedBox(height: 8),
                        _actionButton(
                          icon: Icons.delete_outline,
                          color: Colors.red,
                          bgColor: Colors.red.shade50,
                          onTap: () {},
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: color,
        ),
      ),
    );
  }
}
