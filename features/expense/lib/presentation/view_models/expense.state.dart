import 'package:expense/domain/entities/expense.entity.dart';

/// Sentinel untuk membedakan "tidak diberikan" vs "diberikan null"
const _kUnset = Object();

class ExpenseState {
  final bool isLoading;
  final List<ExpenseEntity> expenses;
  final ExpenseEntity? draftExpense;
  final String? error;
  final bool isSubmitting;

  const ExpenseState({
    this.isLoading = false,
    this.expenses = const [],
    this.draftExpense,
    this.error,
    this.isSubmitting = false,
  });

  /// Gunakan [_kUnset] sebagai sentinel agar nullable field dapat di-set menjadi null.
  ExpenseState copyWith({
    bool? isLoading,
    List<ExpenseEntity>? expenses,
    Object? draftExpense = _kUnset,
    Object? error = _kUnset,
    bool? isSubmitting,
  }) {
    return ExpenseState(
      isLoading: isLoading ?? this.isLoading,
      expenses: expenses ?? this.expenses,
      draftExpense: identical(draftExpense, _kUnset)
          ? this.draftExpense
          : (draftExpense as ExpenseEntity?),
      error: identical(error, _kUnset) ? this.error : (error as String?),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
