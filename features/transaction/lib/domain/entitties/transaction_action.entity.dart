import 'package:transaction/data/models/transaction_action.model.dart';

class TransactionActionEntity {
  final bool success;
  final String message;

  const TransactionActionEntity({
    required this.success,
    required this.message,
  });

  factory TransactionActionEntity.fromModel(TransactionActionModel model) {
    return TransactionActionEntity(
      success: model.success,
      message: model.message,
    );
  }

  TransactionActionModel toModel() {
    return TransactionActionModel(
      success: success,
      message: message,
    );
  }
}
