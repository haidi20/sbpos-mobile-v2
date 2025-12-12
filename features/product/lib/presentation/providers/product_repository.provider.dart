import 'package:core/core.dart';
import 'package:product/data/datasources/product_local.datasource.dart';
import 'package:product/data/datasources/product_remote.datasource.dart';
import 'package:product/domain/repositories/product.repository.dart';

/// Placeholder provider for remote datasource. Override in the app composition
/// root with a concrete implementation that implements `ProductRemoteDataSource`.
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource?>(
  (ref) => null,
);

/// Placeholder provider for local datasource. Override in the app composition
/// root with a concrete implementation that constructs `ProductLocalDataSource`.
final productLocalDataSourceProvider = Provider<ProductLocalDataSource?>(
  (ref) => null,
);

/// Repository provider for product feature. Override this in the app
/// composition root with a concrete `ProductRepository` (e.g. an instance of
/// `ProductRepositoryImpl`).
final productRepositoryProvider = Provider<ProductRepository?>(
  (ref) => null,
);
