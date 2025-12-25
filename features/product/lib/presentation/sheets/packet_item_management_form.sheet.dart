// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:core/utils/theme.dart';
import '../controllers/packet_item_management_form.controller.dart';
import 'package:intl/intl.dart';
import '../widgets/floating_input.widget.dart';
import 'package:product/domain/entities/packet_item.entity.dart';
import 'package:product/domain/entities/product.entity.dart';

typedef OnSaveItem = void Function(ProductItem item);
typedef OnRemoveItem = void Function(String id);

class PacketItemManagementFormSheet extends StatefulWidget {
  const PacketItemManagementFormSheet(
      {super.key,
      required this.controller,
      required this.onSave,
      required this.onClose,
      this.onRemove});

  final PacketItemManagementFormController controller;
  final OnSaveItem onSave;
  final VoidCallback onClose;
  final OnRemoveItem? onRemove;

  @override
  State<PacketItemManagementFormSheet> createState() =>
      _PacketItemManagementFormSheetState();
}

/// Show the packet item management sheet and return an updated
/// [PacketItemEntity] or `null` if cancelled.
Future<PacketItemEntity?> showPacketItemManagementSheet(BuildContext context,
    PacketItemEntity item, List<ProductEntity> products) async {
  final controller = PacketItemManagementFormController(
    initial: ProductItem(
      id: item.id?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: products
              .firstWhere((p) => p.id == item.productId,
                  orElse: () => const ProductEntity())
              .name ??
          '',
      qty: item.qty ?? 1,
      price: item.subtotal ?? 0,
      discount: item.discount ?? 0,
    ),
  );

  final res = await showModalBottomSheet<ProductItem?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      expand: false,
      builder: (_, controllerSheet) => Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
        child: PacketItemManagementFormSheet(
          controller: controller,
          onClose: () => Navigator.of(ctx).pop(),
          onSave: (it) => Navigator.of(ctx).pop(it),
          onRemove: (id) => Navigator.of(ctx).pop(),
        ),
      ),
    ),
  );

  if (res == null) return null;

  // convert ProductItem back to PacketItemEntity
  final pickedProduct = products.firstWhere((p) => p.name == res.name,
      orElse: () => const ProductEntity());
  return PacketItemEntity(
    id: int.tryParse(res.id),
    productId: pickedProduct.id,
    qty: res.qty,
    subtotal: (res.qty * res.price) - res.discount,
    discount: res.discount,
  );
}

class _PacketItemManagementFormSheetState
    extends State<PacketItemManagementFormSheet> {
  late final NumberFormat _currency;

  @override
  void initState() {
    super.initState();
    _currency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    widget.controller.nameController.addListener(_onNameChange);
  }

  void _onNameChange() => setState(() {});
  @override
  void dispose() {
    widget.controller.nameController.removeListener(_onNameChange);
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.controller.value;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
                Expanded(
                  child: Text(
                    item.id.isNotEmpty ? 'Edit Item' : 'Tambah Item',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // subtotal header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Subtotal Item',
                          style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: 6),
                      Text('IDR', style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 6),
                      Text(
                        _currency.format(item.subtotal),
                        style: TextStyle(
                            fontSize: 28,
                            color: AppColors.sbOrange,
                            fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // form
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // product selector trigger
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(12)),
                      child:
                          const Icon(Icons.inventory_2, color: Colors.black45),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Produk',
                              style: Theme.of(context).textTheme.labelSmall),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              // delegate product picking to caller by closing sheet with no-op or via other UI
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 16),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: AppColors.gray200),
                                  borderRadius: BorderRadius.circular(16)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      item.name.isEmpty
                                          ? 'Pilih Produk...'
                                          : item.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: item.name.isEmpty
                                              ? Colors.black26
                                              : Colors.black87)),
                                  Icon(Icons.chevron_right,
                                      color: AppColors.sbBlue),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // qty & price
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.calculate, color: Colors.black45),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FloatingInput(
                        label: 'Jumlah (Qty)',
                        keyboardType: TextInputType.number,
                        controller: widget.controller.qtyController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FloatingInput(
                        label: 'Harga Satuan',
                        keyboardType: TextInputType.number,
                        controller: widget.controller.priceController,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // discount
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.label, color: Colors.black45),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FloatingInput(
                        label: 'Diskon Produk',
                        keyboardType: TextInputType.number,
                        controller: widget.controller.discountController,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                if (item.id.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      widget.onRemove?.call(item.id);
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('HAPUS ITEM',
                        style: TextStyle(color: Colors.red)),
                  ),

                const SizedBox(height: 6),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sbBlue),
                  onPressed:
                      widget.controller.nameController.text.trim().isEmpty
                          ? null
                          : () {
                              widget.controller.updateFromControllers();
                              widget.onSave(widget.controller.value);
                            },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      'Simpan Item',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
