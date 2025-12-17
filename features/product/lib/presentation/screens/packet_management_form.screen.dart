// ignore_for_file: prefer_const_constructors, unused_element

import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/domain/entities/packet_item.entity.dart';
import 'package:product/presentation/providers/packet.provider.dart';
import 'package:product/presentation/controllers/packet_management.controller.dart';

class PacketManagementFormScreen extends ConsumerStatefulWidget {
  final PacketEntity? packet;
  const PacketManagementFormScreen({super.key, this.packet});

  @override
  ConsumerState<PacketManagementFormScreen> createState() => _PacketFormState();
}

class _PacketFormState extends ConsumerState<PacketManagementFormScreen> {
  late final PacketManagementController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PacketManagementController(ref);
    _controller.init(widget.packet);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await _controller.save();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final vmNotifier = ref.read(packetManagementViewModelProvider.notifier);
    final state = ref.watch(packetManagementViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.packet == null ? 'Tambah Paket' : 'Edit Paket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _controller.formKey,
          child: _PacketFormBody(
            controller: _controller,
            state: state,
            notifier: vmNotifier,
            onSave: _save,
          ),
        ),
      ),
    );
  }
}

class _PacketFormBody extends StatelessWidget {
  final PacketManagementController controller;
  final dynamic state;
  final dynamic notifier;
  final VoidCallback onSave;

  const _PacketFormBody(
      {super.key,
      required this.controller,
      required this.state,
      required this.notifier,
      required this.onSave});

  @override
  Widget build(BuildContext context) {
    final itemCount = notifier.draft.items?.length ?? 0;

    return Column(
      children: [
        TextFormField(
          controller: controller.nameCtrl,
          decoration: const InputDecoration(labelText: 'Nama Paket'),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Nama wajib' : null,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child:
              Text('Isi Paket', style: Theme.of(context).textTheme.titleMedium),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (var i = 0; i < itemCount; i++)
                  _PacketItemRow(
                    index: i,
                    controller: controller,
                    notifier: notifier,
                  )
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                final newItem = PacketItemEntity(
                    productId: null, qty: 1, subtotal: 0, discount: 0);
                notifier.addDraftItem(newItem);
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Item'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller.priceCtrl,
          decoration: const InputDecoration(labelText: 'Harga'),
          keyboardType: TextInputType.number,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Harga wajib' : null,
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          value: controller.isActive,
          onChanged: (v) => controller.isActive = v,
          title: const Text('Aktif'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(
              value: controller.applyPacketDiscount,
              onChanged: (v) {
                controller.applyPacketDiscount = v ?? false;
              },
            ),
            const SizedBox(width: 8),
            const Text('Apply packet discount'),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: controller.packetDiscountCtrl,
                decoration: const InputDecoration(labelText: 'Packet Discount'),
                keyboardType: TextInputType.number,
                onChanged: (_) {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child:
              Text('Total: ${controller.computeTotal(notifier.draft.items)}'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: onSave,
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PacketItemRow extends StatelessWidget {
  final int index;
  final PacketManagementController controller;
  final dynamic notifier;

  const _PacketItemRow(
      {super.key,
      required this.index,
      required this.controller,
      required this.notifier});

  @override
  Widget build(BuildContext context) {
    final vm = notifier;
    final items = vm.draft.items ?? [];
    final item = items[index];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: ValueListenableBuilder<List<ProductEntity>>(
                valueListenable: controller.products,
                builder: (context, list, _) {
                  return DropdownButtonFormField<int?>(
                    value: item.productId,
                    items: [
                      const DropdownMenuItem<int?>(
                          value: null, child: Text('- Pilih produk -')),
                      ...list.map((p) => DropdownMenuItem<int?>(
                          value: p.id, child: Text(p.name ?? '-'))),
                    ],
                    onChanged: (val) async {
                      // When a product is selected, prompt for qty then update draft
                      final qtyCtrl = TextEditingController(
                          text: (item.qty ?? 1).toString());
                      final result = await showDialog<int>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Jumlah untuk produk'),
                          content: TextField(
                            controller: qtyCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            autofocus: true,
                            decoration: const InputDecoration(hintText: 'Qty'),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.of(ctx).pop(null),
                                child: const Text('Batal')),
                            ElevatedButton(
                                onPressed: () {
                                  var q = int.tryParse(qtyCtrl.text) ?? 1;
                                  if (q < 1) q = 1;
                                  Navigator.of(ctx).pop(q);
                                },
                                child: const Text('OK')),
                          ],
                        ),
                      );

                      if (result == null) return; // cancelled

                      final subtotal = controller.computeItemSubtotal(
                          productId: val,
                          qty: result < 1 ? 1 : result,
                          discount: item.discount ?? 0);
                      vm.updateDraftItemAt(
                        index,
                        item.copyWith(
                            productId: val,
                            qty: result,
                            subtotal: subtotal,
                            discount: item.discount ?? 0),
                      );
                    },
                    decoration: const InputDecoration(labelText: 'Produk'),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: (item.qty ?? 0).toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Qty'),
                onChanged: (v) {
                  final q = int.tryParse(v) ?? 0;
                  final subtotal = controller.computeItemSubtotal(
                      productId: item.productId,
                      qty: q,
                      discount: item.discount ?? 0);
                  vm.updateDraftItemAt(
                      index, item.copyWith(qty: q, subtotal: subtotal));
                },
              ),
            ),
            const SizedBox(width: 8),
            // price display
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: controller
                        .findProductById(item.productId)
                        ?.price
                        ?.toStringAsFixed(0) ??
                    '0',
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
            ),
            const SizedBox(width: 8),
            // per-item discount
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: (item.discount ?? 0).toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Discount'),
                onChanged: (v) {
                  final d = int.tryParse(v) ?? 0;
                  final subtotal = controller.computeItemSubtotal(
                      productId: item.productId,
                      qty: item.qty ?? 0,
                      discount: d);
                  vm.updateDraftItemAt(
                      index, item.copyWith(subtotal: subtotal, discount: d));
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: (item.subtotal ?? 0).toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Subtotal'),
                onChanged: (v) {
                  final s = int.tryParse(v) ?? 0;
                  vm.updateDraftItemAt(index, item.copyWith(subtotal: s));
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                vm.removeDraftItemAt(index);
              },
            ),
          ],
        ),
      ),
    );
  }
}
