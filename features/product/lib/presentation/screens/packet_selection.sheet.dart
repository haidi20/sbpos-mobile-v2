// Presentational packet selection sheet.
// Returns List<SelectedPacketItem> where each item contains productId and qty.
import 'package:core/core.dart';
import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/presentation/providers/packet.provider.dart';

class SelectedPacketItem {
  final int productId;
  final int qty;

  SelectedPacketItem({required this.productId, required this.qty});
}

class PacketSelectionSheet extends ConsumerStatefulWidget {
  final PacketEntity packet;
  final List<ProductEntity> products;

  const PacketSelectionSheet(
      {super.key, required this.packet, required this.products});

  @override
  ConsumerState<PacketSelectionSheet> createState() =>
      _PacketSelectionSheetState();
}

class _PacketSelectionSheetState extends ConsumerState<PacketSelectionSheet> {
  @override
  void initState() {
    super.initState();
    // initialize selection state in VM
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(packetManagementViewModelProvider.notifier)
          .initSelectionFromPacket(widget.packet);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.packet.name ?? 'Paket',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close),
                  )
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                itemCount: widget.packet.items?.length ?? 0,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final it = widget.packet.items![index];
                  final prod = widget.products.firstWhere(
                      (p) => p.id == it.productId,
                      orElse: () => ProductEntity(id: it.productId ?? 0));
                  final pid = prod.id ?? 0;
                    final viewModel =
                      ref.read(packetManagementViewModelProvider.notifier);
                    final isSelected = viewModel.isSelected(pid);
                    final price = prod.price?.toInt() ?? 0;
                    final qty = viewModel.qtyFor(pid, it.qty ?? 1);
                    final lineSubtotal = price * qty;

                  return ListTile(
                    leading: Checkbox(
                        value: isSelected,
                        onChanged: (v) => notifier.toggleSelected(pid)),
                    title: Text(prod.name ?? 'Item'),
                    subtitle: Text('Harga: ${formatRupiah(price.toDouble())}'),
                    trailing: SizedBox(
                      width: 140,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => notifier.decrementQty(pid)),
                            Text(
                              '$qty',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => notifier.incrementQty(pid)),
                            const SizedBox(width: 8),
                            Text(
                              formatRupiah(lineSubtotal.toDouble()),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ]),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total paket',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Builder(builder: (context) {
                    final viewModel =
                        ref.read(packetManagementViewModelProvider.notifier);
                    final total =
                        (widget.packet.items ?? []).fold<int>(0, (sum, it) {
                      final pid = it.productId ?? 0;
                      final qty = viewModel.qtyFor(pid, it.qty ?? 1);
                      final prod = widget.products.firstWhere(
                          (p) => p.id == pid,
                          orElse: () => ProductEntity(id: pid));
                      final price = prod.price?.toInt() ?? 0;
                      return sum + (price * qty);
                    });
                    return Text(formatRupiah(total.toDouble()),
                        style: const TextStyle(fontWeight: FontWeight.bold));
                  })
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final viewModel = ref
                          .read(packetManagementViewModelProvider.notifier);
                        final selected = <SelectedPacketItem>[];
                        for (final pid in viewModel.selectedIds) {
                          final q = viewModel.qtyFor(pid, 1);
                          selected
                            .add(SelectedPacketItem(productId: pid, qty: q));
                        }
                        Navigator.of(context).pop(selected);
                      },
                      child: const Text('Tambahkan'),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
