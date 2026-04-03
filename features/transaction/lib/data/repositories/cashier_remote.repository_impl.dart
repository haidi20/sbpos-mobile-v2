import 'package:core/core.dart';
import 'package:transaction/data/datasources/cashier_remote.data_source.dart';
import 'package:transaction/domain/entitties/cashier_category.entity.dart';
import 'package:transaction/domain/entitties/edit_order_check.entity.dart';
import 'package:transaction/domain/entitties/order_type.entity.dart';
import 'package:transaction/domain/entitties/ojol_option.entity.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/transaction_action.entity.dart';
import 'package:transaction/domain/repositories/cashier_remote.repository.dart';

class CashierRemoteRepositoryImpl implements CashierRemoteRepository {
  CashierRemoteRepositoryImpl({
    required this.remote,
  });

  final CashierRemoteDataSource remote;
  final Logger _logger = Logger('CashierRemoteRepositoryImpl');

  @override
  Future<Either<Failure, bool>> checkTransactionQty({
    required int productId,
    required int qty,
  }) async {
    try {
      final result = await remote.checkTransactionQty(
        productId: productId,
        qty: qty,
      );
      return Right(result);
    } on ServerValidation catch (failure) {
      return Left(ServerValidation(failure.message));
    } on ServerException {
      return const Left(ServerFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe('checkTransactionQty error', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> checkoutTransaction(
    TransactionEntity transaction, {
    required bool isOnline,
  }) async {
    try {
      final result = await remote.checkoutTransaction(
        transaction,
        isOnline: isOnline,
      );
      return Right(TransactionEntity.fromModel(result));
    } on ServerValidation catch (failure) {
      return Left(ServerValidation(failure.message));
    } on ServerException {
      return const Left(ServerFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe('checkoutTransaction error', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, EditOrderCheckEntity>> checkEditOrder(
    int transactionId,
  ) async {
    try {
      final result = await remote.checkEditOrder(transactionId);
      return Right(EditOrderCheckEntity.fromModel(result));
    } on ServerValidation catch (failure) {
      return Left(ServerValidation(failure.message));
    } on ServerException {
      return const Left(ServerFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe('checkEditOrder error', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, TransactionActionEntity>> confirmCancelTransaction({
    required int transactionId,
    required String otp,
  }) async {
    try {
      final result = await remote.confirmCancelTransaction(
        transactionId: transactionId,
        otp: otp,
      );
      return Right(result.toEntity());
    } on ServerValidation catch (failure) {
      return Left(ServerValidation(failure.message));
    } on ServerException {
      return const Left(ServerFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe('confirmCancelTransaction error', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<CashierCategoryEntity>>> getCustomCategories() async {
    try {
      final result = await remote.getCustomCategories();
      return Right(result.map((item) => item.toEntity()).toList());
    } on ServerValidation catch (failure) {
      return Left(ServerValidation(failure.message));
    } on ServerException {
      return const Left(ServerFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe('getCustomCategories error', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getNotPaidTransactions() async {
    try {
      final result = await remote.getNotPaidTransactions();
      return Right(result.map(TransactionEntity.fromModel).toList());
    } on ServerValidation catch (failure) {
      return Left(ServerValidation(failure.message));
    } on ServerException {
      return const Left(ServerFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe('getNotPaidTransactions error', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<OjolOptionEntity>>> getOjolOptions() async {
    try {
      final result = await remote.getOjolOptions();
      return Right(result.map((item) => item.toEntity()).toList());
    } on ServerValidation catch (failure) {
      return Left(ServerValidation(failure.message));
    } on ServerException {
      return const Left(ServerFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe('getOjolOptions error', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<OrderTypeEntity>>> getOrderTypes() async {
    try {
      final result = await remote.getOrderTypes();
      return Right(result.map((item) => item.toEntity()).toList());
    } on ServerValidation catch (failure) {
      return Left(ServerValidation(failure.message));
    } on ServerException {
      return const Left(ServerFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe('getOrderTypes error', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, TransactionActionEntity>> requestCancelTransaction({
    required int transactionId,
    required String reason,
  }) async {
    try {
      final result = await remote.requestCancelTransaction(
        transactionId: transactionId,
        reason: reason,
      );
      return Right(result.toEntity());
    } on ServerValidation catch (failure) {
      return Left(ServerValidation(failure.message));
    } on ServerException {
      return const Left(ServerFailure());
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e, st) {
      _logger.severe('requestCancelTransaction error', e, st);
      return const Left(UnknownFailure());
    }
  }
}
