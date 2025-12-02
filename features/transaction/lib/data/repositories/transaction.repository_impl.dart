import 'package:core/core.dart';
import 'package:transaction/data/models/transaction_model.dart';
import 'package:transaction/data/responses/transaction.response.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';
import 'package:transaction/data/datasources/transaction_local_data_source.dart';
import 'package:transaction/data/datasources/transaction_remote_data_source.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remote;
  final TransactionLocalDataSource local;

  static final Logger _logger = Logger('TransactionRepositoryImpl');

  TransactionRepositoryImpl({
    required this.remote,
    required this.local,
  });

  Future<List<TransactionEntity>> _getLocalEntities() async {
    final localResp = await local.getTransactions();
    return localResp.map((model) => model.toEntity()).toList();
  }

  Future<List<TransactionModel>?> _saveToLocal(
      List<TransactionModel>? transactions) async {
    if (transactions != null && transactions.isNotEmpty) {
      List<TransactionModel> inserted = [];
      for (var tx in transactions) {
        try {
          final ins = await local.insertTransaction(tx);
          if (ins != null) inserted.add(ins);
        } catch (e, st) {
          _logger.warning('Gagal insert transaction local: $e', e, st);
        }
      }

      if (inserted.isEmpty) {
        _logger.warning('No transactions were synchronized to local database.');
        return null;
      }

      return inserted;
    }
    return null;
  }

  Future<Either<Failure, List<TransactionEntity>>> _fallbackToLocal({
    Failure fallbackFailure = const NetworkFailure(),
  }) async {
    final localEntities = await _getLocalEntities();
    if (localEntities.isNotEmpty) {
      return Right(localEntities);
    }
    return Left(fallbackFailure);
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getDataTransactions({
    bool? isOffline,
  }) async {
    // Jika pemanggil memaksa mode offline, langsung ambil dari local.
    if (isOffline == true) {
      return _fallbackToLocal(fallbackFailure: const NetworkFailure());
    }

    final networkInfo = NetworkInfoImpl(Connectivity());
    final bool isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final TransactionResponse resp = await remote.fetchTransactions();

        if (resp.success != true || resp.data == null) {
          return _fallbackToLocal(fallbackFailure: const ServerFailure());
        }

        final txModels = resp.data!;
        if (txModels.isNotEmpty) {
          final saved = await _saveToLocal(txModels);
          return Right(saved!.map((m) => m.toEntity()).toList());
        } else {
          return _fallbackToLocal(fallbackFailure: const ServerFailure());
        }
      } on ServerException {
        return _fallbackToLocal(fallbackFailure: const ServerFailure());
      } on NetworkException {
        return _fallbackToLocal(fallbackFailure: const NetworkFailure());
      } catch (e, stackTrace) {
        _logger.severe('Error saat mengambil data transaction:', e, stackTrace);
        return _fallbackToLocal(fallbackFailure: const UnknownFailure());
      }
    } else {
      return _fallbackToLocal(fallbackFailure: const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> setTransaction(
      TransactionEntity transaction,
      {bool? isOffline}) async {
    try {
      final txModel = transaction.toModel();

      // 1) Selalu simpan lokal terlebih dahulu menggunakan INSERT (synced_at null)
      final localInserted = await local.insertTransaction(txModel);
      // _logger
      //     .info('setTransaction - localInserted: ${localInserted?.toJson()}');
      if (localInserted == null) {
        // print for test-time debugging when logger may not be configured
        // ignore: avoid_print
        print(
            'setTransaction: local.insertTransaction returned NULL for txModel: ${txModel.toJson()}');
        return const Left(UnknownFailure());
      }

      // Jika pemanggil memaksa offline, kembalikan hasil lokal segera
      if (isOffline == true) {
        // insert details jika ada
        if (txModel.details != null && txModel.details!.isNotEmpty) {
          final detailsWithTxId = txModel.details!
              .map((d) => d.copyWith(transactionId: localInserted.id))
              .toList();
          await local.insertDetails(detailsWithTxId);
        }
        return Right(localInserted
            .copyWith(
                details: txModel.details
                    ?.map((d) => d.copyWith(transactionId: localInserted.id))
                    .toList())
            .toEntity());
      }

      // 2) Jika online, kirim ke remote setelah insert lokal; jika sukses, update lokal dengan id_server + synced_at
      try {
        // pastikan payload berisi details incl. transaction local id not required by API
        final TransactionResponse resp =
            await remote.postTransaction(txModel.toJson());

        if (resp.success != true || resp.data == null || resp.data!.isEmpty) {
          // fallback: simpan lokal
          final inserted = await local.insertSyncTransaction(txModel);
          if (inserted == null) return const Left(ServerFailure());
          return Right(inserted.toEntity());
        }

        final TransactionModel created = resp.data!.first;

        // jika berhasil create di server, update record lokal dengan id_server dan synced_at
        final syncAt = DateTime.now();
        final idServer = created.idServer ?? created.id;
        await local.updateTransaction({
          'id': localInserted.id,
          'id_server': idServer,
          'synced_at': syncAt.toIso8601String(),
        });

        // juga insert details lokal jika belum disimpan
        if (txModel.details != null && txModel.details!.isNotEmpty) {
          final detailsWithTxId = txModel.details!
              .map((d) => d.copyWith(transactionId: localInserted.id))
              .toList();
          await local.insertDetails(detailsWithTxId);
        }

        return Right(localInserted
            .copyWith(
              idServer: idServer,
              syncedAt: syncAt,
              details: txModel.details,
            )
            .toEntity());
      } on ServerException {
        // jika server error, kembalikan hasil lokal yang sudah disimpan
        return Right(localInserted.toEntity());
      } on NetworkException {
        // jika gagal jaringan, kembalikan hasil lokal yang sudah disimpan
        return Right(localInserted.toEntity());
      }
    } catch (e, st) {
      _logger.severe('Error saat menyimpan transaksi:', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> createTransaction(
      TransactionEntity transaction,
      {bool? isOffline}) async {
    // reuse existing setTransaction behavior for create
    return await setTransaction(transaction, isOffline: isOffline);
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
      {bool? isOffline}) async {
    // reuse getDataTransactions
    return await getDataTransactions(isOffline: isOffline);
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(int id,
      {bool? isOffline}) async {
    // check local first when offline or when requested
    if (isOffline == true) {
      final localModel = await local.getTransactionById(id);
      if (localModel != null) return Right(localModel.toEntity());
      return const Left(UnknownFailure());
    }

    final networkInfo = NetworkInfoImpl(Connectivity());
    final bool isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      final localModel = await local.getTransactionById(id);
      if (localModel != null) return Right(localModel.toEntity());
      return const Left(NetworkFailure());
    }

    try {
      final resp = await remote.getTransaction(id);
      if (resp.success != true || resp.data == null || resp.data!.isEmpty) {
        final localModel = await local.getTransactionById(id);
        if (localModel != null) return Right(localModel.toEntity());
        return const Left(ServerFailure());
      }
      final model = resp.data!.first;
      // save to local (replace existing)
      await local.insertSyncTransaction(model);
      return Right(model.toEntity());
    } on ServerException {
      final localModel = await local.getTransactionById(id);
      if (localModel != null) return Right(localModel.toEntity());
      return const Left(ServerFailure());
    } on NetworkException {
      final localModel = await local.getTransactionById(id);
      if (localModel != null) return Right(localModel.toEntity());
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe('Error getTransaction:', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
      TransactionEntity transaction,
      {bool? isOffline}) async {
    try {
      final txModel = transaction.toModel();

      // If the transaction has no local id, treat this as a create to ensure
      // a local row exists before attempting an update. This prevents
      // returning UnknownFailure when callers try to update an unsaved tx.
      if (txModel.id == null) {
        _logger.info(
            'updateTransaction: no local id found, delegating to setTransaction');
        return await setTransaction(transaction, isOffline: isOffline);
      }

      // update local first - ensure 'id' is present in map for update
      final txMapForUpdate =
          Map<String, dynamic>.from(txModel.toInsertDbLocal())
            ..['id'] = txModel.id;

      try {
        final updateCount = await local.updateTransaction(txMapForUpdate);
        if (updateCount == 0) {
          // nothing was updated locally (maybe row missing) -> fallback to create
          _logger.warning(
              'updateTransaction: local update affected 0 rows, falling back to setTransaction');
          return await setTransaction(transaction, isOffline: isOffline);
        }
      } catch (e, st) {
        // unexpected local DB error -> log and fallback to create
        _logger.warning(
            'updateTransaction: local update threw, fallback to set', e, st);
        return await setTransaction(transaction, isOffline: isOffline);
      }

      // If details are provided, replace existing details in local DB so
      // quantities and subtotals are persisted.
      if (txModel.details != null && txModel.details!.isNotEmpty) {
        try {
          // remove existing details for this transaction then insert new ones
          await local.deleteDetailsByTransactionId(txModel.id ?? 0);
          await local.insertDetails(txModel.details!);
        } catch (e, st) {
          _logger.warning(
              'updateTransaction: replacing details failed, continuing', e, st);
          // don't fail the whole update for detail errors; attempt to continue
        }
      }

      // if offline requested, return local
      if (isOffline == true) {
        final localTx = await local.getTransactionById(txModel.id ?? 0);
        if (localTx == null) {
          _logger.warning(
              'updateTransaction: expected local transaction missing, creating via setTransaction');
          return await setTransaction(transaction, isOffline: true);
        }
        return Right(localTx.toEntity());
      }

      final networkInfo = NetworkInfoImpl(Connectivity());
      final bool isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        final localTx = await local.getTransactionById(txModel.id ?? 0);
        if (localTx == null) return const Left(NetworkFailure());
        return Right(localTx.toEntity());
      }

      // determine server id
      final idServer = txModel.idServer;
      if (idServer == null) {
        // no server id, treat as create
        return await createTransaction(transaction, isOffline: false);
      }

      try {
        final resp = await remote.updateTransaction(idServer, txModel.toJson());
        if (resp.success != true || resp.data == null || resp.data!.isEmpty) {
          final localTx = await local.getTransactionById(txModel.id ?? 0);
          if (localTx == null) return const Left(ServerFailure());
          return Right(localTx.toEntity());
        }

        final created = resp.data!.first;
        final syncAt = DateTime.now();
        await local.updateTransaction({
          'id': txModel.id,
          'id_server': created.idServer ?? created.id,
          'synced_at': syncAt.toIso8601String(),
        });

        final updatedLocal = await local.getTransactionById(txModel.id ?? 0);
        if (updatedLocal == null) return const Left(UnknownFailure());
        return Right(updatedLocal.toEntity());
      } on ServerException {
        final localTx = await local.getTransactionById(txModel.id ?? 0);
        if (localTx == null) return const Left(ServerFailure());
        return Right(localTx.toEntity());
      } on NetworkException {
        final localTx = await local.getTransactionById(txModel.id ?? 0);
        if (localTx == null) return const Left(NetworkFailure());
        return Right(localTx.toEntity());
      }
    } catch (e, st) {
      _logger.severe('Error updateTransaction:', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTransaction(int id,
      {bool? isOffline}) async {
    try {
      // delete local first
      await local.deleteTransaction(id);

      if (isOffline == true) return const Right(true);

      final networkInfo = NetworkInfoImpl(Connectivity());
      final bool isConnected = await networkInfo.isConnected;
      if (!isConnected) return const Right(true);

      try {
        final resp = await remote.deleteTransaction(id);
        if (resp.success == true) return const Right(true);
        return const Right(true);
      } on ServerException {
        return const Right(true);
      } on NetworkException {
        return const Right(true);
      }
    } catch (e, st) {
      _logger.severe('Error deleteTransaction:', e, st);
      return const Left(UnknownFailure());
    }
  }
}
