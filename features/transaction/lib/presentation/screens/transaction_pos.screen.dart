import 'package:core/core.dart';
import 'package:product/data/dummies/product.data.dart';
import 'package:product/data/dummies/category.data.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/domain/entities/category.entity.dart';
import 'package:product/presentation/components/product_card.dart';
import 'package:transaction/presentation/view_models/transaction_pos.vm.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';
import 'package:transaction/presentation/controllers/transaction_pos.controller.dart';

class TransactionPosScreen extends ConsumerStatefulWidget {
  const TransactionPosScreen({super.key});

  @override
  ConsumerState<TransactionPosScreen> createState() =>
      _TransactionPosScreenState();
}

class _TransactionPosScreenState extends ConsumerState<TransactionPosScreen> {
  late TransactionPosController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TransactionPosController(ref, context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionPosViewModelProvider);
    final viewModel = ref.read(transactionPosViewModelProvider.notifier);

    final filteredProducts = initialProducts.where((p) {
      final matchesCategory = state.activeCategory == "All" ||
          (p.category?.name ?? '') == state.activeCategory;
      final searchQuery = state.searchQuery ?? '';
      final matchesSearch = searchQuery.isEmpty ||
          (p.name != null &&
              p.name!.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ));
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.sbBg,
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // --- HEADER SECTION ---
                  _buildHeader(
                    state: state,
                    viewModel: viewModel,
                  ),
                  // --- PRODUCT GRID ---
                  _buildProductList(
                    viewModel: viewModel,
                    filteredProducts: filteredProducts,
                  ),
                ],
              ),
              // --- FLOATING CART BUTTON ---
              _buildCartBottomButton(
                state: state,
                viewModel: viewModel,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required TransactionPosState state,
    required TransactionPosViewModel viewModel,
  }) {
    return Container(
      color: AppColors.sbBg,
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        children: [
          // Back Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  "POS Produk",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _controller.searchController,
              onChanged: (val) => viewModel.setSearchQuery(val),
              textInputAction: TextInputAction.search,
              // ✅ Tetap pertahankan onTapOutside sebagai cadangan
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: (state.searchQuery ?? '').isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _controller.searchController.clear();
                          viewModel.setSearchQuery("");
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.sbBlue.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Category List — ✅ onTap di sini sekarang otomatis unfocus TextField
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final CategoryEntity cat = categories[index];
                final catName = cat.name ?? 'All';
                final isActive = state.activeCategory == catName;
                return InkWell(
                  onTap: () {
                    viewModel.setActiveCategory(catName);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.sbBlue : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: isActive
                          ? null
                          : Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Text(
                        catName,
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.grey[700],
                          fontWeight:
                              isActive ? FontWeight.bold : FontWeight.normal,
                        ),
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

  Widget _buildProductList({
    required TransactionPosViewModel viewModel,
    required List<ProductEntity> filteredProducts,
  }) {
    return Expanded(
      child: filteredProducts.isEmpty
          ? const Center(child: Text("Produk tidak ditemukan"))
          : GridView.builder(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    viewModel.onAddToCart(product);
                  },
                );
              },
            ),
    );
  }

  Widget _buildCartBottomButton({
    required TransactionPosState state,
    required TransactionPosViewModel viewModel,
  }) {
    if (state.details.isNotEmpty) {
      return Positioned(
        bottom: 24,
        left: 16,
        right: 16,
        child: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            _controller.onShowCartSheet();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.sbBlue,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sbBlue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // --- BAGIAN KIRI (RESPONSIVE) ---
                Expanded(
                  child: Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(
                            Icons.shopping_cart_outlined, // Icon Relevan
                            color: Colors.white,
                            size: 30,
                          ),
                          // Badge Total Item di Atas Kanan Icon
                          Positioned(
                            right: -5,
                            top: -8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: AppColors.sbOrange, // Warna Badge
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.sbBlue,
                                  width: 1,
                                ),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Center(
                                child: Text(
                                  "${viewModel.getCartCount}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Total",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              viewModel.getCartTotal,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // --- BAGIAN KANAN (DITAMBAHKAN ICON & BADGE) ---
                const Row(
                  children: [
                    // Teks Asli
                    Text(
                      "Keranjang",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      size: 16,
                      color: Colors.white,
                      Icons.arrow_forward_ios,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
