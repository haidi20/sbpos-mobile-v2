import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:product/presentation/controllers/product_management.controller.dart';
import 'package:product/presentation/view_models/product_management.vm.dart';
import 'package:product/presentation/providers/product.provider.dart';
import 'package:product/domain/entities/product.entity.dart';

class MockWidgetRef extends Mock implements WidgetRef {}
class MockProductManagementViewModel extends Mock implements ProductManagementViewModel {}

void main() {
  late MockWidgetRef mockRef;
  late MockProductManagementViewModel mockVM;

  setUp(() {
    mockRef = MockWidgetRef();
    mockVM = MockProductManagementViewModel();
    
    when(() => mockRef.read(productManagementViewModelProvider.notifier)).thenReturn(mockVM);
  });

  testWidgets('populateFromDraft harus mengisi text controller dari VM draft', (tester) async {
    const draft = ProductEntity(name: 'Kopi', price: 15000.0);
    when(() => mockVM.draft).thenReturn(draft);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) {
          final controller = ProductManagementController(mockRef, context);
          controller.populateFromDraft();
          
          expect(controller.nameController.text, 'Kopi');
          expect(controller.priceController.text, '15000.0');
          
          return const SizedBox.shrink();
        }),
      ),
    ));
  });

  testWidgets('saveFromForm harus memanggil onSaveOrUpdate pada VM', (tester) async {
    when(() => mockVM.onSaveOrUpdate()).thenAnswer((_) async => {});
    when(() => mockVM.draft).thenReturn(const ProductEntity());
    when(() => mockVM.setDraftField(any(), any())).thenReturn(null);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) {
          final controller = ProductManagementController(mockRef, context);
          controller.nameController.text = 'Produk X';
          controller.priceController.text = '100.0';
          
          controller.saveFromForm();
          
          verify(() => mockVM.setDraftField('name', 'Produk X')).called(1);
          verify(() => mockVM.onSaveOrUpdate()).called(1);
          
          return const SizedBox.shrink();
        }),
      ),
    ));
  });
}
