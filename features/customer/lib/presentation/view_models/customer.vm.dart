import 'package:core/core.dart';
import 'package:customer/domain/entities/customer.entity.dart';
import 'package:customer/presentation/view_models/customer.state.dart';

class CustomerViewModel extends StateNotifier<CustomerState> {
  CustomerViewModel() : super(const CustomerState());

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  List<CustomerEntity> get filteredCustomers {
    final list = state.customers;
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list
        .where((c) =>
            (c.name ?? '').toLowerCase().contains(q) ||
            (c.phone ?? '').toLowerCase().contains(q) ||
            (c.email ?? '').toLowerCase().contains(q))
        .toList();
  }

  Future<void> load() async {
    state = state.copyWith(loading: true);
    try {
      // TODO: replace with repository fetch
      await Future.delayed(const Duration(milliseconds: 200));
      // Fallback dummy data to avoid cross-package import issues
      final entities = <CustomerEntity>[
        const CustomerEntity(name: 'Andi Wijaya', phone: '081234567890'),
        const CustomerEntity(name: 'Budi Santoso', phone: '081987654321'),
        const CustomerEntity(name: 'Citra Lestari', phone: '081345678901'),
        const CustomerEntity(name: 'Dewi Putri', phone: '081299887766'),
        const CustomerEntity(name: 'Eko Prasetyo', phone: '085712345678'),
      ];
      state = state.copyWith(loading: false, customers: entities);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    // trigger listeners by copying state (no change to customers)
    state = state.copyWith(customers: state.customers);
  }
}
