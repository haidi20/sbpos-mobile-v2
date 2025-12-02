import 'package:core/core.dart';
import 'transaction.state.dart';
import 'package:product/domain/entities/product_entity.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/usecases/get_transaction.usecase.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:transaction/domain/usecases/create_transaction.usecase.dart';
import 'package:transaction/domain/usecases/update_transaction.usecase.dart';
import 'package:transaction/domain/usecases/delete_transaction.usecase.dart';

class TransactionViewModel extends StateNotifier<TransactionState> {
  final CreateTransaction _createTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;
  final GetTransaction _getTransaction;
  final _logger = Logger('TransactionViewModel');

  TransactionViewModel(
    this._createTransaction,
    this._updateTransaction,
    this._deleteTransaction,
    this._getTransaction,
  ) : super(TransactionState()) {
    // load existing transaction from local DB (offline) on init
    _loadLocalTransaction();
  }

  // Persist updated details (and optionally notes) to local DB first,
  // then update state only when persistence succeeds.
  Future<void> _persistAndUpdateState(
      List<TransactionDetailEntity> updatedDetails,
      {String? orderNote}) async {
    try {
      state = state.copyWith(isLoading: true);

      final totalAmount = updatedDetails.fold<int>(0, (sum, d) {
        return sum + (d.subtotal ?? ((d.productPrice ?? 0) * (d.qty ?? 0)));
      });
      final totalQty =
          updatedDetails.fold<int>(0, (sum, d) => sum + (d.qty ?? 0));
      // _logger.info(
      //     "Persisting transaction: totalAmount=$totalAmount, totalQty=$totalQty, detailsCount=${updatedDetails.length}");

      // Build transaction entity to persist
      if (state.transaction == null) {
        final txEntity = TransactionEntity(
          warehouseId: state.transaction?.warehouseId ?? 8,
          sequenceNumber: state.transaction?.sequenceNumber ?? 0,
          orderTypeId: state.transaction?.orderTypeId ?? 1,
          date: DateTime.now(),
          totalAmount: totalAmount,
          totalQty: totalQty,
          notes: orderNote ?? state.orderNote,
          details: updatedDetails,
        );

        final res = await _createTransaction.call(txEntity, isOffline: true);
        res.fold((f) {
          _logger.severe('Create transaction failed: $f');
          state = state.copyWith(isLoading: false);
        }, (created) {
          final updatedDetailsFromServer = created.details ?? updatedDetails;
          state = state.copyWith(
            transaction: created,
            details: updatedDetailsFromServer,
            isLoading: false,
          );
        });
      } else {
        // existing transaction
        if (updatedDetails.isEmpty) {
          // delete transaction first
          final txId = state.transaction?.id;
          if (txId != null) {
            final res = await _deleteTransaction.call(txId, isOffline: true);
            res.fold((f) {
              _logger.severe('Delete transaction failed: $f');
              state = state.copyWith(isLoading: false);
            }, (ok) {
              state = state.copyWith(
                details: [],
                transaction: null,
                orderNote: "",
                activeNoteId: null,
                isLoading: false,
              );
            });
          } else {
            state = state.copyWith(transaction: null, isLoading: false);
          }
        } else {
          final txEntity = state.transaction!.copyWith(
            details: updatedDetails,
            totalAmount: totalAmount,
            totalQty: totalQty,
            notes: orderNote ?? state.orderNote,
          );

          // _logger.info(
          //     "Updating transaction id=${txEntity.id}, totalAmount=$totalAmount, totalQty=$totalQty, detailsCount=${updatedDetails.length}");

          final res = await _updateTransaction.call(txEntity, isOffline: true);
          res.fold((f) {
            _logger.severe("Failed to update transaction: $f");
            state = state.copyWith(isLoading: false);
          }, (updated) {
            _logger.info(
                "Updated transaction id=${updated.id}, detailsCount=${updated.details?.length ?? 0}");
            state = state.copyWith(
                transaction: updated,
                details: updated.details ?? updatedDetails,
                isLoading: false);
          });
        }
      }
    } catch (e) {
      _logger.severe('PersistAndUpdateState failed', e as Object?);
      state = state.copyWith(isLoading: false);
    }
  }

  // attempt to load existing transaction from local db using isOffline=true
  Future<void> _loadLocalTransaction() async {
    try {
      // use a default id to load, adjust if app stores current transaction id elsewhere
      const int defaultTxId = 1;
      final res = await _getTransaction.call(defaultTxId, isOffline: true);
      res.fold((f) {
        // silently ignore failures for init (keep state.transaction null)
        // optionally set state.error: state = state.copyWith(error: f.toString());
        _logger
            .info('_loadLocalTransaction: no existing local transaction found');
      }, (tx) {
        _logger.info("details length", tx.details?.length.toString());
        state = state.copyWith(transaction: tx, details: tx.details ?? []);
      });
    } catch (e) {
      // ignore init load errors
    }
  }

  List<TransactionDetailEntity> get filteredDetails {
    final query = state.searchQuery?.toLowerCase() ?? "";
    final category = state.activeCategory;

    return state.details.where((item) {
      final matchesQuery =
          item.productName?.toLowerCase().contains(query) ?? false;
      final matchesCategory = category == "All" ||
          (item.note?.toLowerCase() == category.toLowerCase());
      return matchesQuery && matchesCategory;
    }).toList();
  }

  String get cartTotal {
    final total = state.details.fold<int>(0, (sum, item) {
      if (item.subtotal != null) return sum + (item.subtotal ?? 0);
      final price = item.productPrice ?? 0;
      final qty = item.qty ?? 0;
      return sum + (price * qty);
    });
    return formatRupiah(total.toDouble());
  }

  int get cartCount =>
      state.details.fold(0, (sum, item) => sum + (item.qty ?? 0));

  Future<void> setUpdateQuantity(int productId, int delta) async {
    final index =
        state.details.indexWhere((item) => item.productId == productId);
    if (index == -1) return;

    final updated = List<TransactionDetailEntity>.from(state.details);
    // Defensive check
    if (index < 0 || index >= updated.length) return;
    final old = updated[index];
    final newQty = (old.qty ?? 0) + delta;
    if (newQty <= 0) {
      updated.removeAt(index);
    } else {
      final price = old.productPrice ?? 0;
      updated[index] = old.copyWith(qty: newQty, subtotal: price * newQty);
    }

    // persist to DB first, then update state when success
    await _persistAndUpdateState(updated);
  }

  // Update Item Note
  Future<void> setItemNote(int productId, String note) async {
    final index = state.details.indexWhere((i) => i.productId == productId);
    if (index == -1) return;
    final updated = List<TransactionDetailEntity>.from(state.details);
    final old = updated[index];
    updated[index] = old.copyWith(note: note);
    // persist note update first
    unawaited(_persistAndUpdateState(updated));
  }

  // Set Order Note
  Future<void> setOrderNote(String note) async {
    // Persist order note change to DB then update state
    final updatedDetails = List<TransactionDetailEntity>.from(state.details);
    unawaited(_persistAndUpdateState(updatedDetails, orderNote: note));
  }

  // Set active category
  void setActiveCategory(String category) {
    state = state.copyWith(activeCategory: category);
  }

  // Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  // Clear Cart
  // Clear Cart — use DeleteTransaction usecase for existing local transaction
  Future<void> onClearCart() async {
    try {
      state = state.copyWith(isLoading: true);

      final txId = state.transaction?.id;
      if (txId != null) {
        final res = await _deleteTransaction.call(txId, isOffline: true);
        res.fold((f) {
          state = state.copyWith(error: f.toString(), isLoading: false);
        }, (ok) {
          state = state.copyWith(
            details: [],
            transaction: null,
            orderNote: "",
            activeNoteId: null,
            isLoading: false,
          );
        });
        return;
      }

      // No transaction to delete; just clear local state
      state = state.copyWith(
        details: [],
        transaction: null,
        orderNote: "",
        activeNoteId: null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Set Active Note ID
  void setActiveNoteId(int? id) {
    state = state.copyWith(activeNoteId: id);
  }

  Future<void> onAddToCart(ProductEntity product) async {
    final index = state.details.indexWhere((d) => d.productId == product.id);
    List<TransactionDetailEntity> updated;
    if (index != -1) {
      updated = List<TransactionDetailEntity>.from(state.details);
      final old = updated[index];
      final newQty = (old.qty ?? 0) + 1;
      updated[index] = old.copyWith(
        qty: newQty,
        subtotal: (old.productPrice ?? product.price?.toInt() ?? 0) * newQty,
      );
    } else {
      final newDetail = TransactionDetailEntity(
        productId: product.id,
        productName: product.name,
        productPrice: product.price?.toInt(),
        qty: 1,
        subtotal: product.price?.toInt(),
        transactionId: state.transaction?.id,
      );
      updated = List<TransactionDetailEntity>.from(state.details)
        ..add(newDetail);
      // _logger.info("details length", updated.length.toString());
    }

    // _logger.info("adding to cart, total items: ${updated.length}");

    // persist to DB first, update state after success
    await _persistAndUpdateState(updated);
  }

  Future<void> onStoreLocal({ProductEntity? product}) async {
    // onStoreLocal: perform DB-first persistence using current state.details
    await _persistAndUpdateState(
        List<TransactionDetailEntity>.from(state.details));
  }
}
