import 'package:core/core.dart';
import 'package:transaction/presentation/screens/cart.screen.dart';
import 'package:transaction/presentation/screens/cart_payment.screen.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_pos/transaction_pos.state.dart';

class CartBottomSheet extends StatelessWidget {
  const CartBottomSheet({super.key});

  /// Buka CartBottomSheet sebagai modal full-screen yang tidak bisa ditarik/dismiss.
  static Future<T?> open<T>(BuildContext context) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height,
        child: const CartBottomScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const CartBottomScreen();
  }
}

/// Konten utama bottom sheet dalam bentuk stateless ConsumerWidget.
class CartBottomScreen extends ConsumerWidget {
  const CartBottomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final vm = ref.read(transactionPosViewModelProvider.notifier);
        unawaited(vm.setActiveNoteId(null, background: true));
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final state = ref.watch(transactionPosViewModelProvider);
                    if (state.typeCart == ETypeCart.main) {
                      return const CartScreen();
                    }
                    if (state.typeCart == ETypeCart.confirm) {
                      return const CartScreen(readOnly: true);
                    }
                    return const CartPaymentScreen();
                  },
                ),
              ),
              Builder(
                builder: (context) {
                  final state = ref.watch(transactionPosViewModelProvider);
                  if (state.typeCart != ETypeCart.main) {
                    final vm =
                        ref.read(transactionPosViewModelProvider.notifier);
                    return SafeArea(
                      top: false,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
                                side: const BorderSide(color: AppColors.sbBlue),
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
  }
}
