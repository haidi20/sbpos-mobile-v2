import 'package:core/core.dart';
import 'package:transaction/presentation/screens/cart.screen.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';
import 'package:transaction/presentation/controllers/cart_screen.controller.dart';
import 'package:transaction/presentation/screens/cart_method_payment.screen.dart';

class CartBottomSheet extends ConsumerStatefulWidget {
  const CartBottomSheet({super.key});

  @override
  ConsumerState<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends ConsumerState<CartBottomSheet> {
  late final CartScreenController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CartScreenController(ref, context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logger = Logger('CartBottomSheet');

    // Dengarkan perubahan state untuk memastikan reaktivitas
    ref.listen<TransactionPosState>(transactionPosViewModelProvider,
        (previous, next) {
      _controller.onStateChanged(previous, next);
      if (previous?.activeNoteId != next.activeNoteId) {
        logger.info(
            'activeNoteId berubah: ${previous?.activeNoteId} -> ${next.activeNoteId}');
      }
    });

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // No-op: use onTapDown to decide if outside tap
        _controller.setActiveItemNoteId(null);
      },
      // Removed global onTapDown clearing to prevent accidental unfocus while typing.
      // Do not clear on pan; avoid unfocus during scroll
      child: DraggableScrollableSheet(
        expand: false,
        // Buka hampir penuh saat diakses
        minChildSize: 0.4,
        initialChildSize: 0.95,
        // Izinkan penuh saat di-drag
        // maxChildSize: 1.0,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            // Make the sheet content scrollable using the provided scrollController
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 48,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.gray300,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Terapkan rendering berdasarkan `typeChart` di state
                    Builder(builder: (context) {
                      final state = ref.watch(transactionPosViewModelProvider);
                      if (state.typeChart == ETypeChart.main) {
                        return const CartScreen();
                      }
                      if (state.typeChart == ETypeChart.confirm) {
                        // Tampilkan CartScreen dalam mode konfirmasi (hanya baca)
                        return const CartScreen(readOnly: true);
                      }
                      return const CartMethodPaymentScreen();
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
