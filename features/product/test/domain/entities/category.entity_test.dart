import 'package:flutter_test/flutter_test.dart';
import 'package:product/domain/entities/category.entity.dart';

void main() {
  group('CategoryEntity', () {
    test('copyWith harus memperbarui field yang ditentukan', () {
      const category = CategoryEntity(id: 1, name: 'Kategori A');
      final updated = category.copyWith(name: 'Kategori B');

      expect(updated.id, 1);
      expect(updated.name, 'Kategori B');
    });

    test('operator == harus membandingkan nilai', () {
      const c1 = CategoryEntity(id: 1, name: 'Kategori A');
      const c2 = CategoryEntity(id: 1, name: 'Kategori A');
      
      expect(c1 == c2, true);
    });
  });
}
