import 'package:core/core.dart';
import 'package:product/presentation/screens/cart_bottom_sheet.dart';

class ProductPosController {
  ProductPosController(this.ref, this.context);
  // static final Logger _logger = Logger('ProductPosController');

  final WidgetRef ref;
  final BuildContext context;

  void onShowCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CartBottomSheet(),
    );
  }
}
