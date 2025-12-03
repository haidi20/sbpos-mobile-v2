import 'package:core/core.dart';
import 'package:transaction/presentation/sheets/cart_bottom.sheet.dart';

class TransactionController {
  final WidgetRef ref;
  final BuildContext context;
  final TextEditingController searchController = TextEditingController();

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
