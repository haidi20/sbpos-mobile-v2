// Controller helpers for Packet Management Form
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product/domain/entities/packet_item.entity.dart';
import 'package:product/presentation/sheets/packet_item_management_form.sheet.dart';

class PacketManagementFormController {
  PacketManagementFormController(this.ref);

  final WidgetRef ref;

  Future<void> openEditSheet({
    required BuildContext context,
    PacketItemEntity? item,
    int? index,
  }) async {
    if (!Navigator.of(context).mounted) return;
    await showPacketItemManagementSheet(
      context,
      item ?? PacketItemEntity(),
      index: index,
    );
  }
}
