import 'package:core/core.dart';
import 'package:expense/domain/entities/expense.entity.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses({bool? isOffline});
  Future<Either<Failure, ExpenseEntity>> createExpense(ExpenseEntity expense,
      {bool? isOffline});
}
