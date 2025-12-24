import 'package:core/core.dart';
import 'package:transaction/domain/entitties/get_transactions.entity.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<TransactionEntity>>> getDataTransactions(
      {bool? isOffline});

  /// Simpan transaksi; bila `isOffline == true` simpan hanya ke local.
  Future<Either<Failure, TransactionEntity>> setTransaction(
      TransactionEntity transaction,
      {bool? isOffline});

  /// Buat a new transaction (named buat to follow convention)
  Future<Either<Failure, TransactionEntity>> createTransaction(
      TransactionEntity transaction,
      {bool? isOffline});

  /// Get all transactions (plural)
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
      {bool? isOffline, QueryGetTransactions? query});

  /// Get the active pending transaction (status = 'Pending'), latest by buatd_at desc
  Future<Either<Failure, TransactionEntity>> getPendingTransaction(
      {bool? isOffline});

  /// Get the highest sequence number stored locally (or 0 if none).
  /// This should be a local-only operation; `isOffline` is accepted for
  /// consistency but the implementation must not call remote.
  Future<Either<Failure, int>> getLastSequenceNumber({bool? isOffline});

  /// Get single transaction by id
  Future<Either<Failure, TransactionEntity>> getTransaction(int id,
      {bool? isOffline});

  /// Perbarui sudah ada transaction
  Future<Either<Failure, TransactionEntity>> updateTransaction(
      TransactionEntity transaction,
      {bool? isOffline});

  /// Hapus transaction by id
  Future<Either<Failure, bool>> deleteTransaction(int id, {bool? isOffline});
}
