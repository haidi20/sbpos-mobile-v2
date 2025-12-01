// Contoh model sederhana
import 'package:core/core.dart';
import 'package:product/domain/entities/product_entity.dart';
import 'package:landing_page_menu/presentation/controllers/landing_page_menu_controller.dart';

class ProductDetailWidget extends ConsumerStatefulWidget {
  final ProductEntity product;

  const ProductDetailWidget({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<ProductDetailWidget> createState() =>
      _ProductDetailWidgetState();
}

class _ProductDetailWidgetState extends ConsumerState<ProductDetailWidget> {
  late LandingPageMenuController controller;

  @override
  void initState() {
    super.initState();
    controller = LandingPageMenuController(ref, context);
  }

  @override
  Widget build(BuildContext contex) {
    // final viewModel = ref.watch(landingPageMenuViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                // padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductImage(context),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProductNameAndPrice(),
                          _buildNotesSection(ref),
                          _buildTotalOrderSection(ref),
                          _buildBackToMenuButton(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const String defaultImageUrl =
        "https://esb-order.oss-ap-southeast-5.aliyuncs.com/images/app/menu/MNU_861_20251027104452_optim.webp";

    return SizedBox(
      width: screenWidth, // Full width
      height: 220, // Tinggi gambar (silakan atur)
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // ✅ Gambar full width & crop atas–bawah → seperti foto contoh
            Positioned.fill(
              child: Image.network(
                widget.product.image ?? defaultImageUrl,
                fit: BoxFit.cover, // ✅ Crop atas–bawah
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported,
                        size: 32, color: Colors.grey),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[100],
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation(AppSetting.primaryColor),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Tombol Close (X) - Kanan Atas
            Positioned(
              top: 50,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
            ),

            // Tombol Zoom - Kanan Bawah
            Positioned(
              bottom: 15,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  controller.showReviewImage(
                    product: widget.product,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.zoom_in,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductNameAndPrice() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.name ?? '-',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rp${widget.product.price.toString()}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(
    WidgetRef ref,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notes',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Text(
            'Optional',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Example: Make my dish delicious!',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              //
            },
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalOrderSection(WidgetRef ref) {
    const int quantity = 1;
    const double totalPrice = 10000;

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Order',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (quantity > 0) {
                    // add to decrease quantity
                  }
                },
                icon: const Icon(Icons.remove),
              ),
              const Text(
                '$quantity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () {
                  //
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const Text(
            'Rp$totalPrice',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackToMenuButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 24),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Back to Menu'),
      ),
    );
  }
}
