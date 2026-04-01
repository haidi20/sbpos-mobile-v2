import 'package:flutter_test/flutter_test.dart';
import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/domain/entities/packet_item.entity.dart';

void main() {
  group('PacketItemEntity', () {
    test('unitPrice harus dihitung dengan benar dari subtotal dan qty', () {
      final item = PacketItemEntity(qty: 2, subtotal: 20000);
      expect(item.unitPrice, 10000);
    });

    test('displayLabel harus memformat mata uang rupiah dengan benar', () {
      final item = PacketItemEntity(
        productName: 'Kopi',
        qty: 1,
        subtotal: 15000,
        discount: 2000,
      );
      // Format: '1x • Rp 15.000 (-Rp 2.000)'
      expect(item.displayLabel, contains('1x • Rp 15.000'));
      expect(item.displayLabel, contains('-Rp 2.000'));
    });

    test('hasDiscount harus true jika ada diskon', () {
      final itemWithDisc = PacketItemEntity(discount: 500);
      final itemNoDisc = PacketItemEntity(discount: 0);
      
      expect(itemWithDisc.hasDiscount, true);
      expect(itemNoDisc.hasDiscount, false);
    });
  });

  group('PacketEntity', () {
    test('copyWith harus mendukung pembaharuan list items', () {
      final item = PacketItemEntity(productName: 'Item 1');
      final packet = PacketEntity(name: 'Paket A', items: []);
      
      final updated = packet.copyWith(items: [item]);
      
      expect(updated.items?.length, 1);
      expect(updated.items?.first.productName, 'Item 1');
    });
  });
}
