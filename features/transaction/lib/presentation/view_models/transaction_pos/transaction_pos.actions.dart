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

  OjolProviderUiModel _mapOjolProviderUi(String id, String name) {
    final lower = '$id $name'.toLowerCase();
    if (lower.contains('go')) {
      return OjolProviderUiModel(
        id: id,
        name: name,
        icon: Icons.delivery_dining,
        color: Colors.red.shade600,
      );
    }
    if (lower.contains('grab')) {
      return OjolProviderUiModel(
        id: id,
        name: name,
        icon: Icons.pedal_bike,
        color: Colors.green.shade600,
      );
    }
    if (lower.contains('shop')) {
      return OjolProviderUiModel(
        id: id,
        name: name,
        icon: Icons.shopping_bag,
        color: Colors.orange.shade700,
      );
    }
    return OjolProviderUiModel(
      id: id,
      name: name,
      icon: Icons.local_shipping_outlined,
      color: Colors.blueGrey,
    );
  }

  TransactionEntity _buildCheckoutTransaction() {
    final totalAmount = _vm.getCartTotalValue;
    final totalQty =
        state.details.fold<int>(0, (sum, detail) => sum + (detail.qty ?? 0));
    final isOnlineOrder = state.orderType == EOrderType.online;
    final paidAmount =
        state.paymentMethod == EPaymentMethod.cash ? state.cashReceived : totalAmount;
    final changeMoney =
        state.paymentMethod == EPaymentMethod.cash && state.cashReceived > totalAmount
            ? state.cashReceived - totalAmount
            : 0;

    final current = state.transaction;
    if (current != null) {
      return current.copyWith(
        details: List<TransactionDetailEntity>.from(state.details),
        totalAmount: totalAmount,
        totalQty: totalQty,
        orderTypeId: state.orderType.index + 1,
        categoryOrder: isOnlineOrder ? 'ONLINE' : state.activeCategory,
        paymentMethod: state.paymentMethod.name,
        paidAmount: paidAmount,
        changeMoney: changeMoney.toInt(),
        isPaid: state.isPaid,
        notes: state.orderNote,
        customerSelected: state.selectedCustomer,
        customerId: state.selectedCustomer?.id,
        customerType: state.selectedCustomer != null ? 'customer' : null,
        ojolProvider: state.ojolProvider,
        numberTable: state.useTableNumber ? state.tableNumber : null,
        status: state.isPaid ? TransactionStatus.lunas : TransactionStatus.pending,
      );
    }

    return TransactionEntity(
      outletId: 1,
      sequenceNumber: 0,
      orderTypeId: state.orderType.index + 1,
      categoryOrder: isOnlineOrder ? 'ONLINE' : state.activeCategory,
      customerId: state.selectedCustomer?.id,
      customerType: state.selectedCustomer != null ? 'customer' : null,
      customerSelected: state.selectedCustomer,
      paymentMethod: state.paymentMethod.name,
      numberTable: state.useTableNumber ? state.tableNumber : null,
      date: DateTime.now(),
      notes: state.orderNote,
      totalAmount: totalAmount,
      totalQty: totalQty,
      paidAmount: paidAmount,
      changeMoney: changeMoney.toInt(),
      isPaid: state.isPaid,
      status: state.isPaid ? TransactionStatus.lunas : TransactionStatus.pending,
      ojolProvider: state.ojolProvider,
      details: List<TransactionDetailEntity>.from(state.details),
    );
  }

  // ------------------ Actions (on*) ------------------
  /// Action: tambahkan produk ke keranjang.
  Future<void> onAddToCart({required ProductEntity product}) async {
    _vm._logger.fine('onAddToCart: delegating to setter addProductToCart');
    await _vm.addProductToCart(product);
  }

  Future<Either<Failure, bool>> validateAndAddProductToCart({
    required ProductEntity product,
    int qty = 1,
  }) async {
    final checker = _vm._checkTransactionQty;
    final displayProduct = _vm.resolveDisplayProduct(product);

    if (checker == null || displayProduct.id == null) {
      await _vm.addProductToCart(displayProduct);
      return const Right(true);
    }

    final result = await checker(
      productId: displayProduct.id!,
      qty: qty,
    );

    return result.fold(
      (failure) async => Left(failure),
      (_) async {
        await _vm.addProductToCart(displayProduct);
        return const Right(true);
      },
    );
  }

  /// Action: tambahkan paket ke keranjang.
  Future<void> onAddPacketToCart({required PacketEntity packet}) async {
    _vm._logger.fine('onAddPacketToCart: delegating to setter addPacketToCart');
    await _vm.addPacketToCart(packet);
  }

  /// Action: tambahkan beberapa item paket ke keranjang.
  Future<void> onAddPacketItems(
      List<TransactionDetailEntity> detailsToAdd) async {
    _vm._logger.fine('onAddPacketItems: delegating to setter addPacketItems');
    await _vm.addPacketItems(detailsToAdd);
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

  ReceiptPrintJob buildReceiptPrintJob(TransactionEntity transaction) {
    final lines = <ReceiptPrintLine>[
      ReceiptPrintLine(
        label: 'No. Order',
        value: '#${transaction.sequenceNumber}',
        emphasize: true,
      ),
      ReceiptPrintLine(
        label: 'Tanggal',
        value: transaction.date.dateTimeReadable(),
      ),
      ReceiptPrintLine(
        label: 'Tipe Order',
        value: transaction.categoryOrder ?? '-',
      ),
      ReceiptPrintLine(
        label: 'Metode Bayar',
        value: (transaction.paymentMethod ?? '-').toUpperCase(),
      ),
    ];

    for (final detail in transaction.details ?? const <TransactionDetailEntity>[]) {
      final detailName = detail.productName ?? detail.packetName ?? 'Item';
      lines.add(
        ReceiptPrintLine(
          label: '$detailName x${detail.qty ?? 0}',
          value: formatRupiah((detail.subtotal ?? 0).toDouble()),
        ),
      );
    }

    lines.add(
      ReceiptPrintLine(
        label: 'Total',
        value: formatRupiah(transaction.totalAmount.toDouble()),
        emphasize: true,
      ),
    );
    lines.add(
      ReceiptPrintLine(
        label: 'Bayar',
        value: formatRupiah((transaction.paidAmount ?? 0).toDouble()),
      ),
    );
    lines.add(
      ReceiptPrintLine(
        label: 'Kembalian',
        value: formatRupiah(transaction.changeMoney.toDouble()),
      ),
    );

    return ReceiptPrintJob(
      title: 'SB POS',
      lines: lines,
      footer: 'Terima kasih telah berbelanja',
    );
  }

  Future<ReceiptPrintResult> onPrintReceiptJob(ReceiptPrintJob job) async {
    final printerFacade = _vm._printerFacade;
    if (printerFacade == null) {
      return const ReceiptPrintResult.failure(
        'Layanan printer belum dikonfigurasi',
      );
    }

    return printerFacade.printReceipt(job);
  }

  Future<ReceiptPrintResult> onPrintReceipt(TransactionEntity transaction) async {
    final job = buildReceiptPrintJob(transaction);
    return onPrintReceiptJob(job);
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
      await syncMasterData();
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

  Future<void> syncMasterData() async {
    if (state.isSyncingMasterData) {
      return;
    }

    final categoriesUsecase = _vm._getCashierCategories;
    final orderTypesUsecase = _vm._getCashierOrderTypes;
    final ojolUsecase = _vm._getCashierOjolOptions;

    if (categoriesUsecase == null &&
        orderTypesUsecase == null &&
        ojolUsecase == null) {
      return;
    }

    state = state.copyWith(isSyncingMasterData: true);
    try {
      if (categoriesUsecase != null) {
        final categoriesResult = await categoriesUsecase();
        categoriesResult.fold(
          (_) {},
          (categories) {
            state = state.copyWith(customCategories: categories);
          },
        );
      }

      if (orderTypesUsecase != null) {
        final orderTypesResult = await orderTypesUsecase();
        orderTypesResult.fold(
          (_) {},
          (orderTypes) {
            state = state.copyWith(orderTypes: orderTypes);
          },
        );
      }

      if (ojolUsecase != null) {
        final ojolResult = await ojolUsecase();
        ojolResult.fold(
          (_) {},
          (ojolOptions) {
            state = state.copyWith(
              ojolProviders: ojolOptions
                  .where((option) => option.isActive)
                  .map((option) => _mapOjolProviderUi(option.id, option.name))
                  .toList(),
            );
          },
        );
      }
    } finally {
      state = state.copyWith(isSyncingMasterData: false);
    }
  }

  Future<Either<Failure, TransactionEntity>> checkoutCurrentTransaction() async {
    if (state.details.isEmpty) {
      return const Left(LocalValidation('Keranjang masih kosong'));
    }

    final checkoutUsecase = _vm._checkoutTransaction;
    if (checkoutUsecase == null) {
      await onStore();
      final transaction = state.transaction;
      if (transaction == null) {
        return const Left(UnknownFailure());
      }
      return Right(transaction);
    }

    state = state.copyWith(isCheckingOut: true);
    try {
      final payload = _buildCheckoutTransaction();
      final result = await checkoutUsecase(
        payload,
        isOnline: state.orderType == EOrderType.online,
      );

      return await result.fold(
        (failure) async => Left(failure),
        (remoteTransaction) async {
          final mergedTransaction = payload.copyWith(
            idServer: remoteTransaction.idServer ?? remoteTransaction.id,
            status: remoteTransaction.status,
            paidAmount: remoteTransaction.paidAmount ?? payload.paidAmount,
            changeMoney: remoteTransaction.changeMoney,
            details: payload.details,
          );

          final persisted = await _vm._updateTransaction.call(
            mergedTransaction.copyWith(id: state.transaction?.id),
            isOffline: true,
          );

          persisted.fold(
            (_) {
              state = state.copyWith(
                isCheckingOut: false,
                transaction: mergedTransaction,
              );
            },
            (localTransaction) {
              state = state.copyWith(
                isCheckingOut: false,
                transaction: localTransaction,
                details: localTransaction.details ?? state.details,
              );
            },
          );

          return Right(state.transaction ?? mergedTransaction);
        },
      );
    } finally {
      state = state.copyWith(isCheckingOut: false);
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

      _vm._logger.info('calling GetProducts usecase (offline)...');
      final res = await _vm._getProductsUsecase!(isOffline: true);
      res.fold((f) {
        _vm._logger.info('GetProducts returned failure: $f');
        _vm._cachedProducts = [];
        _vm._rebuildCombinedCache();
      }, (list) {
        _vm._logger.info('GetProducts returned ${list.length} products');
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
