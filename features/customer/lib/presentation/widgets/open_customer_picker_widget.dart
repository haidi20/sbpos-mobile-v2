import 'package:core/core.dart';
import 'package:customer/presentation/providers/customer.providers.dart';

class OpenCustomerPickerWidget {
  static void openCustomerPicker(
    BuildContext context,
    void Function(dynamic customerEntity) setCustomer,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(customerViewModelProvider);
                final vm = ref.read(customerViewModelProvider.notifier);

                // Trigger load once when empty and not already loading
                if (!state.loading && state.customers.isEmpty) {
                  Future.microtask(vm.load);
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.gray300,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Pilih Pelanggan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Top: Tambah Pelanggan Baru button
                      DottedBorder(
                        dashPattern: const [6, 4],
                        color: const Color(0xFF3B82F6),
                        strokeWidth: 1,
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            // TODO: navigate to customer create form
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Form Tambah Pelanggan belum dihubungkan'),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_add_alt_1,
                                  color: Color(0xFF3B82F6),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '+ Tambah Pelanggan Baru',
                                  style: TextStyle(
                                    color: Color(0xFF3B82F6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Search form
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Ketik Nama atau Nomor HP...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFE5E7EB)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFF93C5FD)),
                          ),
                        ),
                        onChanged: vm.setSearchQuery,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'HASIL PENCARIAN',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: state.loading
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.separated(
                                controller: scrollController,
                                itemCount: vm.filteredCustomers.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (_, index) {
                                  final c = vm.filteredCustomers[index];
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blueAccent,
                                      child: Text(
                                        ((c.name ?? '').isNotEmpty
                                            ? c.name!.substring(0, 1)
                                            : ''),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                    title: Text(c.name ?? ''),
                                    subtitle: Text(c.phone ?? ''),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () {
                                      setCustomer(c);
                                      Navigator.of(context).pop();
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
