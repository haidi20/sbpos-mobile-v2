import 'package:core/core.dart';
import 'package:customer/presentation/screens/customer.sheet.dart';
import 'package:transaction/presentation/components/order.card.dart';
import 'package:transaction/presentation/view_models/transaction_pos.vm.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';
import 'package:transaction/presentation/controllers/cart_screen.controller.dart';

Widget buildHeader({
  required VoidCallback onClearCart,
  required TransactionPosViewModel viewModel,
  required TransactionPosState stateTransaction,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pesanan (${viewModel.cartCount} items)',
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

Widget buildCustomerCard({
  required BuildContext context,
  required TransactionPosState state,
  required TransactionPosViewModel viewModel,
}) {
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
              ? _customerInfoSelected(
                  customer: customer,
                  viewModel: viewModel,
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.user, size: 20, color: AppColors.gray500),
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

Widget buildOrderList({
  required CartScreenController controller,
  required TransactionPosViewModel viewModel,
  required TransactionPosState stateTransaction,
  required TextEditingController orderNoteController,
  bool readOnly = false,
}) {
  // final logger = Logger('CartBottomSheetWidget.buildOrderList');

  return ListView.builder(
    // padding: const EdgeInsets.symmetric(horizontal: 24),
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

        // logger.info(
        //     'activeNoteId=${stateTransaction.activeNoteId} productId=$id isActive=$isActive');

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

Widget buildSummaryBottom({
  required BuildContext context,
  required CartScreenController controller,
  required TransactionPosViewModel viewModel,
  bool readOnly = false,
}) {
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
          _buildSummaryRow(
            'Subtotal',
            formatRupiah(controller.cartTotal),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              color: Color(0xFFE5E7EB),
            ),
          ),
          _buildSummaryRow(
            'Total',
            formatRupiah(controller.finalTotal),
            isTotal: true,
          ),
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

Widget _buildSummaryRow(
  String label,
  String value, {
  bool isTotal = false,
}) {
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

Widget _customerInfoSelected({
  required dynamic customer,
  required TransactionPosViewModel viewModel,
}) {
  return Stack(
    children: [
      Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent,
              boxShadow: [
                BoxShadow(
                  blurRadius: 3,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: Center(
              child: Text(
                (customer.name != null && customer.name!.isNotEmpty
                    ? customer.name!.substring(0, 1)
                    : ''),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '• ${customer.phone}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Remove Button
          InkWell(
            onTap: () {
              viewModel.setCustomer(null);
              viewModel.setActiveNoteId(null);
            },
            child: const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(
                size: 18,
                LucideIcons.x,
                color: Colors.grey,
              ),
            ),
          )
        ],
      ),
      // Notes if available
      if (customer.note != null && customer.note!.isNotEmpty)
        Positioned(
          top: 0,
          right: 0,
          child: IgnorePointer(
            ignoring: true,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(
                    8.0,
                  ),
                ),
              ),
              child: Text(
                'Catatan: ${customer.note}',
                style: TextStyle(
                    color: Colors.yellow[800],
                    fontSize: 10,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
    ],
  );
}
