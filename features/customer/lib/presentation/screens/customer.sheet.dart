import 'package:core/core.dart';
import 'package:customer/presentation/providers/customer.providers.dart';
import 'package:customer/presentation/screens/customer_list.screen.dart';
import 'package:customer/presentation/screens/customer_form.screen.dart';

class CustomerSheet {
  static void openCustomerPicker(
    BuildContext context,
    void Function(dynamic customerEntity) setCustomer,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.gray100,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.95,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Consumer(
              builder: (context, ref, __) {
                final state = ref.watch(customerViewModelProvider);
                final vm = ref.read(customerViewModelProvider.notifier);

                if (state.isAdding) {
                  // Show form with a back button to return to list
                  return Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 48,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.gray300,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: vm.cancelAdd,
                              tooltip: 'Kembali',
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Pelanggan Baru',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: const CustomerFormScreen(),
                        ),
                      ),
                    ],
                  );
                }
                // Default: show list
                return CustomerListScreen(
                  scrollController: scrollController,
                  setCustomer: setCustomer,
                );
              },
            );
          },
        );
      },
    );
  }
}
