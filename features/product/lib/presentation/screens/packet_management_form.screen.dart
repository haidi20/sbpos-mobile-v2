// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_element, unused_import, unnecessary_import, depend_on_referenced_packages, use_build_context_synchronously, public_member_api_docs

import 'package:core/core.dart';
import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/domain/entities/packet_item.entity.dart';
import 'package:product/presentation/providers/packet.provider.dart';
import 'package:product/presentation/components/packet_item.card.dart';
import 'package:product/presentation/controllers/packet_management_form.controller.dart';

class PacketManagementFormScreen extends ConsumerStatefulWidget {
  final PacketEntity? packetEntity;
  const PacketManagementFormScreen({
    super.key,
    this.packetEntity,
  });

  @override
  ConsumerState<PacketManagementFormScreen> createState() =>
      _PacketManagementFormScreenState();
}

class _PacketManagementFormScreenState
    extends ConsumerState<PacketManagementFormScreen> {
  // data comes from `widget.packetEntity`

  late final PacketManagementFormController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = PacketManagementFormController(ref);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // initialize VM draft from provided packetEntity when screen is shown
    // Defer provider modifications to after build to avoid Riverpod errors
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final vm = ref.read(packetManagementViewModelProvider.notifier);
        vm.setDraft(widget.packetEntity ?? PacketEntity());
        vm.setIsForm(true);
        vm.ensureProductsLoaded();
      });
    }
  }

  Future<void> _openEditSheet({PacketItemEntity? item, int? index}) async {
    await _controller.openEditSheet(context: context, item: item, index: index);
  }

  // product picker handled inside item sheet flow via product list passed in

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sbBg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info comes from VM draft so mutations go through VM
                    Builder(builder: (context) {
                      final notifier =
                          ref.read(packetManagementViewModelProvider.notifier);
                      final draft = notifier.draft;
                      return _InfoSection(
                        name: draft.name ?? 'Paket',
                        isActive: draft.isActive ?? true,
                        onNameChanged: (v) =>
                            notifier.setDraft(draft.copyWith(name: v)),
                        onToggleActive: () => notifier.setDraft(draft.copyWith(
                            isActive: !(draft.isActive ?? true))),
                      );
                    }),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Item Produk',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        TextButton.icon(
                          onPressed: () => _openEditSheet(),
                          icon: const Icon(Icons.add, color: AppColors.sbBlue),
                          label: const Text('TAMBAH ITEM',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.sbBlue)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Packet items provided by VM draft
                    Builder(builder: (context) {
                      final notifier =
                          ref.read(packetManagementViewModelProvider.notifier);
                      final draft = notifier.draft;
                      final items = draft.items ?? <PacketItemEntity>[];
                      return _PacketItemList(
                          items: items,
                          onEdit: (it) {
                            final idx = items.indexWhere((i) => i.id == it.id);
                            _openEditSheet(
                                item: it, index: idx == -1 ? null : idx);
                          });
                    }),
                    const SizedBox(height: 22),
                    Text('Konfigurasi Harga',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  labelText: 'Harga Dasar Paket'),
                              controller: TextEditingController(
                                  text: (widget.packetEntity?.price ?? 0)
                                      .toString()),
                              onChanged: (v) {},
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            title: const Text('Gunakan Diskon Paket',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            trailing: Switch(
                                value: (widget.packetEntity?.discount ?? 0) > 0,
                                onChanged: (_) {}),
                          ),
                          if ((widget.packetEntity?.discount ?? 0) > 0)
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    labelText: 'Nominal Diskon'),
                                controller: TextEditingController(
                                    text: (widget.packetEntity?.discount ?? 0)
                                        .toString()),
                                onChanged: (v) {},
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SummaryCard(
                        total: ref
                            .read(packetManagementViewModelProvider.notifier)
                            .computeTotal(
                                basePrice: ref
                                        .read(packetManagementViewModelProvider
                                            .notifier)
                                        .draft
                                        .price ??
                                    0,
                                applyPacketDiscount: (ref
                                            .read(
                                                packetManagementViewModelProvider
                                                    .notifier)
                                            .draft
                                            .discount ??
                                        0) >
                                    0,
                                packetDiscount: ref
                                        .read(packetManagementViewModelProvider
                                            .notifier)
                                        .draft
                                        .discount ??
                                    0)),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
            _BottomBar(onSave: () async {
              final notifier =
                  ref.read(packetManagementViewModelProvider.notifier);
              final draft = notifier.draft;
              if (draft.id == null) {
                await notifier.onCreatePacket();
              } else {
                await notifier.onUpdatePacket();
              }
              if (!mounted) return;
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Disimpan')));
              Navigator.of(context).maybePop();
            }),
          ],
        ),
      ),
      floatingActionButton: null,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: AppColors.gray200))),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: onBack),
          const Expanded(
              child: Center(
                  child: Text('Edit Paket',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)))),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection(
      {super.key,
      required this.name,
      required this.isActive,
      required this.onNameChanged,
      required this.onToggleActive});
  final String name;
  final bool isActive;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Info Utama',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Text(isActive ? 'AKTIF' : 'NONAKTIF',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Switch(value: isActive, onChanged: (_) => onToggleActive()),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
              labelText: 'Nama Paket',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white),
          controller: TextEditingController(text: name),
          onChanged: onNameChanged,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({super.key, required this.total});
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppColors.sbBlue, AppColors.sbBlue700]),
          borderRadius: BorderRadius.circular(24)),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(6))),
          const SizedBox(height: 12),
          const Text('Total Harga Paket',
              style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          const SizedBox(height: 8),
          Text('Rp $total',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text('Sudah termasuk pajak & diskon',
              style: TextStyle(
                  color: Colors.white70, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({super.key, required this.onSave});
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          border: Border(top: BorderSide(color: AppColors.gray200))),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sbBlue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16))),
          onPressed: onSave,
          child: const Text('Simpan Data',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        ),
      ),
    );
  }
}

class _PacketItemList extends StatelessWidget {
  const _PacketItemList({
    super.key,
    required this.items,
    required this.onEdit,
  });

  final List<PacketItemEntity> items;
  final void Function(PacketItemEntity item) onEdit;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Center(
          child: const Text('Keranjang masih kosong',
              style: TextStyle(
                  color: AppColors.gray400, fontWeight: FontWeight.w600)),
        ),
      );
    }

    return Column(
      children: items.map(
        (packetItem) {
          return PacketItemCard(packetItem: packetItem, onEdit: onEdit);
        },
      ).toList(),
    );
  }
}
