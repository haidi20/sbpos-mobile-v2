import 'package:core/core.dart';
import 'package:expense/domain/entities/expense.entity.dart';
import 'package:expense/domain/repositories/expense.repository.dart';

class GetExpenses {
  final ExpenseRepository repository;
  GetExpenses(this.repository);

  Future<Either<Failure, List<ExpenseEntity>>> call({bool? isOffline}) async {
    return await repository.getExpenses(isOffline: isOffline);
  }
}
