import 'package:core/core.dart';
import 'package:customer/presentation/view_models/customer.state.dart';

final customerViewModelProvider =
    StateNotifierProvider<CustomerViewModel, CustomerState>((ref) {
  return CustomerViewModel();
});

class CustomerViewModel extends StateNotifier<CustomerState> {
  CustomerViewModel() : super(const CustomerState());

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      // TODO: load customers from repository
      await Future.delayed(const Duration(milliseconds: 300));
      state = state.copyWith(loading: false, customers: const []);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}
