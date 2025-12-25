import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/domain/entities/packet_item.entity.dart';
import 'package:product/presentation/controllers/packet_management.controller.dart';

void main() {
  testWidgets('computeItemSubtotal calculates correctly and clamps at 0',
      (tester) async {
    PacketManagementController? controller;

    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Consumer(builder: (context, ref, _) {
          controller = PacketManagementController(ref);
          return const SizedBox.shrink();
        }),
      ),
    ));

    expect(controller, isNotNull);

    // setup product with price 1000
    controller!.products.value = const [
      ProductEntity(id: 1, price: 1000.0),
    ];

    final subtotal =
        controller!.computeItemSubtotal(productId: 1, qty: 2, discount: 500);
    expect(subtotal, 1500); // (1000 * 2) - 500

    // discount greater than price*qty should clamp to 0
    final clamped =
        controller!.computeItemSubtotal(productId: 1, qty: 1, discount: 2000);
    expect(clamped, 0);
  });

  testWidgets(
      'computeTotal sums items, adds basePrice and applies packet discount',
      (tester) async {
    PacketManagementController? controller;

    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: Consumer(builder: (context, ref, _) {
          controller = PacketManagementController(ref);
          return const SizedBox.shrink();
        }),
      ),
    ));

    expect(controller, isNotNull);

    // product with price 1000
    controller!.products.value = const [ProductEntity(id: 1, price: 1000.0)];

    // one item without override subtotal: price*qty = 2000
    final items = [PacketItemEntity(productId: 1, qty: 2)];

    // set base price
    controller!.priceCtrl.text = '500';

    // no packet discount
    controller!.applyPacketDiscount = false;
    controller!.packetDiscountCtrl.text = '0';

    final total = controller!.computeTotal(items);
    expect(total, 2500); // 2000 + 500

    // enable packet discount
    controller!.applyPacketDiscount = true;
    controller!.packetDiscountCtrl.text = '1000';
    final totalAfterDisc = controller!.computeTotal(items);
    expect(totalAfterDisc, 1500); // 2500 - 1000

    // discount bigger than total clamps to 0
    controller!.packetDiscountCtrl.text = '999999';
    final clamped = controller!.computeTotal(items);
    expect(clamped, 0);
  });
}
