import 'package:core/core.dart';
import 'package:expense/data/datasources/expense_local.datasource.dart';
import 'package:expense/data/datasources/expense_remote.datasource.dart';
import 'package:expense/data/repositories/expense.repository.impl.dart';
import 'package:expense/domain/repositories/expense.repository.dart';
import 'package:expense/domain/usecases/create_expense.usecase.dart';
import 'package:expense/domain/usecases/get_expenses.usecase.dart';
import 'package:expense/presentation/view_models/expense.state.dart';
import 'package:expense/presentation/view_models/expense.vm.dart';

final expenseLocalDataSourceProvider = Provider<ExpenseLocalDataSource>((ref) {
  return ExpenseLocalDataSource();
});

final expenseRemoteDataSourceProvider = Provider<ExpenseRemoteDataSource>((ref) {
  return ExpenseRemoteDataSource();
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(
    remote: ref.watch(expenseRemoteDataSourceProvider),
    local: ref.watch(expenseLocalDataSourceProvider),
  );
});

final getExpensesProvider = Provider<GetExpenses>((ref) {
  return GetExpenses(ref.watch(expenseRepositoryProvider));
});

final createExpenseProvider = Provider<CreateExpense>((ref) {
  return CreateExpense(ref.watch(expenseRepositoryProvider));
});

final expenseViewModelProvider =
    StateNotifierProvider<ExpenseViewModel, ExpenseState>((ref) {
  return ExpenseViewModel(
    getExpensesUsecase: ref.watch(getExpensesProvider),
    createExpenseUsecase: ref.watch(createExpenseProvider),
  );
});
