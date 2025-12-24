part of 'transaction_pos.vm.dart';

/// Build combined content list (packets + products).
/// Applies opsional search and category filters.
List<ContentItemEntity> buildCombinedContent({
  required List<PacketEntity> packets,
  required List<ProductEntity> products,
  String? searchQuery,
  String activeCategory = 'Semua',
}) {
  final q = (searchQuery ?? '').toLowerCase();

  final filteredPackets = packets.where((p) {
    if (q.isEmpty) return true;
    return p.name != null && p.name!.toLowerCase().contains(q);
  }).toList();

  final filteredProducts = products.where((prod) {
    final matchesCategory = activeCategory == 'Semua' ||
        (prod.category?.name ?? '') == activeCategory;
    final matchesSearch = q.isEmpty ||
        (prod.name != null && prod.name!.toLowerCase().contains(q));
    return matchesCategory && matchesSearch;
  }).toList();

  final out = <ContentItemEntity>[];
  for (final pkt in filteredPackets) {
    out.add(ContentItemEntity.packet(pkt));
  }

  for (final prod in filteredProducts) {
    out.add(ContentItemEntity.product(prod));
  }
  return out;
}

mixin TransactionPosViewModelGetters on StateNotifier<TransactionPosState> {
  TransactionPosViewModel get _vm => this as TransactionPosViewModel;
  // ------------------ Pengambil (Getters) ------------------
  /// Filter details berdasarkan query dan kategori aktif.
  List<TransactionDetailEntity> get getFilteredDetails {
    final query = state.searchQuery?.toLowerCase() ?? "";
    final category = state.activeCategory;

    return state.details.where((item) {
      final matchesQuery =
          item.productName?.toLowerCase().contains(query) ?? false;
      final matchesCategory = category == "Semua" ||
          (item.note?.toLowerCase() == category.toLowerCase());
      return matchesQuery && matchesCategory;
    }).toList();
  }

  /// Kembalikan konfigurasi tipe order untuk UI selector.
  List<Map<String, Object?>> get getOrderTypes {
    return orderTypeDummies.map((m) {
      final id = (m.idServer ?? m.id)?.toString() ?? m.name;
      return {
        'id': id,
        'label': m.name,
        'icon': resolveOrderTypeIcon(m.icon),
      };
    }).toList();
  }

  /// Total keranjang terformat (Rupiah).
  String get getCartTotal {
    final total = calculateCartTotal(state.details);
    return formatRupiah(total.toDouble());
  }

  /// Hitung jumlah item di keranjang.
  int get getCartCount => calculateCartCount(state.details);

  /// Total nilai keranjang (int, tanpa format).
  int get getCartTotalValue {
    return calculateCartTotalValue(state.details);
  }

  /// Hitung nilai pajak dari total keranjang.
  int get getTaxValue {
    return calculateTaxValue(state.details);
  }

  /// Hitung grand total (total + pajak).
  // int get getGrandTotalValue => getCartTotalValue + getTaxValue;
  int get getGrandTotalValue => getCartTotalValue;

  /// Hitung kembalian berdasarkan cash yang diterima.
  int get getChangeValue =>
      calculateChangeValue(state.cashReceived, state.details);

  /// Konversi tipe order mentah menjadi `OrderTypeItemUiModel`.
  List<OrderTypeItemUiModel> getOrderTypeItems() {
    final raw = getOrderTypes; // List<Map<String, Object?>
    return raw.map((m) {
      final id = (m['id'] as String);
      final label = (m['label'] as String);
      final icon = (m['icon'] as IconData);

      // Map raw id (could be numeric string like '1' or canonical names)
      EOrderType? mapIdToType(String rawId) {
        // numeric ids from dummy data
        if (rawId == '1' ||
            rawId.toLowerCase() == 'dine_in' ||
            rawId.toLowerCase() == 'dinein' ||
            rawId.toLowerCase().contains('makan')) {
          return EOrderType.dineIn;
        }
        if (rawId == '2' ||
            rawId.toLowerCase() == 'take_away' ||
            rawId.toLowerCase().contains('bungkus') ||
            rawId.toLowerCase().contains('take')) {
          return EOrderType.takeAway;
        }
        if (rawId == '3' ||
            rawId.toLowerCase() == 'online' ||
            rawId.toLowerCase().contains('ojol')) {
          return EOrderType.online;
        }
        return null;
      }

      final mapped = mapIdToType(id);
      final selected = mapped != null && mapped == state.orderType;

      return OrderTypeItemUiModel(
        id: id,
        icon: icon,
        label: label,
        selected: selected,
      );
    }).toList();
  }

  /// Sarankan nominal uang cepat (quick-cash) yang sesuai berdasarkan `total`.
  /// Membulatkan ke atas ke kelipatan `step` (default 50 ribu) dan minimal `step`.
  int suggestQuickCash(int total, {int step = 50000}) {
    if (total <= step) return step;
    return ((total + step - 1) ~/ step) * step;
  }

  // ojol provider data moved to state (`ojolProviders` of type
  // `List<OjolProviderUiModel>`). Use `state.ojolProviders` from the VM.

  /// Expose ojol provider models for UI (forwarder to state).
  List<OjolProviderUiModel> get ojolProviders => state.ojolProviders;

  /// Expose available payment methods (UI models) for the UI to consume.
  List<PaymentMethodUiModel> get paymentMethods => paymentMethodList;

  /// Filter produk menurut kategori dan query saat ini.
  List<ProductEntity> getFilteredProducts(List<ProductEntity> products) {
    final category = state.activeCategory;
    final searchQuery = state.searchQuery?.toLowerCase() ?? '';

    return products.where((p) {
      final matchesCategory =
          category == "Semua" || (p.category?.name ?? '') == category;
      final matchesSearch = searchQuery.isEmpty ||
          (p.name != null && p.name!.toLowerCase().contains(searchQuery));
      return matchesCategory && matchesSearch;
    }).toList();
  }

  /// Filter paket menurut query (opsional).
  List<PacketEntity> getFilteredPackets([String? query]) {
    final packetQuery = (query ?? state.searchQuery ?? '').toLowerCase();
    return state.packets.where((p) {
      if (packetQuery.isEmpty) return true;
      return p.name != null && p.name!.toLowerCase().contains(packetQuery);
    }).toList();
  }

  /// Daftar kategori yang tersedia (termasuk 'Paket').
  List<String> get availableCategories {
    final set = <String>{'Paket'};
    for (final p in _vm._cachedProducts) {
      final n = p.category?.name;
      if (n != null && n.isNotEmpty) set.add(n);
    }
    return set.toList();
  }

  /// Urutan kategori untuk UI: 'Semua', 'Paket', lalu lainnya.
  List<String> get orderedCategories {
    final others =
        availableCategories.where((c) => c.toLowerCase() != 'paket').toList();
    return <String>['Semua', 'Paket', ...others];
  }

  /// Ambil cache konten gabungan untuk UI (paket + produk).
  List<ContentItemEntity> getCombinedContent() {
    return _vm._combinedCache;
  }

  /// Bangun ulang cache konten gabungan berdasarkan filter saat ini.
  void _rebuildCombinedCache() {
    try {
      final packets = getFilteredPackets();
      final products = getFilteredProducts(_vm._cachedProducts);

      final List<ContentItemEntity> out = [];
      for (final pkt in packets) {
        out.add(ContentItemEntity.packet(pkt));
      }
      for (final prod in products) {
        out.add(ContentItemEntity.product(prod));
      }

      _vm._combinedCache = out;
      state = state.copyWith();
    } catch (e, st) {
      _vm._logger.warning('failed to rebuild combined cache: $e', e, st);
    }
  }

  /// Ambil daftar paket (offline) dan perbarui state.
  Future<void> getPacketsList({String? query}) async {
    try {
      if (_vm._getPacketsUsecase == null) {
        _vm._logger.info('no packets usecase provided');
        state = state.copyWith(packets: []);
        return;
      }

      _vm._logger.info('calling GetPackets usecase (offline)...');
      final res = await _vm._getPacketsUsecase!(isOffline: true, query: query);
      res.fold((f) {
        _vm._logger.warning('getPacketsList failed: $f');
        state = state.copyWith(packets: []);
        _vm._rebuildCombinedCache();
      }, (list) {
        _vm._logger.info('GetPackets returned ${list.length} packets');
        state = state.copyWith(packets: list);
        _vm._rebuildCombinedCache();
      });
    } catch (e, st) {
      _vm._logger.warning('getPacketsList exception: $e', e, st);
    }
  }

  /// Cari indeks produk pertama untuk kategori tertentu.
  int indexOfFirstProductForCategory(String name) {
    final all = getFilteredProducts(_vm._cachedProducts);
    return calcIndexOfFirstProductForCategory(all, name);
  }

  /// Hitung target scroll untuk indeks dalam grid.
  double computeScrollTargetForIndex(
    int index,
    double screenWidth, {
    int columns = 2,
    double horizontalPadding = 32.0,
    double spacing = 12.0,
    double childAspectRatio = 0.75,
  }) {
    return calcComputeScrollTargetForIndex(
      index,
      screenWidth,
      columns: columns,
      horizontalPadding: horizontalPadding,
      spacing: spacing,
      childAspectRatio: childAspectRatio,
    );
  }
}
