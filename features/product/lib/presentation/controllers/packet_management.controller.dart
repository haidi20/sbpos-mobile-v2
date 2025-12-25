// ignore_for_file: use_build_context_synchronously

import 'package:core/core.dart';
import 'package:product/presentation/sheets/packet_item_management_form.sheet.dart';
import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/domain/entities/packet_item.entity.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/presentation/providers/packet.provider.dart';
import 'package:product/presentation/providers/product.provider.dart';
import 'package:product/presentation/sheets/product.sheet.dart';

class PacketManagementController {
  final WidgetRef ref;

  final formKey = GlobalKey<FormState>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  bool isActive = true;

  final ValueNotifier<List<ProductEntity>> products = ValueNotifier(const []);

  // packet-level discount
  final TextEditingController packetDiscountCtrl = TextEditingController();
  bool applyPacketDiscount = false;

  PacketManagementController(this.ref);

  /// Initialize controller. Prefer using [packetId] so VM/usecase loads the
  /// full packet entity. If [packet] is provided, it will be used directly.
  Future<void> init({PacketEntity? packet, int? packetId}) async {
    _loadProducts();
    if (packet != null) {
      final p = packet;
      nameCtrl.text = p.name ?? '';
      priceCtrl.text = p.price?.toString() ?? '';
      packetDiscountCtrl.text = p.discount?.toString() ?? '';
      isActive = p.isActive ?? true;
      ref.read(packetManagementViewModelProvider.notifier).setDraft(p);
      return;
    }

    if (packetId != null) {
      // Load via usecase (offline) through provider
      final getPacket = ref.read(packetGetPacketProvider);
      final res = await getPacket(packetId, isOffline: true);
      res.fold((f) {
        // fallback to empty draft
        ref
            .read(packetManagementViewModelProvider.notifier)
            .setDraft(PacketEntity());
      }, (p) {
        nameCtrl.text = p.name ?? '';
        priceCtrl.text = p.price?.toString() ?? '';
        packetDiscountCtrl.text = p.discount?.toString() ?? '';
        isActive = p.isActive ?? true;
        ref.read(packetManagementViewModelProvider.notifier).setDraft(p);
      });
      return;
    }

    // default: new draft
    ref
        .read(packetManagementViewModelProvider.notifier)
        .setDraft(PacketEntity());
  }

  /// Open product selection sheet (deduped) and then prompt for qty/price/discount
  /// to update draft item at [index].
  Future<void> openProductSelectionAndEdit(
      BuildContext context, int index) async {
    if (products.value.isEmpty) await _loadProducts();

    final seen = <int>{};
    final list = <ProductEntity>[];
    for (final p in products.value) {
      final pid = p.id;
      if (pid == null) continue;
      if (seen.add(pid)) list.add(p);
    }

    final selected = await showProductSelectionSheet(context);
    if (selected != null) {
      await selectProductForDraftItem(context, index, selected.id);
    }
  }

  Future<void> _loadProducts() async {
    final getProducts = ref.read(productGetProductsProvider);
    final res = await getProducts(isOffline: true);
    res.fold((f) {
      products.value = [];
    }, (list) {
      // dedupe by id to avoid duplicate entries
      final seen = <int>{};
      final unique = <ProductEntity>[];
      for (final p in list) {
        final pid = p.id;
        if (pid == null) {
          if (!unique.contains(p)) unique.add(p);
          continue;
        }
        if (seen.add(pid)) unique.add(p);
      }
      products.value = unique;
    });
  }

  ProductEntity? findProductById(int? id) {
    if (id == null) return null;
    try {
      return products.value.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Show a dialog to collect qty/price/discount after a product is selected
  /// then update the draft item at [index].
  Future<void> selectProductForDraftItem(
      BuildContext context, int index, int? selectedProductId) async {
    // ensure products are loaded
    if (products.value.isEmpty) await _loadProducts();

    final vm = ref.read(packetManagementViewModelProvider.notifier);
    final draft = vm.draft;
    final items = List<PacketItemEntity>.from(draft.items ?? []);
    if (index < 0 || index >= items.length) return;
    final item = items[index];

    // gunakan sheet yang meng-handle VM secara langsung
    await showPacketItemManagementSheet(context, item, index: index);
  }

  int computeItemSubtotal(
      {int? productId, required int qty, required int discount}) {
    final int price = findProductById(productId)?.price?.toInt() ?? 0;
    // Hitung subtotal untuk satu item: gunakan price produk dikali qty,
    // lalu kurangi discount item (jika ada). Pastikan hasil tidak negatif.
    int subtotal = (price * qty) - discount;
    if (subtotal < 0) subtotal = 0;
    return subtotal;
  }

  int computeTotal(List<PacketItemEntity>? items) {
    // 1) Hitung total item: gunakan subtotal yang sudah ada atau hitung ulang
    //    berdasarkan harga produk, qty, dan discount per item.
    var total = 0;
    for (final it in items ?? []) {
      final int subtotal = (it.subtotal ??
          computeItemSubtotal(
              productId: it.productId,
              qty: it.qty ?? 0,
              discount: it.discount ?? 0));
      total += subtotal;
    }

    // 2) Tambahkan harga dasar paket (`priceCtrl`). Pastikan parsing aman.
    final basePrice = int.tryParse(priceCtrl.text.trim()) ?? 0;
    total += basePrice;

    // 3) Jika applyPacketDiscount aktif, kurangi diskon paket.
    if (applyPacketDiscount) {
      final disc = int.tryParse(packetDiscountCtrl.text.trim()) ?? 0;
      total -= disc;
      if (total < 0) total = 0;
    }
    return total;
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    final vm = ref.read(packetManagementViewModelProvider.notifier);
    final draft = vm.draft.copyWith(
      name: nameCtrl.text.trim(),
      price: int.tryParse(priceCtrl.text.trim()) ?? 0,
      discount: applyPacketDiscount
          ? int.tryParse(packetDiscountCtrl.text.trim()) ?? 0
          : null,
      isActive: isActive,
    );
    vm.setDraft(draft);
    if (draft.id != null) {
      await vm.onUpdatePacket();
    } else {
      await vm.onCreatePacket();
    }
  }

  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    packetDiscountCtrl.dispose();
    products.dispose();
  }
}
