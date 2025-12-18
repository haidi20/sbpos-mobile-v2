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
        unawaited(_controller.setActiveItemNoteId(null));
      },
      // Removed global onTapDown clearing to prevent accidental unfocus while typing.
      // Do not clear on pan; avoid unfocus during scroll
      child: DraggableScrollableSheet(
        controller: _controller.sheetController,
        expand: false,
        // Buka hampir penuh saat diakses. Izinkan expand penuh agar konten
        // tidak terpotong saat daftar atau footer tinggi.
        minChildSize: 0.35,
        initialChildSize: 0.9,
        // Izinkan penuh saat di-drag agar tidak memotong konten.
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            // Make the sheet occupy the full available height and allow only
            // the inner content (the Builder result) to scroll. The grab
            // handle (top area) stays fixed while the content below scrolls.
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Show the grab handle only when sheet is not fully expanded.
                  ValueListenableBuilder<double>(
                    valueListenable: _controller.sheetSize,
                    builder: (_, size, __) {
                      if (size <= 0.95) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Align(
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
                        );
                      } else {
                        return const SizedBox(height: 16);
                      }
                    },
                  ),

                  Expanded(
                    child: Builder(builder: (context) {
                      final state = ref.watch(transactionPosViewModelProvider);
                      if (state.typeCart == ETypeCart.main) {
                        return CartScreen(
                            outerScrollController: scrollController);
                      }
                      if (state.typeCart == ETypeCart.confirm) {
                        // Tampilkan CartScreen dalam mode konfirmasi (hanya baca)
                        return CartScreen(
                            readOnly: true,
                            outerScrollController: scrollController);
                      }
                      return const CartMethodPaymentScreen();
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
