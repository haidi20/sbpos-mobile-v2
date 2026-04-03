class OpenCashierRequestModel {
  final int initialBalance;

  const OpenCashierRequestModel({
    required this.initialBalance,
  });

  Map<String, dynamic> toJson() {
    return {
      'initial_balance': initialBalance,
    };
  }
}
