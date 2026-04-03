import 'package:core/core.dart';
import 'package:expense/domain/entities/expense.entity.dart';
import 'package:expense/domain/repositories/expense.repository.dart';
import 'package:expense/domain/usecases/create_expense.usecase.dart';
import 'package:expense/domain/usecases/get_expenses.usecase.dart';
import 'package:flutter_test/flutter_test.dart';

/// ---------------------------------------------------------------
/// Fake Repository — implementasi in-memory untuk unit test
/// ---------------------------------------------------------------
class _FakeExpenseRepository implements ExpenseRepository {
  final List<ExpenseEntity> _store = [];
  int _nextId = 1;

  Future<Either<Failure, List<ExpenseEntity>>> Function({bool? isOffline})?
      onGetExpenses;
  Future<Either<Failure, ExpenseEntity>> Function(
          ExpenseEntity expense, {bool? isOffline})?
      onCreateExpense;

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses(
      {bool? isOffline}) async {
    if (onGetExpenses != null) {
      return await onGetExpenses!(isOffline: isOffline);
    }
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

void main() {
  late _FakeExpenseRepository repository;

  setUp(() {
    repository = _FakeExpenseRepository();
  });

  // ---------------------------------------------------------------
  // GetExpenses Usecase
  // ---------------------------------------------------------------
  group('GetExpenses usecase', () {
    test('mengembalikan list kosong bila repositori kosong', () async {
      final usecase = GetExpenses(repository);

      final result = await usecase(isOffline: true);

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => []), isEmpty);
    });

    test('mengembalikan semua expense yang ada di repositori', () async {
      await repository.createExpense(
        const ExpenseEntity(categoryName: 'Gas', totalAmount: 30000),
        isOffline: true,
      );
      await repository.createExpense(
        const ExpenseEntity(categoryName: 'Listrik', totalAmount: 150000),
        isOffline: true,
      );

      final usecase = GetExpenses(repository);
      final result = await usecase(isOffline: true);

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => []).length, equals(2));
    });

    test('meneruskan failure dari repository ke caller', () async {
      repository.onGetExpenses =
          ({bool? isOffline}) async => const Left(NetworkFailure());

      final usecase = GetExpenses(repository);
      final result = await usecase();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Seharusnya failure'),
      );
    });
  });

  // ---------------------------------------------------------------
  // CreateExpense Usecase
  // ---------------------------------------------------------------
  group('CreateExpense usecase', () {
    test('berhasil membuat expense dan mengembalikan entity dengan id', () async {
      const expense = ExpenseEntity(
        categoryName: 'Parkir',
        qty: 1,
        totalAmount: 5000,
        notes: 'Parkir motor',
      );
      final usecase = CreateExpense(repository);

      final result = await usecase(expense, isOffline: true);

      expect(result.isRight(), isTrue);
      final entity = result.getOrElse(() => const ExpenseEntity());
      expect(entity.id, isNotNull);
      expect(entity.categoryName, equals('Parkir'));
      expect(entity.totalAmount, equals(5000));
    });

    test('expense baru tersimpan dan muncul di getExpenses', () async {
      const expense =
          ExpenseEntity(categoryName: 'Bahan Baku', totalAmount: 75000);
      final createUsecase = CreateExpense(repository);
      final getUsecase = GetExpenses(repository);

      await createUsecase(expense, isOffline: true);
      final result = await getUsecase(isOffline: true);

      final list = result.getOrElse(() => []);
      expect(list.any((e) => e.categoryName == 'Bahan Baku'), isTrue);
    });

    test('membuat 3 expense - semuanya mendapat id unik', () async {
      final usecase = CreateExpense(repository);
      final ids = <int?>[];

      for (final name in ['A', 'B', 'C']) {
        final r = await usecase(
          ExpenseEntity(categoryName: name, totalAmount: 1000),
          isOffline: true,
        );
        ids.add(r.getOrElse(() => const ExpenseEntity()).id);
      }

      expect(ids.toSet().length, equals(3));
    });

    test('meneruskan failure dari repository ke caller', () async {
      repository.onCreateExpense = (expense, {isOffline}) async =>
          const Left(UnknownFailure());

      final usecase = CreateExpense(repository);
      final result = await usecase(
        const ExpenseEntity(categoryName: 'X', totalAmount: 100),
      );

      expect(result.isLeft(), isTrue);
    });
  });
}
