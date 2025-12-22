import 'package:core/core.dart';
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

// Usecase providers (dipindahkan dari transaction_usecase_providers.dart)
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

final transactionPosViewModelProvider =
    StateNotifierProvider<TransactionPosViewModel, TransactionPosState>((ref) {
  final createTxn = ref.watch(createTransaction);
  final updateTxn = ref.watch(updateTransaction);
  final deleteTxn = ref.watch(deleteTransaction);
  final getTxnActive = ref.watch(getTransactionActive);
  final getLastSeq = ref.watch(getLastSequenceNumber);
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
  );
});

final transactionHistoryViewModelProvider =
    StateNotifierProvider<TransactionHistoryViewModel, TransactionHistoryState>(
        (ref) {
  final getTxn = ref.watch(getTransactions);
  return TransactionHistoryViewModel(getTxn);
});

// No local fallback repository here; the app should provide `productRepositoryProvider`.
