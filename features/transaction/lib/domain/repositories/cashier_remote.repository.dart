import 'package:core/core.dart';
import 'package:transaction/domain/entitties/cashier_category.entity.dart';
import 'package:transaction/domain/entitties/edit_order_check.entity.dart';
import 'package:transaction/domain/entitties/order_type.entity.dart';
import 'package:transaction/domain/entitties/ojol_option.entity.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/transaction_action.entity.dart';

abstract class CashierRemoteRepository {
  Future<Either<Failure, bool>> checkTransactionQty({
    required int productId,
    required int qty,
  });

  Future<Either<Failure, List<CashierCategoryEntity>>> getCustomCategories();

  Future<Either<Failure, List<OrderTypeEntity>>> getOrderTypes();

  Future<Either<Failure, List<OjolOptionEntity>>> getOjolOptions();

  Future<Either<Failure, TransactionEntity>> checkoutTransaction(
    TransactionEntity transaction, {
    required bool isOnline,
  });

  Future<Either<Failure, List<TransactionEntity>>> getNotPaidTransactions();

  Future<Either<Failure, TransactionActionEntity>> requestCancelTransaction({
    required int transactionId,
    required String reason,
  });

  Future<Either<Failure, TransactionActionEntity>> confirmCancelTransaction({
    required int transactionId,
    required String otp,
  });

  Future<Either<Failure, EditOrderCheckEntity>> checkEditOrder(
    int transactionId,
  );
}
