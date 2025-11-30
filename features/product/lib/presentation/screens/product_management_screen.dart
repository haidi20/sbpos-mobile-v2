import 'package:core/core.dart';
import 'package:product/data/data/product_data.dart';
import 'package:product/data/data/category_data.dart';
import 'package:product/data/models/product_model.dart';
import 'package:product/presentation/components/product_management_card.dart';
import 'package:product/presentation/screens/product_management_form_screen.dart';

// --- 4. MAIN SCREEN ---

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  // State
  String _activeCategory = "All";
  final List<ProductModel> _products = List.from(initialProducts);

  // Filter Logic
  List<ProductModel> get _filteredProducts {
    return _products.where((p) {
      if (_activeCategory == "All") return true;
      final name = p.category?.name ?? '';
      return name == _activeCategory;
    }).toList();
  }

  // Show Add/Edit Modal
  void _showProductForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar keyboard tidak menutupi form
      backgroundColor: Colors.transparent,
      builder: (context) => const ProductFormSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sbBg,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER (Sticky) ---
            _buildHeader(),
            // --- PRODUCT LIST ---
            _buildProductList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                onPressed: () => _showProductForm(context),
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
          // Bungkus dengan SizedBox atau Container yang memiliki height pasti
          // karena ListView horizontal membutuhkan height constraint.
          SizedBox(
            height: 40, // Sesuaikan tinggi chip/tab
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              // Padding untuk awal dan akhir list (agar tidak mepet layar)
              padding: const EdgeInsets.symmetric(horizontal: 16),

              // Memberikan jarak antar item secara otomatis
              separatorBuilder: (context, index) => const SizedBox(width: 8),

              // Agar scroll terasa mulus (opsional: BouncingScrollPhysics untuk efek iOS)
              physics: const BouncingScrollPhysics(),

              itemBuilder: (context, index) {
                final cat = categories[index];
                final catName = cat.name ?? 'All';
                final isActive = _activeCategory == catName;

                return InkWell(
                  onTap: () => setState(() => _activeCategory = catName),
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
                        width:
                            1.5, // Sedikit ditebalkan agar border lebih jelas
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
                    alignment: Alignment.center, // Pastikan teks di tengah
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

  Widget _buildProductList() {
    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredProducts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
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
