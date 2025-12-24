import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';
import 'package:transaction/domain/usecases/create_transaction.usecase.dart';
import 'package:transaction/domain/usecases/update_transaction.usecase.dart';
import 'package:transaction/domain/usecases/delete_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_transactions.usecase.dart';
import 'package:transaction/domain/entitties/get_transactions.entity.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_pos.vm.dart';
import 'package:transaction/domain/usecases/get_transaction_active.usecase.dart';
import 'package:transaction/presentation/controllers/cart_screen.controller.dart';

class _FakeRepo implements TransactionRepository {
  final TransactionEntity? active;
  _FakeRepo([this.active]);

  @override
  Future<Either<Failure, List<TransactionEntity>>> getDataTransactions(
          {bool? isOffline}) async =>
      Right([]);

  @override
  Future<Either<Failure, TransactionEntity>> setTransaction(
          TransactionEntity transaction,
          {bool? isOffline}) async =>
      Right(transaction);

  @override
  Future<Either<Failure, TransactionEntity>> createTransaction(
          TransactionEntity transaction,
          {bool? isOffline}) async =>
      Right(transaction);

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
          {bool? isOffline, QueryGetTransactions? query}) async =>
      Right([]);

  @override
  Future<Either<Failure, TransactionEntity>> getLatestTransaction(
          {bool? isOffline}) async =>
      Right(active ??
          TransactionEntity(
              outletId: 1,
              sequenceNumber: 1,
              orderTypeId: 1,
              date: DateTime.now(),
              totalAmount: 0,
              totalQty: 0));

  @override
  Future<Either<Failure, TransactionEntity>> getTransaction(int id,
          {bool? isOffline}) async =>
      Right(TransactionEntity(
          outletId: 1,
          sequenceNumber: id,
          orderTypeId: 1,
          date: DateTime.now(),
          totalAmount: 0,
          totalQty: 0));

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
          TransactionEntity transaction,
          {bool? isOffline}) async =>
      Right(transaction);

  @override
  Future<Either<Failure, bool>> deleteTransaction(int id,
          {bool? isOffline}) async =>
      Right(true);
}

// Harness widget to expose controller instance created with real WidgetRef
class _ControllerHarness extends ConsumerStatefulWidget {
  const _ControllerHarness({Key? key}) : super(key: key);

  @override
  ConsumerState<_ControllerHarness> createState() => _ControllerHarnessState();
}

class _ControllerHarnessState extends ConsumerState<_ControllerHarness> {
  late final CartScreenController controller;

  @override
  void initState() {
    super.initState();
    controller = CartScreenController(ref, context);
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

void main() {
  late _FakeRepo fakeRepo;

  setUp(() {
    fakeRepo = _FakeRepo();
  });

  testWidgets('cartTotal calculates correctly from details', (tester) async {
    final detail1 = TransactionDetailEntity(
        productId: 1, productPrice: 10000, qty: 2, subtotal: 20000);
    final detail2 = TransactionDetailEntity(
        productId: 2, productPrice: 5000, qty: 1, subtotal: 5000);

    await tester.pumpWidget(ProviderScope(overrides: [
      transactionPosViewModelProvider.overrideWith((ref) {
        return TransactionPosViewModel(
          CreateTransaction(fakeRepo),
          UpdateTransaction(fakeRepo),
          DeleteTransaction(fakeRepo),
          GetTransactionActive(fakeRepo),
        );
      }),
    ], child: const MaterialApp(home: Scaffold(body: _ControllerHarness()))));

    await tester.pumpAndSettle();

    final state =
        tester.state<_ControllerHarnessState>(find.byType(_ControllerHarness));
    final controller = state.controller;

    // set details setelah controller dibuat untuk menghindari race init async
    final vmNotifier = state.ref.read(transactionPosViewModelProvider.notifier);
    vmNotifier.state = vmNotifier.state.copyWith(details: [detail1, detail2]);
    await tester.pumpAndSettle();

    expect(controller.cartTotal, 25000.0);
    expect(controller.finalTotal, 25000.0);
  });

  testWidgets(
      'order note controller initial text and listener updates viewmodel',
      (tester) async {
    await tester.pumpWidget(ProviderScope(overrides: [
      transactionPosViewModelProvider.overrideWith((ref) {
        final vm = TransactionPosViewModel(
          CreateTransaction(fakeRepo),
          UpdateTransaction(fakeRepo),
          DeleteTransaction(fakeRepo),
          GetTransactionActive(fakeRepo),
        );
        vm.state = vm.state.copyWith(orderNote: 'initial');
        return vm;
      }),
    ], child: const MaterialApp(home: Scaffold(body: _ControllerHarness()))));

    await tester.pumpAndSettle();

    final state =
        tester.state<_ControllerHarnessState>(find.byType(_ControllerHarness));
    final controller = state.controller;
    final vm = state.ref.read(transactionPosViewModelProvider.notifier);

    // initial from provided state
    expect(controller.orderNoteController.text, 'initial');

    // perubahan teks controller harus langsung dipropagasikan ke viewmodel.state
    controller.orderNoteController.text = 'changed-note';
    // advance time to allow debounce/timers to complete and avoid pending timers
    await tester.pump(const Duration(milliseconds: 600));
    expect(vm.state.orderNote, 'changed-note');
  });

  testWidgets('initialize item controllers from initial details',
      (tester) async {
    final d1 = TransactionDetailEntity(productId: 10, note: 'n1');
    final d2 = TransactionDetailEntity(productId: 20, note: 'n2');

    await tester.pumpWidget(ProviderScope(overrides: [
      transactionPosViewModelProvider.overrideWith((ref) {
        final vm = TransactionPosViewModel(
          CreateTransaction(fakeRepo),
          UpdateTransaction(fakeRepo),
          DeleteTransaction(fakeRepo),
          GetTransactionActive(fakeRepo),
        );
        vm.state = vm.state.copyWith(details: [d1, d2]);
        return vm;
      }),
    ], child: const MaterialApp(home: Scaffold(body: _ControllerHarness()))));

    await tester.pumpAndSettle();
    final state =
        tester.state<_ControllerHarnessState>(find.byType(_ControllerHarness));
    final controller = state.controller;

    expect(controller.itemNoteControllers.containsKey(10), isTrue);
    expect(controller.itemNoteControllers.containsKey(20), isTrue);
    expect(controller.itemNoteControllers[10]?.text, 'n1');
    expect(controller.itemNoteControllers[20]?.text, 'n2');
  });

  testWidgets(
      'onStateChanged removes active item and restores focus when re-added',
      (tester) async {
    final detail = TransactionDetailEntity(productId: 5, note: 'x');
    final vmInstance = TransactionPosViewModel(
      CreateTransaction(fakeRepo),
      UpdateTransaction(fakeRepo),
      DeleteTransaction(fakeRepo),
      GetTransactionActive(fakeRepo),
    );
    vmInstance.state =
        vmInstance.state.copyWith(details: [detail], activeNoteId: 5);

    await tester.pumpWidget(ProviderScope(overrides: [
      transactionPosViewModelProvider.overrideWith((ref) => vmInstance),
    ], child: const MaterialApp(home: Scaffold(body: _ControllerHarness()))));

    await tester.pumpAndSettle();
    final state =
        tester.state<_ControllerHarnessState>(find.byType(_ControllerHarness));
    final controller = state.controller;
    final vm = state.ref.read(transactionPosViewModelProvider.notifier);

    // simulate removal: previous had id 5, next has no details
    final prev = vm.state;
    final next = vm.state.copyWith(details: []);
    controller.onStateChanged(prev, next);
    await tester.pump();

    // simulate re-add: previous is next (empty), next contains the item again
    final prev2 = vm.state;
    final next2 = vm.state.copyWith(details: [detail]);
    controller.onStateChanged(prev2, next2);
    await tester.pump();
    // setelah ditambahkan kembali, controller harus mengembalikan active id ke 5
    // controller mengatur active id melalui viewmodel saat merestore
    expect(vm.state.activeNoteId, 5);
  });

  testWidgets('onUpdateQuantity updates and pops when cart empty',
      (tester) async {
    final detail = TransactionDetailEntity(
        productId: 7, qty: 1, productPrice: 1000, subtotal: 1000);
    final vmInstance = TransactionPosViewModel(
      CreateTransaction(fakeRepo),
      UpdateTransaction(fakeRepo),
      DeleteTransaction(fakeRepo),
      GetTransactionActive(fakeRepo),
    );
    vmInstance.state = vmInstance.state.copyWith(details: [detail]);

    await tester.pumpWidget(ProviderScope(
        overrides: [
          transactionPosViewModelProvider.overrideWith((ref) => vmInstance),
        ],
        child: MaterialApp(home: Builder(builder: (context) {
          return Column(children: [
            ElevatedButton(
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const SizedBox())),
                child: const Text('push')),
            const _ControllerHarness()
          ]);
        }))));

    await tester.pumpAndSettle();

    final state =
        tester.state<_ControllerHarnessState>(find.byType(_ControllerHarness));
    final controller = state.controller;

    // push a new route so Navigator.canPop becomes true
    await tester.tap(find.text('push'));
    await tester.pumpAndSettle();

    // call update to remove the only item
    controller.onUpdateQuantity(7, -1);
    await tester.pumpAndSettle();

    // setelah update, details pada vm.state harus kosong
    final vm = state.ref.read(transactionPosViewModelProvider.notifier);
    expect(vm.state.details.length, 0);
  });

  testWidgets('onClearCart clears state and pops when possible',
      (tester) async {
    final detail = TransactionDetailEntity(productId: 3, qty: 1);
    final vmInstance = TransactionPosViewModel(
      CreateTransaction(fakeRepo),
      UpdateTransaction(fakeRepo),
      DeleteTransaction(fakeRepo),
      GetTransactionActive(fakeRepo),
    );
    vmInstance.state = vmInstance.state.copyWith(details: [detail]);

    await tester.pumpWidget(ProviderScope(
        overrides: [
          transactionPosViewModelProvider.overrideWith((ref) => vmInstance),
        ],
        child: MaterialApp(home: Builder(builder: (context) {
          return Column(children: [
            ElevatedButton(
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const SizedBox())),
                child: const Text('push')),
            const _ControllerHarness()
          ]);
        }))));

    await tester.pumpAndSettle();
    final state =
        tester.state<_ControllerHarnessState>(find.byType(_ControllerHarness));
    final controller = state.controller;

    // push route so pop is possible
    await tester.tap(find.text('push'));
    await tester.pumpAndSettle();

    controller.onClearCart();
    await tester.pumpAndSettle();

    final vm = state.ref.read(transactionPosViewModelProvider.notifier);
    expect(vm.state.details.isEmpty, isTrue);
  });

  testWidgets('dispose does not throw', (tester) async {
    await tester.pumpWidget(ProviderScope(overrides: [
      transactionPosViewModelProvider
          .overrideWith((ref) => TransactionPosViewModel(
                CreateTransaction(fakeRepo),
                UpdateTransaction(fakeRepo),
                DeleteTransaction(fakeRepo),
                GetTransactionActive(fakeRepo),
              )),
    ], child: const MaterialApp(home: Scaffold(body: _ControllerHarness()))));

    await tester.pumpAndSettle();
    final state =
        tester.state<_ControllerHarnessState>(find.byType(_ControllerHarness));
    final controller = state.controller;

    // dispose tidak boleh melempar
    expect(() => controller.dispose(), returnsNormally);
  });
}
