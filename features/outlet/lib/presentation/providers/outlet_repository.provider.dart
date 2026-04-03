import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:outlet/data/datasources/outlet_local.data_source.dart';
import 'package:outlet/data/datasources/outlet_remote.data_source.dart';
import 'package:outlet/data/repositories/outlet.repository_impl.dart';
import 'package:outlet/domain/repositories/outlet.repository.dart';

final outletRemoteDataSourceProvider = Provider<OutletRemoteDataSource>(
  (ref) => OutletRemoteDataSource(),
);

final outletLocalDataSourceProvider = Provider<OutletLocalDataSource>(
  (ref) => OutletLocalDataSource(),
);

final outletRepositoryProvider = Provider<OutletRepository>((ref) {
  final remote = ref.read(outletRemoteDataSourceProvider);
  final local = ref.read(outletLocalDataSourceProvider);
  return OutletRepositoryImpl(remote: remote, local: local);
});
