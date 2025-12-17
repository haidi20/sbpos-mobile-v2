import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:transaction/domain/usecases/create_transaction.usecase.dart';
import 'package:transaction/domain/usecases/update_transaction.usecase.dart';
import 'package:transaction/domain/usecases/delete_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_transaction_active.usecase.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';

class TransactionPersistence {
  final CreateTransaction _createTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;
  final Logger _logger;

  TransactionPersistence(
    this._createTransaction,
    this._updateTransaction,
    this._deleteTransaction,
    this._logger,
  );

  Future<void> persistAndUpdateState(
    TransactionPosState Function() getState,
    void Function(TransactionPosState) setState,
    List<TransactionDetailEntity> updatedDetails, {
    String? orderNote,
    TransactionStatus? forceStatus,
  }) async {
    final currentState = getState();
    setState(currentState.copyWith(isLoading: true));

    try {
      final totalAmount = updatedDetails.fold<int>(0, (sum, d) {
        return sum + (d.subtotal ?? ((d.productPrice ?? 0) * (d.qty ?? 0)));
      });
      final totalQty =
          updatedDetails.fold<int>(0, (sum, d) => sum + (d.qty ?? 0));

      // Create new transaction when none exists
      if (currentState.transaction == null) {
        if (updatedDetails.isEmpty) {
          setState(currentState.copyWith(isLoading: false));
          return;
        }

        final txEntity = TransactionEntity(
          outletId: currentState.transaction?.outletId ?? 1,
          sequenceNumber: currentState.transaction?.sequenceNumber ?? 1,
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
          setState(currentState.copyWith(isLoading: false));
        }, (created) {
          final updatedDetailsFromServer = created.details ?? updatedDetails;
          setState(currentState.copyWith(
            isLoading: false,
            transaction: created,
            details: updatedDetailsFromServer,
          ));
        });

        return;
      }

      // Existing transaction handling
      if (updatedDetails.isEmpty) {
        final txId = currentState.transaction?.id;
        if (txId != null) {
          final res = await _deleteTransaction.call(txId, isOffline: true);
          res.fold((f) {
            _logger.severe('Delete transaction failed: $f');
            setState(currentState.copyWith(isLoading: false));
          }, (ok) {
            setState(currentState.clear(
              clearTransaction: true,
              clearDetails: true,
              clearOrderNote: true,
              resetIsLoading: true,
            ));
          });
        } else {
          setState(currentState.clear(
            clearTransaction: true,
            clearDetails: true,
            clearOrderNote: true,
            resetIsLoading: true,
          ));
        }

        return;
      }

      // Update existing transaction with new details
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

      final res = await _updateTransaction.call(txEntity, isOffline: true);
      res.fold((f) {
        _logger.severe("Failed to update transaction: $f");
        setState(currentState.copyWith(isLoading: false));
      }, (updated) {
        final safeDetails =
            (updated.details != null && (updated.details?.isNotEmpty ?? false))
                ? updated.details!
                : updatedDetails;
        setState(currentState.copyWith(
            transaction: updated, details: safeDetails, isLoading: false));
      });
    } catch (e, st) {
      _logger.severe('PersistAndUpdateState failed', e, st);
      setState(getState().copyWith(isLoading: false));
    }
  }

  /// Load the active local transaction (isOffline=true) and apply it to state.
  Future<void> loadLocalTransaction(
    GetTransactionActive getTransactionActive,
    TransactionPosState Function() getState,
    void Function(TransactionPosState) setState,
  ) async {
    _logger.info('loadLocalTransaction: starting load from local DB...');
    try {
      final res = await getTransactionActive.call(isOffline: true);
      res.fold((f) {
        _logger
            .info('loadLocalTransaction: no existing local transaction found');
      }, (tx) {
        _logger.info(
            'Loaded local transaction, details length: ${tx.details?.length ?? 0}');
        setState(
            getState().copyWith(transaction: tx, details: tx.details ?? []));
      });
    } catch (e, st) {
      _logger.warning('loadLocalTransaction failed', e, st);
    }
  }
}
