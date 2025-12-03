import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<TransactionEntity>>> getDataTransactions(
      {bool? isOffline});

  /// Simpan transaksi; bila `isOffline == true` simpan hanya ke local.
  Future<Either<Failure, TransactionEntity>> setTransaction(
      TransactionEntity transaction,
      {bool? isOffline});

  /// Create a new transaction (named create to follow convention)
  Future<Either<Failure, TransactionEntity>> createTransaction(
      TransactionEntity transaction,
      {bool? isOffline});

  /// Get all transactions (plural)
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
      {bool? isOffline});

  /// Get the latest single transaction (created_at desc limit 1)
  Future<Either<Failure, TransactionEntity>> getLatestTransaction(
      {bool? isOffline});

  /// Get single transaction by id
  Future<Either<Failure, TransactionEntity>> getTransaction(int id,
      {bool? isOffline});

  /// Update existing transaction
  Future<Either<Failure, TransactionEntity>> updateTransaction(
      TransactionEntity transaction,
      {bool? isOffline});

  /// Delete transaction by id
  Future<Either<Failure, bool>> deleteTransaction(int id, {bool? isOffline});
}
