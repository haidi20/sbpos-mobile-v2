import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:core/utils/theme.dart';
import 'package:product/domain/entities/packet_item.entity.dart';

typedef OnEditItem = void Function(PacketItemEntity item);

class PacketItemCard extends StatelessWidget {
  const PacketItemCard({
    super.key,
    required this.onEdit,
    required this.packetItem,
  });

  final OnEditItem onEdit;
  final PacketItemEntity packetItem;

  @override
  Widget build(BuildContext context) {
    final fmt =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () => onEdit(packetItem),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(packetItem.productId?.toString() ?? 'Pilih Produk',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    packetItem.displayLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray500,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    fmt.format(packetItem.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.sbBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
