// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:core/utils/theme.dart';

typedef OnProductPicked = void Function(String name);

class ProductPickerSheet extends StatefulWidget {
  const ProductPickerSheet(
      {super.key, required this.onPick, this.initialSelected});

  final OnProductPicked onPick;
  final String? initialSelected;

  @override
  State<ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<ProductPickerSheet> {
  final _masterProducts = const [
    'Kopi Susu',
    'Nasi Kuning',
    'Kopi Hitam',
    'Roti Bakar',
    'Bubur Ayam',
    'Es Teh Manis',
    'Lontong Sayur',
    'Nasi Uduk',
    'Soto Ayam',
    'Gorengan Mix'
  ];

  String _query = '';
  String? _selected;

  List<String> get _filtered => _masterProducts
      .where((p) => p.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    _selected ??= widget.initialSelected;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Cari produk...'),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text('Produk tidak ditemukan',
                        style: TextStyle(color: AppColors.gray500)))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final p = _filtered[idx];
                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            widget.onPick(p);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(p,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: AppColors.gray200),
                                      shape: BoxShape.circle),
                                  child: _selected == p
                                      ? Container(
                                          margin: const EdgeInsets.all(5),
                                          decoration: const BoxDecoration(
                                              color: AppColors.sbBlue,
                                              shape: BoxShape.circle))
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Helper to show a product selection sheet from a list of product entities.
/// Returns the selected product id or `null` if cancelled.
Future<int?> showProductSelectionSheet(
    BuildContext context, List<dynamic> products) async {
  // `products` is expected to be a list of objects with `id` and `name`.
  final result = await showModalBottomSheet<int>(
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
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Cari produk...'),
                        onChanged: (_) {},
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final p = products[idx];
                    final name = (p?.name ?? p?.toString() ?? '') as String;
                    final id = (p?.id ?? p) as int?;
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.of(context).pop(id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                      border:
                                          Border.all(color: AppColors.gray200),
                                      shape: BoxShape.circle)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return result;
}
