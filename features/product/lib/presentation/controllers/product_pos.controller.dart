import 'package:core/core.dart';
import 'package:product/presentation/screens/cart_bottom_sheet.dart';

class ProductPosController {
  final WidgetRef ref;
  final BuildContext context;

  ProductPosController(this.ref, this.context);

  void onShowCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CartBottomSheet(),
    );
  }
}
