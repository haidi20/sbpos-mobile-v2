import 'package:core/core.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository?>(
  (ref) => throw UnimplementedError(
    'transactionRepositoryProvider must be overridden in the app composition root.',
  ),
);
