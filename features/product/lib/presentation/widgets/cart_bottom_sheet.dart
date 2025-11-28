import 'package:core/core.dart';
import 'package:product/data/model/product_model.dart';
import 'package:product/presentation/widgets/qty_button.dart';
import 'package:product/presentation/widgets/summary_row.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  double get subtotal => product.price * quantity;
}

class CartBottomSheet extends StatelessWidget {
  final List<CartItem> cart;
  final double total;
  final Function(int, int) onUpdateQty;
  final VoidCallback onClear;
  final Color sbBlue;
  final Color sbOrange;

  const CartBottomSheet({
    required this.cart,
    required this.total,
    required this.onUpdateQty,
    required this.onClear,
    required this.sbBlue,
    required this.sbOrange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(3))),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pesanan (${cart.length})',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () {
                    onClear();
                    Navigator.pop(context);
                  },
                  child: const Text('Hapus Semua',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                          fontSize: 13)),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Items List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: cart.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = cart[index];
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(formatRupiah(item.product.price),
                              style: TextStyle(
                                  color: sbOrange,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          QtyBtn(
                              icon: Icons.remove,
                              onTap: () => onUpdateQty(item.product.id, -1)),
                          SizedBox(
                            width: 32,
                            child: Text(
                              '${item.quantity}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          QtyBtn(
                              icon: Icons.add,
                              onTap: () => onUpdateQty(item.product.id, 1),
                              isBlue: true,
                              color: sbBlue),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Footer / Summary
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4))
              ],
            ),
            child: Column(
              children: [
                SummaryRow(label: 'Subtotal', value: formatRupiah(total)),
                const SizedBox(height: 8),
                SummaryRow(
                    label: 'Pajak (10%)', value: formatRupiah(total * 0.1)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(), // Or Custom Dotted Line
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(formatRupiah(total * 1.1),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Transaksi Berhasil!')));
                      onClear();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sbOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    child: const Text('Bayar Sekarang',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
