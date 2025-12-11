import 'package:core/core.dart';
import 'package:customer/domain/entities/customer.entity.dart';
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

  Future<void> handleDeleteCustomer(
    BuildContext context,
    CustomerEntity customer,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Hapus pelanggan\n\n${customer.name ?? '-'}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                final ok = await _vm.onDeleteCustomerById(customer.id);
                if (!context.mounted) return;
                if (ok) {
                  showSuccessSnackBar(
                    context,
                    'Pelanggan berhasil dihapus',
                  );
                } else {
                  showErrorSnackBar(
                    context,
                    'Gagal menghapus pelanggan',
                  );
                }
              },
              child: const Text(
                'Hapus',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> confirmAndDelete({
    required BuildContext context,
    required CustomerViewModel vm,
    required CustomerEntity customer,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Hapus pelanggan\n\n${customer.name ?? '-'}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                final ok = await vm.onDeleteCustomerById(customer.id);
                if (!context.mounted) return;
                if (ok) {
                  showSuccessSnackBar(context, 'Pelanggan berhasil dihapus');
                } else {
                  showErrorSnackBar(context, 'Gagal menghapus pelanggan');
                }
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
