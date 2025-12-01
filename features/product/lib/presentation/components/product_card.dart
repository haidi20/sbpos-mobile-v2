import 'package:core/core.dart';
import 'package:product/domain/entities/product_entity.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
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
              offset: const Offset(0, 2),
            )
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child:
                          (product.image != null && product.image!.isNotEmpty)
                              ? Image.network(
                                  product.image!,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return Container(
                                      color: Colors.grey.shade100,
                                      child: const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade100,
                                      child: const Center(
                                        child: Icon(Icons.broken_image,
                                            size: 32, color: Colors.grey),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: Icon(Icons.image,
                                        size: 32, color: Colors.grey),
                                  ),
                                ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(
                          8,
                        ),
                      ),
                      child: Icon(
                        size: 16,
                        Icons.add,
                        color: sbBlue,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.name ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatRupiah(product.price ?? 0),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: sbOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
