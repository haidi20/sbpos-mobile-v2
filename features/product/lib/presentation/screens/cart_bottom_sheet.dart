import 'package:core/core.dart';
import 'package:product/data/models/cart_model.dart';
import 'package:product/presentation/widgets/qty_button.dart';
import 'package:product/presentation/view_models/product_pos.state.dart';
import 'package:product/presentation/providers/product_pos_provider.dart';

class CartBottomSheet extends ConsumerStatefulWidget {
  const CartBottomSheet({super.key});

  @override
  ConsumerState<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends ConsumerState<CartBottomSheet> {
  late FocusNode _orderFocusNode;
  final Map<int, FocusNode> _itemFocusNodes = {};
  late TextEditingController _orderNoteController;
  final Map<int, TextEditingController> _itemNoteControllers = {};

  @override
  void initState() {
    super.initState();
    _orderFocusNode = FocusNode();

    // 1. Initial State Read (One time)
    final stateProductPos = ref.read(productPosViewModelProvider);
    // Avoid calling ref.watch in initState; use ref.read for notifiers
    final viewModel = ref.read(productPosViewModelProvider.notifier);

    _orderNoteController =
        TextEditingController(text: stateProductPos.orderNote);

    // Listener saat user mengetik di Order Note
    _orderNoteController.addListener(() {
      // Cek agar tidak looping infinite update
      if (_orderNoteController.text != stateProductPos.orderNote) {
        viewModel.setOrderNote(_orderNoteController.text);
      }
    });

    // Inisialisasi controller item
    _initializeItemControllers(stateProductPos.cart);
  }

  void _initializeItemControllers(List<CartItem> cart) {
    for (final item in cart) {
      final id = item.product.id ?? 0;
      if (!_itemNoteControllers.containsKey(id)) {
        _itemNoteControllers[id] = TextEditingController(text: item.note);
        _itemFocusNodes[id] = FocusNode();
      }
    }
  }

  @override
  void dispose() {
    _orderNoteController.dispose();
    _orderFocusNode.dispose();
    for (final controller in _itemNoteControllers.values) {
      controller.dispose();
    }
    for (final node in _itemFocusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _unfocusAll() {
    FocusScope.of(context).unfocus();
  }

  void _activateItemNote(int id) {
    // Unfocus yang lain
    for (final nodeId in _itemFocusNodes.keys) {
      if (nodeId != id) {
        _itemFocusNodes[nodeId]?.unfocus();
      }
    }
    _orderFocusNode.unfocus();
    // Fokus ke item yang dipilih agar keyboard muncul segera
    _itemFocusNodes[id]?.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    // 2. WATCH STATE: Agar UI rebuild saat cart/total berubah
    final stateProductPos = ref.watch(productPosViewModelProvider);
    final viewModel = ref.read(productPosViewModelProvider.notifier);

    // Hitung Total (bisa ambil dari getter VM atau hitung manual di sini)
    // Karena getter VM tidak reactive via ref.watch(provider), kita hitung manual via state
    final double cartTotal =
        stateProductPos.cart.fold(0, (sum, item) => sum + item.subtotal);
    // final double finalTotal = cartTotal * 1.1; // Pajak 10%
    final double finalTotal = cartTotal;

    // 3. LISTEN STATE: Pengganti didUpdateWidget
    // Digunakan untuk sinkronisasi Controller jika state berubah drastis (add/remove item)
    ref.listen<ProductPosState>(productPosViewModelProvider, (previous, next) {
      if (previous == null) return;

      // A. Jika Order Note berubah dari luar (jarang terjadi di bottom sheet, tapi good practice)
      if (previous.orderNote != next.orderNote &&
          _orderNoteController.text != next.orderNote) {
        _orderNoteController.text = next.orderNote;
      }

      // B. Logic Sinkronisasi Item Controllers
      if (previous.cart.length != next.cart.length) {
        // 1. Hapus controller untuk item yang hilang
        final nextIds = next.cart.map((e) => e.product.id).toSet();
        _itemNoteControllers.removeWhere((id, controller) {
          if (!nextIds.contains(id)) {
            controller.dispose();
            _itemFocusNodes[id]?.dispose();
            _itemFocusNodes.remove(id);
            return true;
          }
          return false;
        });

        // 2. Tambah controller untuk item baru
        for (final item in next.cart) {
          final id = item.product.id ?? 0;
          if (!_itemNoteControllers.containsKey(id)) {
            _itemNoteControllers[id] = TextEditingController(text: item.note);
            _itemFocusNodes[id] = FocusNode();
          }
        }
      } else {
        // Jika length sama, cek apakah text note berubah dari luar (bukan dari ketikan sendiri)
        for (final item in next.cart) {
          final id = item.product.id ?? 0;
          final controller = _itemNoteControllers[id];
          if (controller != null && controller.text != item.note) {
            // Cek focus agar tidak mengganggu user yang sedang mengetik
            if (!(_itemFocusNodes[id]?.hasFocus ?? false)) {
              controller.text = item.note;
            }
          }
        }
      }
    });

    return GestureDetector(
      onTap: _unfocusAll,
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
            _buildItemsSection(
                stateProductPos, viewModel, cartTotal, finalTotal),
          ],
        ),
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

  Widget _buildItemsSection(ProductPosState stateProductPos, dynamic viewModel,
      double cartTotal, double finalTotal) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: stateProductPos.cart.length + 1,
        itemBuilder: (context, index) {
          if (index < stateProductPos.cart.length) {
            final item = stateProductPos.cart[index];
            final id = item.product.id ?? 0;

            // Safety check jika controller belum ready (karena async gap)
            if (!_itemNoteControllers.containsKey(id)) {
              _itemNoteControllers[id] = TextEditingController(text: item.note);
              _itemFocusNodes[id] = FocusNode();
            }

            final controller = _itemNoteControllers[id]!;
            final focusNode = _itemFocusNodes[id]!;

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
                              onTap: () => viewModel.setUpdateQuantity(id, -1),
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
                              onTap: () => viewModel.setUpdateQuantity(id, 1),
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
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 12),
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
                        _activateItemNote(id);
                        // ACTION: Set Active ID
                        viewModel.setActiveNoteId(id);
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Divider(height: 1, color: Color(0xFFF3F4F6)),
                  )
                ],
              ),
            );
          } else {
            // --- GENERAL NOTE & SUMMARY BLOCK ---
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
                          controller: _orderNoteController,
                          focusNode: _orderFocusNode,
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
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200),
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
                    _buildSummaryRow('Subtotal', formatRupiah(cartTotal)),
                    // _buildSummaryRow(
                    //     'Pajak (10%)', formatRupiah(cartTotal * 0.1)),
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(color: Color(0xFFE5E7EB))),
                    _buildSummaryRow('Total', formatRupiah(finalTotal),
                        isTotal: true),
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
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
