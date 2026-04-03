class CloseCashierRequestModel {
  final int cashInDrawer;

  const CloseCashierRequestModel({
    required this.cashInDrawer,
  });

  Map<String, dynamic> toJson() {
    return {
      'cash_in_drawer': cashInDrawer,
    };
  }
}
