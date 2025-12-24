part of 'transaction_pos.vm.dart';

mixin TransactionPosViewModelSetters on StateNotifier<TransactionPosState> {
  TransactionPosViewModel get _vm => this as TransactionPosViewModel;
  // ------------------ Setter / Mutator ------------------
  /// Perbarui kuantitas item dan persist perubahan.
  Future<void> setUpdateQuantity(int productId, int valueAddQty) async {
    final updated =
        updateQuantityInDetails(state.details, productId, valueAddQty);
    if (identical(updated, state.details)) return;

    await _vm._persistence.persistAndUpdateState(
      () => state,
      (s) => state = s,
      updated,
    );
  }

  /// Tambahkan atau perbarui produk ke dalam detail keranjang dan persist.
  Future<void> addProductToCart(ProductEntity product) async {
    final updated = addOrUpdateProductInDetails(
      state.details,
      product,
      transactionId: state.transaction?.id ?? 0,
    );
    await _vm._persistence.persistAndUpdateState(
      () => state,
      (s) => state = s,
      updated,
    );
  }

  /// Tambahkan atau perbarui paket ke dalam detail keranjang dan persist.
  Future<void> addPacketToCart(PacketEntity packet) async {
    final updated = addOrUpdatePacketInDetails(
      state.details,
      packet,
      transactionId: state.transaction?.id,
    );
    await _vm._persistence.persistAndUpdateState(
      () => state,
      (s) => state = s,
      updated,
    );
  }

  /// Tambahkan beberapa item paket ke detail keranjang dan persist.
  Future<void> addPacketItems(
      List<TransactionDetailEntity> detailsToAdd) async {
    final updated = addPacketItemsToDetails(state.details, detailsToAdd);
    await _vm._persistence.persistAndUpdateState(
      () => state,
      (s) => state = s,
      updated,
    );
  }

  /// Set catatan untuk item tertentu (debounced persist).
  Future<void> setItemNote(int productId, String note) async {
    final index = state.details.indexWhere((i) => i.productId == productId);
    if (index == -1) return;

    final updatedLocal = List<TransactionDetailEntity>.from(state.details);
    final old = updatedLocal[index];
    updatedLocal[index] = old.copyWith(note: note);
    state = state.copyWith(details: updatedLocal);

    _vm._itemNoteDebounces[productId]?.cancel();
    _vm._itemNoteDebounces[productId] =
        Timer(const Duration(milliseconds: 400), () {
      unawaited(_vm._persistence.persistAndUpdateState(
        () => state,
        (s) => state = s,
        List<TransactionDetailEntity>.from(state.details),
      ));
    });
  }

  /// Set catatan order (debounced persist ke persistence).
  Future<void> setOrderNote(String note) async {
    state = state.copyWith(orderNote: note);
    _vm._orderNoteDebounce?.cancel();
    _vm._orderNoteDebounce = Timer(const Duration(milliseconds: 500), () {
      final updatedDetails = List<TransactionDetailEntity>.from(state.details);
      unawaited(
        _vm._persistence.persistOnly(
          state,
          updatedDetails,
          orderNote: state.orderNote,
        ),
      );
    });
  }

  /// Set atau hapus selected customer pada state.
  void setCustomer(CustomerEntity? customer) {
    if (customer == null) {
      state = state.clear(clearSelectedCustomer: true);
      return;
    } else {
      state = state.copyWith(selectedCustomer: customer);
    }
  }

  /// Set kategori aktif dan persist pilihan.
  void setActiveCategory(String category) {
    state = state.copyWith(activeCategory: category);
    unawaited(
      _vm._persistence.persistOnly(
        state,
        List<TransactionDetailEntity>.from(state.details),
      ),
    );
    (this as TransactionPosViewModel)._rebuildCombinedCache();
  }

  /// Set query pencarian dan rebuild cache konten.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _vm._rebuildCombinedCache();
  }

  /// Set active catatan id dan persist perubahan (opsional latar belakang).
  Future<void> setActiveNoteId(int? id,
      {bool persist = true, bool background = false}) async {
    if (id == null) {
      state = state.clear(clearActiveNoteId: true);
      if (!persist) return;
      if (background) {
        unawaited(
          _vm._persistence.persistOnly(
            state,
            List<TransactionDetailEntity>.from(state.details),
          ),
        );

        return;
      }

      await _vm._persistence.persistOnly(
        state,
        List<TransactionDetailEntity>.from(state.details),
      );

      return;
    }

    state = state.copyWith(activeNoteId: id);
    if (!persist) return;
    if (background) {
      unawaited(
        _vm._persistence.persistOnly(
          state,
          List<TransactionDetailEntity>.from(state.details),
        ),
      );
      return;
    }

    await _vm._persistence.persistOnly(
      state,
      List<TransactionDetailEntity>.from(state.details),
    );
  }

  /// Set tipe cart/view pada UI.
  void setTypeCart(ETypeCart type) {
    state = state.copyWith(typeCart: type);
  }

  /// Set tipe order dan persist pilihan.
  void setOrderType(EOrderType type) {
    state = state.copyWith(orderType: type);
    unawaited(
      _vm._persistence.persistOnly(
        state,
        List<TransactionDetailEntity>.from(state.details),
      ),
    );
  }

  /// Set order type dari string id mentah (mendukung id numerik dari data dummy
  /// atau kunci lokal/kanonikal) dan persist melalui `setOrderType`.
  void setOrderTypeById(String rawId) {
    final id = rawId.toLowerCase();
    if (id == '1' ||
        id == 'dine_in' ||
        id == 'dinein' ||
        id.contains('makan')) {
      setOrderType(EOrderType.dineIn);
      return;
    }
    if (id == '2' ||
        id == 'take_away' ||
        id.contains('bungkus') ||
        id.contains('take')) {
      setOrderType(EOrderType.takeAway);
      return;
    }
    if (id == '3' || id == 'online' || id.contains('ojol')) {
      setOrderType(EOrderType.online);
      return;
    }
    // Cadangan: try matching by enum name
    for (final e in EOrderType.values) {
      if (e.name.toLowerCase() == id) {
        setOrderType(e);
        return;
      }
    }
  }

  /// Set provider ojol dan persist.
  void setOjolProvider(String provider) {
    state = state.copyWith(ojolProvider: provider);
    unawaited((this as TransactionPosViewModel)
        ._persistence
        .persistOnly(state, List<TransactionDetailEntity>.from(state.details)));
  }

  /// Set metode pembayaran dan persist.
  void setPaymentMethod(EPaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
    unawaited(
      _vm._persistence.persistOnly(
        state,
        List<TransactionDetailEntity>.from(state.details),
      ),
    );
  }

  /// Pilih tipe order berdasarkan id string (digunakan oleh controller)
  // `selectOrderTypeById` dihapus — gunakan `setOrderType(EOrderType)` langsung.

  /// Tandai transaksi telah dibayar dan persist.
  void setIsPaid(bool v) {
    state = state.copyWith(isPaid: v);
    unawaited(
      _vm._persistence.persistOnly(
        state,
        List<TransactionDetailEntity>.from(state.details),
      ),
    );
  }

  /// Perbarui jumlah cash yang diterima dan persist.
  void setCashReceived(int amount) {
    state = state.copyWith(cashReceived: amount);
    unawaited((this as TransactionPosViewModel)
        ._persistence
        .persistOnly(state, List<TransactionDetailEntity>.from(state.details)));
  }

  /// Siapkan VM untuk mengubah transaksi yang sudah ada.
  /// Memasukkan `transaction` dan `details` ke state dan menandai mode sebagai `edit`.
  Future<void> setTransactionForEdit(TransactionEntity txn) async {
    // Pemetaan field TransactionEntity ke state POS agar input form menampilkan nilai
    EOrderType mapOrderType(int? id) {
      if (id == 2) return EOrderType.takeAway;
      if (id == 3) return EOrderType.online;
      return EOrderType.dineIn;
    }

    EPaymentMethod mapPayment(String? raw) {
      final v = (raw ?? '').toLowerCase();
      if (v.contains('qris')) return EPaymentMethod.qris;
      if (v.contains('transfer')) return EPaymentMethod.transfer;
      return EPaymentMethod.cash;
    }

    state = state.copyWith(
      transaction: txn,
      details: txn.details ?? [],
      orderNote: txn.notes ?? '',
      orderType: mapOrderType(txn.orderTypeId),
      paymentMethod: mapPayment(txn.paymentMethod),
      cashReceived: txn.paidAmount ?? 0,
      isPaid: txn.isPaid,
      ojolProvider: txn.ojolProvider ?? '',
      useTableNumber: (txn.numberTable != null),
      tableNumber: txn.numberTable,
    );
    state = state.copyWith(transactionMode: ETransactionMode.edit);
  }

  /// Tampilkan atau sembunyikan snackbar error.
  void setShowErrorSnackbar(bool v) {
    state = state.copyWith(showErrorSnackbar: v);
  }

  /// Gunakan atau nonaktifkan nomor meja, lalu persist perubahan.
  void setUseTableNumber(bool v) {
    state = v
        ? state.copyWith(useTableNumber: true)
        : state.copyWith(useTableNumber: false, tableNumber: null);
    unawaited(
      _vm._persistence.persistOnly(
        state,
        List<TransactionDetailEntity>.from(state.details),
      ),
    );
  }

  /// Set nomor meja (nullable), lalu persist perubahan.
  void setTableNumber(int? number) {
    state = state.copyWith(tableNumber: number);
    unawaited(
      _vm._persistence.persistOnly(
        state,
        List<TransactionDetailEntity>.from(state.details),
      ),
    );
  }
}
