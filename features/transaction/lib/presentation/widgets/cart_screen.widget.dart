import 'package:core/core.dart';
import 'package:customer/domain/entities/customer.entity.dart';
import 'package:customer/presentation/screens/customer.sheet.dart';
import 'package:transaction/presentation/components/order.card.dart';
import 'package:transaction/presentation/view_models/transaction_pos.vm.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';
import 'package:transaction/presentation/controllers/cart_screen.controller.dart';

class CartHeader extends StatelessWidget {
  final Future<void> Function() onClearCart;
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
                onPressed: () async {
                  // First, perform clear operation and await completion so
                  // persistence/deletes happen before we update UI.
                  await onClearCart();

                  // Then clear active item note in-memory only (no persistence)
                  // to avoid re-creating transactions from background writes.
                  unawaited(viewModel.setActiveNoteId(null, persist: false));
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
        onTap: () async {
          // Collapse any active note input before opening picker (persist in background)
          unawaited(viewModel.setActiveNoteId(null, background: true));
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
      // Show only items already in cart (state.details), not the filtered list
      itemCount: stateTransaction.details.length,
      itemBuilder: (context, index) {
        if (index < stateTransaction.details.length) {
          final item = stateTransaction.details[index];
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
            onSetActiveNoteId: (pid) =>
                unawaited(controller.setActiveItemNoteId(pid)),
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

class SummaryBottomWidget extends StatefulWidget {
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
  State<SummaryBottomWidget> createState() => _SummaryBottomWidgetState();
}

class _SummaryBottomWidgetState extends State<SummaryBottomWidget> {
  bool _isEditing = false;

  void _enterEdit() {
    if (widget.readOnly) return;
    setState(() => _isEditing = true);
    widget.controller.orderFocusNode.requestFocus();
  }

  void _exitEdit() {
    widget.controller.orderFocusNode.unfocus();
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final viewModel = widget.viewModel;
    final logger = Logger('SummaryBottomWidget');

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 24 : 48,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Compact header
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

          // Preview or editor
          GestureDetector(
            onTap: _isEditing ? null : _enterEdit,
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(LucideIcons.edit,
                      size: 18, color: AppColors.gray600),
                ),
                Expanded(
                  child: _isEditing && !widget.readOnly
                      ? TextField(
                          controller: controller.orderNoteController,
                          focusNode: controller.orderFocusNode,
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
                          onSubmitted: (_) => _exitEdit(),
                          onEditingComplete: _exitEdit,
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.grey.shade200, width: 1),
                          ),
                          child: Text(
                            controller.orderNoteController.text.isNotEmpty
                                ? controller.orderNoteController.text
                                : 'Catatan Pesanan (opsional)',
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  controller.orderNoteController.text.isNotEmpty
                                      ? Colors.black87
                                      : Colors.grey.shade400,
                            ),
                          ),
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
              onPressed: () async {
                await viewModel.onShowMethodPayment();
                logger.info("read only ${widget.readOnly}");

                if (widget.readOnly == false) {
                  // Tunggu sampai frame berikutnya agar perubahan state/layout
                  // (typeCart -> confirm/checkout) sudah dirender, lalu lakukan
                  // scroll agar posisi target tersedia.
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    unawaited(widget.controller.scrollContentBy(25));
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.sbOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.readOnly
                    ? 'Melanjutkan Pembayaran'
                    : 'Konfirmasi Pesanan',
                style: const TextStyle(
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
