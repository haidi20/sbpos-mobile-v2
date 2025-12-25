import 'package:core/core.dart';
import 'package:product/presentation/view_models/inventory.state.dart';
import 'package:product/presentation/view_models/inventory.vm.dart';
import 'package:product/presentation/screens/packet_management.screen.dart';
import 'package:product/presentation/widgets/inventory_list.widget.dart';
// Riverpod types are re-exported from core

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(inventoryViewModelProvider.notifier);
    final state = ref.watch(inventoryViewModelProvider);
    const sbBlue = AppColors.sbBlue;
    const sbOrange = AppColors.sbOrange;
    const sbBg = AppColors.sbBg;

    return Scaffold(
      backgroundColor: sbBg,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              _buildHeader(context, state, vm, sbBlue, sbOrange),
              const TabBar(
                indicatorColor: Colors.blue,
                labelColor: Colors.black87,
                tabs: [
                  Tab(text: 'Menu'),
                  Tab(text: 'Paket'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // Items tab: reuse inventory list and add button
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.push(AppRoutes.productManagement);
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Tambah Menu'),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                            child: InventoryList(
                                state: state, vm: vm, sbBlue: sbBlue)),
                      ],
                    ),

                    // Packet tab: show packet management screen inside tab
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.push(AppRoutes.packetManagement);
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Tambah Paket'),
                              ),
                            ],
                          ),
                        ),
                        const Expanded(child: PacketManagementScreen()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, InventoryState state,
      InventoryViewModel vm, Color sbBlue, Color sbOrange) {
    return Container(
      color: AppColors.sbBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black87,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                tooltip: 'Kembali',
              ),
              const Text(
                'Manajemen Stok',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => vm.setFilter('all'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: state.filter == 'all' ? sbBlue : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: state.filter == 'all'
                            ? sbBlue
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Item',
                              style: TextStyle(
                                fontSize: 12,
                                color: state.filter == 'all'
                                    ? Colors.blue.shade100
                                    : Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${state.items.length}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: state.filter == 'all'
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.inventory_2_outlined,
                          color: state.filter == 'all'
                              ? Colors.blue.shade200
                              : Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => vm.setFilter('low'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: state.filter == 'low'
                          ? Colors.orange.shade50
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: state.filter == 'low'
                            ? sbOrange
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stok Menipis',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.orange.shade800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${vm.lowStockCount}',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: sbOrange),
                            ),
                          ],
                        ),
                        Icon(Icons.warning_amber_rounded, color: sbOrange),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: vm.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Cari nama barang...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
              suffixIcon: Icon(Icons.filter_list, color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: sbBlue.withOpacity(0.2), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
