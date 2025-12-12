import 'package:core/core.dart';
import 'package:transaction/presentation/sheets/cart_bottom.sheet.dart';

class TransactionPosController {
  final WidgetRef ref;
  final BuildContext context;
  final TextEditingController searchController = TextEditingController();

  TransactionPosController(this.ref, this.context);

  void onShowCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CartBottomSheet(),
    );
  }
}
