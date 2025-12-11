import 'package:core/core.dart';
import 'package:customer/presentation/providers/customer.providers.dart';
import 'package:customer/presentation/view_models/customer.state.dart';
import 'package:customer/presentation/view_models/customer.vm.dart';

/// Controller to manage TextEditingControllers for the customer module
/// - Form draft (name, phone, email, note)
/// - Optional search field for the list
class CustomerFormController {
  CustomerFormController(this.ref, this.context)
      : _vm = ref.read(customerViewModelProvider.notifier),
        _state = ref.read(customerViewModelProvider);

  final WidgetRef ref;
  final BuildContext context;
  final CustomerViewModel _vm;
  final CustomerState _state;

  // Text controllers for Add/Edit form
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
  late final TextEditingController noteController;

  // Optional: search box controller used in list screen
  final TextEditingController searchController = TextEditingController();

  void init() {
    final draft = _vm.draftCustomer;
    nameController = TextEditingController(text: draft.name ?? '');
    phoneController = TextEditingController(text: draft.phone ?? '');
    emailController = TextEditingController(text: draft.email ?? '');
    noteController = TextEditingController(text: draft.note ?? '');

    // Bind changes back into the ViewModel draft (set* naming)
    nameController.addListener(() {
      _vm.setDraftField('name', nameController.text);
    });
    phoneController.addListener(() {
      _vm.setDraftField('phone', phoneController.text);
    });
    emailController.addListener(() {
      _vm.setDraftField('email', emailController.text);
    });
    noteController.addListener(() {
      _vm.setDraftField('note', noteController.text);
    });

    // Initialize and hook up search controller if used by caller
    final currentSearch = _state.searchQuery;
    if (currentSearch != null && currentSearch.isNotEmpty) {
      searchController.text = currentSearch;
    }
    searchController.addListener(() {
      _vm.setSearchQuery(searchController.text);
    });
  }

  Future<void> saveAndClose() async {
    await _vm.onSaveOrUpdate();
    if (context.mounted) Navigator.of(context).pop();
  }

  void cancel() {
    _vm.setIsAdding(false);
  }

  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    noteController.dispose();
    searchController.dispose();
  }
}
