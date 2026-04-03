import 'package:core/core.dart';
import 'package:expense/domain/entities/expense.entity.dart';
import 'package:expense/domain/repositories/expense.repository.dart';

class CreateExpense {
  final ExpenseRepository repository;
  CreateExpense(this.repository);

  Future<Either<Failure, ExpenseEntity>> call(ExpenseEntity expense,
      {bool? isOffline}) async {
    return await repository.createExpense(expense, isOffline: isOffline);
  }
}
