import 'package:core/core.dart';
import 'package:product/domain/entities/product_entity.dart';
import 'package:landing_page_menu/presentation/widgets/product_detail_widget.dart';

class LandingPageMenuController {
  LandingPageMenuController(this.ref, this.context);
  static final Logger _logger = Logger('LandingPageMenuController');

  final WidgetRef ref;
  final BuildContext context;

  // late final LandingPageMenuViewModel _landingPageMenuViewModel =
  //     ref.read(landingPageMenuViewModelProvider.notifier);

  // @override
  // void dispose() {
  //   // Dispose any controllers or resources here if needed
  // }

  void showProductAddDialog({
    required ProductEntity product,
  }) {
    _logger.info('Tampilkan dialog untuk menambahkan produk: ${product.name}');

    showModalBottomSheet(
      context: context, // ✅ gunakan context langsung
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ProductDetailWidget(product: product);
      },
    );
  }

  void showReviewImage({
    required ProductEntity product,
  }) {
    String imageUrl = product.image ??
        'https://esb-order.oss-ap-southeast-5.aliyuncs.com/images/app/menu/MNU_861_20251027104452_optim.webp';

    ReviewImageModal.show(
      context: context,
      imageUrl: imageUrl,
    );
  }
}
