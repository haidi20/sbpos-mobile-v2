import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:transaction/domain/usecases/create_transaction.usecase.dart';
import 'package:transaction/domain/usecases/update_transaction.usecase.dart';
import 'package:transaction/domain/usecases/delete_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_transaction_active.usecase.dart';
import 'package:transaction/domain/usecases/get_last_secuence_number_transaction.usecase.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';

class TransactionPersistence {
  final CreateTransaction _createTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;
  final Logger _logger;

  TransactionPersistence(this._createTransaction, this._updateTransaction,
      this._deleteTransaction, this._logger,
      {GetLastSequenceNumberTransaction? getLastSequenceUsecase})
      : _getLastSequenceUsecase = getLastSequenceUsecase;

  final GetLastSequenceNumberTransaction? _getLastSequenceUsecase;

  // Guard to ensure local transaction is loaded at most once unless forced.
  bool _isLoadingLocal = false;
  bool _didLoadLocal = false;
  Completer<void>? _loadLocalCompleter;

  // Persist dan perbarui state dengan detail transaksi yang diperbarui.
  Future<void> persistAndUpdateState(
    TransactionPosState Function() getState,
    void Function(TransactionPosState) setState,
    List<TransactionDetailEntity> updatedDetails, {
    String? orderNote,
    TransactionStatus? forceStatus,
  }) async {
    final currentState = getState();
    // mark persistent loading for long-running persistence
    _logger.fine('persistAndUpdateState: setting isLoadingPersistent=true');
    setState(currentState.copyWith(isLoadingPersistent: true));

    try {
      final totalAmount = updatedDetails.fold<int>(0, (sum, d) {
        return sum + (d.subtotal ?? ((d.productPrice ?? 0) * (d.qty ?? 0)));
      });
      final totalQty =
          updatedDetails.fold<int>(0, (sum, d) => sum + (d.qty ?? 0));

      // Create new transaction when none exists
      if (currentState.transaction == null) {
        if (updatedDetails.isEmpty) {
          setState(currentState.copyWith(isLoadingPersistent: false));
          return;
        }

        // determine next sequence number (try usecase first, fallback to 1)
        int nextSequence = 1;
        try {
          final usecase = _getLastSequenceUsecase;
          if (usecase != null) {
            final last = await usecase.call(isOffline: true);
            if (last > 0) {
              nextSequence = last + 1;
            }
          }
        } catch (_) {
          // ignore and fallback to default
        }

        final txEntity = TransactionEntity(
          outletId: currentState.transaction?.outletId ?? 1,
          sequenceNumber: nextSequence,
          orderTypeId: currentState.orderType.index + 1,
          date: DateTime.now(),
          totalAmount: totalAmount,
          totalQty: totalQty,
          notes: orderNote ?? currentState.orderNote,
          categoryOrder: currentState.activeCategory,
          userId: currentState.selectedCustomer?.id,
          paymentMethod: currentState.paymentMethod.toString().split('.').last,
          ojolProvider: currentState.ojolProvider,
          paidAmount: currentState.isPaid ? currentState.cashReceived : null,
          changeMoney: currentState.cashReceived,
          isPaid: currentState.isPaid,
          status: forceStatus ??
              (currentState.isPaid
                  ? TransactionStatus.lunas
                  : TransactionStatus.pending),
          details: updatedDetails,
        );

        final res = await _createTransaction.call(txEntity, isOffline: true);
        res.fold((f) {
          _logger.severe('Create transaction failed: $f');
          _logger.fine(
              'persistAndUpdateState: clearing isLoadingPersistent (create failed)');
          setState(currentState.copyWith(isLoadingPersistent: false));
        }, (created) {
          // Ensure in-memory state reflects paid status when caller marked it paid.
          final updatedDetailsFromServer = created.details ?? updatedDetails;
          final enforced = created.copyWith(
            status:
                currentState.isPaid ? TransactionStatus.lunas : created.status,
            paidAmount: currentState.isPaid
                ? currentState.cashReceived
                : created.paidAmount,
            changeMoney: currentState.cashReceived,
            details: updatedDetailsFromServer,
          );
          _logger.fine(
              'persistAndUpdateState: create succeeded, clearing isLoadingPersistent');
          setState(currentState.copyWith(
            isLoadingPersistent: false,
            transaction: enforced,
            details: updatedDetailsFromServer,
          ));
        });

        return;
      }

      // Penanganan transaksi yang sudah ada
      if (updatedDetails.isEmpty) {
        final txId = currentState.transaction?.id;
        if (txId != null) {
          final res = await _deleteTransaction.call(txId, isOffline: true);
          res.fold((f) {
            _logger.severe('Delete transaction failed: $f');
            _logger.fine(
                'persistAndUpdateState: clearing isLoadingPersistent (delete failed)');
            setState(currentState.copyWith(isLoadingPersistent: false));
          }, (ok) {
            setState(currentState.clear(
              clearTransaction: true,
              clearDetails: true,
              clearOrderNote: true,
              resetIsLoading: true,
              resetIsLoadingPersistent: true,
            ));
          });
        } else {
          setState(currentState.clear(
            clearTransaction: true,
            clearDetails: true,
            clearOrderNote: true,
            resetIsLoading: true,
            resetIsLoadingPersistent: true,
          ));
        }

        return;
      }

      // Perbarui transaksi yang ada dengan detail baru
      final detailsWithTxId = updatedDetails
          .map((d) => d.copyWith(transactionId: currentState.transaction?.id))
          .toList();

      final txEntity = currentState.transaction!.copyWith(
        details: detailsWithTxId,
        totalAmount: totalAmount,
        totalQty: totalQty,
        notes: orderNote ?? currentState.orderNote,
        orderTypeId: currentState.orderType.index + 1,
        categoryOrder: currentState.activeCategory,
        userId: currentState.selectedCustomer?.id,
        paymentMethod: currentState.paymentMethod.toString().split('.').last,
        ojolProvider: currentState.ojolProvider,
        paidAmount: currentState.isPaid
            ? currentState.cashReceived
            : currentState.transaction!.paidAmount,
        changeMoney: currentState.cashReceived,
        isPaid: currentState.isPaid,
        status: forceStatus ??
            (currentState.isPaid
                ? TransactionStatus.lunas
                : currentState.transaction!.status),
      );

      // ketika update data
      _logger.info("transaction to update: $txEntity");

      final res = await _updateTransaction.call(txEntity, isOffline: true);
      res.fold((f) {
        _logger.severe("Failed to update transaction: $f");
        _logger.fine(
            'persistAndUpdateState: clearing isLoadingPersistent (update failed)');
        setState(currentState.copyWith(isLoadingPersistent: false));
      }, (updated) {
        final safeDetails =
            (updated.details != null && (updated.details?.isNotEmpty ?? false))
                ? updated.details!
                : updatedDetails;
        // If caller intended the transaction to be paid, enforce in-memory status
        final enforcedUpdated = updated.copyWith(
          status:
              currentState.isPaid ? TransactionStatus.lunas : updated.status,
          paidAmount: currentState.isPaid
              ? currentState.cashReceived
              : updated.paidAmount,
          changeMoney: currentState.cashReceived,
          details: safeDetails,
        );
        _logger.fine(
            'persistAndUpdateState: update succeeded, clearing isLoadingPersistent');
        setState(currentState.copyWith(
            transaction: enforcedUpdated,
            details: safeDetails,
            isLoadingPersistent: false));
      });
    } catch (e, st) {
      _logger.severe('PersistAndUpdateState failed', e, st);
      _logger
          .fine('persistAndUpdateState: finally clearing isLoadingPersistent');
      setState(getState().copyWith(isLoadingPersistent: false));
    }
  }

  /// Persist detail yang diperbarui ke database lokal tanpa mengubah state di memori.
  /// Ini akan menulis/membuat/memperbarui/menghapus transaksi lokal tetapi TIDAK memanggil
  /// [setState] sehingga pemanggil dapat memperbarui state UI sendiri tanpa ditimpa hasil persistence.
  Future<void> persistOnly(
    TransactionPosState currentState,
    List<TransactionDetailEntity> updatedDetails, {
    String? orderNote,
    TransactionStatus? forceStatus,
  }) async {
    try {
      final totalAmount = updatedDetails.fold<int>(0, (sum, d) {
        return sum + (d.subtotal ?? ((d.productPrice ?? 0) * (d.qty ?? 0)));
      });
      final totalQty =
          updatedDetails.fold<int>(0, (sum, d) => sum + (d.qty ?? 0));

      // Create new transaction when none exists
      if (currentState.transaction == null) {
        if (updatedDetails.isEmpty) return;

        int nextSequence = 1;
        try {
          final usecase = _getLastSequenceUsecase;
          if (usecase != null) {
            final last = await usecase.call(isOffline: true);
            if (last > 0) nextSequence = last + 1;
          }
        } catch (_) {}

        final txEntity = TransactionEntity(
          outletId: currentState.transaction?.outletId ?? 1,
          sequenceNumber: nextSequence,
          orderTypeId: currentState.orderType.index + 1,
          date: DateTime.now(),
          totalAmount: totalAmount,
          totalQty: totalQty,
          notes: orderNote ?? currentState.orderNote,
          categoryOrder: currentState.activeCategory,
          userId: currentState.selectedCustomer?.id,
          paymentMethod: currentState.paymentMethod.toString().split('.').last,
          ojolProvider: currentState.ojolProvider,
          paidAmount: currentState.isPaid ? currentState.cashReceived : null,
          changeMoney: currentState.cashReceived,
          isPaid: currentState.isPaid,
          status: forceStatus ??
              (currentState.isPaid
                  ? TransactionStatus.lunas
                  : TransactionStatus.pending),
          details: updatedDetails,
        );

        await _createTransaction.call(txEntity, isOffline: true);
        return;
      }

      // Existing transaction handling
      if (updatedDetails.isEmpty) {
        final txId = currentState.transaction?.id;
        if (txId != null) {
          await _deleteTransaction.call(txId, isOffline: true);
        }
        return;
      }

      final detailsWithTxId = updatedDetails
          .map((d) => d.copyWith(transactionId: currentState.transaction?.id))
          .toList();

      final txEntity = currentState.transaction!.copyWith(
        details: detailsWithTxId,
        totalAmount: totalAmount,
        totalQty: totalQty,
        notes: orderNote ?? currentState.orderNote,
        orderTypeId: currentState.orderType.index + 1,
        categoryOrder: currentState.activeCategory,
        userId: currentState.selectedCustomer?.id,
        paymentMethod: currentState.paymentMethod.toString().split('.').last,
        ojolProvider: currentState.ojolProvider,
        paidAmount: currentState.isPaid
            ? currentState.cashReceived
            : currentState.transaction!.paidAmount,
        changeMoney: currentState.cashReceived,
        isPaid: currentState.isPaid,
        status: forceStatus ??
            (currentState.isPaid
                ? TransactionStatus.lunas
                : currentState.transaction!.status),
      );

      await _updateTransaction.call(txEntity, isOffline: true);
    } catch (e, st) {
      _logger.severe('persistOnly failed', e, st);
    }
  }

  // Muat transaksi lokal aktif (isOffline=true) dan terapkan ke state.
  Future<void> loadLocalTransaction(
      GetTransactionActive getTransactionActive,
      TransactionPosState Function() getState,
      void Function(TransactionPosState) setState,
      {bool force = false}) async {
    if (_didLoadLocal && !force) {
      _logger.fine('loadLocalTransaction: already loaded, skipping');
      return;
    }

    if (_isLoadingLocal) {
      _logger.info('loadLocalTransaction: already in progress, awaiting');
      await _loadLocalCompleter?.future;
      return;
    }

    _isLoadingLocal = true;
    _loadLocalCompleter = Completer<void>();
    _logger.info('loadLocalTransaction: starting load from local DB...');
    try {
      // indicate persistent loading while fetching from DB
      setState(getState().copyWith(isLoadingPersistent: true));

      final res = await getTransactionActive.call(isOffline: true);
      res.fold((f) {
        _logger
            .info('loadLocalTransaction: no existing local transaction found');
      }, (tx) {
        // _logger.info(
        //     'Loaded local transaction, details length: ${tx.details?.length ?? 0}');
        _logger.info('status tx lokal: ${tx.statusValue}');
        setState(
            getState().copyWith(transaction: tx, details: tx.details ?? []));
      });
    } catch (e, st) {
      _logger.warning('loadLocalTransaction failed', e, st);
    } finally {
      // clear persistent loading flag
      setState(getState().copyWith(isLoadingPersistent: false));
      _didLoadLocal = true;
      _isLoadingLocal = false;
      _loadLocalCompleter?.complete();
      _loadLocalCompleter = null;
    }
  }
}
