import 'package:core/core.dart';

@immutable
class PaymentMethodState {
  final int id;
  final String name;
  final bool isActive;

  const PaymentMethodState({
    required this.id,
    required this.name,
    required this.isActive,
  });

  PaymentMethodState copyWith({
    int? id,
    String? name,
    bool? isActive,
  }) {
    return PaymentMethodState(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }
}

@immutable
class PaymentSettingsState {
  final List<PaymentMethodState> methods;

  const PaymentSettingsState({
    required this.methods,
  });

  const PaymentSettingsState.initial()
      : methods = const [
          PaymentMethodState(id: 1, name: 'Tunai (Cash)', isActive: true),
          PaymentMethodState(id: 2, name: 'QRIS', isActive: true),
          PaymentMethodState(id: 3, name: 'Kartu Debit', isActive: true),
          PaymentMethodState(id: 4, name: 'Kartu Kredit', isActive: false),
          PaymentMethodState(id: 5, name: 'Transfer Bank', isActive: false),
        ];

  PaymentSettingsState copyWith({
    List<PaymentMethodState>? methods,
  }) {
    return PaymentSettingsState(
      methods: methods ?? this.methods,
    );
  }
}
