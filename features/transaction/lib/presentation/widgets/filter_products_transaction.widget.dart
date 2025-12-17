import 'package:core/core.dart';

class FilterResult {
  final bool includePacket;
  final String? categoryName;

  FilterResult({required this.includePacket, this.categoryName});
}

Future<FilterResult?> showFilterProductsPopup(
  BuildContext context, {
  required List<String> categories,
  bool initialIncludePacket = false,
  String? initialCategoryName,
}) {
  return showDialog<FilterResult>(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _FilterPopupContent(
            categories: categories,
            initialIncludePacket: initialIncludePacket,
            initialCategoryName: initialCategoryName,
          ),
        ),
      );
    },
  );
}

class _FilterPopupContent extends StatefulWidget {
  final List<String> categories;
  final bool initialIncludePacket;
  final String? initialCategoryName;

  const _FilterPopupContent({
    required this.categories,
    this.initialIncludePacket = false,
    this.initialCategoryName,
  });

  @override
  State<_FilterPopupContent> createState() => _FilterPopupContentState();
}

class _FilterPopupContentState extends State<_FilterPopupContent> {
  late bool includePacket;
  String? selectedCategoryName;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    includePacket = widget.initialIncludePacket;
    selectedCategoryName = widget.initialCategoryName ?? 'All';
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allCats = widget.categories;
    final query = _searchCtrl.text.toLowerCase();
    final filtered = query.isEmpty
        ? allCats
        : allCats.where((c) => c.toLowerCase().contains(query)).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Filter Produk',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          value: includePacket,
          title: const Text('Packet'),
          subtitle: const Text('Tampilkan paket pada hasil pencarian'),
          onChanged: (v) => setState(() => includePacket = v ?? false),
        ),
        const SizedBox(height: 8),
        const Text('Kategori produk',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: 'Cari kategori...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final name = filtered[index];
              final isSelected = name == selectedCategoryName;
              return ListTile(
                title: Text(name),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColors.sbBlue)
                    : null,
                onTap: () => setState(() => selectedCategoryName = name),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Batal'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final pickedCat = widget.categories.firstWhere(
                      (c) => c == selectedCategoryName,
                      orElse: () => widget.categories.first);
                  Navigator.of(context).pop(FilterResult(
                      includePacket: includePacket, categoryName: pickedCat));
                },
                child: const Text('Terapkan'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
