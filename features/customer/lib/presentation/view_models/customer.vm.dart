import 'package:core/core.dart';
import 'package:customer/domain/entities/customer.entity.dart';
import 'package:customer/presentation/view_models/customer.state.dart';

class CustomerViewModel extends StateNotifier<CustomerState> {
  CustomerViewModel() : super(const CustomerState());

  String get searchQuery => state.searchQuery;

  // Draft entity for add-new-customer form
  CustomerEntity _draftCustomer = const CustomerEntity();
  CustomerEntity get draftCustomer => _draftCustomer;

  // UI mode: list vs form
  void startAdd() {
    state = state.copyWith(isAdding: true);
  }

  void cancelAdd() {
    state = state.copyWith(isAdding: false);
  }

  List<CustomerEntity> get filteredCustomers {
    final list = state.customers;
    if (state.searchQuery.isEmpty) return list;
    final q = state.searchQuery.toLowerCase();
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
    state = state.copyWith(searchQuery: query);
  }

  void updateDraft(String field, String value) {
    switch (field) {
      case 'name':
        _draftCustomer = _draftCustomer.copyWith(name: value);
        break;
      case 'phone':
        _draftCustomer = _draftCustomer.copyWith(phone: value);
        break;
      case 'email':
        _draftCustomer = _draftCustomer.copyWith(email: value);
        break;
      case 'note':
      case 'notes':
        _draftCustomer = _draftCustomer.copyWith(note: value);
        break;
    }
    // no state change broadcast needed until save
  }

  Future<void> handleSaveNewCustomer() async {
    final name = (_draftCustomer.name ?? '').trim();
    final phone = (_draftCustomer.phone ?? '').trim();
    if (name.isEmpty || phone.isEmpty) {
      return;
    }
    final newEntity = _draftCustomer.copyWith(
      name: name,
      phone: phone,
      createdAt: DateTime.now(),
    );
    final updated = [...state.customers, newEntity];
    state = state.copyWith(customers: updated, isAdding: false);
    // Reset draft
    _draftCustomer = const CustomerEntity();
  }
}
