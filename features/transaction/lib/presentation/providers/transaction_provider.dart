import 'package:core/core.dart';
import 'package:transaction/presentation/view_models/transaction.state.dart';
import 'package:transaction/presentation/view_models/transaction.vm.dart';

final transactionViewModelProvider =
    StateNotifierProvider<TransactionViewModel, TransactionState>(
  (ref) => TransactionViewModel(),
);
