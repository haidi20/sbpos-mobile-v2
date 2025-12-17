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
      appBar: AppBar(
        title: const Text('Paket'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            PacketManagementHeader(
              state: state,
              onSearch: notifier.setSearchQuery,
              onAdd: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PacketManagementFormScreen()),
                );
                if (!mounted) return;
                notifier.getPackets();
              },
            ),
            if (state.loading) const LinearProgressIndicator(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: state.packets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final p = state.packets[index];
                  return PacketListItem(
                    packet: p,
                    onEdit: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                PacketManagementFormScreen(packet: p)),
                      );
                      if (!mounted) return;
                      notifier.getPackets();
                    },
                    onDelete: () async {
                      final ok = await notifier.onDeletePacketById(p.id);
                      if (!ok) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Gagal hapus')));
                      } else {
                        notifier.getPackets();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PacketManagementHeader extends StatelessWidget {
  final dynamic state;
  final void Function(String) onSearch;
  final VoidCallback onAdd;

  const PacketManagementHeader(
      {super.key,
      required this.state,
      required this.onSearch,
      required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TextField(
              onChanged: onSearch,
              decoration: const InputDecoration(hintText: 'Cari paket...'),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Tambah'),
          ),
        ],
      ),
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

// import removed (already imported at top)
