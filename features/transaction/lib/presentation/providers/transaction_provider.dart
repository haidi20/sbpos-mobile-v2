import 'package:core/core.dart';
import 'package:transaction/presentation/view_models/transaction.state.dart';
import 'package:transaction/presentation/view_models/transaction.vm.dart';
import 'package:transaction/presentation/providers/transaction_repository_provider.dart';
import 'package:transaction/domain/usecases/create_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_transactions.usecase.dart';
import 'package:transaction/domain/usecases/get_transaction.usecase.dart';
import 'package:transaction/domain/usecases/update_transaction.usecase.dart';
import 'package:transaction/domain/usecases/delete_transaction.usecase.dart';

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

final transactionViewModelProvider =
    StateNotifierProvider<TransactionViewModel, TransactionState>((ref) {
  // TransactionViewModel saat ini belum menerima usecase di konstruktor.
  // Buat tanpa argumen agar sesuai dengan `TransactionViewModel()`.
  return TransactionViewModel();
});
