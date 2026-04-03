import 'package:core/core.dart';
import 'package:expense/domain/entities/expense.entity.dart';
import 'package:expense/domain/usecases/create_expense.usecase.dart';
import 'package:expense/domain/usecases/get_expenses.usecase.dart';
import 'package:expense/presentation/view_models/expense.state.dart';

class ExpenseViewModel extends StateNotifier<ExpenseState> {
  final GetExpenses _getExpensesUsecase;
  final CreateExpense _createExpenseUsecase;

  ExpenseViewModel({
    required GetExpenses getExpensesUsecase,
    required CreateExpense createExpenseUsecase,
  })  : _getExpensesUsecase = getExpensesUsecase,
        _createExpenseUsecase = createExpenseUsecase,
        super(const ExpenseState()) {
    getExpenses();
  }

  // --- GETTERS (I/O) ---

  bool get isValid {
    final draft = state.draftExpense;
    if (draft == null) return false;
    final hasCategory =
        draft.categoryName != null && draft.categoryName!.trim().isNotEmpty;
    final hasAmount = draft.totalAmount != null && draft.totalAmount! > 0;
    return hasCategory && hasAmount;
  }

  Future<void> getExpenses() async {
    state = state.copyWith(isLoading: true, error: null);
    
    // Defaulting to isOffline: true for initial load speed/reliability as per pattern
    final result = await _getExpensesUsecase(isOffline: true);
    
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, error: 'Gagal mengambil data: $failure'),
      (expenses) => state = state.copyWith(isLoading: false, expenses: expenses),
    );

    // Sync from remote in background
    _syncWithRemote();
  }

  Future<void> _syncWithRemote() async {
    final result = await _getExpensesUsecase(isOffline: false);
    result.fold(
      (failure) => null, // Silently fail sync
      (expenses) => state = state.copyWith(expenses: expenses),
    );
  }

  // --- SETTERS (Local State Only) ---

  void setDraftExpense(ExpenseEntity draft) {
    state = state.copyWith(draftExpense: draft);
  }

  void resetDraft() {
    state = state.copyWith(draftExpense: const ExpenseEntity());
  }

  // --- ACTIONS (Aksi/Event dengan I/O) ---

  Future<bool> onCreateExpense() async {
    if (state.draftExpense == null) return false;
    
    state = state.copyWith(isSubmitting: true, error: null);
    
    final expenseToCreate = state.draftExpense!.copyWith(
      createdAt: DateTime.now(),
    );

    final result = await _createExpenseUsecase(expenseToCreate, isOffline: true);
    
    return result.fold(
      (failure) {
        state = state.copyWith(isSubmitting: false, error: 'Gagal menyimpan: $failure');
        return false;
      },
      (successEntity) {
        state = state.copyWith(
          isSubmitting: false,
          expenses: [successEntity, ...state.expenses],
          draftExpense: null,
        );
        // Terus sinkronkan ke server secara background
        _createExpenseUsecase(successEntity, isOffline: false);
        return true;
      },
    );
  }
}
