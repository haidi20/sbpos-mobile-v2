// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:core/utils/theme.dart';
import 'package:intl/intl.dart';
import '../controllers/packet_item_management_form.controller.dart';

typedef OnEditItem = void Function(ProductItem item);

class ProductListWidget extends StatelessWidget {
  const ProductListWidget(
      {super.key, required this.items, required this.onEdit});

  final List<ProductItem> items;
  final OnEditItem onEdit;

  @override
  Widget build(BuildContext context) {
    final fmt =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Center(
          child: const Text('Keranjang masih kosong',
              style: TextStyle(
                  color: AppColors.gray400, fontWeight: FontWeight.w600)),
        ),
      );
    }

    return Column(
      children: items.map((it) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: InkWell(
            onTap: () => onEdit(it),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(it.name.isEmpty ? 'Pilih Produk' : it.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        '${it.qty}x • ${fmt.format(it.price)}${it.discount > 0 ? ' (-${fmt.format(it.discount)})' : ''}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.gray500,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(fmt.format(it.subtotal),
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.sbBlue)),
                      const SizedBox(height: 6),
                      const Text('KLIK UNTUK EDIT',
                          style: TextStyle(
                              fontSize: 10,
                              color: AppColors.gray300,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
