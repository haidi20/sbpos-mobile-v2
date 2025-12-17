import 'package:core/core.dart';
import 'package:product/presentation/view_models/inventory.state.dart';
import 'package:product/presentation/view_models/inventory.vm.dart';

class InventoryList extends StatelessWidget {
  final InventoryState state;
  final InventoryViewModel vm;
  final Color sbBlue;
  const InventoryList(
      {super.key, required this.state, required this.vm, required this.sbBlue});

  @override
  Widget build(BuildContext context) {
    final items = vm.filteredItems;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final isLow = item.stock <= item.minStock;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(item.image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (isLow)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(Icons.error_outline,
                                  size: 20, color: Colors.red),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isLow
                                  ? Colors.red.shade50
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${item.stock} ${item.unit}',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isLow ? Colors.red : Colors.green),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Min: ${item.minStock}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildStockBtn(
                      icon: Icons.remove,
                      onTap: () => vm.adjustStock(item.id, -1),
                    ),
                    const SizedBox(width: 4),
                    _buildStockBtn(
                      icon: Icons.add,
                      onTap: () => vm.adjustStock(item.id, 1),
                      isBlue: true,
                      color: sbBlue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStockBtn({
    required IconData icon,
    required VoidCallback onTap,
    bool isBlue = false,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isBlue ? color : Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Icon(
          icon,
          size: 16,
          color: isBlue ? Colors.white : Colors.grey.shade600,
        ),
      ),
    );
  }
}
