import 'package:core/core.dart';
import 'package:customer/domain/usecases/delete_customer.usecase.dart';
import 'package:customer/domain/usecases/create_customer.usecase.dart';
import 'package:customer/domain/usecases/get_customers.usecase.dart';
import 'package:customer/domain/usecases/update_customer.usecase.dart';
import 'package:customer/data/dummies/customer.data.dart';
import 'package:customer/domain/entities/customer.entity.dart';
import 'package:customer/presentation/view_models/customer.state.dart';

class CustomerViewModel extends StateNotifier<CustomerState> {
  CustomerViewModel({
    required DeleteCustomer deleteCustomerUsecase,
    required CreateCustomer createCustomerUsecase,
    required UpdateCustomer updateCustomerUsecase,
    required GetCustomers getCustomersUsecase,
  })  : _deleteCustomerUsecase = deleteCustomerUsecase,
        _createCustomerUsecase = createCustomerUsecase,
        _updateCustomerUsecase = updateCustomerUsecase,
        _getCustomersUsecase = getCustomersUsecase,
        super(const CustomerState());

  final GetCustomers _getCustomersUsecase;
  final DeleteCustomer _deleteCustomerUsecase;
  final CreateCustomer _createCustomerUsecase;
  final UpdateCustomer _updateCustomerUsecase;

  String? get searchQuery => state.searchQuery;

  // Draft entity for add-new-customer form
  CustomerEntity _draftCustomer = const CustomerEntity();
  CustomerEntity get draftCustomer => _draftCustomer;

  // UI mode: list vs form
  // State setters (use `set*` naming)
  void setIsAdding(bool value) {
    state = state.copyWith(isAdding: value);
  }

  void setDraftCustomer(CustomerEntity customer) {
    _draftCustomer = customer;
  }

  // (startAdd/cancelAdd removed — use `setIsAdding` directly)

  // Mulai mode edit: set draft ke customer terpilih dan buka form
  void startEdit(CustomerEntity customer) {
    setDraftCustomer(customer);
    setIsAdding(true);
  }

  List<CustomerEntity> get filteredCustomers {
    final list = state.customers;
    if (state.searchQuery == null || state.searchQuery!.isEmpty) return list;
    final q = state.searchQuery!.toLowerCase();
    return list
        .where((c) =>
            (c.name ?? '').toLowerCase().contains(q) ||
            (c.phone ?? '').toLowerCase().contains(q) ||
            (c.email ?? '').toLowerCase().contains(q))
        .toList();
  }

  /// Data getter: load customers from local DB, seed if empty
  Future<void> getCustomers() async {
    state = state.copyWith(loading: true);
    try {
      final result = await _getCustomersUsecase(isOffline: true);
      await Future.delayed(const Duration(milliseconds: 200));
      result.fold(
        (failure) {
          state = state.copyWith(loading: false, error: failure.message);
        },
        (customers) async {
          if (customers.isEmpty) {
            // Seed initialCustomers into local DB
            for (final c in initialCustomers) {
              await _createCustomerUsecase(c, isOffline: true);
            }
            // Re-fetch after seeding
            final seeded = await _getCustomersUsecase(isOffline: true);
            seeded.fold(
              (failure) {
                state = state.copyWith(loading: false, error: failure.message);
              },
              (seededList) {
                state = state.copyWith(loading: false, customers: seededList);
              },
            );
          } else {
            state = state.copyWith(loading: false, customers: customers);
          }
        },
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  // (load removed — use `getCustomers` directly)

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setDraftField(String field, String value) {
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

  // (updateDraft removed — use `setDraftField` directly)

  // Event: create
  Future<void> onCreateCustomer() async {
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

    final result = await _createCustomerUsecase(newEntity, isOffline: true);
    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (created) {
        final updated = [...state.customers, created];
        state = state.copyWith(customers: updated, isAdding: false);
        _draftCustomer = const CustomerEntity();
      },
    );
  }

  // (handleSaveNewCustomer removed — use `onCreateCustomer` directly)

  // Event: update
  Future<void> onUpdateCustomer() async {
    final name = (_draftCustomer.name ?? '').trim();
    final phone = (_draftCustomer.phone ?? '').trim();
    if (name.isEmpty || phone.isEmpty) {
      return;
    }
    final entity = _draftCustomer.copyWith(
      name: name,
      phone: phone,
    );
    final result = await _updateCustomerUsecase(entity, isOffline: true);
    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (updatedEntity) {
        final updatedList = state.customers
            .map((c) => c.id == updatedEntity.id ? updatedEntity : c)
            .toList();
        state = state.copyWith(customers: updatedList, isAdding: false);
        _draftCustomer = const CustomerEntity();
      },
    );
  }

  // (handleUpdateCustomer removed — use `onUpdateCustomer` directly)

  // Hapus customer dari list berdasarkan id sederhana (assume unique by id)
  Future<bool> onDeleteCustomerById(int? id) async {
    try {
      if (id == null) return false;
      final result = await _deleteCustomerUsecase(id, isOffline: true);

      return result.fold(
        (failure) {
          state = state.copyWith(error: failure.message);
          return false;
        },
        (ok) {
          if (ok) {
            final updated = state.customers.where((c) => c.id != id).toList();

            state = state.copyWith(customers: updated);
          }

          return ok;
        },
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // (deleteCustomerById removed — use `onDeleteCustomerById` directly)

  // Event: save or update
  Future<void> onSaveOrUpdate() async {
    // If draft has an id, treat as update; else create
    if (_draftCustomer.id != null) {
      await onUpdateCustomer();
    } else {
      await onCreateCustomer();
    }
  }

  // (handleSaveOrUpdate removed — use `onSaveOrUpdate` directly)
}
