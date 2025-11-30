import 'package:core/core.dart';
import 'package:product/data/data/product_data.dart';
import 'package:product/data/model/cart_model.dart';
import 'package:product/data/model/product_model.dart';

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

  // Colors
  final Color sbBlue = const Color(0xFF1E40AF);
  final Color sbOrange = const Color(0xFFF97316);
  final Color sbBg = const Color(0xFFF8FAFC);

  // Filter Logic
  List<ProductModel> get _filteredProducts {
    return _products
        .where((p) => _activeCategory == "All" || p.category == _activeCategory)
        .toList();
  }

  // Show Add/Edit Modal
  void _showProductForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar keyboard tidak menutupi form
      backgroundColor: Colors.transparent,
      builder: (context) => _ProductFormSheet(sbBlue: sbBlue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sbBg,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER (Sticky) ---
            Container(
              color: sbBg,
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
                          backgroundColor: sbBlue,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: Colors.blue.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
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
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),

                      // Agar scroll terasa mulus (opsional: BouncingScrollPhysics untuk efek iOS)
                      physics: const BouncingScrollPhysics(),

                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isActive = _activeCategory == cat;

                        return InkWell(
                          onTap: () => setState(() => _activeCategory = cat),
                          borderRadius: BorderRadius.circular(8),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isActive ? sbBlue : Colors.transparent,
                                width:
                                    1.5, // Sedikit ditebalkan agar border lebih jelas
                              ),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: sbBlue.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : [],
                            ),
                            alignment:
                                Alignment.center, // Pastikan teks di tengah
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isActive ? sbBlue : Colors.grey.shade500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // --- PRODUCT LIST ---
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredProducts.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];
                  final isActive = product.status == 'active';
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 5. WIDGETS ---

class _ProductFormSheet extends StatelessWidget {
  final Color sbBlue;

  const _ProductFormSheet({required this.sbBlue});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            24,
          ),
        ),
      ),
      padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom:
              MediaQuery.of(context).viewInsets.bottom + 24 // Handle Keyboard
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tambah Produk Baru',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          // Image Upload Placeholder
          Container(
            width: double.infinity,
            height: 128,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle
                      .solid), // Dashed border not native, solid used
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined,
                    size: 32, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text(
                  'Upload Foto',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Inputs
          const _FormLabel('Nama Produk'),
          const _FormInput(hint: 'Contoh: Kopi Susu'),

          const SizedBox(height: 16),

          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FormLabel('Harga'),
                    _FormInput(hint: '0', isNumber: true),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FormLabel('Kategori'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: 'Coffee',
                          items: categories
                              .where((c) => c != 'All')
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    c,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    foregroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sbBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                    elevation: 4,
                    shadowColor: Colors.blue.withOpacity(0.4),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String label;
  const _FormLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }
}

class _FormInput extends StatelessWidget {
  final String hint;
  final bool isNumber;

  const _FormInput({required this.hint, this.isNumber = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 2,
          ),
        ),
      ),
    );
  }
}
