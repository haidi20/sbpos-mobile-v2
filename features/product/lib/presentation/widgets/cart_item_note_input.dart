import 'package:core/core.dart';
import 'package:product/data/model/cart_model.dart';

class CartItemNoteInput extends StatefulWidget {
  final CartItem item;
  final Function(String) onUpdateNote;
  final int? activeId;
  final Function(int?) onSetActiveId;

  const CartItemNoteInput({
    super.key,
    required this.item,
    required this.onUpdateNote,
    required this.activeId,
    required this.onSetActiveId,
  });

  @override
  State<CartItemNoteInput> createState() => _CartItemNoteInputState();
}

class _CartItemNoteInputState extends State<CartItemNoteInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.item.note);
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant CartItemNoteInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeId == widget.item.product.id && !_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
    // Sinkronisasi controller jika state luar (misal: tombol X ditekan) mereset catatan
    if (_controller.text != widget.item.note) {
      _controller.text = widget.item.note;
    }
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      // Logika Blur: Ketika input kehilangan fokus
      if (widget.activeId == widget.item.product.id) {
        widget.onSetActiveId(null);
      }
      // Jika catatan kosong saat blur, reset teks controller (agar placeholder muncul saat dibuka lagi)
      if (widget.item.note.isEmpty && _controller.text.isNotEmpty) {
        _controller.clear();
      }
    } else {
      // Logika Focus: Ketika input mendapat fokus
      widget.onSetActiveId(widget.item.product.id);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasNote = widget.item.note.isNotEmpty;
    final bool isActive = widget.activeId == widget.item.product.id;

    if (!hasNote && !isActive) {
      // State 1: Tampilkan tombol 'Tambah Catatan'
      return TextButton.icon(
        onPressed: () => widget.onSetActiveId(widget.item.product.id),
        icon: Icon(Icons.edit, size: 14, color: Colors.grey.shade400),
        label: Text('Tambah Catatan',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
        style: TextButton.styleFrom(
            padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
      );
    }

    // State 2: Tampilkan input field
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: widget.onUpdateNote,
          onSubmitted: (_) => _focusNode.unfocus(),
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          decoration: InputDecoration(
            hintText: "Cth: Jangan pedas, Less sugar",
            hintStyle: TextStyle(color: Colors.grey.shade300, fontSize: 13),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding:
                const EdgeInsets.only(left: 10, right: 30, top: 10, bottom: 10),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: AppColors.sbBlue, width: 1)),
          ),
        ),
        if (hasNote)
          IconButton(
            icon: Icon(Icons.close, size: 14, color: Colors.grey.shade400),
            onPressed: () {
              widget.onUpdateNote('');
              widget.onSetActiveId(null);
            },
          ),
      ],
    );
  }
}
