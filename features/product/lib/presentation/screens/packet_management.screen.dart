// ignore_for_file: use_build_context_synchronously

import 'package:core/core.dart';
import 'package:product/presentation/providers/packet.provider.dart';
import 'package:product/presentation/screens/packet_management_form.screen.dart';

class PacketManagementScreen extends ConsumerStatefulWidget {
  const PacketManagementScreen({super.key});

  @override
  ConsumerState<PacketManagementScreen> createState() =>
      _PacketManagementScreenState();
}

class _PacketManagementScreenState
    extends ConsumerState<PacketManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(packetManagementViewModelProvider.notifier).getPackets());
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(packetManagementViewModelProvider.notifier);
    final state = ref.watch(packetManagementViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.sbBg,
      body: SafeArea(
        child: Column(
          children: [
            if (state.loading) const LinearProgressIndicator(),

            // Content area: loading / empty / data
            Expanded(
              child: Builder(builder: (context) {
                if (state.loading) {
                  return const _PacketManagementLoading();
                }
                if (state.packets.isEmpty) {
                  return const _PacketManagementEmpty();
                }
                return _PacketManagementDataList(
                  packets: state.packets,
                  notifier: notifier,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// PacketManagementHeader removed; header inlined in the screen build

class _PacketManagementLoading extends StatelessWidget {
  const _PacketManagementLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _PacketManagementEmpty extends StatelessWidget {
  const _PacketManagementEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('Belum ada paket.',
                style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

class _PacketManagementDataList extends StatelessWidget {
  final List packets;
  final dynamic notifier;

  const _PacketManagementDataList(
      {required this.packets, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: packets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = packets[index];
        return PacketListItem(
          packet: p,
          onEdit: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => PacketManagementFormScreen(packet: p)),
            );
            if (!Navigator.of(context).mounted) return;
            notifier.getPackets();
          },
          onDelete: () async {
            final ok = await notifier.onDeletePacketById(p.id);
            if (!ok) {
              if (!Navigator.of(context).mounted) return;
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Gagal hapus')));
            } else {
              notifier.getPackets();
            }
          },
        );
      },
    );
  }
}

class PacketListItem extends StatelessWidget {
  final dynamic packet;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PacketListItem(
      {super.key,
      required this.packet,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(packet.name ?? '-'),
      subtitle: Text('Rp ${packet.price ?? 0}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
          IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
        ],
      ),
    );
  }
}
