import 'package:core/core.dart';
import 'package:customer/presentation/controllers/customer_list.controller.dart';
import 'package:customer/presentation/providers/customer.providers.dart';

class CustomerListScreen extends HookConsumerWidget {
  const CustomerListScreen({
    super.key,
    required this.scrollController,
    required this.setCustomer,
  });

  final ScrollController scrollController;
  final void Function(dynamic customerEntity) setCustomer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerViewModelProvider);
    final vm = ref.read(customerViewModelProvider.notifier);

    // Controller manages search TextEditingController lifecycle and sync
    final listController = useMemoized(
      () => CustomerListController(ref),
      [ref],
    );

    useEffect(() {
      listController.init();
      return listController.dispose;
    }, [listController]);

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
          Row(
            children: [
              const Text(
                'Pilih Pelanggan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.sbLightBlue,
                ),
                tooltip: 'Tambah Pelanggan Baru',
                onPressed: () => vm.startAdd(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: listController.searchController,
            decoration: InputDecoration(
              hintText: 'Ketik Nama atau Nomor HP...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.sbLightBlue,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.sbLightBlue,
                ),
              ),
            ),
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
                    itemCount: vm.filteredCustomers.isEmpty
                        ? 1
                        : vm.filteredCustomers.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      if (vm.filteredCustomers.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => vm.startAdd(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.sbLightBlue,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.person_add_alt_1,
                                    color: Color(0xFF3B82F6),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Tambah Pelanggan Baru',
                                    style: TextStyle(
                                      color: Color(0xFF1D4ED8),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      final c = vm.filteredCustomers[index];
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Text(
                            ((c.name ?? '').isNotEmpty
                                ? c.name!.substring(0, 1)
                                : ''),
                            style: const TextStyle(color: Colors.white),
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
  }
}
