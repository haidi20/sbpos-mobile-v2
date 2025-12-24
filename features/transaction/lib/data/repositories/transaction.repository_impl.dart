import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:transaction/data/models/transaction.model.dart';
import 'package:transaction/data/responses/transaction.response.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/get_transactions.entity.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';
import 'package:transaction/data/datasources/transaction_local.data_source.dart';
import 'package:transaction/data/datasources/transaction_remote.data_source.dart';
import 'package:transaction/data/dummy/transaction.dummy.dart';
import 'package:transaction/data/datasources/db/transaction.table.dart';
import 'package:transaction/data/datasources/db/transaction_detail.table.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remote;
  final TransactionLocalDataSource local;

  static final Logger _logger = Logger('TransactionRepositoryImpl');

  TransactionRepositoryImpl({
    required this.remote,
    required this.local,
  });

  Future<List<TransactionEntity>> _getLocalEntities(
      {QueryGetTransactions? query}) async {
    // Rely entirely on DAO-level filtering (including product name via JOINs)
    final base = await local.getTransactions(query: query);
    return base.map((model) => TransactionEntity.fromModel(model)).toList();
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

  Future<Either<Failure, TransactionEntity>> _localOrFailureById(
      int id, Failure failure) async {
    final localModel = await local.getTransactionById(id);
    if (localModel != null) {
      return Right(TransactionEntity.fromModel(localModel));
    }
    return Left(failure);
  }

  Future<Either<Failure, TransactionEntity>> _localAfterClearOrFailure(
      int? id, Failure failure) async {
    if (id != null) {
      await local.clearSyncedAt(id);
    }
    final localModel = await local.getTransactionById(id ?? 0);
    if (localModel != null) {
      return Right(TransactionEntity.fromModel(localModel));
    }
    return Left(failure);
  }

  Future<Either<Failure, List<TransactionEntity>>> _fallbackToLocal({
    Failure fallbackFailure = const NetworkFailure(),
  }) async {
    // Try seeding local DB if empty, then read again
    try {
      final localEntities = await _getLocalEntities();
      if (localEntities.isNotEmpty) {
        return Right(localEntities);
      }
      // attempt to seed sample transactions and re-read
      await _ensureSeededLocal();
      final reloaded = await _getLocalEntities();
      if (reloaded.isNotEmpty) return Right(reloaded);
    } catch (e, st) {
      _logger.fine('Fallback local read/seed failed: $e', e, st);
    }
    return Left(fallbackFailure);
  }

  /// Pastikan DB lokal memiliki beberapa transaksi contoh jika kosong.
  /// Berguna untuk skenario cadangan/offline agar UI tetap menampilkan data.
  Future<void> _ensureSeededLocal() async {
    _logger.info('Memeriksa/menyisipkan seed transaksi lokal...');
    try {
      final existing = await local.getTransactions();
      if (existing.isEmpty) {
        for (final t in transactionList) {
          try {
            await local.insertSyncTransaction(t);
          } catch (e, st) {
            _logger.warning(
                'Failed seeding transaction local (DAO path): $e', e, st);
            // cadangan for web: write directly to LocalDatabase (sembast)
            try {
              final db = LocalDatabase.instance;
              // masukkan transaksi dan gunakan kunci yang dikembalikan sebagai id lokal untuk detail
              final txMap = t.toInsertDbLocal();
              final txKey = await db.insert(TransactionTable.tableName, txMap);
              final details = t.details ?? [];
              for (var d in details) {
                final detailMap = d.toInsertDbLocal();
                detailMap[TransactionDetailTable.colTransactionId] = txKey;
                await db.insert(TransactionDetailTable.tableName, detailMap);
              }
            } catch (e2, st2) {
              _logger.warning(
                  'Failed seeding transaction local (sembast fallback): $e2',
                  e2,
                  st2);
            }
          }
        }
      }
    } catch (e, st) {
      _logger.warning('Error checking/seeding local transactions: $e', e, st);
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getDataTransactions({
    bool? isOffline,
    QueryGetTransactions? query,
  }) async {
    // Jika pemanggil memaksa mode offline, langsung ambil dari local.
    // Kembalikan daftar lokal bahkan ketika kosong untuk menghindari menampilkan kesalahan jaringan
    // when caller explicitly requested offline mode.
    if (isOffline == true) {
      final localEntities = await _getLocalEntities(query: query);
      return Right(localEntities);
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
          return Right(
              saved!.map((m) => TransactionEntity.fromModel(m)).toList());
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
        if (kDebugMode) {
          debugPrint(
              'setTransaction: local.insertTransaction returned NULL for txModel: ${txModel.toJson()}');
        }
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
        return Right(TransactionEntity.fromModel(localInserted.copyWith(
          details: txModel.details
              ?.map((d) => d.copyWith(transactionId: localInserted.id))
              .toList(),
        )));
      }

      // 2) Jika online, kirim ke remote setelah insert lokal; jika sukses, perbarui lokal dengan id_server + synced_at
      try {
        // pastikan paymuat berisi details incl. transaction local id not required by API
        final TransactionResponse resp =
            await remote.postTransaction(txModel.toJson());

        if (resp.success != true || resp.data == null || resp.data!.isEmpty) {
          // cadangan: simpan lokal
          final inserted = await local.insertSyncTransaction(txModel);
          if (inserted == null) {
            return const Left(ServerFailure());
          }
          return Right(TransactionEntity.fromModel(inserted));
        }

        final TransactionModel created = resp.data!.first;

        // jika berhasil buat di server, perbarui record lokal dengan id_server dan synced_at
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

        return Right(TransactionEntity.fromModel(localInserted.copyWith(
          idServer: idServer,
          syncedAt: syncAt,
          details: txModel.details,
        )));
      } on ServerException {
        // jika server error, kembalikan hasil lokal yang sudah disimpan
        return Right(TransactionEntity.fromModel(localInserted));
      } on NetworkException {
        // jika gagal jaringan, kembalikan hasil lokal yang sudah disimpan
        return Right(TransactionEntity.fromModel(localInserted));
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
    // regunakan sudah ada setTransaction behavior for buat
    return await setTransaction(transaction, isOffline: isOffline);
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
      {bool? isOffline, QueryGetTransactions? query}) async {
    // regunakan getDataTransactions
    return await getDataTransactions(isOffline: isOffline, query: query);
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(int id,
      {bool? isOffline}) async {
    // check local first when offline or when requested
    if (isOffline == true) {
      final localModel = await local.getTransactionById(id);
      if (localModel != null) {
        return Right(TransactionEntity.fromModel(localModel));
      }
      return const Left(UnknownFailure());
    }

    final networkInfo = NetworkInfoImpl(Connectivity());
    final bool isConnected = await networkInfo.isConnected;

    if (!isConnected) {
      return await _localOrFailureById(id, const NetworkFailure());
    }

    try {
      final resp = await remote.fetchTransaction(id);
      if (resp.success != true || resp.data == null || resp.data!.isEmpty) {
        return await _localOrFailureById(id, const ServerFailure());
      }
      final model = resp.data!.first;
      // save to local (replace sudah ada)
      await local.insertSyncTransaction(model);
      return Right(TransactionEntity.fromModel(model));
    } on ServerException {
      return await _localOrFailureById(id, const ServerFailure());
    } on NetworkException {
      return await _localOrFailureById(id, const NetworkFailure());
    } catch (e, st) {
      _logger.severe('Error getTransaction:', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> getPendingTransaction(
      {bool? isOffline}) async {
    // Always resolve from local DB only (no remote/network involvement).
    try {
      final localModel = await local.getPendingTransaction();
      if (localModel != null) {
        return Right(TransactionEntity.fromModel(localModel));
      }
      return const Left(UnknownFailure());
    } catch (e, st) {
      _logger.severe('Error getPendingTransaction (local):', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, int>> getLastSequenceNumber({bool? isOffline}) async {
    try {
      // Always read from local DB only
      final last = await local.getLastSequenceNumber();
      return Right(last);
    } catch (e, st) {
      _logger.warning(
          'Error getLastSequenceNumber, returning Left(UnknownFailure)', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
      TransactionEntity transaction,
      {bool? isOffline}) async {
    try {
      final txModel = transaction.toModel();

      // Jika transaksi tidak memiliki id lokal, perlakukan ini sebagai buat untuk
      // memastikan baris lokal ada sebelum mencoba perbarui.
      // a local row exists before attempting an perbarui. This prevents
      // returning UnknownFailure when callers try to perbarui an unsaved tx.
      if (txModel.id == null) {
        _logger.info(
            'updateTransaction: no local id found, delegating to setTransaction');
        return await setTransaction(transaction, isOffline: isOffline);
      }

      // perbarui lokal terlebih dahulu - pastikan 'id' ada di map untuk proses perbarui
      final txMapForUpdate =
          Map<String, dynamic>.from(txModel.toInsertDbLocal())
            ..['id'] = txModel.id;

      try {
        final updateCount = await local.updateTransaction(txMapForUpdate);
        if (updateCount == 0) {
          // nothing was perbaruid locally (maybe row missing) -> cadangan to buat
          _logger.warning(
              'updateTransaction: local update affected 0 rows, falling back to setTransaction');
          return await setTransaction(transaction, isOffline: isOffline);
        }
      } catch (e, st) {
        // unexpected local DB error -> log and cadangan to buat
        _logger.warning(
            'updateTransaction: local update threw, fallback to set', e, st);
        return await setTransaction(transaction, isOffline: isOffline);
      }

      // If details are provided, replace sudah ada details in local DB so
      // quantities and subtotals are persisted.
      if (txModel.details != null && txModel.details!.isNotEmpty) {
        try {
          // Ganti detail secara atomik agar tidak terjadi duplikasi qty.
          final txId = txModel.id ?? 0;
          await local.replaceDetails(txId, txModel.details!);
        } catch (e, st) {
          _logger.warning(
              'updateTransaction: replacing details failed, continuing', e, st);
          // don't fail the whole perbarui for detail errors; attempt to continue
        }
      }

      // if offline requested, return local and tandai as unsynced
      if (isOffline == true) {
        if (txModel.id != null) {
          await local.clearSyncedAt(txModel.id!);
        }
        final localTx = await local.getTransactionById(txModel.id ?? 0);
        if (localTx == null) {
          _logger.warning(
              'updateTransaction: expected local transaction missing, creating via setTransaction');
          return await setTransaction(transaction, isOffline: true);
        }
        return Right(TransactionEntity.fromModel(localTx));
      }

      final networkInfo = NetworkInfoImpl(Connectivity());
      final bool isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return await _localAfterClearOrFailure(
            txModel.id, const NetworkFailure());
      }

      // determine server id
      final idServer = txModel.idServer;
      if (idServer == null) {
        // no server id, treat as buat
        return await createTransaction(transaction, isOffline: false);
      }

      try {
        final resp = await remote.updateTransaction(idServer, txModel.toJson());
        if (resp.success != true || resp.data == null || resp.data!.isEmpty) {
          return await _localAfterClearOrFailure(
              txModel.id, const ServerFailure());
        }

        final created = resp.data!.first;
        final syncAt = DateTime.now();
        await local.updateTransaction({
          'id': txModel.id,
          'id_server': created.idServer ?? created.id,
          'synced_at': syncAt.toIso8601String(),
        });

        final updatedLocal = await local.getTransactionById(txModel.id ?? 0);
        if (updatedLocal == null) {
          return const Left(UnknownFailure());
        }
        return Right(TransactionEntity.fromModel(updatedLocal));
      } on ServerException {
        return await _localAfterClearOrFailure(
            txModel.id, const ServerFailure());
      } on NetworkException {
        return await _localAfterClearOrFailure(
            txModel.id, const NetworkFailure());
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
      // hapus local first
      await local.deleteTransaction(id);

      if (isOffline == true) {
        return const Right(true);
      }

      final networkInfo = NetworkInfoImpl(Connectivity());
      final bool isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return const Right(true);
      }

      try {
        final resp = await remote.deleteTransaction(id);
        if (resp.success == true) {
          return const Right(true);
        }
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
