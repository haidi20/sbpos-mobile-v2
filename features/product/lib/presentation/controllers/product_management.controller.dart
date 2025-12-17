import 'package:core/core.dart';
import 'package:product/presentation/view_models/product_management.vm.dart';
import 'package:product/presentation/providers/product.provider.dart';
import 'package:product/presentation/screens/product_management_form.screen.dart';
import 'package:product/data/dummies/category.dummy.dart';

class ProductManagementController {
  ProductManagementController(this.ref, this.context);

  final WidgetRef ref;
  final BuildContext context;

  late final ProductManagementViewModel _vm =
      ref.read(productManagementViewModelProvider.notifier);

  // Form controllers (centralized)
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  String? selectedCategory;

  void loadProducts() => _vm.getProducts();

  void setActiveCategory(String cat) => _vm.setActiveCategory(cat);

  /// Populate controllers from current VM draft.
  void populateFromDraft() {
    final draft = _vm.draft;
    nameController.text = draft.name ?? '';
    priceController.text = draft.price?.toString() ?? '';
    selectedCategory = draft.category?.name;
  }

  /// Prepare VM draft from controller values.
  void populateDraftFromControllers() {
    _vm.setDraftField('name', nameController.text.trim());
    final price = double.tryParse(priceController.text) ?? 0.0;
    _vm.setDraftField('price', price);
    if (selectedCategory != null) {
      final cat = categories.firstWhere((c) => c.name == selectedCategory,
          orElse: () => categories.first);
      _vm.setDraftField('category', cat);
    }
  }

  Future<dynamic> showProductForm() {
    populateFromDraft();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductFormSheet(controller: this),
    );
  }

  Future<void> saveFromForm() async {
    populateDraftFromControllers();
    await _vm.onSaveOrUpdate();
  }

  void dispose() {
    nameController.dispose();
    priceController.dispose();
  }
}
