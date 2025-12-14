import 'package:core/core.dart';
import 'package:customer/domain/entities/customer.entity.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:transaction/domain/usecases/create_transaction.usecase.dart';
import 'package:transaction/domain/usecases/update_transaction.usecase.dart';
import 'package:transaction/domain/usecases/delete_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_transaction_active.usecase.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';
import 'package:transaction/presentation/helpers/order_type_icon.helper.dart';
import 'package:transaction/data/dummy/order_type_dummy.dart';

class TransactionPosViewModel extends StateNotifier<TransactionPosState> {
  final CreateTransaction _createTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;
  final GetTransactionActive _getTransactionActive;
  final _logger = Logger('TransactionPosViewModel');
  // Debounce timers for note updates
  Timer? _orderNoteDebounce;
  final Map<int, Timer> _itemNoteDebounces = {};

  TransactionPosViewModel(
    this._createTransaction,
    this._updateTransaction,
    this._deleteTransaction,
    this._getTransactionActive,
  ) : super(TransactionPosState()) {
    // load existing transaction from local DB (offline) on init
    _loadLocalTransaction();
  }

  // ------------------ Getters ------------------
  List<TransactionDetailEntity> get getFilteredDetails {
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

  String get getCartTotal {
    final total = state.details.fold<int>(0, (sum, item) {
      if (item.subtotal != null) return sum + (item.subtotal ?? 0);
      final price = item.productPrice ?? 0;
      final qty = item.qty ?? 0;
      return sum + (price * qty);
    });
    return formatRupiah(total.toDouble());
  }

  int get getCartCount =>
      state.details.fold(0, (sum, item) => sum + (item.qty ?? 0));

  // ------------------ Setters / Mutators ------------------
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

  // Update Item Note with debounce to avoid rapid DB writes
  Future<void> setItemNote(int productId, String note) async {
    final index = state.details.indexWhere((i) => i.productId == productId);
    if (index == -1) return;

    // Update local state immediately for responsive UI
    final updatedLocal = List<TransactionDetailEntity>.from(state.details);
    final old = updatedLocal[index];
    updatedLocal[index] = old.copyWith(note: note);
    state = state.copyWith(details: updatedLocal);

    // Debounce persistence per item
    _itemNoteDebounces[productId]?.cancel();
    _itemNoteDebounces[productId] =
        Timer(const Duration(milliseconds: 400), () {
      unawaited(_persistAndUpdateState(
          List<TransactionDetailEntity>.from(state.details)));
    });
  }

  // Set Order Note with debounce; avoid re-writing details on every keystroke
  Future<void> setOrderNote(String note) async {
    // Update local state immediately for UI
    state = state.copyWith(orderNote: note);

    // Debounce persistence
    _orderNoteDebounce?.cancel();
    _orderNoteDebounce = Timer(const Duration(milliseconds: 500), () {
      final updatedDetails = List<TransactionDetailEntity>.from(state.details);
      unawaited(
          _persistAndUpdateState(updatedDetails, orderNote: state.orderNote));
    });
  }

  void setCustomer(CustomerEntity? customer) {
    if (customer == null) {
      // Use factory that preserves all other fields and clears customer only
      state = state.clear(clearSelectedCustomer: true);
      return;
    } else {
      state = state.copyWith(selectedCustomer: customer);
    }
  }

  // Set active category
  void setActiveCategory(String category) {
    state = state.copyWith(activeCategory: category);
    unawaited(_persistAndUpdateState(
        List<TransactionDetailEntity>.from(state.details)));
  }

  // Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  // Set Active Note ID
  void setActiveNoteId(int? id) {
    if (id == null) {
      state = state.clear(clearActiveNoteId: true);

      return;
    }
    state = state.copyWith(activeNoteId: id);
  }

  void setTypeCart(ETypeCart type) {
    state = state.copyWith(typeCart: type);
  }

  // UI setters for payment/order flow
  void setOrderType(EOrderType type) {
    state = state.copyWith(orderType: type);
    // persist change to local DB using current details
    unawaited(_persistAndUpdateState(
        List<TransactionDetailEntity>.from(state.details)));
  }

  void setOjolProvider(String provider) {
    state = state.copyWith(ojolProvider: provider);
    unawaited(_persistAndUpdateState(
        List<TransactionDetailEntity>.from(state.details)));
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
    unawaited(_persistAndUpdateState(
        List<TransactionDetailEntity>.from(state.details)));
  }

  void setCashReceived(int amount) {
    state = state.copyWith(cashReceived: amount);
    unawaited(_persistAndUpdateState(
        List<TransactionDetailEntity>.from(state.details)));
  }

  void setViewMode(String mode) {
    state = state.copyWith(viewMode: mode);
  }

  void setShowErrorSnackbar(bool v) {
    state = state.copyWith(showErrorSnackbar: v);
  }

  // ------------------ Actions (on*) ------------------
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

  Future<void> onStore({ProductEntity? product}) async {
    await _persistAndUpdateState(
        List<TransactionDetailEntity>.from(state.details),
        // set status to proses when explicitly storing/processing the order
        forceStatus: TransactionStatus.proses);
  }

  Future<void> onShowMethodPayment() async {
    final ETypeCart current = state.typeCart;

    if (current == ETypeCart.main) {
      state = state.copyWith(typeCart: ETypeCart.confirm);
    } else if (current == ETypeCart.confirm) {
      state = state.copyWith(typeCart: ETypeCart.checkout);
    } else {
      state = state.copyWith(typeCart: ETypeCart.checkout);
    }
  }

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
          state = TransactionPosState.cleared();
        });
        return;
      }

      // No transaction to delete; just clear local state
      state = TransactionPosState.cleared();
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // ------------------ Private helpers ------------------
  // Persist updated details (and optionally notes) to local DB first,
  // then update state only when persistence succeeds.
  Future<void> _persistAndUpdateState(
      List<TransactionDetailEntity> updatedDetails,
      {String? orderNote,
      TransactionStatus? forceStatus}) async {
    try {
      state = state.copyWith(isLoading: true);

      final totalAmount = updatedDetails.fold<int>(0, (sum, d) {
        return sum + (d.subtotal ?? ((d.productPrice ?? 0) * (d.qty ?? 0)));
      });
      final totalQty =
          updatedDetails.fold<int>(0, (sum, d) => sum + (d.qty ?? 0));
      // map UI order type to DB id
      int orderTypeIdFromState() {
        switch (state.orderType) {
          case EOrderType.dineIn:
            return 1;
          case EOrderType.takeAway:
            return 2;
          case EOrderType.online:
            return 3;
        }
      }

      // prepare paid/change values from UI
      final paidAmountFromState =
          state.cashReceived == 0 ? null : state.cashReceived;
      final changeMoneyFromState = (state.cashReceived - totalAmount) < 0
          ? 0
          : (state.cashReceived - totalAmount);

      // bikin transaksi baru
      if (state.transaction == null) {
        final txEntity = TransactionEntity(
          outletId: state.transaction?.outletId ?? 8,
          sequenceNumber: state.transaction?.sequenceNumber ?? 1,
          orderTypeId: orderTypeIdFromState(),
          date: DateTime.now(),
          totalAmount: totalAmount,
          totalQty: totalQty,
          notes: orderNote ?? state.orderNote,
          categoryOrder: state.activeCategory,
          userId: state.selectedCustomer?.id,
          paymentMethod: state.paymentMethod,
          ojolProvider: state.ojolProvider,
          paidAmount: paidAmountFromState,
          changeMoney: changeMoneyFromState,
          // allow forcing status (e.g., proses on explicit store), default pending
          status: forceStatus ?? TransactionStatus.pending,
          details: updatedDetails,
        );

        final res = await _createTransaction.call(txEntity, isOffline: true);
        res.fold((f) {
          _logger.severe('Create transaction failed: $f');
          state = state.copyWith(isLoading: false);
        }, (created) {
          final updatedDetailsFromServer = created.details ?? updatedDetails;
          state = state.copyWith(
            isLoading: false,
            transaction: created,
            details: updatedDetailsFromServer,
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
          // ensure details point to current transaction id when updating
          final detailsWithTxId = updatedDetails
              .map((d) => d.copyWith(transactionId: state.transaction?.id))
              .toList();

          final txEntity = state.transaction!.copyWith(
            details: detailsWithTxId,
            totalAmount: totalAmount,
            totalQty: totalQty,
            notes: orderNote ?? state.orderNote,
            orderTypeId: orderTypeIdFromState(),
            categoryOrder: state.activeCategory,
            userId: state.selectedCustomer?.id,
            paymentMethod: state.paymentMethod,
            ojolProvider: state.ojolProvider,
            paidAmount: paidAmountFromState,
            changeMoney: changeMoneyFromState,
            // preserve existing status unless forceStatus provided
            status: forceStatus ?? state.transaction!.status,
          );

          final res = await _updateTransaction.call(txEntity, isOffline: true);
          res.fold((f) {
            _logger.severe("Failed to update transaction: $f");
            state = state.copyWith(isLoading: false);
          }, (updated) {
            _logger.info(
                "Updated transaction id=${updated.id}, detailsCount=${updated.details?.length ?? 0}");
            final safeDetails = (updated.details != null &&
                    (updated.details?.isNotEmpty ?? false))
                ? updated.details!
                : updatedDetails;
            state = state.copyWith(
                transaction: updated, details: safeDetails, isLoading: false);
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
    _logger.info('_loadLocalTransaction: starting load from local DB...');
    try {
      // fetch the single active/latest transaction (created desc, limit 1)
      final res = await _getTransactionActive.call(isOffline: true);
      res.fold((f) {
        // silently ignore failures for init
        _logger
            .info('_loadLocalTransaction: no existing local transaction found');
      }, (tx) {
        _logger.info(
            'Loaded local transaction, details length: ${tx.details?.length ?? 0}');
        state = state.copyWith(transaction: tx, details: tx.details ?? []);
      });
    } catch (e) {
      // ignore init load errors
    }
  }
}
