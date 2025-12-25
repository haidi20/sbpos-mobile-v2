// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/utils/theme.dart';
import 'package:product/domain/entities/packet_item.entity.dart';
import 'package:product/presentation/widgets/floating_input.widget.dart';
import 'package:product/presentation/controllers/packet_item_management_form.controller.dart';
// product provider moved into product.sheet; not needed here
import 'package:product/presentation/providers/packet.provider.dart';
import 'package:product/presentation/sheets/product.sheet.dart';

// Sheet now interacts directly with PacketManagementViewModel for draft
// add/update/remove. No external callbacks required.

class PacketItemManagementFormSheet extends ConsumerStatefulWidget {
  const PacketItemManagementFormSheet({
    super.key,
    required this.onClose,
    required this.controller,
    this.index,
  });

  final VoidCallback onClose;
  final PacketItemManagementFormController controller;
  final int? index; // index in draft items, null = new item

  @override
  ConsumerState<PacketItemManagementFormSheet> createState() =>
      _PacketItemManagementFormSheetState();
}

/// Show the packet item management sheet and return an updated
/// [PacketItemEntity] or `null` if cancelled.
Future<void> showPacketItemManagementSheet(
  BuildContext context,
  PacketItemEntity item, {
  int? index,
}) async {
  final controller = PacketItemManagementFormController(initial: item);
  controller.nameController.text = item.productName?.toString() ?? '';
  controller.qtyController.text = (item.qty ?? 1).toString();
  controller.priceController.text = (item.subtotal ?? 0).toString();
  controller.discountController.text = (item.discount ?? 0).toString();

  await showModalBottomSheet<PacketItemEntity?>(
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
          index: index,
        ),
      ),
    ),
  );
  // sheet performs VM updates internally; no value returned.
  return;
}

class _PacketItemManagementFormSheetState
    extends ConsumerState<PacketItemManagementFormSheet> {
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
    final controller = widget.controller;
    final item = controller.value;

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
                    (item.id != null) ? 'Edit Item' : 'Tambah Item',
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
                        _currency.format(item.subtotal ?? 0),
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
                              // show product picker (fetching handled inside the sheet)
                              final selected =
                                  await showProductSelectionSheet(context);
                              if (selected == null) return;
                              if (!mounted) return;
                              widget.controller.nameController.text =
                                  selected.name ?? '';
                              widget.controller.priceController.text =
                                  (selected.price?.toInt() ?? 0).toString();
                              widget.controller.updateFromControllers(
                                  productId: selected.id);
                              setState(() {});
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
                                      controller.nameController.text.isEmpty
                                          ? 'Pilih Produk...'
                                          : controller.nameController.text,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: controller
                                                  .nameController.text.isEmpty
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

                if (item.id != null)
                  TextButton.icon(
                    onPressed: () {
                      // remove via VM when editing existing draft item
                      final vm =
                          ref.read(packetManagementViewModelProvider.notifier);
                      if (widget.index != null) {
                        vm.removeDraftItemAt(widget.index!);
                      }
                      Navigator.of(context).maybePop();
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('HAPUS ITEM',
                        style: TextStyle(color: Colors.red)),
                  ),

                const SizedBox(height: 6),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sbBlue),
                  onPressed: widget.controller.nameController.text
                          .trim()
                          .isEmpty
                      ? null
                      : () {
                          final vm = ref
                              .read(packetManagementViewModelProvider.notifier);
                          widget.controller.updateFromControllers();
                          final value = widget.controller.value;
                          if (widget.index != null) {
                            vm.updateDraftItemAt(widget.index!, value);
                          } else {
                            vm.addDraftItem(value);
                          }
                          Navigator.of(context).maybePop();
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
