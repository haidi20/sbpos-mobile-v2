import 'package:core/core.dart';
import 'package:product/presentation/widgets/qty_button.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';

class OrderCard extends StatelessWidget {
  final int index;
  final dynamic viewModel;
  final TransactionPosState stateTransaction;
  final dynamic controller;

  const OrderCard({
    super.key,
    required this.index,
    required this.viewModel,
    required this.controller,
    required this.stateTransaction,
  });

  @override
  Widget build(BuildContext context) {
    final item = stateTransaction.details[index];
    final id = item.productId ?? 0;

    // Safety check jika controller belum ready (karena async gap)
    if (!controller.itemNoteControllers.containsKey(id)) {
      controller.itemNoteControllers[id] =
          TextEditingController(text: item.note);
      controller.itemFocusNodes[id] = FocusNode();
    }

    final focusNode = controller.itemFocusNodes[id]!;
    final textController = controller.itemNoteControllers[id]!;

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
                      item.productName ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatRupiah((item.productPrice ?? 0).toDouble()),
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
                      onTap: () => controller.onUpdateQuantity(id, -1),
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '${item.qty ?? 0}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    QtyButton(
                      icon: Icons.add,
                      // ACTION: Update Qty +1
                      onTap: () => controller.onUpdateQuantity(id, 1),
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
              controller: textController,
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
                controller.activateItemNote(id);
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
}
