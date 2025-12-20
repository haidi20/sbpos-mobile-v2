part of 'transaction_pos.vm.dart';

// Detail-list pure helpers moved here from transaction_pos.details_helpers.dart
/// Tambah atau perbarui produk pada daftar detail transaksi.
List<TransactionDetailEntity> addOrUpdateProductInDetails(
  List<TransactionDetailEntity> details,
  ProductEntity product, {
  int transactionId = 0,
}) {
  final idx = details.indexWhere((d) => d.productId == product.id);
  final updated = List<TransactionDetailEntity>.from(details);
  if (idx != -1) {
    final old = updated[idx];
    final newQty = (old.qty ?? 0) + 1;
    updated[idx] = old.copyWith(
      qty: newQty,
      subtotal: (old.productPrice ?? product.price?.toInt() ?? 0) * newQty,
    );
  } else {
    updated.add(TransactionDetailEntity.fromProductEntity(
      transactionId: transactionId,
      product: product,
      qty: 1,
    ));
  }
  return updated;
}

/// Tambah atau perbarui paket pada daftar detail transaksi.
List<TransactionDetailEntity> addOrUpdatePacketInDetails(
  List<TransactionDetailEntity> details,
  PacketEntity packet, {
  int? transactionId,
}) {
  final idx = details.indexWhere((d) => d.packetId == packet.id);
  final updated = List<TransactionDetailEntity>.from(details);
  if (idx != -1) {
    final old = updated[idx];
    final newQty = (old.qty ?? 0) + 1;
    updated[idx] = old.copyWith(
      qty: newQty,
      subtotal: (old.packetPrice ?? packet.price ?? 0) * newQty,
    );
  } else {
    final newDetail = TransactionDetailEntity(
      packetId: packet.id,
      packetName: packet.name,
      packetPrice: packet.price,
      qty: 1,
      subtotal: packet.price,
      transactionId: transactionId,
    );
    updated.add(newDetail);
  }
  return updated;
}

/// Tambah daftar item paket ke daftar detail transaksi.
List<TransactionDetailEntity> addPacketItemsToDetails(
  List<TransactionDetailEntity> details,
  List<TransactionDetailEntity> toAdd,
) {
  final updated = List<TransactionDetailEntity>.from(details);
  for (final d in toAdd) {
    final index = updated.indexWhere((e) => e.productId == d.productId);
    if (index != -1) {
      final old = updated[index];
      final newQty = (old.qty ?? 0) + (d.qty ?? 1);
      updated[index] = old.copyWith(
        qty: newQty,
        subtotal: (old.productPrice ?? d.productPrice ?? 0) * newQty,
      );
    } else {
      updated.add(d);
    }
  }
  return updated;
}

/// Perbarui kuantitas untuk item tertentu di detail transaksi.
List<TransactionDetailEntity> updateQuantityInDetails(
  List<TransactionDetailEntity> details,
  int productId,
  int valueAddQty,
) {
  final index = details.indexWhere((item) => item.productId == productId);
  if (index == -1) return details;
  final updated = List<TransactionDetailEntity>.from(details);
  final old = updated[index];
  final newQty = (old.qty ?? 0) + valueAddQty;
  if (newQty <= 0) {
    updated.removeAt(index);
  } else {
    final price = old.productPrice ?? 0;
    updated[index] = old.copyWith(qty: newQty, subtotal: price * newQty);
  }
  return updated;
}

mixin TransactionPosViewModelActions on StateNotifier<TransactionPosState> {
  TransactionPosViewModel get _vm => this as TransactionPosViewModel;
  // ------------------ Actions (on*) ------------------
  /// Action: tambahkan produk ke keranjang.
  Future<void> onAddToCart(ProductEntity product) async {
    _vm._logger.fine(
        'onAddToCart: start, isLoading=${state.isLoading}, isLoadingPersistent=${state.isLoadingPersistent}');

    final updated = addOrUpdateProductInDetails(
      state.details,
      product,
      transactionId: state.transaction?.id ?? 0,
    );

    _vm._logger.fine(
        'onAddToCart: updating details locally (count=${updated.length})');
    state = state.copyWith(details: updated);

    if (state.transaction == null) {
      if (_vm._isCreatingTx) {
        await (_vm._createTxCompleter?.future);
        unawaited(_vm._persistence.persistOnly(state, updated));
        return;
      }

      _vm._isCreatingTx = true;
      _vm._createTxCompleter = Completer<void>();
      try {
        await _vm._persistence.persistAndUpdateState(
          () => state,
          (s) => state = s,
          List<TransactionDetailEntity>.from(state.details),
        );
      } finally {
        _vm._isCreatingTx = false;
        _vm._createTxCompleter?.complete();
        _vm._createTxCompleter = null;
      }
      return;
    }

    // Pastikan perubahan detail di-persist dan state diperbarui
    await _vm._persistence.persistAndUpdateState(
      () => state,
      (s) => state = s,
      updated,
    );
  }

  /// Action: tambahkan paket ke keranjang.
  Future<void> onAddPacketToCart({required PacketEntity packet}) async {
    final updated = addOrUpdatePacketInDetails(
      state.details,
      packet,
      transactionId: state.transaction?.id,
    );

    if (state.transaction == null) {
      if (_vm._isCreatingTx) {
        await (_vm._createTxCompleter?.future);
        unawaited(_vm._persistence.persistOnly(state, updated));
        return;
      }

      _vm._isCreatingTx = true;
      _vm._createTxCompleter = Completer<void>();
      try {
        await _vm._persistence.persistAndUpdateState(
          () => state,
          (s) => state = s,
          updated,
        );
      } finally {
        _vm._isCreatingTx = false;
        _vm._createTxCompleter?.complete();
        _vm._createTxCompleter = null;
      }
      return;
    }

    await _vm._persistence.persistAndUpdateState(
      () => state,
      (s) => state = s,
      updated,
    );
  }

  /// Action: tambahkan beberapa item paket ke keranjang.
  Future<void> onAddPacketItems(
      List<TransactionDetailEntity> detailsToAdd) async {
    final updated = addPacketItemsToDetails(state.details, detailsToAdd);

    if (state.transaction == null) {
      if (_vm._isCreatingTx) {
        await (_vm._createTxCompleter?.future);
        unawaited(_vm._persistence.persistOnly(state, updated));
        return;
      }

      _vm._isCreatingTx = true;
      _vm._createTxCompleter = Completer<void>();
      try {
        await _vm._persistence.persistAndUpdateState(
          () => state,
          (s) => state = s,
          updated,
        );
      } finally {
        _vm._isCreatingTx = false;
        _vm._createTxCompleter?.complete();
        _vm._createTxCompleter = null;
      }
      return;
    }

    await _vm._persistence.persistAndUpdateState(
      () => state,
      (s) => state = s,
      updated,
    );
  }

  /// Buat dan tambahkan detail untuk pilihan paket yang dipilih.
  Future<void> addPacketSelection({
    required PacketEntity packet,
    required List<SelectedPacketItem> selectedItems,
  }) async {
    final details = <TransactionDetailEntity>[];
    for (final s in selectedItems) {
      final pid = s.productId;
      final qty = s.qty;
      final prod = _vm._cachedProducts.firstWhere(
        (p) => p.id == pid,
        orElse: () => ProductEntity(id: pid),
      );
      details.add(TransactionDetailEntity.fromProductEntity(
        transactionId: state.transaction?.id ?? 0,
        product: prod,
        qty: qty,
        packetId: packet.id,
        packetName: packet.name,
        packetPrice: packet.price?.toInt(),
      ));
    }
    if (details.isNotEmpty) await onAddPacketItems(details);
  }

  /// Simpan transaksi (force status 'proses').
  Future<void> onStore({ProductEntity? product}) async {
    await _vm._persistence.persistAndUpdateState(
      () => state,
      (s) => state = s,
      List<TransactionDetailEntity>.from(state.details),
      forceStatus: TransactionStatus.proses,
    );
  }

  /// Ubah tampilan langkah pembayaran (incremental).
  Future<void> onShowMethodPayment() async {
    final ETypeCart current = state.typeCart;
    if (current == ETypeCart.main) {
      state = state.copyWith(typeCart: ETypeCart.confirm);
    } else {
      state = state.copyWith(typeCart: ETypeCart.checkout);
    }
  }

  /// Segarkan paket dan produk secara offline.
  Future<void> refreshProductsAndPackets({String? packetQuery}) async {
    if (_vm._isRefreshing) return;

    _vm._isRefreshing = true;
    state = state.copyWith(isLoadingContent: true);
    try {
      await _vm.getPacketsList(query: packetQuery);
      await _vm._loadProductsAndCategories();

      // Jika paket dan produk keduanya kosong, pastikan UI menampilkan kondisi kosong
      if (state.packets.isEmpty && _vm._cachedProducts.isEmpty) {
        state = state.copyWith(packets: []);
      }
    } catch (e, st) {
      _vm._logger.warning('refreshProductsAndPackets failed: $e', e, st);
    } finally {
      _vm._isRefreshing = false;
      state = state.copyWith(isLoadingContent: false);
    }
  }

  /// Muat produk & kategori (offline) dan perbarui cache.
  Future<void> _loadProductsAndCategories() async {
    try {
      if (_vm._getProductsUsecase == null) {
        _vm._logger.info('no products usecase provided');
        _vm._cachedProducts = [];
        if (state.activeCategory.isEmpty) {
          state = state.copyWith(activeCategory: 'Semua');
        }
        return;
      }

      final res = await _vm._getProductsUsecase!(isOffline: true);
      res.fold((f) {
        _vm._logger.info('no products loaded');
        _vm._cachedProducts = [];
        _vm._rebuildCombinedCache();
      }, (list) {
        _vm._cachedProducts = list;
        if (state.activeCategory.isEmpty) {
          state = state.copyWith(activeCategory: 'Semua');
        }
        _vm._rebuildCombinedCache();
      });
    } catch (e, st) {
      _vm._logger.warning('load products/categories error: $e', e, st);
    }
  }

  /// Pastikan transaksi pending lokal sudah dimuat ke state.
  Future<void> ensureLocalPendingTransactionLoaded() async {
    try {
      await _vm._persistence.loadLocalTransaction(
        _vm._getTransactionActive,
        () => state,
        (s) => state = s,
      );
    } catch (e, st) {
      _vm._logger.warning('ensureLocalPendingTransactionLoaded failed', e, st);
    }
  }

  /// Segarkan produk saja (offline).
  Future<void> refreshProducts() async {
    if (_vm._isRefreshing) return;
    _vm._isRefreshing = true;
    state = state.copyWith(isLoadingContent: true);
    try {
      await _vm._loadProductsAndCategories();
    } catch (e, st) {
      _vm._logger.warning('refreshProducts failed: $e', e, st);
    } finally {
      _vm._isRefreshing = false;
      state = state.copyWith(isLoadingContent: false);
    }
  }

  /// Segarkan paket saja (offline).
  Future<void> refreshPackets({String? packetQuery}) async {
    if (_vm._isRefreshing) return;
    _vm._isRefreshing = true;
    state = state.copyWith(isLoadingContent: true);
    try {
      await _vm.getPacketsList(query: packetQuery);
    } catch (e, st) {
      _vm._logger.warning('refreshPackets failed: $e', e, st);
    } finally {
      _vm._isRefreshing = false;
      state = state.copyWith(isLoadingContent: false);
    }
  }

  /// Kosongkan keranjang, termasuk menghapus transaksi remote jika ada.
  Future<void> onClearCart() async {
    try {
      state = state.copyWith(isLoading: true);

      final txId = state.transaction?.id;
      if (txId != null) {
        final res = await _vm._deleteTransaction.call(txId, isOffline: true);
        res.fold((f) {
          state = state.copyWith(error: f.toString(), isLoading: false);
        }, (ok) {
          state = TransactionPosState.cleared();
        });
        return;
      }

      state = TransactionPosState.cleared();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Reset seluruh state POS ke kondisi awal.
  void onClearAll() {
    state = TransactionPosState.cleared();
  }
}
