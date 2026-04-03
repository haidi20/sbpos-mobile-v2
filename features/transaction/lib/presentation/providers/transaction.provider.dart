import 'package:core/core.dart';
import 'package:transaction/domain/repositories/cashier_remote.repository.dart';
import 'package:transaction/domain/usecases/check_edit_order.usecase.dart';
import 'package:transaction/domain/usecases/check_transaction_qty.usecase.dart';
import 'package:transaction/domain/usecases/checkout_transaction.usecase.dart';
import 'package:transaction/domain/usecases/confirm_cancel_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_cashier_categories.usecase.dart';
import 'package:transaction/domain/usecases/get_cashier_ojol_options.usecase.dart';
import 'package:transaction/domain/usecases/get_cashier_order_types.usecase.dart';
import 'package:transaction/domain/usecases/get_not_paid_transactions.usecase.dart';
import 'package:transaction/domain/usecases/request_cancel_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_transactions.usecase.dart';
import 'package:transaction/domain/usecases/create_transaction.usecase.dart';
import 'package:transaction/domain/usecases/update_transaction.usecase.dart';
import 'package:transaction/domain/usecases/delete_transaction.usecase.dart';
import 'package:transaction/presentation/view_models/transaction_pos/transaction_pos.vm.dart';
import 'package:transaction/presentation/view_models/transaction_pos/transaction_pos.state.dart';
import 'package:transaction/domain/usecases/get_transaction_active.usecase.dart';
import 'package:transaction/domain/usecases/get_last_secuence_number_transaction.usecase.dart';
import 'package:product/presentation/providers/packet.provider.dart';
import 'package:product/presentation/providers/product.provider.dart';
import 'package:transaction/presentation/view_models/transaction_history.vm.dart';
import 'package:transaction/presentation/view_models/transaction_history.state.dart';
import 'package:transaction/presentation/providers/transaction_repository.provider.dart';

final cashierRemoteRepositoryProvider = Provider<CashierRemoteRepository?>(
  (ref) => throw UnimplementedError(
    'cashierRemoteRepositoryProvider must be overridden in the app composition root.',
  ),
);

// Usecase providers (dipindahkan dari transaction_gunakancase_providers.dart)
final createTransaction = Provider((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return CreateTransaction(repo!);
});

final getTransactions = Provider((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return GetTransactionsUsecase(repo!);
});

final getTransaction = Provider((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return GetTransaction(repo!);
});

final updateTransaction = Provider((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return UpdateTransaction(repo!);
});

final deleteTransaction = Provider((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return DeleteTransaction(repo!);
});

final getTransactionActive = Provider((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return GetTransactionActive(repo!);
});

final getLastSequenceNumber = Provider((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return GetLastSequenceNumberTransaction(repo!);
});

final checkTransactionQtyProvider = Provider((ref) {
  final repo = ref.watch(cashierRemoteRepositoryProvider);
  return repo == null ? null : CheckTransactionQty(repo);
});

final checkoutTransactionProvider = Provider((ref) {
  final repo = ref.watch(cashierRemoteRepositoryProvider);
  return repo == null ? null : CheckoutTransaction(repo);
});

final getCashierCategoriesProvider = Provider((ref) {
  final repo = ref.watch(cashierRemoteRepositoryProvider);
  return repo == null ? null : GetCashierCategories(repo);
});

final getCashierOrderTypesProvider = Provider((ref) {
  final repo = ref.watch(cashierRemoteRepositoryProvider);
  return repo == null ? null : GetCashierOrderTypes(repo);
});

final getCashierOjolOptionsProvider = Provider((ref) {
  final repo = ref.watch(cashierRemoteRepositoryProvider);
  return repo == null ? null : GetCashierOjolOptions(repo);
});

final getNotPaidTransactionsProvider = Provider((ref) {
  final repo = ref.watch(cashierRemoteRepositoryProvider);
  return repo == null ? null : GetNotPaidTransactions(repo);
});

final requestCancelTransactionProvider = Provider((ref) {
  final repo = ref.watch(cashierRemoteRepositoryProvider);
  return repo == null ? null : RequestCancelTransaction(repo);
});

final confirmCancelTransactionProvider = Provider((ref) {
  final repo = ref.watch(cashierRemoteRepositoryProvider);
  return repo == null ? null : ConfirmCancelTransaction(repo);
});

final checkEditOrderProvider = Provider((ref) {
  final repo = ref.watch(cashierRemoteRepositoryProvider);
  return repo == null ? null : CheckEditOrder(repo);
});

final transactionPosViewModelProvider =
    StateNotifierProvider<TransactionPosViewModel, TransactionPosState>((ref) {
  final createTxn = ref.watch(createTransaction);
  final updateTxn = ref.watch(updateTransaction);
  final deleteTxn = ref.watch(deleteTransaction);
  final getTxnActive = ref.watch(getTransactionActive);
  final getLastSeq = ref.watch(getLastSequenceNumber);
  final printerFacade = ref.watch(printerFacadeProvider);
  final checkQty = ref.watch(checkTransactionQtyProvider);
  final checkoutTransaction = ref.watch(checkoutTransactionProvider);
  final getCategories = ref.watch(getCashierCategoriesProvider);
  final getOrderTypes = ref.watch(getCashierOrderTypesProvider);
  final getOjolOptions = ref.watch(getCashierOjolOptionsProvider);
  final packetsProvider = (() {
    try {
      return ref.watch(packetGetPacketsProvider);
    } catch (_) {
      return null;
    }
  })();

  final productsProvider = (() {
    try {
      return ref.watch(productGetProductsProvider);
    } catch (_) {
      return null;
    }
  })();

  return TransactionPosViewModel(
    createTxn,
    updateTxn,
    deleteTxn,
    getTxnActive,
    getLastSeq,
    packetsProvider,
    productsProvider,
    printerFacade,
    checkQty,
    checkoutTransaction,
    getCategories,
    getOrderTypes,
    getOjolOptions,
  );
});

final transactionHistoryViewModelProvider =
    StateNotifierProvider<TransactionHistoryViewModel, TransactionHistoryState>(
        (ref) {
  final getTxn = ref.watch(getTransactions);
  final getNotPaid = ref.watch(getNotPaidTransactionsProvider);
  return TransactionHistoryViewModel(
    getTxn,
    getNotPaid,
  );
});

// No local cadangan repository here; the app should provide `productRepositoryProvider`.
