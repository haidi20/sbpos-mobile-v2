import 'package:core/core.dart';
import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/presentation/providers/packet.provider.dart';
import 'package:product/domain/entities/packet_selected_item.entity.dart';
import 'package:product/presentation/view_models/packet_management.vm.dart';
import 'package:product/presentation/view_models/packet_management.state.dart';

class PacketSelectionSheet extends ConsumerStatefulWidget {
  final PacketEntity packet;
  final List<ProductEntity> products;

  const PacketSelectionSheet({
    super.key,
    required this.packet,
    required this.products,
  });

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _PacketHeader(
                packet: widget.packet,
                onClose: () => Navigator.of(context).maybePop(),
              ),
              const Divider(height: 1),
              // Content area handles loading / empty / list states
              Expanded(
                child: _PacketContent(
                  packet: widget.packet,
                  products: widget.products,
                  viewModelState: ref.watch(packetManagementViewModelProvider),
                  viewModelNotifier:
                      ref.read(packetManagementViewModelProvider.notifier),
                ),
              ),
              _PacketTotalBar(
                  packet: widget.packet,
                  products: widget.products,
                  viewModel:
                      ref.read(packetManagementViewModelProvider.notifier)),
              _PacketFooter(
                  viewModel:
                      ref.read(packetManagementViewModelProvider.notifier)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PacketHeader extends StatelessWidget {
  final PacketEntity packet;
  final VoidCallback onClose;

  const _PacketHeader({required this.packet, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              packet.name ?? 'Paket',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _PacketItemRow extends StatelessWidget {
  final dynamic item;
  final ProductEntity product;
  final dynamic viewModel;

  const _PacketItemRow(
      {required this.item, required this.product, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final pid = product.id ?? 0;
    final isSelected = viewModel.isSelected(pid);
    final price = product.price?.toInt() ?? 0;
    final qty = viewModel.qtyFor(pid, item.qty ?? 1);
    final lineSubtotal = price * qty;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => viewModel.toggleSelected(pid),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (_) => viewModel.toggleSelected(pid),
                activeColor: AppColors.sbBlue,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? 'Item',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$qty x ${formatRupiah(price.toDouble())} = ${formatRupiah(lineSubtotal.toDouble())}',
                      style: const TextStyle(
                        color: AppColors.gray600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        constraints:
                            const BoxConstraints(minWidth: 32, minHeight: 32),
                        onPressed: () => viewModel.decrementQty(pid),
                      ),
                      Text(
                        '$qty',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.sbBlue : Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        constraints:
                            const BoxConstraints(minWidth: 32, minHeight: 32),
                        onPressed: () => viewModel.incrementQty(pid),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PacketContent extends StatelessWidget {
  final PacketEntity packet;
  final List<ProductEntity> products;
  final PacketManagementState viewModelState;
  final PacketManagementViewModel viewModelNotifier;

  const _PacketContent({
    required this.packet,
    required this.products,
    required this.viewModelState,
    required this.viewModelNotifier,
  });

  @override
  Widget build(BuildContext context) {
    if (viewModelState.loading) {
      return const _PacketLoadingView();
    }

    final items = packet.items ?? [];
    if (items.isEmpty) {
      return _PacketEmptyView(onClose: () => Navigator.of(context).maybePop());
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final it = items[index];
        final prod = products.firstWhere(
          (p) => p.id == it.productId,
          orElse: () => ProductEntity(id: it.productId ?? 0),
        );
        return _PacketItemRow(
          item: it,
          product: prod,
          viewModel: viewModelNotifier,
        );
      },
    );
  }
}

class _PacketLoadingView extends StatelessWidget {
  const _PacketLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text('Memuat item paket...', style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

class _PacketEmptyView extends StatelessWidget {
  final VoidCallback onClose;

  const _PacketEmptyView({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 56, color: AppColors.gray400),
          SizedBox(height: 12),
          Text('Tidak ada menu di paket',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray800)),
          SizedBox(height: 8),
          Text(
              'Paket ini belum memiliki produk. Tambahkan menu terlebih dahulu atau tutup.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.gray600)),
        ],
      ),
    );
  }
}

class _PacketTotalBar extends StatelessWidget {
  final PacketEntity packet;
  final List<ProductEntity> products;
  final dynamic viewModel;
  const _PacketTotalBar(
      {required this.packet, required this.products, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final total = (packet.items ?? []).fold<int>(0, (sum, it) {
      final pid = it.productId ?? 0;
      // only include selected items in total
      if (!viewModel.isSelected(pid)) return sum;
      final qty = viewModel.qtyFor(pid, it.qty ?? 1);
      final prod = products.firstWhere((p) => p.id == pid,
          orElse: () => ProductEntity(id: pid));
      final price = prod.price?.toInt() ?? 0;
      return sum + price * (qty as num).toInt();
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text(
          'Total paket',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(formatRupiah(total.toDouble()),
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

class _PacketFooter extends StatelessWidget {
  final dynamic viewModel;

  const _PacketFooter({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(children: [
        Expanded(
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sbOrange,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  final selected = <SelectedPacketItem>[];
                  for (final pid in viewModel.selectedIds) {
                    final q = viewModel.qtyFor(pid, 1);
                    selected.add(SelectedPacketItem(productId: pid, qty: q));
                  }
                  Navigator.of(context).pop(selected);
                },
                child: const Text('Tambahkan'))),
      ]),
    );
  }
}
