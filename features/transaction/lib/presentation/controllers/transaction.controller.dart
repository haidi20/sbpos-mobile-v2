import 'package:core/core.dart';
import 'package:transaction/presentation/screens/cart_bottom_sheet.dart';

class TransactionController {
  final WidgetRef ref;
  final BuildContext context;

  TransactionController(this.ref, this.context);
  void onShowCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CartBottomSheet(),
    );
  }
}
