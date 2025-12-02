import 'package:core/core.dart';
import 'package:product/data/models/cart_model.dart';
import 'package:product/data/datasources/cart_local_data_source.dart';
import 'package:product/data/datasources/cart_remote_data_source.dart';

class ProductPosRepositoryImpl {
  final CartLocalDataSource local;
  final CartRemoteDataSource remote;

  static final Logger _logger = Logger('ProductPosRepositoryImpl');

  ProductPosRepositoryImpl({required this.remote, required this.local});

  Future<List<CartModel>> _getLocalCarts() async {
    return await local.getCarts();
  }

  Future<List<CartModel>?> _saveToLocal(List<CartModel>? carts) async {
    if (carts == null || carts.isEmpty) return [];
    final res = await local.insertSyncCarts(carts: carts);
    if (res.isEmpty) {
      _logger.warning('Tidak ada cart yang disinkronkan ke local');
      return null;
    }
    return res;
  }

  Future<Either<Failure, List<CartModel>>> fetchCarts() async {
    final networkInfo = NetworkInfoImpl(Connectivity());
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final resp = await remote.fetchCarts();
        if (resp.success == true && resp.data != null) {
          await _saveToLocal(resp.data);
          final local = await _getLocalCarts();
          return Right(local);
        }
        return const Left(ServerFailure());
      } on ServerException {
        return const Left(ServerFailure());
      } on NetworkException {
        return const Left(NetworkFailure());
      } catch (e, st) {
        _logger.severe('Error fetchCarts', e, st);
        return const Left(UnknownFailure());
      }
    } else {
      final local = await _getLocalCarts();
      if (local.isNotEmpty) return Right(local);
      return const Left(NetworkFailure());
    }
  }
}
