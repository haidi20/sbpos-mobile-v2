import 'package:core/core.dart';
import 'package:product/data/model/cart_model.dart';
import 'package:product/presentation/widgets/qty_button.dart';

class CartBottomSheet extends StatefulWidget {
  final List<CartItem> cart;
  final double total;
  final Function(int, int) onUpdateQty;
  final VoidCallback onClear;
  final String orderNote;
  final Function(String) onOrderNoteChanged;
  final Function(int, String) onUpdateItemNote;
  final int? activeNoteId;
  final Function(int?) onSetActiveId;

  const CartBottomSheet({
    super.key,
    required this.cart,
    required this.total,
    required this.onUpdateQty,
    required this.onClear,
    required this.orderNote,
    required this.onOrderNoteChanged,
    required this.onUpdateItemNote,
    required this.activeNoteId,
    required this.onSetActiveId,
  });

  @override
  State<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet> {
  late TextEditingController _orderNoteController;
  final Map<int, TextEditingController> _itemNoteControllers =
      {}; // key: product.id
  final Map<int, FocusNode> _itemFocusNodes = {}; // key: product.id
  late FocusNode _orderFocusNode;

  @override
  void initState() {
    super.initState();
    _orderNoteController = TextEditingController(text: widget.orderNote);
    _orderFocusNode = FocusNode();

    _orderNoteController.addListener(() {
      widget.onOrderNoteChanged(_orderNoteController.text);
    });

    // Inisialisasi controller untuk setiap item
    for (final item in widget.cart) {
      final id = item.product.id ?? 0;
      _itemNoteControllers[id] = TextEditingController(text: item.note);
      _itemFocusNodes[id] = FocusNode();
    }
  }

  @override
  void didUpdateWidget(covariant CartBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update order note jika berubah dari parent
    if (oldWidget.orderNote != widget.orderNote) {
      _orderNoteController.text = widget.orderNote;
    }

    // Update item notes jika cart berubah
    if (oldWidget.cart.length != widget.cart.length) {
      // Bersihkan controller lama
      for (final id in _itemNoteControllers.keys) {
        if (!widget.cart.any((item) => item.product.id == id)) {
          _itemNoteControllers[id]?.dispose();
          _itemFocusNodes[id]?.dispose();
        }
      }
      _itemNoteControllers.clear();
      _itemFocusNodes.clear();

      // Buat ulang
      for (final item in widget.cart) {
        final id = item.product.id ?? 0;
        _itemNoteControllers[id] = TextEditingController(text: item.note);
        _itemFocusNodes[id] = FocusNode();
      }
    } else {
      // Update text jika note berubah
      for (final item in widget.cart) {
        final id = item.product.id;
        if (_itemNoteControllers[id]?.text != (item.note)) {
          _itemNoteControllers[id]?.text = item.note;
        }
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
    for (final nodeId in _itemFocusNodes.keys) {
      if (nodeId != id) {
        _itemFocusNodes[nodeId]?.unfocus();
      }
    }
    _orderFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final double finalTotal = widget.total * 1.1;

    return GestureDetector(
      onTap: _unfocusAll, // Klik di luar input → unfocus semua
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
            // Drag Handle & Header
            Padding(
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
                        'Pesanan (${widget.cart.length})',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: widget.onClear,
                        child: const Text(
                          'Hapus Semua',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Items List & General Note
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: widget.cart.length + 1,
                itemBuilder: (context, index) {
                  if (index < widget.cart.length) {
                    final item = widget.cart[index];
                    final id = item.product.id ?? 0;
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
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatRupiah(item.product.price ?? 0),
                                      style: const TextStyle(
                                          color: AppColors.sbOrange,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500),
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
                                      onTap: () => widget.onUpdateQty(id, -1),
                                    ),
                                    SizedBox(
                                      width: 32,
                                      child: Text(
                                        '${item.quantity}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                    ),
                                    QtyButton(
                                      icon: Icons.add,
                                      onTap: () => widget.onUpdateQty(id, 1),
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
                                  borderSide:
                                      BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: AppColors.sbBlue,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                widget.onUpdateItemNote(id, value);
                              },
                              onSubmitted: (_) {
                                FocusScope.of(context)
                                    .unfocus(); // tutup keyboard
                              },
                              onTap: () {
                                _activateItemNote(id);
                                widget.onSetActiveId(id);
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
                              border: Border.all(color: Colors.yellow.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.notes,
                                        size: 16,
                                        color: Colors.yellow.shade700),
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
                                        fontSize: 13),
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
                            _buildSummaryRow(
                                'Subtotal', formatRupiah(widget.total)),
                            _buildSummaryRow('Pajak (10%)',
                                formatRupiah(widget.total * 0.1)),
                            const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(color: Color(0xFFE5E7EB))),
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
                                widget.onClear();
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
            ),
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
}
