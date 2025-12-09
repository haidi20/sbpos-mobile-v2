import 'package:core/core.dart';
import 'package:product/presentation/widgets/qty_button.dart';

class OrderCard extends StatelessWidget {
  final int id;
  final String productName;
  final double productPrice;
  final int qty;
  final bool isActive;
  final String? note;
  final int? activeNoteId;
  final TextEditingController textController;
  final FocusNode focusNode;
  final void Function(int productId, int delta) onUpdateQuantity;
  final void Function(int? productId) onSetActiveNoteId;
  final void Function(int productId, String value) onSetItemNote;

  const OrderCard({
    super.key,
    required this.id,
    required this.isActive,
    required this.productName,
    required this.productPrice,
    required this.qty,
    required this.textController,
    required this.focusNode,
    required this.onUpdateQuantity,
    required this.onSetActiveNoteId,
    required this.onSetItemNote,
    this.note,
    this.activeNoteId,
  });
  @override
  Widget build(BuildContext context) {
    final itemNote = note ?? '';
    final logger = Logger('OrderCard');
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
                      productName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatRupiah(productPrice.toDouble()),
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
                      onTap: () => onUpdateQuantity(id, -1),
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '$qty',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    QtyButton(
                      icon: Icons.add,
                      // ACTION: Update Qty +1
                      onTap: () => onUpdateQuantity(id, 1),
                      isBlue: true,
                      color: AppColors.sbBlue,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Builder(
            builder: (_) {
              if (isActive) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextField(
                    controller: textController,
                    focusNode: focusNode,
                    maxLines: 2,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: 'Catatan item...',
                      hintStyle:
                          TextStyle(color: Colors.grey.shade400, fontSize: 12),
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
                    onChanged: (value) {
                      onSetItemNote(id, value);
                    },
                    onSubmitted: (_) {
                      FocusScope.of(context).unfocus();
                      onSetActiveNoteId(null);
                    },
                    onTap: () {
                      // Only set active id; controller will manage focus
                      onSetActiveNoteId(id);
                    },
                    onTapOutside: (_) {
                      //
                    },
                  ),
                );
              }

              // Tidak aktif: tampilkan ikon pensil + teks preview catatan
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: InkWell(
                  onTap: () {
                    // Only set active id; controller handles focus internally
                    onSetActiveNoteId(id);
                    logger.info('OrderCard: Activate note for productId=$id');
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.grey.shade200, width: 1),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: AppColors.sbBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: Colors.grey.shade200, width: 1),
                          ),
                          child: Text(
                            (itemNote).isNotEmpty
                                ? itemNote
                                : 'Catatan item (opsional)',
                            style: TextStyle(
                              fontSize: 12,
                              color: (itemNote).isNotEmpty
                                  ? Colors.black87
                                  : Colors.grey.shade400,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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
