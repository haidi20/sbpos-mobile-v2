import 'package:core/core.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';
import 'package:transaction/data/datasources/transaction_local.data_source.dart';
import 'package:transaction/data/datasources/transaction_remote.data_source.dart';
import 'package:transaction/data/repositories/transaction.repository_impl.dart';

final transactionRemoteDataSourceProvider =
    Provider<TransactionRemoteDataSource>(
  (ref) => TransactionRemoteDataSource(),
);

final transactionLocalDataSourceProvider = Provider<TransactionLocalDataSource>(
  (ref) => TransactionLocalDataSource(),
);

final transactionRepositoryProvider = Provider<TransactionRepository?>(
  (ref) => TransactionRepositoryImpl(
    remote: ref.read(transactionRemoteDataSourceProvider),
    local: ref.read(transactionLocalDataSourceProvider),
  ),
);
