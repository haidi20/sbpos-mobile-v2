// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:core/utils/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/presentation/providers/product.provider.dart';

class ProductPickerSheet extends ConsumerWidget {
  const ProductPickerSheet({
    super.key,
    this.initialSelected,
    required this.onClose,
    required this.queryController,
    required this.selectedNotifier,
  });

  final VoidCallback onClose;
  final String? initialSelected;
  final TextEditingController queryController;
  final ValueNotifier<String?> selectedNotifier;

  static Future<ProductEntity?> show(BuildContext context,
      {required TextEditingController queryController,
      required ValueNotifier<String?> selectedNotifier,
      String? initialSelected}) async {
    final resultId = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(18),
            ),
          ),
          child: SafeArea(
            child: ProductPickerSheet(
              initialSelected: initialSelected,
              queryController: queryController,
              selectedNotifier: selectedNotifier,
              onClose: () => Navigator.of(ctx).pop(),
            ),
          ),
        ),
      ),
    );

    if (resultId == null) return null;
    final container = ProviderScope.containerOf(context, listen: false);
    final state = container.read(productManagementViewModelProvider);

    ProductEntity? product;
    try {
      product = state.products.firstWhere((p) => p.id == resultId);
    } catch (_) {
      product = null;
    }

    return product;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productManagementViewModelProvider);
    final vm = ref.read(productManagementViewModelProvider.notifier);

    final products = state.products;

    if (products.isEmpty) {
      // Muat data secara fire-and-forget. Jangan pakai await di sini agar tidak menggunakan
      // `context` setelah jeda async — controller akan memperbarui state saat selesai.
      vm.getProducts();
    }
    return Column(
      children: [
        _ProductPickerHeader(
          queryController: queryController,
          onClose: onClose,
        ),
        Expanded(
          child: _ProductList(
            queryController: queryController,
            selectedNotifier: selectedNotifier,
          ),
        ),
      ],
    );
  }
}

/// Header with close button and search field.
class _ProductPickerHeader extends StatelessWidget {
  const _ProductPickerHeader({
    required this.queryController,
    required this.onClose,
  });

  final TextEditingController queryController;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close),
          ),
          Expanded(
            child: TextField(
              controller: queryController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// List wrapper that reads filtered products from providers.
class _ProductList extends ConsumerWidget {
  const _ProductList({
    required this.queryController,
    required this.selectedNotifier,
  });

  final TextEditingController queryController;
  final ValueNotifier<String?> selectedNotifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: queryController,
      builder: (_, val, __) {
        final q = val.text;
        final vm = ref.read(productManagementViewModelProvider.notifier);
        // update VM search query so filteredProducts reflects the query
        vm.setSearchQuery(q);
        final filtered = vm.filteredProducts;

        if (filtered.isEmpty) {
          return const Center(
            child: Text(
              'Produk tidak ditemukan',
              style: TextStyle(
                color: AppColors.gray500,
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final p = filtered[idx];
            return _ProductListItem(p: p, selectedNotifier: selectedNotifier);
          },
        );
      },
    );
  }
}

/// Single product row.
class _ProductListItem extends StatelessWidget {
  const _ProductListItem({required this.p, required this.selectedNotifier});

  final ProductEntity p;
  final ValueNotifier<String?> selectedNotifier;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).pop(p.id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                p.name ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.gray200),
                    shape: BoxShape.circle),
                child: ValueListenableBuilder<String?>(
                  valueListenable: selectedNotifier,
                  builder: (_, s, __) => s == p.name
                      ? Container(
                          margin: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.sbBlue,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
