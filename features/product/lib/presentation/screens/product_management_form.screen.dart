import 'package:core/core.dart';
import 'package:product/data/dummies/category.dummy.dart';
import 'package:product/presentation/providers/product.provider.dart';

class ProductFormSheet extends ConsumerWidget {
  const ProductFormSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(productManagementViewModelProvider.notifier);

    final name = notifier.draft.name ?? '';
    final price =
        notifier.draft.price != null ? notifier.draft.price!.toString() : '';
    final selectedCategory = notifier.draft.category?.name ??
        categories.firstWhere((c) => c.name != 'All').name;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom:
            // Handle Keyboard
            MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notifier.draft.id == null ? 'Tambah Produk Baru' : 'Edit Produk',
            style: const TextStyle(
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
                style: BorderStyle.solid,
                color: Colors.grey.shade300,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_outlined,
                  size: 32,
                  color: Colors.grey.shade400,
                ),
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
          const FormLabel('Nama Produk'),
          TextFormField(
            initialValue: name,
            onChanged: (v) => notifier.setDraftField('name', v),
            decoration: _inputDecor(hint: 'Contoh: Kopi Susu'),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FormLabel('Harga'),
                    TextFormField(
                      initialValue: price,
                      keyboardType: TextInputType.number,
                      onChanged: (v) => notifier.setDraftField(
                          'price', double.tryParse(v) ?? 0.0),
                      decoration: _inputDecor(hint: '0'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FormLabel('Kategori'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: selectedCategory,
                          items: categories
                              .where((c) => c.name != 'All')
                              .map(
                                (c) => DropdownMenuItem<String>(
                                  value: c.name,
                                  child: Text(
                                    c.name ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            final cat =
                                categories.firstWhere((c) => c.name == val);
                            notifier.setDraftField('category', cat);
                          },
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
                      borderRadius: BorderRadius.circular(12),
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
                  onPressed: () async {
                    await notifier.onSaveOrUpdate();
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sbBlue,
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

InputDecoration _inputDecor({required String hint}) => InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.all(12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.blue,
          width: 2,
        ),
      ),
    );

class FormLabel extends StatelessWidget {
  final String label;
  const FormLabel(this.label, {super.key});

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
