import 'package:core/core.dart';
import 'package:customer/presentation/view_models/customer.vm.dart';
import 'package:customer/presentation/providers/customer.providers.dart';

/// Controller to manage TextEditingControllers for the customer module
/// - Form draft (name, phone, email, note)
/// - Optional search field for the list
class CustomerFormController {
  CustomerFormController(this.ref, this.context)
      : _vm = ref.read(customerViewModelProvider.notifier);

  final WidgetRef ref;
  final BuildContext context;
  final CustomerViewModel _vm;

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

    // Bind changes back into the ViewModel draft
    nameController.addListener(() {
      _vm.updateDraft('name', nameController.text);
    });
    phoneController.addListener(() {
      _vm.updateDraft('phone', phoneController.text);
    });
    emailController.addListener(() {
      _vm.updateDraft('email', emailController.text);
    });
    noteController.addListener(() {
      _vm.updateDraft('note', noteController.text);
    });

    // Initialize and hook up search controller if used by caller
    final currentSearch = ref.read(customerViewModelProvider).searchQuery;
    if (currentSearch.isNotEmpty) {
      searchController.text = currentSearch;
    }
    searchController.addListener(() {
      _vm.setSearchQuery(searchController.text);
    });
  }

  Future<void> saveAndClose() async {
    await _vm.handleSaveNewCustomer();
    if (context.mounted) Navigator.of(context).pop();
  }

  void cancel() {
    _vm.cancelAdd();
  }

  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    noteController.dispose();
    searchController.dispose();
  }
}
