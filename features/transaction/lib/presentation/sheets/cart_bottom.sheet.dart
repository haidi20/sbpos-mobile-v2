import 'package:core/core.dart';
import 'package:transaction/presentation/screens/cart.screen.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';
import 'package:transaction/presentation/controllers/cart_screen.controller.dart';
import 'package:transaction/presentation/screens/cart_payment.screen.dart';

class CartBottomSheet extends ConsumerStatefulWidget {
  const CartBottomSheet({super.key});

  @override
  ConsumerState<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends ConsumerState<CartBottomSheet> {
  late final CartScreenController _controller;
  ScrollController? _sheetScrollController;
  bool _listenerRegistered = false;

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
    // Register listener during build (once). Riverpod requires `ref.listen`
    // to be called during build for ConsumerState.
    if (!_listenerRegistered) {
      _listenerRegistered = true;
      ref.listen<TransactionPosState>(transactionPosViewModelProvider,
          (previous, next) {
        _controller.onStateChanged(previous, next);
        if (previous?.activeNoteId != next.activeNoteId) {
          Logger('CartBottomSheet').info(
              'activeNoteId berubah: ${previous?.activeNoteId} -> ${next.activeNoteId}');
        }

        // Scroll to top when the cart view type changes.
        if (previous?.typeCart != next.typeCart &&
            _sheetScrollController != null) {
          try {
            _sheetScrollController!.animateTo(
              0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          } catch (_) {
            // Ignore if controller not attached yet.
          }
        }
      });
    }

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
        // Start fully expanded so the sheet appears full-screen.
        // The grab handle will be shown when the user drags the sheet
        // and the `sheetSize` falls below the visibility threshold.
        initialChildSize: 1.0,
        // Izinkan penuh saat di-drag agar tidak memotong konten.
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          // Capture the inner scroll controller provided by the sheet so
          // `initState`-registered listener can animate it when needed.
          _sheetScrollController = scrollController;

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            // Make the sheet occupy the available height and allow only
            // the inner content (the Builder result) to scroll. The grab
            // handle (top area) stays fixed while the content below scrolls.
            // Wrap the Column in AnimatedSize so changes in the content
            // height (when footer appears/disappears) animate smoothly.
            child: SizedBox.expand(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Show the grab handle only when sheet is not fully expanded.
                    ValueListenableBuilder<double>(
                      valueListenable: _controller.sheetSize,
                      builder: (_, size, __) {
                        if (size <= 0.95) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 15, left: 12, right: 12),
                            child: Row(
                              children: [
                                Expanded(
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
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const SizedBox(height: 16);
                        }
                      },
                    ),

                    Builder(
                      builder: (context) {
                        final state =
                            ref.watch(transactionPosViewModelProvider);

                        // Area konten harus fleksibel mengisi sisa ruang
                        // antara grab handle dan footer. Gunakan Expanded
                        // agar footer (jika muncul) otomatis mengurangi tinggi konten
                        // dan mencegah overflow.
                        if (state.typeCart == ETypeCart.main) {
                          return Expanded(
                            child: CartScreen(
                              outerScrollController: scrollController,
                            ),
                          );
                        }

                        if (state.typeCart == ETypeCart.confirm) {
                          return Expanded(
                            child: CartScreen(
                              readOnly: true,
                              outerScrollController: scrollController,
                            ),
                          );
                        }

                        return const Expanded(
                          child: CartPaymentScreen(),
                        );
                      },
                    ),
                    // Footer tetap (fixed) yang muncul ketika bukan mode utama cart.
                    // Tombol ini mengembalikan tampilan ke mode `main`.
                    Builder(
                      builder: (context) {
                        final state =
                            ref.watch(transactionPosViewModelProvider);
                        if (state.typeCart != ETypeCart.main) {
                          final vm = ref
                              .read(transactionPosViewModelProvider.notifier);
                          return SafeArea(
                            top: false,
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 12, 16, 16),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  top: BorderSide(
                                    color: AppColors.gray100,
                                  ),
                                ),
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final target =
                                        state.typeCart == ETypeCart.checkout
                                            ? ETypeCart.confirm
                                            : ETypeCart.main;
                                    vm.setTypeCart(target);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.sbBlue,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                          color: AppColors.sbBlue),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Kembali',
                                    style: TextStyle(
                                      color: AppColors.sbBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
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
