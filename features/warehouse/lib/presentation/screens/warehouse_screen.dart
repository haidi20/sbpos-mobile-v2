// warehouse/presentation/screens/warehouse_screen.dart
import 'package:core/core.dart';
import 'package:warehouse/presentation/view_models/warehouse.vm.dart';
import 'package:warehouse/presentation/providers/warehouse_provider.dart';

class WarehouseScreen extends ConsumerWidget {
  const WarehouseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(warehouseViewModelProvider);
    final viewModel = ref.read(warehouseViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Lokasi Sekarang'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Menu action
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'GB',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: const Row(
                children: [
                  Icon(Icons.search, size: 18, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari nama warung atau usaha',
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Daftar warung SB POS',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Konten Utama
            Expanded(
              child: _buildContent(
                ref: ref,
                state: state,
                viewModel: viewModel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent({
    required WidgetRef ref,
    required WarehouseState state,
    required WarehouseViewModel viewModel,
  }) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Refresh manual
                viewModel.fetchWarehouses();
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (state.warehouses.isEmpty) {
      return const Center(child: Text('Tidak ada data warehouse.'));
    }

    return ListView.separated(
      itemCount: state.warehouses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final warehouse = state.warehouses[index];
        return Card(
          elevation: 2,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: _gbPlaceholder(width: 36, height: 36),
            title: Text(
              warehouse.name ?? '-',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 14,
                  color: Colors.red,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    warehouse.address != null && warehouse.address!.length > 30
                        ? '${warehouse.address!.substring(0, 30)}...'
                        : warehouse.address ?? 'Alamat tidak tersedia',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {
              GoRouter.of(context).push('/app/${warehouse.id}/mode');
            },
          ),
        );
      },
    );
  }

  Widget _gbPlaceholder({double width = 40, double height = 40}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'GB',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
