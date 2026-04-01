import 'package:flutter_test/flutter_test.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/domain/entities/category.entity.dart';

void main() {
  group('ProductEntity', () {
    test('copyWith harus memperbarui field yang ditentukan', () {
      const product = ProductEntity(id: 1, name: 'Produk A');
      final updated = product.copyWith(name: 'Produk B');

      expect(updated.id, 1);
      expect(updated.name, 'Produk B');
    });

    test('operator == harus membandingkan nilai, bukan referensi', () {
      const p1 = ProductEntity(id: 1, name: 'Produk A');
      const p2 = ProductEntity(id: 1, name: 'Produk A');
      const p3 = ProductEntity(id: 2, name: 'Produk A');

      expect(p1 == p2, true);
      expect(p1 == p3, false);
    });

    test('hashCode harus sama untuk objek dengan nilai yang sama', () {
      const p1 = ProductEntity(id: 1, name: 'Produk A');
      const p2 = ProductEntity(id: 1, name: 'Produk A');

      expect(p1.hashCode, p2.hashCode);
    });

    test('harus mendukung category sebagai nested entity', () {
      const category = CategoryEntity(id: 10, name: 'Kategori X');
      const product = ProductEntity(id: 1, name: 'Produk A', category: category);

      expect(product.category?.name, 'Kategori X');
    });
  });
}
