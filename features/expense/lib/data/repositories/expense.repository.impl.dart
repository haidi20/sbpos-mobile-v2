import 'package:core/core.dart';
import 'package:expense/data/models/expense.model.dart';
import 'package:expense/domain/entities/expense.entity.dart';
import 'package:expense/data/responses/expense.response.dart';
import 'package:expense/domain/repositories/expense.repository.dart';
import 'package:expense/data/datasources/expense_local.datasource.dart';
import 'package:expense/data/datasources/expense_remote.datasource.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remote;
  final ExpenseLocalDataSource local;

  static final Logger _logger = Logger('ExpenseRepositoryImpl');

  ExpenseRepositoryImpl({
    required this.remote,
    required this.local,
  });

  Future<List<ExpenseEntity>> _getLocalEntities() async {
    final localResp = await local.getExpenses();
    return localResp.map((model) => model.toEntity()).toList();
  }

  Future<List<ExpenseModel>?> _saveToLocal(List<ExpenseModel>? expenses) async {
    if (expenses != null && expenses.isNotEmpty) {
      List<ExpenseModel> inserted = [];
      for (var e in expenses) {
        try {
          final ins = await local.insertExpense(e);
          if (ins != null) inserted.add(ins);
        } catch (e, st) {
          _logger.warning('Gagal insert expense lokal: $e', e, st);
        }
      }
      return inserted.isEmpty ? null : inserted;
    }
    return null;
  }

  Future<Either<Failure, List<ExpenseEntity>>> _fallbackToLocal({
    Failure fallbackFailure = const NetworkFailure(),
  }) async {
    final localEntities = await _getLocalEntities();
    if (localEntities.isNotEmpty) {
      return Right(localEntities);
    }
    return Left(fallbackFailure);
  }

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses(
      {bool? isOffline}) async {
    if (isOffline == true) {
      return Right(await _getLocalEntities());
    }

    final networkInfo = NetworkInfoImpl(Connectivity());
    final bool isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final ExpenseResponse resp = await remote.fetchExpenses();
        if (resp.success != true || resp.data == null) {
          return _fallbackToLocal(fallbackFailure: const ServerFailure());
        }
        final models = resp.data!;
        if (models.isNotEmpty) {
          final saved = await _saveToLocal(models);
          return Right(saved?.map((m) => m.toEntity()).toList() ?? []);
        } else {
          return const Right([]);
        }
      } on ServerException {
        return _fallbackToLocal(fallbackFailure: const ServerFailure());
      } catch (e, st) {
        _logger.severe('Error fetchExpenses:', e, st);
        return _fallbackToLocal(fallbackFailure: const UnknownFailure());
      }
    } else {
      return _fallbackToLocal(fallbackFailure: const NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, ExpenseEntity>> createExpense(ExpenseEntity expense,
      {bool? isOffline}) async {
    try {
      final model = ExpenseModel.fromEntity(expense);
      // Simpan lokal dulu
      final localInserted = await local.insertExpense(model);
      if (localInserted == null) return const Left(UnknownFailure());

      if (isOffline == true) {
        return Right(localInserted.toEntity());
      }

      final networkInfo = NetworkInfoImpl(Connectivity());
      final bool isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return Right(localInserted.toEntity());
      }

      try {
        final ExpenseResponse resp = await remote.postExpense(model.toInsertDbLocal());
        if (resp.success != true || resp.data == null || resp.data!.isEmpty) {
          return Right(localInserted.toEntity());
        }
        
        final createdServer = resp.data!.first;
        // Update local with server info and synced_at
        await local.updateExpense({
          'id': localInserted.id,
          'id_server': createdServer.idServer ?? createdServer.id,
          'synced_at': DateTime.now().toIso8601String(),
        });
        
        return Right(createdServer.toEntity());
      } catch (e) {
        _logger.warning('Gagal sync expense ke server, tetap di lokal: $e');
        return Right(localInserted.toEntity());
      }
    } catch (e, st) {
      _logger.severe('Error createExpense:', e, st);
      return const Left(UnknownFailure());
    }
  }
}
