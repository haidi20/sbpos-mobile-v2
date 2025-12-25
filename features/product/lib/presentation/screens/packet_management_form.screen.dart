// ignore_for_file: prefer_const_constructors, unused_element

import 'package:flutter/material.dart';
import 'package:core/utils/theme.dart';
import '../controllers/packet_item_management_form.controller.dart';
import '../sheets/packet_item_management_form.sheet.dart';
import '../sheets/product.sheet.dart';
import '../widgets/product_list.widget.dart';

class PacketManagementFormScreen extends StatefulWidget {
  final int? packetId;
  const PacketManagementFormScreen({super.key, this.packetId});

  @override
  State<PacketManagementFormScreen> createState() =>
      _PacketManagementFormScreenState();
}

class _PacketManagementFormScreenState
    extends State<PacketManagementFormScreen> {
  String name = 'Paket Sarapan';
  List<ProductItem> items = [
    ProductItem(id: '1', name: 'Kopi Susu', qty: 1, price: 10000),
    ProductItem(id: '2', name: 'Nasi Kuning', qty: 1, price: 15000),
  ];

  int basePrice = 25000;
  bool isActive = true;
  bool applyPacketDiscount = false;
  int packetDiscount = 0;

  PacketItemManagementFormController? _editingController;

  int calculateTotal() {
    var itemsTotal = items.fold<int>(
        0, (acc, it) => acc + (it.qty * it.price) - it.discount);
    var finalTotal =
        applyPacketDiscount ? itemsTotal - packetDiscount : itemsTotal;
    finalTotal += basePrice;
    return finalTotal.clamp(0, 1 << 31);
  }

  void _openEditSheet({ProductItem? item}) {
    _editingController = PacketItemManagementFormController(initial: item);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        expand: false,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
          child: PacketItemManagementFormSheet(
            controller: _editingController!,
            onClose: () {
              Navigator.of(ctx).pop();
            },
            onSave: (it) {
              setState(() {
                final exists = items.indexWhere((e) => e.id == it.id);
                if (exists >= 0) {
                  items[exists] = it;
                } else {
                  items.add(it);
                }
              });
              Navigator.of(ctx).pop();
            },
            onRemove: (id) {
              setState(() => items.removeWhere((e) => e.id == id));
              Navigator.of(ctx).pop();
            },
          ),
        ),
      ),
    );
  }

  void _openProductPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
          child: ProductPickerSheet(
              initialSelected: _editingController?.nameController.text,
              onPick: (namePicked) {
                // assign into editing controller if present
                if (_editingController != null) {
                  _editingController!.nameController.text = namePicked;
                }
                Navigator.of(ctx).pop();
              }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sbBg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoSection(
                      name: name,
                      isActive: isActive,
                      onNameChanged: (v) => setState(() => name = v),
                      onToggleActive: () =>
                          setState(() => isActive = !isActive),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Item Produk',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        TextButton.icon(
                          onPressed: () => _openEditSheet(),
                          icon: const Icon(Icons.add, color: AppColors.sbBlue),
                          label: const Text('TAMBAH ITEM',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.sbBlue)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ProductListWidget(
                        items: items, onEdit: (it) => _openEditSheet(item: it)),
                    const SizedBox(height: 22),
                    Text('Konfigurasi Harga',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  labelText: 'Harga Dasar Paket'),
                              controller: TextEditingController(
                                  text: basePrice.toString()),
                              onChanged: (v) => setState(
                                  () => basePrice = int.tryParse(v) ?? 0),
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            title: const Text('Gunakan Diskon Paket',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            trailing: Switch(
                                value: applyPacketDiscount,
                                onChanged: (v) =>
                                    setState(() => applyPacketDiscount = v)),
                          ),
                          if (applyPacketDiscount)
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: 'Nominal Diskon'),
                                controller: TextEditingController(
                                    text: packetDiscount.toString()),
                                onChanged: (v) => setState(() =>
                                    packetDiscount = int.tryParse(v) ?? 0),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SummaryCard(total: calculateTotal()),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
            _BottomBar(onSave: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Disimpan ke Livin Dashboard')));
            }),
          ],
        ),
      ),
      floatingActionButton: _editingController == null
          ? null
          : FloatingActionButton(
              onPressed: _openProductPicker,
              backgroundColor: AppColors.sbBlue,
              child: const Icon(Icons.search),
            ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: AppColors.gray200))),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: onBack),
          const Expanded(
              child: Center(
                  child: Text('Edit Paket',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)))),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection(
      {super.key,
      required this.name,
      required this.isActive,
      required this.onNameChanged,
      required this.onToggleActive});
  final String name;
  final bool isActive;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Info Utama',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Text(isActive ? 'AKTIF' : 'NONAKTIF',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Switch(value: isActive, onChanged: (_) => onToggleActive()),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
              labelText: 'Nama Paket',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white),
          controller: TextEditingController(text: name),
          onChanged: onNameChanged,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({super.key, required this.total});
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppColors.sbBlue, AppColors.sbBlue700]),
          borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(6))),
          const SizedBox(height: 12),
          const Text('Total Harga Paket',
              style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          const SizedBox(height: 8),
          Text('Rp $total',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Sudah termasuk pajak & diskon',
              style: TextStyle(
                  color: Colors.white70, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({super.key, required this.onSave});
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          border: Border(top: BorderSide(color: AppColors.gray200))),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sbBlue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16))),
          onPressed: onSave,
          child: const Text('Simpan Data',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        ),
      ),
    );
  }
}
