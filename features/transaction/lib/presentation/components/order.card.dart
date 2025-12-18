import 'package:core/core.dart';
import 'package:product/presentation/widgets/qty_button.dart';

class OrderCard extends StatelessWidget {
  final int id;
  final int qty;
  final String? note;
  final bool readOnly;
  final bool isActive;
  final int? activeNoteId;
  final String productName;
  final double productPrice;
  final FocusNode focusNode;
  final TextEditingController textController;
  final void Function(int? productId) onSetActiveNoteId;
  final void Function(int productId, int delta) onUpdateQuantity;
  final void Function(int productId, String value) onSetItemNote;

  const OrderCard({
    super.key,
    this.note,
    required this.id,
    required this.qty,
    this.activeNoteId,
    this.readOnly = false,
    required this.isActive,
    required this.focusNode,
    required this.productName,
    required this.productPrice,
    required this.onSetItemNote,
    required this.textController,
    required this.onUpdateQuantity,
    required this.onSetActiveNoteId,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          _OrderCardMain(
            id: id,
            qty: qty,
            productName: productName,
            productPrice: productPrice,
            readOnly: readOnly,
            onUpdateQuantity: onUpdateQuantity,
          ),
          _OrderCardNoteArea(
            id: id,
            note: note,
            isActive: isActive,
            readOnly: readOnly,
            focusNode: focusNode,
            textController: textController,
            onSetItemNote: onSetItemNote,
            onSetActiveNoteId: onSetActiveNoteId,
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

class _OrderCardMain extends StatelessWidget {
  final int id;
  final int qty;
  final bool readOnly;
  final String productName;
  final double productPrice;
  final void Function(int productId, int delta) onUpdateQuantity;

  const _OrderCardMain({
    required this.id,
    required this.qty,
    this.readOnly = false,
    required this.productName,
    required this.productPrice,
    required this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
              if (!readOnly)
                QtyButton(
                  icon: Icons.remove,
                  onTap: () => onUpdateQuantity(id, -1),
                ),
              SizedBox(
                width: 32,
                child: Text(
                  '$qty',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!readOnly)
                QtyButton(
                  isBlue: true,
                  icon: Icons.add,
                  color: AppColors.sbBlue,
                  onTap: () => onUpdateQuantity(id, 1),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderCardNoteArea extends StatelessWidget {
  final int id;
  final String? note;
  final bool isActive;
  final bool readOnly;
  final FocusNode focusNode;
  final TextEditingController textController;
  final void Function(int? productId) onSetActiveNoteId;
  final void Function(int productId, String value) onSetItemNote;

  const _OrderCardNoteArea({
    required this.id,
    this.note,
    required this.isActive,
    required this.readOnly,
    required this.focusNode,
    required this.textController,
    required this.onSetItemNote,
    required this.onSetActiveNoteId,
  });

  @override
  Widget build(BuildContext context) {
    final itemNote = note ?? '';
    if (isActive) {
      return _OrderNoteEditor(
        id: id,
        focusNode: focusNode,
        controller: textController,
        onSetActiveNoteId: onSetActiveNoteId,
        onSetItemNote: onSetItemNote,
      );
    }

    // Reusable non-editable preview used for both readOnly and non-active states.
    return _OrderNotePreview(
      text: itemNote.isNotEmpty ? itemNote : 'Catatan item (opsional)',
      onTap: readOnly ? null : () => onSetActiveNoteId(id),
    );
  }
}

class _OrderNotePreview extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _OrderNotePreview({
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.edit,
          size: 16,
          color: AppColors.sbBlue,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: text.isNotEmpty ? Colors.black87 : Colors.grey.shade400,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    if (onTap != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: InkWell(onTap: onTap, child: content),
      );
    }

    return Padding(padding: const EdgeInsets.only(top: 8), child: content);
  }
}

class _OrderNoteEditor extends StatelessWidget {
  final int id;
  final FocusNode focusNode;
  final TextEditingController controller;
  final void Function(int? productId) onSetActiveNoteId;
  final void Function(int productId, String value) onSetItemNote;

  const _OrderNoteEditor({
    required this.id,
    required this.focusNode,
    required this.controller,
    required this.onSetActiveNoteId,
    required this.onSetItemNote,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
        onChanged: (value) => onSetItemNote(id, value),
        onSubmitted: (_) {
          FocusScope.of(context).unfocus();
          onSetActiveNoteId(null);
        },
        onTap: () {
          onSetActiveNoteId(id);
        },
        onTapOutside: (_) {},
      ),
    );
  }
}
