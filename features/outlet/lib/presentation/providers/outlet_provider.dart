import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'outlet_repository_provider.dart';
import '../view_models/outlet.vm.dart';
import '../../domain/usecases/get_outlets.dart';

final getOutletsProvider = Provider<GetOutlets>((ref) {
  final repo = ref.read(outletRepositoryProvider);
  return GetOutlets(repo);
});

final outletViewModelProvider =
    StateNotifierProvider<OutletViewModel, OutletState>((ref) {
  final getOutlets = ref.watch(getOutletsProvider);
  return OutletViewModel(getOutlets);
});
