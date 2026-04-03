import 'package:core/core.dart';
import 'package:expense/domain/entities/expense.entity.dart';
import 'package:expense/domain/repositories/expense.repository.dart';
import 'package:expense/domain/usecases/create_expense.usecase.dart';
import 'package:expense/domain/usecases/get_expenses.usecase.dart';
import 'package:expense/presentation/view_models/expense.state.dart';
import 'package:expense/presentation/view_models/expense.vm.dart';
import 'package:flutter_test/flutter_test.dart';

/// ---------------------------------------------------------------
/// Fake Repository untuk ViewModel Tests
/// ---------------------------------------------------------------
class _FakeExpenseRepository implements ExpenseRepository {
  final List<ExpenseEntity> _store = [];
  int _nextId = 1;

  /// Configurable handlers per skenario
  Future<Either<Failure, List<ExpenseEntity>>> Function({bool? isOffline})?
      onGetExpenses;
  Future<Either<Failure, ExpenseEntity>> Function(
          ExpenseEntity, {bool? isOffline})?
      onCreateExpense;

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses(
      {bool? isOffline}) async {
    if (onGetExpenses != null) return await onGetExpenses!(isOffline: isOffline);
    return Right(List.from(_store));
  }

  @override
  Future<Either<Failure, ExpenseEntity>> createExpense(ExpenseEntity expense,
      {bool? isOffline}) async {
    if (onCreateExpense != null) {
      return await onCreateExpense!(expense, isOffline: isOffline);
    }
    final saved = expense.copyWith(id: _nextId++);
    _store.add(saved);
    return Right(saved);
  }
}

/// ---------------------------------------------------------------
/// Helper: buat ViewModel dengan repository fake
/// ---------------------------------------------------------------
ExpenseViewModel _buildVm(_FakeExpenseRepository repo) {
  return ExpenseViewModel(
    getExpensesUsecase: GetExpenses(repo),
    createExpenseUsecase: CreateExpense(repo),
  );
}

void main() {
  late _FakeExpenseRepository repository;

  setUp(() {
    repository = _FakeExpenseRepository();
  });

  // ---------------------------------------------------------------
  // Initial State
  // ---------------------------------------------------------------
  group('ExpenseViewModel - initial state', () {
    test('state awal mengikuti default ExpenseState', () async {
      // ViewModel memanggil getExpenses saat konstruktor
      final vm = _buildVm(repository);
      await Future.delayed(Duration.zero); // biarkan async selesai

      // Setelah load selesai, isLoading harus false
      expect(vm.state.isLoading, isFalse);
      expect(vm.state.isSubmitting, isFalse);
      expect(vm.state.error, isNull);
      expect(vm.state.draftExpense, isNull);
    });

    test('state expenses kosong bila repositori kosong', () async {
      final vm = _buildVm(repository);
      await Future.delayed(Duration.zero);

      expect(vm.state.expenses, isEmpty);
    });

    test('state expenses berisi data bila repositori sudah ada isi', () async {
      repository._store.add(
        const ExpenseEntity(id: 1, categoryName: 'Awal', totalAmount: 10000),
      );

      final vm = _buildVm(repository);
      await Future.delayed(Duration.zero);

      expect(vm.state.expenses.length, equals(1));
      expect(vm.state.expenses.first.categoryName, equals('Awal'));
    });
  });

  // ---------------------------------------------------------------
  // getExpenses
  // ---------------------------------------------------------------
  group('ExpenseViewModel - getExpenses', () {
    test('getExpenses mengisi state.expenses dari repositori', () async {
      repository._store
        ..add(const ExpenseEntity(id: 1, categoryName: 'Gas', totalAmount: 30000))
        ..add(const ExpenseEntity(id: 2, categoryName: 'Listrik', totalAmount: 150000));

      final vm = _buildVm(repository);
      await vm.getExpenses();

      expect(vm.state.expenses.length, equals(2));
    });

    test('getExpenses set error saat repositori gagal', () async {
      repository.onGetExpenses =
          ({isOffline}) async => const Left(NetworkFailure());

      final vm = _buildVm(repository);
      await vm.getExpenses();

      expect(vm.state.error, isNotNull);
    });

    test('getExpenses menghapus error saat pemuatan berhasil', () async {
      // Skenario: error muncul dulu, lalu sukses menghapusnya
      repository.onGetExpenses =
          ({isOffline}) async => const Left(ServerFailure());
      final vm = _buildVm(repository);
      await vm.getExpenses();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(vm.state.error, isNotNull);

      // Reset ke sukses — error harus hilang
      repository.onGetExpenses = null;
      await vm.getExpenses();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(vm.state.error, isNull);
    });
  });

  // ---------------------------------------------------------------
  // setDraftExpense & resetDraft
  // ---------------------------------------------------------------
  group('ExpenseViewModel - setter draft', () {
    test('setDraftExpense menyimpan entity ke state.draftExpense', () async {
      final vm = _buildVm(repository);
      await Future.delayed(Duration.zero);

      const draft =
          ExpenseEntity(categoryName: 'Test', totalAmount: 12345, qty: 2);
      vm.setDraftExpense(draft);

      expect(vm.state.draftExpense?.categoryName, equals('Test'));
      expect(vm.state.draftExpense?.totalAmount, equals(12345));
      expect(vm.state.draftExpense?.qty, equals(2));
    });

    test('resetDraft mengosongkan draftExpense menjadi empty entity', () async {
      final vm = _buildVm(repository);
      await Future.delayed(Duration.zero);

      vm.setDraftExpense(
          const ExpenseEntity(categoryName: 'Isi Dulu', totalAmount: 999));
      expect(vm.state.draftExpense?.categoryName, isNotNull);

      vm.resetDraft();
      // Setelah reset, entity "kosong" tapi tidak null — semua field null
      expect(vm.state.draftExpense?.categoryName, isNull);
    });
  });

  // ---------------------------------------------------------------
  // onCreateExpense
  // ---------------------------------------------------------------
  group('ExpenseViewModel - onCreateExpense', () {
    test('mengembalikan false bila draftExpense null', () async {
      final vm = _buildVm(repository);
      await Future.delayed(Duration.zero);

      final result = await vm.onCreateExpense();

      expect(result, isFalse);
    });

    test('berhasil membuat expense dan menambahkannya ke list', () async {
      final vm = _buildVm(repository);
      await Future.delayed(Duration.zero);

      vm.setDraftExpense(
        const ExpenseEntity(
          categoryName: 'Bahan Baku',
          qty: 3,
          totalAmount: 90000,
          notes: 'Beli sayur',
        ),
      );

      final result = await vm.onCreateExpense();

      expect(result, isTrue);
      expect(vm.state.expenses.length, equals(1));
      expect(vm.state.expenses.first.categoryName, equals('Bahan Baku'));
      expect(vm.state.draftExpense, isNull);
      expect(vm.state.isSubmitting, isFalse);
    });

    test('expense baru muncul di posisi pertama (prepend)', () async {
      repository._store.add(
        const ExpenseEntity(id: 1, categoryName: 'Lama', totalAmount: 1000),
      );
      final vm = _buildVm(repository);
      await vm.getExpenses();

      vm.setDraftExpense(
          const ExpenseEntity(categoryName: 'Baru', totalAmount: 5000));
      await vm.onCreateExpense();

      expect(vm.state.expenses.first.categoryName, equals('Baru'));
    });

    test('onCreateExpense set error saat repositori gagal', () async {
      repository.onCreateExpense =
          (_, {isOffline}) async => const Left(ServerFailure());

      final vm = _buildVm(repository);
      await Future.delayed(Duration.zero);

      vm.setDraftExpense(
          const ExpenseEntity(categoryName: 'X', totalAmount: 100));
      final result = await vm.onCreateExpense();

      expect(result, isFalse);
      expect(vm.state.error, isNotNull);
      expect(vm.state.isSubmitting, isFalse);
    });

    test('createdAt diisi otomatis saat onCreateExpense dipanggil', () async {
      ExpenseEntity? capturedExpense;
      repository.onCreateExpense = (expense, {isOffline}) async {
        capturedExpense = expense;
        return Right(expense.copyWith(id: 99));
      };

      final vm = _buildVm(repository);
      await Future.delayed(Duration.zero);

      vm.setDraftExpense(
          const ExpenseEntity(categoryName: 'Auto Date', totalAmount: 5000));
      await vm.onCreateExpense();

      expect(capturedExpense?.createdAt, isNotNull);
    });

    test('isSubmitting false setelah onCreateExpense selesai', () async {
      repository.onCreateExpense = (expense, {isOffline}) async {
        return Right(expense.copyWith(id: 1));
      };

      final vm = _buildVm(repository);
      await Future.delayed(Duration.zero);

      vm.setDraftExpense(
          const ExpenseEntity(categoryName: 'Y', totalAmount: 200));
      await vm.onCreateExpense();

      expect(vm.state.isSubmitting, isFalse);
    });

    test('state.expenses tidak berubah bila draftExpense null', () async {
      repository._store
          .add(const ExpenseEntity(id: 1, categoryName: 'Ada', totalAmount: 50));
      final vm = _buildVm(repository);
      await vm.getExpenses();

      await vm.onCreateExpense();

      expect(vm.state.expenses.length, equals(1));
    });
  });

  // ---------------------------------------------------------------
  // ExpenseState copyWith
  // ---------------------------------------------------------------
  group('ExpenseState - copyWith', () {
    test('copyWith mengganti hanya field yang diberikan', () {
      const initial = ExpenseState();
      final updated = initial.copyWith(isLoading: true, error: 'Gagal');

      expect(updated.isLoading, isTrue);
      expect(updated.error, equals('Gagal'));
      expect(updated.isSubmitting, isFalse);
      expect(updated.expenses, isEmpty);
    });

    test('copyWith tanpa argumen menghasilkan state yang sama', () {
      final state = ExpenseState(
        isLoading: true,
        error: 'e',
        isSubmitting: true,
        expenses: const [ExpenseEntity(id: 1, totalAmount: 100)],
      );

      final copied = state.copyWith();

      expect(copied.isLoading, equals(state.isLoading));
      expect(copied.error, equals(state.error));
      expect(copied.isSubmitting, equals(state.isSubmitting));
      expect(copied.expenses.length, equals(state.expenses.length));
    });
  });
  // ---------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------
  group('ExpenseViewModel - validation', () {
    test('isValid returns false if categoryName is empty', () {
      final vm = _buildVm(repository);
      vm.setDraftExpense(
          const ExpenseEntity(categoryName: '', totalAmount: 100));
      expect(vm.isValid, isFalse);
    });

    test('isValid returns false if totalAmount is null or zero', () {
      final vm = _buildVm(repository);
      vm.setDraftExpense(
          const ExpenseEntity(categoryName: 'Gas', totalAmount: 0));
      expect(vm.isValid, isFalse);
    });

    test('isValid returns true if category and amount are valid', () {
      final vm = _buildVm(repository);
      vm.setDraftExpense(
          const ExpenseEntity(categoryName: 'Gas', totalAmount: 50000));
      expect(vm.isValid, isTrue);
    });
  });
}
