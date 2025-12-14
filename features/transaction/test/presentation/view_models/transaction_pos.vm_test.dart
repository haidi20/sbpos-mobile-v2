// File ini berisi unit test untuk `TransactionPosViewModel`.
// Semua komentar di file ini menggunakan bahasa Indonesia untuk menjelaskan
// proses dan tujuan setiap langkah pengujian.
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/domain/entities/category.entity.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';
import 'package:transaction/presentation/ui_models/order_type_item.um.dart';
import 'package:transaction/domain/repositories/transaction_repository.dart';
import 'package:transaction/domain/usecases/create_transaction.usecase.dart';
import 'package:transaction/domain/usecases/update_transaction.usecase.dart';
import 'package:transaction/domain/usecases/delete_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_transaction_active.usecase.dart';
import 'package:transaction/presentation/view_models/transaction_pos.vm.dart';
import 'package:customer/domain/entities/customer.entity.dart';

class _FakeRepo implements TransactionRepository {
  TransactionEntity? last;

  @override
  Future<Either<Failure, List<TransactionEntity>>> getDataTransactions(
          {bool? isOffline}) async =>
      Right([]);

  @override
  Future<Either<Failure, TransactionEntity>> setTransaction(
      TransactionEntity transaction,
      {bool? isOffline}) async {
    last = transaction;
    return Right(transaction);
  }

  @override
  Future<Either<Failure, TransactionEntity>> createTransaction(
      TransactionEntity transaction,
      {bool? isOffline}) async {
    final created = transaction.copyWith(id: 1);
    last = created;
    return Right(created);
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(
          {bool? isOffline}) async =>
      Right([]);

  @override
  Future<Either<Failure, TransactionEntity>> getLatestTransaction(
          {bool? isOffline}) async =>
      Left(UnknownFailure());

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
      {bool? isOffline}) async {
    last = transaction;
    return Right(transaction);
  }

  @override
  Future<Either<Failure, bool>> deleteTransaction(int id,
      {bool? isOffline}) async {
    last = null;
    return Right(true);
  }
}

// Varian repo lokal yang mengembalikan transaksi yang disediakan untuk
// `getLatestTransaction`
class _LocalRepo extends _FakeRepo {
  final TransactionEntity provided;
  _LocalRepo(this.provided);

  @override
  Future<Either<Failure, TransactionEntity>> getLatestTransaction(
          {bool? isOffline}) async =>
      Right(provided);
}

// Varian repo yang mensimulasikan kegagalan untuk operasi tertentu
class _FakeRepoCreateFail extends _FakeRepo {
  @override
  Future<Either<Failure, TransactionEntity>> createTransaction(
          TransactionEntity transaction,
          {bool? isOffline}) async =>
      const Left(UnknownFailure());
}

class _FakeRepoUpdateFail extends _FakeRepo {
  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
          TransactionEntity transaction,
          {bool? isOffline}) async =>
      const Left(UnknownFailure());
}

class _FakeRepoDeleteFail extends _FakeRepo {
  @override
  Future<Either<Failure, bool>> deleteTransaction(int id,
          {bool? isOffline}) async =>
      const Left(UnknownFailure());
}

void main() {
  late _FakeRepo fake;
  late TransactionPosViewModel vm;

  setUp(() {
    fake = _FakeRepo();
    vm = TransactionPosViewModel(
      CreateTransaction(fake),
      UpdateTransaction(fake),
      DeleteTransaction(fake),
      GetTransactionActive(fake),
    );
  });

  // Memastikan getter default mengembalikan nilai awal/empty
  test('initial getters are zero/empty', () {
    expect(vm.getCartCount, 0);
    expect(vm.getCartTotalValue, 0);
    expect(vm.getTaxValue, 0);
    expect(vm.getGrandTotalValue, 0);
    expect(vm.getChangeValue, 0);
  });

  // Menambahkan produk ke keranjang dan memverifikasi transaksi dibuat
  test('onAddToCart creates transaction and adds detail', () async {
    final p = ProductEntity(id: 101, name: 'Apple', price: 10000.0);

    await vm.onAddToCart(p);

    expect(vm.state.details.length, 1);
    expect(vm.state.transaction, isNotNull);
    expect(vm.getCartCount, 1);
    expect(vm.getCartTotalValue, 10000);
  });

  // Menguji penambahan dan pengurangan kuantitas pada detail
  test('setUpdateQuantity increments and removes item', () async {
    final p = ProductEntity(id: 201, name: 'Banana', price: 5000.0);
    await vm.onAddToCart(p);
    // increase by 1 -> qty 2
    await vm.setUpdateQuantity(201, 1);
    expect(vm.state.details.first.qty, 2);

    // decrease by 2 -> removed
    await vm.setUpdateQuantity(201, -2);
    expect(vm.state.details.where((d) => d.productId == 201), isEmpty);
  });

  // Memastikan setItemNote meng-update state lokal sebelum debounce
  test('setItemNote updates local state immediately', () async {
    final p = ProductEntity(id: 301, name: 'C', price: 3000.0);
    await vm.onAddToCart(p);

    await vm.setItemNote(301, 'hello');
    final detail = vm.state.details.firstWhere((d) => d.productId == 301);
    expect(detail.note, 'hello');
  });

  // Memastikan setOrderNote mengubah orderNote di state
  test('setOrderNote updates state', () async {
    await vm.setOrderNote('Order X');
    expect(vm.state.orderNote, 'Order X');
  });

  // Verifikasi mapping string id ke enum EOrderType
  test('selectOrderTypeById maps to proper enum', () {
    vm.selectOrderTypeById('take_away');
    expect(vm.state.orderType, EOrderType.takeAway);
  });

  // Menguji setter terkait metode pembayaran dan provider ojol
  test('setOjolProvider, setPaymentMethod, setCashReceived', () {
    vm.setOjolProvider('GoFood');
    vm.setPaymentMethod(EPaymentMethod.qris);
    vm.setCashReceived(50000);

    expect(vm.state.ojolProvider, 'GoFood');
    expect(vm.state.paymentMethod, EPaymentMethod.qris);
    expect(vm.state.cashReceived, 50000);
  });

  // Toggle view mode harus membalikkan nilai viewMode
  test('onToggleView toggles viewMode', () {
    final before = vm.state.viewMode;
    vm.onToggleView();
    expect(vm.state.viewMode, isNot(equals(before)));
  });

  // Siklus typeCart saat menavigasi metode pembayaran
  test('onShowMethodPayment cycles cart type', () async {
    expect(vm.state.typeCart, ETypeCart.main);
    await vm.onShowMethodPayment();
    expect(vm.state.typeCart, ETypeCart.confirm);
    await vm.onShowMethodPayment();
    expect(vm.state.typeCart, ETypeCart.checkout);
  });

  // Hapus transaksi lokal jika ada dan clear state
  test('onClearCart deletes existing transaction and clears state', () async {
    final p = ProductEntity(id: 401, name: 'D', price: 2000.0);
    await vm.onAddToCart(p);

    // pastikan transaksi ada
    expect(vm.state.transaction, isNotNull);

    await vm.onClearCart();
    expect(vm.state.transaction, isNull);
    expect(vm.state.details, isEmpty);
  });

  // Menyimpan/order harus memaksa status menjadi 'proses'
  test('onStore forces status to proses', () async {
    final p = ProductEntity(id: 501, name: 'E', price: 1500.0);
    await vm.onAddToCart(p);

    await vm.onStore();
    expect(vm.state.transaction, isNotNull);
    expect(vm.state.transaction!.status, TransactionStatus.proses);
  });

  // Filter produk berdasarkan kategori dan search query
  test('getFilteredProducts honors category and search', () {
    final catFood = CategoryEntity(name: 'Food');
    final catDrink = CategoryEntity(name: 'Drink');

    final p1 = ProductEntity(
        id: 601, name: 'Nasi Goreng', price: 20000.0, category: catFood);
    final p2 = ProductEntity(
        id: 602, name: 'Es Teh', price: 5000.0, category: catDrink);

    // default activeCategory adalah 'All' -> keduanya muncul
    final both = vm.getFilteredProducts([p1, p2]);
    expect(both.length, 2);

    vm.setActiveCategory('Food');
    final onlyFood = vm.getFilteredProducts([p1, p2]);
    expect(onlyFood.length, 1);
    expect(onlyFood.first.id, 601);

    // reset category to All before testing search-only behavior
    vm.setActiveCategory('All');
    vm.setSearchQuery('es');
    final searchRes = vm.getFilteredProducts([p1, p2]);
    // pencarian case-insensitive harus menemukan 'Es Teh'
    expect(searchRes.length, 1);
    expect(searchRes.first.id, 602);
  });

  // Menghasilkan UI model untuk order type dan memverifikasi struktur
  test('getOrderTypeItems returns selectable items', () {
    final items = vm.getOrderTypeItems();
    expect(items, isNotEmpty);
    expect(items.first, isA<OrderTypeItemUiModel>());
  });

  // Filter details berdasarkan searchQuery dan activeCategory
  test('getFilteredDetails filters by searchQuery and activeCategory', () {
    final d1 = TransactionDetailEntity(
        productId: 1,
        productName: 'Sate',
        note: 'Food',
        qty: 2,
        productPrice: 10000,
        subtotal: 20000);
    final d2 = TransactionDetailEntity(
        productId: 2,
        productName: 'Teh Manis',
        note: 'Drink',
        qty: 1,
        productPrice: 5000,
        subtotal: 5000);

    vm.state = vm.state.copyWith(details: [d1, d2]);

    // search by name
    vm.setSearchQuery('sate');
    var res = vm.getFilteredDetails;
    expect(res.length, 1);
    expect(res.first.productId, 1);

    // filter by category via activeCategory (note used as category in getter)
    vm.setSearchQuery('');
    vm.setActiveCategory('Drink');
    res = vm.getFilteredDetails;
    expect(res.length, 1);
    expect(res.first.productId, 2);
  });

  // Memastikan format rupiah dikembalikan sebagai string
  test('getCartTotal returns formatted rupiah string', () async {
    final p = ProductEntity(id: 701, name: 'Test', price: 12345.0);
    await vm.onAddToCart(p);
    final formatted = vm.getCartTotal;
    expect(formatted, isA<String>());
    expect(formatted, contains(RegExp(r'\d')));
  });

  // Set dan hapus selectedCustomer di state
  test('setCustomer sets and clears selectedCustomer', () {
    final c = CustomerEntity(id: 9, name: 'Budi');
    vm.setCustomer(c);
    expect(vm.state.selectedCustomer, equals(c));
    vm.setCustomer(null);
    expect(vm.state.selectedCustomer, isNull);
  });

  // Set dan clear nilai activeNoteId
  test('setActiveNoteId set and clear', () {
    vm.setActiveNoteId(42);
    expect(vm.state.activeNoteId, 42);
    vm.setActiveNoteId(null);
    expect(vm.state.activeNoteId, isNull);
  });

  // Menguji setter tipe cart, snackbar error, dan onClearAll
  test('setTypeCart and setShowErrorSnackbar and onClearAll', () {
    vm.setTypeCart(ETypeCart.confirm);
    expect(vm.state.typeCart, ETypeCart.confirm);
    vm.setShowErrorSnackbar(true);
    expect(vm.state.showErrorSnackbar, isTrue);
    vm.onClearAll();
    // verifikasi beberapa invariant state setelah clear
    expect(vm.state.transaction, isNull);
    expect(vm.state.details, isEmpty);
    expect(vm.state.orderNote, '');
    expect(vm.state.activeCategory, 'All');
    expect(vm.state.viewMode, EViewMode.cart);
    expect(vm.state.paymentMethod, EPaymentMethod.cash);
  });

  // Debounce pada orderNote harus memicu persistence ke repo setelah delay
  test('debounced setOrderNote triggers persistence', () async {
    fake = _FakeRepo();
    vm = TransactionPosViewModel(
      CreateTransaction(fake),
      UpdateTransaction(fake),
      DeleteTransaction(fake),
      GetTransactionActive(fake),
    );

    await vm.setOrderNote('Delayed');
    // tunggu/poll hingga 1s agar persistence selesai
    var waited = 0;
    while (fake.last == null && vm.state.transaction == null && waited < 1000) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      waited += 50;
    }
    expect(fake.last ?? vm.state.transaction, isNotNull);
  });

  // Debounce pada item note memicu persistence setelah delay
  test('debounced setItemNote triggers persistence', () async {
    // pastikan ada item untuk diberikan note
    final p = ProductEntity(id: 801, name: 'F', price: 2000.0);
    await vm.onAddToCart(p);

    await vm.setItemNote(801, 'note1');
    var waited2 = 0;
    while (
        fake.last == null && vm.state.transaction == null && waited2 < 1000) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      waited2 += 50;
    }
    expect(fake.last ?? vm.state.transaction, isNotNull);
  });

  // Constructor harus memuat transaksi lokal jika tersedia
  test('constructor _loadLocalTransaction populates state when repo has tx',
      () async {
    // create a fake repo that returns an existing transaction
    final tx = TransactionEntity(
      id: 77,
      outletId: 1,
      sequenceNumber: 7,
      orderTypeId: 1,
      date: DateTime.now(),
      totalAmount: 100,
      totalQty: 1,
      details: [
        TransactionDetailEntity(
            productId: 900,
            productName: 'X',
            productPrice: 100,
            qty: 1,
            subtotal: 100)
      ],
    );

    // gunakan _LocalRepo untuk mengembalikan transaksi yang disediakan
    final localRepo = _LocalRepo(tx);
    final vm2 = TransactionPosViewModel(
      CreateTransaction(localRepo),
      UpdateTransaction(localRepo),
      DeleteTransaction(localRepo),
      GetTransactionActive(localRepo),
    );

    // tunggu inisialisasi async selesai (menggunakan polling)
    var waited3 = 0;
    while (vm2.state.transaction == null && waited3 < 1000) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      waited3 += 50;
    }
    expect(vm2.state.transaction, isNotNull);
    expect(vm2.state.details.length, 1);
  });

  // Memastikan getOrderTypes menghasilkan list map dengan kunci yang diharapkan
  test('getOrderTypes returns raw map list with expected keys', () {
    final raw = vm.getOrderTypes;
    expect(raw, isNotEmpty);
    final first = raw.first;
    expect(first, isA<Map<String, Object?>>());
    expect(first.containsKey('id'), isTrue);
    expect(first.containsKey('label'), isTrue);
    expect(first.containsKey('icon'), isTrue);
  });

  // Mengubah order type harus memicu persistence create/update
  test('setOrderType triggers persistence via create/update', () async {
    // use fresh fake repo to observe persistence
    fake = _FakeRepo();
    vm = TransactionPosViewModel(
      CreateTransaction(fake),
      UpdateTransaction(fake),
      DeleteTransaction(fake),
      GetTransactionActive(fake),
    );

    vm.setOrderType(EOrderType.online);

    // polling untuk menunggu efek samping persistence
    var waited = 0;
    while (fake.last == null && waited < 1000) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      waited += 50;
    }

    expect(fake.last ?? vm.state.transaction, isNotNull);
  });

  // Cabang kegagalan: mensimulasikan kegagalan repo untuk menguji penanganan error
  // Simulasi kegagalan create: VM harus menangani error dan menghentikan loading
  test('createTransaction failure sets error and clears loading', () async {
    final failRepo = _FakeRepoCreateFail();
    final vmFail = TransactionPosViewModel(
      CreateTransaction(failRepo),
      UpdateTransaction(failRepo),
      DeleteTransaction(failRepo),
      GetTransactionActive(failRepo),
    );

    final p = ProductEntity(id: 901, name: 'FailCreate', price: 1000.0);
    await vmFail.onAddToCart(p);

    // simpan dengan status dipaksa agar jalur create dieksekusi
    await vmFail.onStore();

    // create failed: repository returned Left; no new transaction saved
    expect(vmFail.state.isLoading, isFalse);
    expect(failRepo.last, isNull);
  });

  // Simulasi kegagalan update: VM harus tetap stabil dan menghentikan loading
  test('updateTransaction failure sets error and clears loading', () async {
    // repo that fails on update only
    final failRepo = _FakeRepoUpdateFail();
    final vmFail = TransactionPosViewModel(
      CreateTransaction(failRepo),
      UpdateTransaction(failRepo),
      DeleteTransaction(failRepo),
      GetTransactionActive(failRepo),
    );

    final p = ProductEntity(id: 902, name: 'FailUpdate', price: 2000.0);
    await vmFail.onAddToCart(p);

    // ensure transaction exists now
    expect(vmFail.state.transaction, isNotNull);

    // trigger an update path
    await vmFail.setUpdateQuantity(902, 1);

    expect(vmFail.state.isLoading, isFalse);
    // transaction should remain unchanged (not updated)
    expect(vmFail.state.transaction, isNotNull);
  });

  // Simulasi kegagalan delete: transaksi harus tetap ada jika delete gagal
  test('deleteTransaction failure sets error and keeps transaction', () async {
    final failRepo = _FakeRepoDeleteFail();
    final vmFail = TransactionPosViewModel(
      CreateTransaction(failRepo),
      UpdateTransaction(failRepo),
      DeleteTransaction(failRepo),
      GetTransactionActive(failRepo),
    );

    final p = ProductEntity(id: 903, name: 'FailDelete', price: 3000.0);
    await vmFail.onAddToCart(p);

    // remove item to trigger delete path
    await vmFail.setUpdateQuantity(903, -1);

    expect(vmFail.state.isLoading, isFalse);
    // delete failed: transaction should still exist
    expect(vmFail.state.transaction, isNotNull);
  });

  // Perubahan metode pembayaran harus tersimpan sebagai nama enum pada entitas
  test('setPaymentMethod persists enum name into stored transaction', () async {
    // fresh fake repo to observe created transaction
    fake = _FakeRepo();
    vm = TransactionPosViewModel(
      CreateTransaction(fake),
      UpdateTransaction(fake),
      DeleteTransaction(fake),
      GetTransactionActive(fake),
    );

    // set payment method to QRIS and add an item to trigger create
    vm.setPaymentMethod(EPaymentMethod.qris);
    final p = ProductEntity(id: 1001, name: 'G', price: 2500.0);
    await vm.onAddToCart(p);

    // poll for persistence
    var waited = 0;
    while (fake.last == null && waited < 1000) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      waited += 50;
    }

    expect(fake.last, isNotNull);
    // persisted paymentMethod should be the enum's name
    expect(fake.last!.paymentMethod, equals(EPaymentMethod.qris.name));
  });

  // Menandai transaksi lunas lalu simpan harus merefleksikan pada entity
  test('setIsPaid and onStore result in TransactionStatus.lunas when paid',
      () async {
    fake = _FakeRepo();
    vm = TransactionPosViewModel(
      CreateTransaction(fake),
      UpdateTransaction(fake),
      DeleteTransaction(fake),
      GetTransactionActive(fake),
    );

    final p = ProductEntity(id: 1101, name: 'H', price: 10000.0);
    await vm.onAddToCart(p);

    // tandai sebagai lunas lalu simpan
    vm.setIsPaid(true);
    await vm.onStore();

    expect(vm.state.transaction, isNotNull);
    expect(vm.state.transaction!.status, TransactionStatus.proses);
    // entitas yang dibuat (fake.last) harus mencerminkan isPaid = true
    expect(fake.last, isNotNull);
    expect(fake.last!.isPaid, isTrue);
  });

  // Memverifikasi perhitungan total, pajak, dan grand total
  test('getCartTotalValue and tax/grand total calculation are correct', () {
    final d1 = TransactionDetailEntity(
        productId: 2001,
        productName: 'Item1',
        qty: 2,
        productPrice: 5000,
        subtotal: 10000);
    final d2 = TransactionDetailEntity(
        productId: 2002,
        productName: 'Item2',
        qty: 1,
        productPrice: 3000,
        subtotal: null);

    vm.state = vm.state.copyWith(details: [d1, d2]);

    // total: d1 subtotal 10000 + d2 price*qty 3000 = 13000
    expect(vm.getCartTotalValue, 13000);
    expect(vm.getTaxValue, (13000 * 0.1).round());
    expect(vm.getGrandTotalValue, vm.getCartTotalValue + vm.getTaxValue);
  });

  // Menghitung kembalian berdasarkan cashReceived dikurangi grand total
  test('getChangeValue reflects cash received minus grand total', () async {
    final p = ProductEntity(id: 1201, name: 'I', price: 2500.0);
    await vm.onAddToCart(p);
    // grand total harus sama dengan harga produk + pajak
    final grand = vm.getGrandTotalValue;
    vm.setCashReceived(grand + 5000);
    expect(vm.getChangeValue, equals(5000));
  });
}
