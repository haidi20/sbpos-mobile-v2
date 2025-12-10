import 'package:core/core.dart';
import 'package:customer/presentation/view_models/customer.state.dart';
import 'package:customer/presentation/view_models/customer.vm.dart';
import 'package:customer/presentation/providers/customer.providers.dart';

class CustomerListController {
  CustomerListController(this.ref)
      : _vm = ref.read(customerViewModelProvider.notifier);

  final WidgetRef ref;
  final CustomerViewModel _vm;

  // Search box controller for list screen
  final TextEditingController searchController = TextEditingController();

  void init() {
    final state = ref.read(customerViewModelProvider);

    // Initialize from current state
    final currentSearch = state.searchQuery;
    if (currentSearch != null && currentSearch.isNotEmpty) {
      searchController.text = currentSearch;
    }

    // Push changes to ViewModel
    searchController.addListener(_onSearchChanged);

    // Keep controller text in sync if state changes externally
    ref.listen<CustomerState>(customerViewModelProvider, (prev, next) {
      final nextText = next.searchQuery ?? '';
      if (searchController.text != nextText) {
        searchController.value = TextEditingValue(
          text: nextText,
          selection: TextSelection.collapsed(offset: nextText.length),
        );
      }
    });
  }

  void _onSearchChanged() {
    _vm.setSearchQuery(searchController.text);
  }

  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
  }
}
