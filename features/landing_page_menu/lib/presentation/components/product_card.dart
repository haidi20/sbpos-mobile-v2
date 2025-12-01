import 'package:core/core.dart';
import 'package:product/domain/entities/product_entity.dart';
import 'package:landing_page_menu/presentation/controllers/landing_page_menu_controller.dart';

class ProductCard extends ConsumerStatefulWidget {
  final ProductEntity product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  late LandingPageMenuController controller;

  @override
  void initState() {
    super.initState();
    controller = LandingPageMenuController(ref, context);
  }

  // @override
  // void dispose() {
  //   controller.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    // final viewModel = ref.read(landingPageMenuViewModelProvider.notifier);

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias, // agar child terclip rapi sesuai shape
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gambar produk
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: widget.product.imageUrl ??
                      'https://esb-order.oss-ap-southeast-5.aliyuncs.com/images/app/menu/MNU_861_20251027104452_optim.webp',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[100],
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppSetting.primaryColor,
                        ),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 32,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Nama produk
            Text(
              widget.product.name ?? 'Produk tidak tersedia',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const Spacer(),

            // Harga
            Text(
              widget.product.formattedPrice,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 4),

            // Tombol Add
            ElevatedButton(
              onPressed: () {
                // ✅ Aman: hanya read (notifier), tidak watch → tidak trigger rebuild
                controller.showProductAddDialog(
                  product: widget.product,
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 32),
                backgroundColor: Colors.white,
                foregroundColor: AppSetting.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(
                    color: AppSetting.primaryColor,
                    width: 1.5,
                  ),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Add',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
