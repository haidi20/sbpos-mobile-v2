import 'package:core/core.dart';
import 'package:customer/presentation/view_models/customer.vm.dart';
import 'package:customer/presentation/view_models/customer.state.dart';

final customerViewModelProvider =
    StateNotifierProvider<CustomerViewModel, CustomerState>((ref) {
  return CustomerViewModel();
});
