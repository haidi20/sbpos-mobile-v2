import 'package:core/core.dart';
import 'package:product/presentation/widgets/qty_button.dart';
import 'package:product/presentation/view_models/product_pos.state.dart';
import 'package:product/presentation/providers/product_pos_provider.dart';
import 'package:product/presentation/controllers/cart_bottom_sheet.controller.dart';

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
    // startListening uses ref.listen internally which must be called during
    // build; instead we will call ref.listen in build and delegate to controller.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 2. WATCH STATE: Agar UI rebuild saat cart/total berubah
    final stateProductPos = ref.watch(productPosViewModelProvider);
    final viewModel = ref.read(productPosViewModelProvider.notifier);

    // listen should be called during build; delegate handling to controller
    ref.listen<ProductPosState>(productPosViewModelProvider, (previous, next) {
      _controller.onStateChanged(previous, next);
    });

    return GestureDetector(
      onTap: () => _controller.unfocusAll(),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          children: [
            _buildHeader(stateProductPos, viewModel),
            _buildOrderList(
              viewModel: viewModel,
              stateProductPos: stateProductPos,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ProductPosState stateProductPos, dynamic viewModel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pesanan (${stateProductPos.cart.length})',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                // ACTION: Clear Cart
                onPressed: () => viewModel.clearCart(),
                child: const Text(
                  'Hapus Semua',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList({
    required dynamic viewModel,
    required ProductPosState stateProductPos,
  }) {
    final double cartTotal = _controller.cartTotal;
    final double finalTotal = _controller.finalTotal;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: stateProductPos.cart.length + 1,
        itemBuilder: (context, index) {
          if (index < stateProductPos.cart.length) {
            return _buildOrderCard(
              index: index,
              viewModel: viewModel,
              stateProductPos: stateProductPos,
            );
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 24 : 48,
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
                    border: Border.all(color: Colors.yellow.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.notes,
                              size: 16, color: Colors.yellow.shade700),
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
                          hintText: "Contoh: Bungkus dipisah, Meja nomor 5...",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Colors.yellow.shade400),
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
                  _buildSummaryRow(
                    'Subtotal',
                    formatRupiah(cartTotal),
                  ),
                  // _buildSummaryRow(
                  //     'Pajak (10%)', formatRupiah(cartTotal * 0.1)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(
                      color: Color(0xFFE5E7EB),
                    ),
                  ),
                  _buildSummaryRow(
                    'Total',
                    formatRupiah(finalTotal),
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
                              'Transaksi Berhasil!\nTotal: ${formatRupiah(finalTotal)}'),
                        ),
                      );
                      // ACTION: Clear Cart
                      viewModel.clearCart();
                      Navigator.pop(context); // Tutup bottom sheet
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sbOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Bayar Sekarang',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard({
    required int index,
    required dynamic viewModel,
    required ProductPosState stateProductPos,
  }) {
    final item = stateProductPos.cart[index];
    final id = item.product.id ?? 0;

    // Safety check jika controller belum ready (karena async gap)
    if (!_controller.itemNoteControllers.containsKey(id)) {
      _controller.itemNoteControllers[id] =
          TextEditingController(text: item.note);
      _controller.itemFocusNodes[id] = FocusNode();
    }

    final focusNode = _controller.itemFocusNodes[id]!;
    final controller = _controller.itemNoteControllers[id]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatRupiah(item.product.price ?? 0),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.sbOrange,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    QtyButton(
                      icon: Icons.remove,
                      // ACTION: Update Qty -1
                      onTap: () => _controller.onUpdateQuantity(id, -1),
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${item.quantity}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    QtyButton(
                      icon: Icons.add,
                      // ACTION: Update Qty +1
                      onTap: () => _controller.onUpdateQuantity(id, 1),
                      isBlue: true,
                      color: AppColors.sbBlue,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              maxLines: 2,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'Catatan item...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.sbBlue,
                  ),
                ),
              ),
              // ACTION: Update Item Note
              onChanged: (value) {
                viewModel.setItemNote(id, value);
              },
              onSubmitted: (_) {
                FocusScope.of(context).unfocus();
              },
              onTap: () {
                _controller.activateItemNote(id);
                // ACTION: Set Active ID
                viewModel.setActiveNoteId(id);
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Divider(
              height: 1,
              color: Color(0xFFF3F4F6),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.black : Colors.grey.shade600,
            fontSize: isTotal ? 20 : 14,
            fontWeight: isTotal ? FontWeight.bold : null,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isTotal ? Colors.black : Colors.grey.shade600,
            fontSize: isTotal ? 20 : 14,
            fontWeight: isTotal ? FontWeight.bold : null,
          ),
        ),
      ],
    );
  }
}
