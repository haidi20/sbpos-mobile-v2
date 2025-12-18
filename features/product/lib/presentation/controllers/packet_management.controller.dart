import 'package:core/core.dart';
import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/presentation/providers/packet.provider.dart';
import 'package:product/presentation/providers/product.provider.dart';

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

  void init(PacketEntity? packet) {
    final p = packet;
    _loadProducts();
    if (p != null) {
      nameCtrl.text = p.name ?? '';
      priceCtrl.text = p.price?.toString() ?? '';
      packetDiscountCtrl.text = p.discount?.toString() ?? '';
      isActive = p.isActive ?? true;
      ref.read(packetManagementViewModelProvider.notifier).setDraft(p);
    } else {
      ref
          .read(packetManagementViewModelProvider.notifier)
          .setDraft(PacketEntity());
    }
  }

  Future<void> _loadProducts() async {
    final getProducts = ref.read(productGetProductsProvider);
    final res = await getProducts(isOffline: true);
    res.fold((f) {
      products.value = [];
    }, (list) {
      products.value = list;
    });
  }

  Future<void> dispose() async {
    nameCtrl.dispose();
    priceCtrl.dispose();
    products.dispose();
    packetDiscountCtrl.dispose();
  }

  ProductEntity? findProductById(int? id) {
    if (id == null) return null;
    try {
      return products.value.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  int computeItemSubtotal({int? productId, int qty = 1, int discount = 0}) {
    final p = findProductById(productId);
    final priceDouble = p?.price ?? 0.0;
    final base = (priceDouble * qty).toInt();
    final sub = base - (discount);
    return sub < 0 ? 0 : sub;
  }

  int computeTotal(List<dynamic>? items) {
    if (items == null) return 0;
    var total = 0;
    for (final it in items) {
      final int subtotal = it.subtotal ??
          computeItemSubtotal(
              productId: it.productId,
              qty: it.qty ?? 0,
              discount: it.discount ?? 0);
      total += subtotal;
    }
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
}
