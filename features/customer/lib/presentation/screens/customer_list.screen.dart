import 'package:core/core.dart';
import 'package:customer/presentation/screens/action.sheet.dart';
import 'package:customer/presentation/view_models/customer.state.dart';
import 'package:customer/presentation/view_models/customer.vm.dart';
import 'package:customer/presentation/providers/customer.providers.dart';
import 'package:customer/presentation/widgets/customer_list_tile.card.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:customer/presentation/controllers/customer_list.controller.dart';
import 'package:transaction/presentation/view_models/transaction_pos/transaction_pos.vm.dart';

class CustomerListScreen extends HookConsumerWidget {
  const CustomerListScreen({
    super.key,
    required this.scrollController,
  });

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerViewModelProvider);
    final vm = ref.read(customerViewModelProvider.notifier);
    final transactionPosVm = ref.read(transactionPosViewModelProvider.notifier);

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
      Future.microtask(vm.getCustomers);
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
          _buildHeader(vm: vm, listController: listController),
          const SizedBox(height: 12),
          _buildSearchingBox(listController: listController),
          const SizedBox(height: 12),
          _buildListCustomer(
            vm: vm,
            state: state,
            context: context,
            transactionPosVm: transactionPosVm,
            scrollController: scrollController,
            listController: listController,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({
    required CustomerViewModel vm,
    required CustomerListController listController,
  }) {
    return Row(
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
          onPressed: () => vm.openFormFromSearch(null),
        ),
      ],
    );
  }

  Widget _buildSearchingBox({
    required CustomerListController listController,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
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
        ),
      ],
    );
  }

  Widget _buildListCustomer({
    required CustomerState state,
    required CustomerViewModel vm,
    required BuildContext context,
    required ScrollController scrollController,
    required CustomerListController listController,
    required TransactionPosViewModel transactionPosVm,
  }) {
    final bool isEmptyState = !state.loading && state.customers.isEmpty;
    final items = vm.filteredCustomers;

    Widget body;
    if (isEmptyState) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_outline,
              size: 56,
              color: AppColors.gray400,
            ),
            const SizedBox(height: 12),
            const Text(
              'Belum ada pelanggan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => vm.openFormFromSearch(
                  listController.searchController.text.trim()),
              icon: const Icon(
                Icons.add_circle_outline,
                color: AppColors.sbLightBlue,
              ),
              label: const Text('Tambah Pelanggan Baru'),
            ),
          ],
        ),
      );
    } else if (state.loading) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = ListView.separated(
        controller: scrollController,
        itemCount: items.isEmpty ? 1 : items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, index) {
          if (items.isEmpty) return _buildButtonAddCustomer(vm: vm);

          final filteredCustomer = items[index];
          return CustomerListTileCard(
            customer: filteredCustomer,
            onTapCallback: (customer) {
              // set selected customer in transaction VM then close the sheet
              transactionPosVm.setCustomer(customer);
              try {
                Navigator.of(context).pop();
              } catch (_) {}
            },
            onLongPressCallback: (customer) =>
                showCustomerActionSheet(context, vm, customer),
          );
        },
      );
    }

    return Expanded(child: body);
  }

  Widget _buildButtonAddCustomer({
    required CustomerViewModel vm,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 8,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => vm.openFormFromSearch(null),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.sbLightBlue,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 12,
          ),
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
}
