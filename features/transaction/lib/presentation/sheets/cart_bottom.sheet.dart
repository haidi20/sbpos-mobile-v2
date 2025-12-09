import 'package:core/core.dart';
import 'package:transaction/presentation/components/order.card.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_pos.vm.dart';
import 'package:transaction/presentation/widgets/cart_bottom_sheet.widget.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';
import 'package:transaction/presentation/controllers/cart_bottom_sheet.controller.dart';

class CartBottomSheet extends ConsumerStatefulWidget {
  const CartBottomSheet({super.key});

  @override
  ConsumerState<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends ConsumerState<CartBottomSheet> {
  late final CartBottomSheetController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CartBottomSheetController(ref, context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logger = Logger('CartBottomSheet');
    // 2. WATCH STATE: Agar UI rebuild saat cart/total berubah
    final stateTransaction = ref.watch(transactionPosViewModelProvider);
    final viewModel = ref.read(transactionPosViewModelProvider.notifier);

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
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: ListView(
              controller: scrollController,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
                ),
                buildHeader(
                  onClearCart: _controller.onClearCart,
                  viewModel: viewModel,
                  stateTransaction: stateTransaction,
                ),
                buildCustomerCard(
                  context: context,
                  viewModel: viewModel,
                  state: stateTransaction,
                ),
                const SizedBox(height: 24),
                // Inline order list in the parent scroll to enable full drag-to-expand
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      buildOrderList(
                        viewModel: viewModel,
                        stateTransaction: stateTransaction,
                        controller: _controller,
                        orderNoteController: _controller.orderNoteController,
                      ),
                      buildSummaryBottom(
                        context: context,
                        viewModel: viewModel,
                        controller: _controller,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
