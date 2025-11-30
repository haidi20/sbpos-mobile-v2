import 'package:core/core.dart';
import 'package:product/data/model/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final Color sbBlue;
  final Color sbOrange;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.sbBlue,
    required this.sbOrange,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                          image: NetworkImage(product.image ?? ''),
                          fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.add, size: 16, color: sbBlue),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(product.name ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.2)),
            const SizedBox(height: 4),
            Text(formatRupiah(product.price ?? 0),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: sbOrange)),
          ],
        ),
      ),
    );
  }
}
