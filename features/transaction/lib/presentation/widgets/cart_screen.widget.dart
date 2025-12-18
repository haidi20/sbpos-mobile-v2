import 'package:core/core.dart';
import 'package:customer/domain/entities/customer.entity.dart';
import 'package:customer/presentation/screens/customer.sheet.dart';
import 'package:transaction/presentation/components/order.card.dart';
import 'package:transaction/presentation/view_models/transaction_pos.vm.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';
import 'package:transaction/presentation/controllers/cart_screen.controller.dart';

class CartHeader extends StatelessWidget {
  final VoidCallback onClearCart;
  final TransactionPosViewModel viewModel;
  final TransactionPosState stateTransaction;

  const CartHeader({
    super.key,
    required this.onClearCart,
    required this.viewModel,
    required this.stateTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pesanan (${viewModel.getCartCount} items)',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                // ACTION: Clear Cart
                onPressed: () {
                  // Clear active item note to collapse any open input
                  viewModel.setActiveNoteId(null);
                  onClearCart();
                },
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
}

class CustomerCard extends StatelessWidget {
  final TransactionPosState state;
  final TransactionPosViewModel viewModel;

  const CustomerCard({super.key, required this.state, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    const sbBlue = Color(0xFF3B82F6);
    final customer = state.selectedCustomer;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: InkWell(
        onTap: () {
          // Collapse any active note input before opening picker
          viewModel.setActiveNoteId(null);
          CustomerSheet.openCustomerPicker(context);
        },
        borderRadius: BorderRadius.circular(16.0),
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(16),
          color: customer != null ? sbBlue : AppColors.gray300,
          strokeWidth: 1,
          dashPattern: const [8, 4],
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: customer != null ? Colors.blue[50] : Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                width: 1,
                color: AppColors.gray200,
              ),
              boxShadow: [
                if (customer != null)
                  BoxShadow(
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                    color: Colors.black.withOpacity(0.03),
                  ),
              ],
            ),
            child: customer != null
                ? CustomerInfoSelected(
                    customer: customer,
                    viewModel: viewModel,
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.user,
                          size: 20, color: AppColors.gray500),
                      SizedBox(width: 8),
                      Text(
                        'Pilih Pelanggan / Member',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class OrderListWidget extends StatelessWidget {
  final bool readOnly;
  final CartScreenController controller;
  final TransactionPosViewModel viewModel;
  final TransactionPosState stateTransaction;
  final TextEditingController orderNoteController;

  const OrderListWidget({
    super.key,
    this.readOnly = false,
    required this.controller,
    required this.viewModel,
    required this.stateTransaction,
    required this.orderNoteController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewModel.getFilteredDetails.length + 1,
      itemBuilder: (context, index) {
        if (index < viewModel.getFilteredDetails.length) {
          final item = viewModel.getFilteredDetails[index];
          final id = item.productId ?? 0;

          controller.itemNoteControllers[id] ??=
              TextEditingController(text: item.note);
          controller.itemFocusNodes[id] ??= FocusNode();

          bool isActive = (stateTransaction.activeNoteId == id);

          return OrderCard(
            id: id,
            note: item.note,
            isActive: isActive,
            qty: item.qty ?? 0,
            productName: item.productName ?? '',
            focusNode: controller.itemFocusNodes[id]!,
            activeNoteId: stateTransaction.activeNoteId,
            productPrice: (item.productPrice ?? 0).toDouble(),
            textController: controller.itemNoteControllers[id]!,
            readOnly: readOnly,
            onSetActiveNoteId: (pid) => controller.setActiveItemNoteId(pid),
            onSetItemNote: (pid, value) => viewModel.setItemNote(pid, value),
            onUpdateQuantity: (pid, delta) =>
                controller.onUpdateQuantity(pid, delta),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}

class SummaryBottomWidget extends StatelessWidget {
  final CartScreenController controller;
  final TransactionPosViewModel viewModel;
  final bool readOnly;

  const SummaryBottomWidget({
    super.key,
    required this.controller,
    required this.viewModel,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
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
                if (!readOnly)
                  TextField(
                    controller: controller.orderNoteController,
                    focusNode: controller.orderFocusNode,
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
                        borderSide: BorderSide(color: Colors.yellow.shade400),
                      ),
                    ),
                    onSubmitted: (_) {
                      FocusScope.of(context).unfocus();
                    },
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200)),
                    child: Text(
                      controller.orderNoteController.text.isNotEmpty
                          ? controller.orderNoteController.text
                          : '-',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Summary
          ...[
            _SummaryRow(
                label: 'Subtotal', value: formatRupiah(controller.cartTotal)),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(
                color: Color(0xFFE5E7EB),
              ),
            ),
            _SummaryRow(
                label: 'Total',
                value: formatRupiah(controller.finalTotal),
                isTotal: true),
          ],
          const SizedBox(height: 24),
          // Pay Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                viewModel.onShowMethodPayment();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.sbOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Melanjutkan Pembayaran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// replaced by private widget `_SummaryRow`

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow(
      {required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
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

// CustomerInfoSelected widget is implemented as `CustomerInfoSelected` class above.
class CustomerInfoSelected extends StatelessWidget {
  final CustomerEntity customer;
  final TransactionPosViewModel viewModel;

  const CustomerInfoSelected(
      {super.key, required this.customer, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.user, size: 20, color: AppColors.gray700),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  customer.phone ?? '-',
                  style:
                      const TextStyle(color: AppColors.gray600, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            // clear selected customer
            viewModel.setCustomer(null);
          },
          icon: const Icon(Icons.close, size: 18, color: AppColors.gray500),
          tooltip: 'Hapus pelanggan',
        ),
      ],
    );
  }
}
