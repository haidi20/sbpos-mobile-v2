import 'package:core/core.dart';
import 'package:product/data/dummies/category.dummy.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/presentation/components/product_management.card.dart';
import 'package:product/presentation/providers/product.provider.dart';
import 'package:product/presentation/controllers/product_management.controller.dart';

// --- 4. MAIN SCREEN ---

class ProductManagementScreen extends ConsumerStatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  ConsumerState<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState
    extends ConsumerState<ProductManagementScreen> {
  // initialProducts is a list of ProductEntity; convert to ProductEntity
  // initialProducts removed; use viewmodel state

  // Filter Logic is based on viewmodel products (see getter below)

  // UI-only: controller handles modal and actions.

  @override
  Widget build(BuildContext context) {
    final controller = ProductManagementController(ref, context);
    final vmState = ref.watch(productManagementViewModelProvider);
    return Scaffold(
      backgroundColor: AppColors.sbBg,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER (Sticky) ---
            _ProductManagementHeader(
              activeCategory: vmState.activeCategory,
              onCategoryChanged: (v) => controller.setActiveCategory(v),
              onAddPressed: () => controller.showProductForm(),
            ),
            // --- PRODUCT LIST ---
            _ProductListWidget(products: _filteredProducts),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ProductManagementController(ref, context);
      controller.loadProducts();
    });
  }

  List<ProductEntity> get _filteredProducts {
    final vm = ref.watch(productManagementViewModelProvider.notifier);
    return vm.filteredProducts;
  }
}

class _ProductManagementHeader extends StatelessWidget {
  final String activeCategory;
  final ValueChanged<String> onCategoryChanged;
  final VoidCallback onAddPressed;

  const _ProductManagementHeader({
    required this.activeCategory,
    required this.onCategoryChanged,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.sbBg,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          // Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              const Text(
                'Daftar Menu',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              ElevatedButton.icon(
                onPressed: onAddPressed,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sbBlue,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shadowColor: Colors.blue.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Categories Row
          SizedBox(
            height: 40, // Sesuaikan tinggi chip/tab
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final catName = cat.name ?? 'All';
                final isActive = activeCategory == catName;

                return InkWell(
                  onTap: () => onCategoryChanged(catName),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isActive ? AppColors.sbBlue : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.sbBlue.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : [],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      catName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            isActive ? AppColors.sbBlue : Colors.grey.shade500,
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

class _ProductListWidget extends StatelessWidget {
  final List<ProductEntity> products;
  const _ProductListWidget({required this.products});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final product = products[index];
          final isActive = product.isActive ?? false;

          return ProductManagementCard(
            product: product,
            isActive: isActive,
          );
        },
      ),
    );
  }
}
