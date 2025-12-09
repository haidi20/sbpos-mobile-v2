import 'package:core/core.dart';
import 'package:transaction/presentation/components/order.card.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
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
                      for (int i = 0; i < viewModel.filteredDetails.length; i++)
                        Builder(builder: (context) {
                          final item = viewModel.filteredDetails[i];
                          final id = item.productId ?? 0;

                          // Ensure controllers exist for this item
                          _controller.itemNoteControllers[id] ??=
                              TextEditingController(text: item.note);
                          _controller.itemFocusNodes[id] ??= FocusNode();

                          return OrderCard(
                            id: id,
                            productName: item.productName ?? '',
                            productPrice: (item.productPrice ?? 0).toDouble(),
                            qty: item.qty ?? 0,
                            note: item.note,
                            activeNoteId: stateTransaction.activeNoteId,
                            textController:
                                _controller.itemNoteControllers[id]!,
                            focusNode: _controller.itemFocusNodes[id]!,
                            onUpdateQuantity: (pid, delta) {
                              // Clear any active note when changing qty
                              _controller.setActiveItemNoteId(null);
                              _controller.onUpdateQuantity(pid, delta);
                            },
                            onSetActiveNoteId: (pid) =>
                                _controller.setActiveItemNoteId(pid),
                            onSetItemNote: (pid, value) =>
                                viewModel.setItemNote(pid, value),
                          );
                        }),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom > 0
                              ? 24
                              : 48,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Order General Note
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.yellow.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.yellow.shade100),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.notes,
                                        size: 16,
                                        color: Colors.yellow.shade700,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Catatan Pesanan',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.yellow.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _controller.orderNoteController,
                                    focusNode: _controller.orderFocusNode,
                                    maxLines: 3,
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.done,
                                    decoration: InputDecoration(
                                      hintText:
                                          "Contoh: Bungkus dipisah, Meja nomor 5...",
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade300,
                                        fontSize: 13,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.all(8),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade200),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Colors.yellow.shade400),
                                      ),
                                    ),
                                    onSubmitted: (_) {
                                      FocusScope.of(context).unfocus();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Summary
                            ...[
                              buildSummaryRow(
                                'Subtotal',
                                formatRupiah(_controller.cartTotal),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                              buildSummaryRow(
                                'Total',
                                formatRupiah(_controller.finalTotal),
                                isTotal: true,
                              ),
                            ],
                            const SizedBox(height: 24),
                            // Pay Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Transaksi Berhasil!\nTotal: ${formatRupiah(_controller.finalTotal)}'),
                                    ),
                                  );
                                  viewModel.onShowMethodPayment();
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.sbOrange,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Bayar Sekarang',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
