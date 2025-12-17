import 'package:core/core.dart';
import 'package:transaction/domain/usecases/get_transaction.usecase.dart';
import 'package:transaction/domain/usecases/get_transactions.usecase.dart';
import 'package:transaction/domain/usecases/create_transaction.usecase.dart';
import 'package:transaction/domain/usecases/update_transaction.usecase.dart';
import 'package:transaction/domain/usecases/delete_transaction.usecase.dart';
import 'package:transaction/presentation/view_models/transaction_pos.vm.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';
import 'package:transaction/domain/usecases/get_transaction_active.usecase.dart';
import 'package:product/presentation/providers/packet.provider.dart';
import 'package:product/presentation/providers/product.provider.dart';
import 'package:product/data/datasources/product_local.datasource.dart';
import 'package:product/domain/repositories/product.repository.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/domain/usecases/get_products.usecase.dart';
import 'package:transaction/presentation/view_models/transaction_history.vm.dart';
import 'package:transaction/presentation/view_models/transaction_history.state.dart';
import 'package:transaction/presentation/providers/transaction_repository.provider.dart';

// Usecase providers (dipindahkan dari transaction_usecase_providers.dart)
final createTransaction = Provider((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return CreateTransaction(repo!);
});

final getTransactions = Provider((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return GetTransactionsUsecase(repo!);
});

final getTransaction = Provider((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return GetTransaction(repo!);
});

final updateTransaction = Provider((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return UpdateTransaction(repo!);
});

final deleteTransaction = Provider((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return DeleteTransaction(repo!);
});

final getTransactionActive = Provider((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return GetTransactionActive(repo!);
});

final transactionPosViewModelProvider =
    StateNotifierProvider<TransactionPosViewModel, TransactionPosState>((ref) {
  final createTxn = ref.watch(createTransaction);
  final updateTxn = ref.watch(updateTransaction);
  final deleteTxn = ref.watch(deleteTransaction);
  final getTxnActive = ref.watch(getTransactionActive);
  // Some composition roots (tests, isolated screens) may not provide
  // product repositories/providers. Read the product-related providers
  // defensively and fall back to `null` so `TransactionPosViewModel` can
  // use its internal noop implementations.
  final packetsProvider = (() {
    try {
      return ref.watch(packetGetPacketsProvider);
    } catch (_) {
      return null;
    }
  })();

  final productsProvider = (() {
    try {
      return ref.watch(productGetProductsProvider);
    } catch (_) {
      // If the app composition root didn't provide product usecases/repositories,
      // provide a lightweight local-only fallback that reads from local DB so
      // the POS screen still has products to display.
      try {
        final local = ProductLocalDataSource();
        return GetProducts(_LocalProductRepository(local));
      } catch (_) {
        return null;
      }
    }
  })();

  return TransactionPosViewModel(
    createTxn,
    updateTxn,
    deleteTxn,
    getTxnActive,
    packetsProvider,
    productsProvider,
  );
});

final transactionHistoryViewModelProvider =
    StateNotifierProvider<TransactionHistoryViewModel, TransactionHistoryState>(
        (ref) {
  final getTxn = ref.watch(getTransactions);
  return TransactionHistoryViewModel(getTxn);
});

// Lightweight local-only product repository fallback used when the app root
// does not provide a `productRepositoryProvider`. This reads products from
// local DB (ProductLocalDataSource) and maps them to entities.
class _LocalProductRepository implements ProductRepository {
  final ProductLocalDataSource local;
  _LocalProductRepository(this.local);

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts(
      {String? query, bool? isOffline}) async {
    try {
      final models = await local.getProducts();
      final entities = models.map((m) => ProductEntity.fromModel(m)).toList();
      return Right(entities);
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProduct(int id,
      {bool? isOffline}) async {
    try {
      final m = await local.getProductById(id);
      if (m != null) return Right(ProductEntity.fromModel(m));
      return const Left(UnknownFailure());
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct(ProductEntity product,
      {bool? isOffline}) async {
    return const Left(UnknownFailure());
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct(ProductEntity product,
      {bool? isOffline}) async {
    return const Left(UnknownFailure());
  }

  @override
  Future<Either<Failure, bool>> deleteProduct(int id, {bool? isOffline}) async {
    return const Left(UnknownFailure());
  }
}
