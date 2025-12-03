import 'package:core/core.dart';
import 'package:transaction/domain/usecases/get_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_transactions.usecase.dart';
import 'package:transaction/domain/usecases/get_transactions_offline.usecase.dart';
import 'package:transaction/domain/usecases/get_transaction_active.usecase.dart';
import 'package:transaction/domain/usecases/create_transaction.usecase.dart';
import 'package:transaction/domain/usecases/update_transaction.usecase.dart';
import 'package:transaction/domain/usecases/delete_transaction.usecase.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';
import 'package:transaction/presentation/view_models/transaction_pos.vm.dart';
import 'package:transaction/presentation/view_models/transaction.vm.dart';
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

final getTransactionsOffline = Provider((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return GetTransactionsOffline(repo!);
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

final transactionPosViewModelProvider =
    StateNotifierProvider<TransactionPosViewModel, TransactionPosState>((ref) {
  final createTxn = ref.watch(createTransaction);
  final updateTxn = ref.watch(updateTransaction);
  final deleteTxn = ref.watch(deleteTransaction);
  final getTxnActive = ref.watch(getTransactionActive);

  return TransactionPosViewModel(
    createTxn,
    updateTxn,
    deleteTxn,
    getTxnActive,
  );
});

final transactionViewModelProvider =
    StateNotifierProvider<TransactionViewModel, TransactionState>((ref) {
  final getTxn = ref.watch(getTransactions);
  final getTxnOffline = ref.watch(getTransactionsOffline);
  return TransactionViewModel(getTxn, getTxnOffline);
});
