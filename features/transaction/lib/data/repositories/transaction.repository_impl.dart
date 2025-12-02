import 'package:core/core.dart';
import 'package:transaction/data/models/transaction_model.dart';
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

  Future<Either<Failure, List<TransactionEntity>>> getDataTransactions() async {
    final networkInfo = NetworkInfoImpl(Connectivity());
    final bool isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final response = await remote.fetchTransactions();

        // response could be Map or List depending on API
        List<TransactionModel> txModels = [];
        if (response is Map<String, dynamic>) {
          if (response['success'] == true && response['data'] != null) {
            final data = response['data'];
            if (data is List) {
              txModels = data
                  .map((e) =>
                      TransactionModel.fromJson(e as Map<String, dynamic>))
                  .toList();
            }
          } else {
            return _fallbackToLocal(fallbackFailure: const ServerFailure());
          }
        } else if (response is List) {
          txModels = response
              .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          return _fallbackToLocal(fallbackFailure: const ServerFailure());
        }

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
}
