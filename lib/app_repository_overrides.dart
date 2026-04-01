import 'package:core/core.dart';
import 'package:product/data/datasources/packet_local.datasource.dart';
import 'package:product/data/datasources/product_local.datasource.dart';
import 'package:product/data/datasources/product_remote.datasource.dart';
import 'package:product/data/repositories/packet.repository.impl.dart';
import 'package:product/data/repositories/product.repository.impl.dart';
import 'package:product/presentation/providers/product_repository.provider.dart';
import 'package:transaction/data/datasources/transaction_local.data_source.dart';
import 'package:transaction/data/datasources/transaction_remote.data_source.dart';
import 'package:transaction/data/repositories/transaction.repository_impl.dart';
import 'package:transaction/presentation/providers/transaction_repository.provider.dart';

List<Override> buildAppRepositoryOverrides() {
  return [
    productRepositoryProvider.overrideWith(
      (ref) => ProductRepositoryImpl(
        remote: ProductRemoteDataSource(),
        local: ProductLocalDataSource(),
        networkInfo: NetworkInfoImpl(Connectivity()),
      ),
    ),
    packetRepositoryProvider.overrideWith(
      (ref) => PacketRepositoryImpl(
        local: PacketLocalDataSource(),
      ),
    ),
    transactionRepositoryProvider.overrideWith(
      (ref) => TransactionRepositoryImpl(
        remote: TransactionRemoteDataSource(),
        local: TransactionLocalDataSource(),
      ),
    ),
  ];
}
