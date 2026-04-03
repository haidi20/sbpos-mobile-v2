import 'package:transaction/data/models/edit_order_check.model.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';

class EditOrderCheckEntity {
  final bool canEdit;
  final String message;
  final TransactionEntity? transaction;

  const EditOrderCheckEntity({
    required this.canEdit,
    required this.message,
    this.transaction,
  });

  factory EditOrderCheckEntity.fromModel(EditOrderCheckModel model) {
    return EditOrderCheckEntity(
      canEdit: model.canEdit,
      message: model.message,
      transaction: model.transaction == null
          ? null
          : TransactionEntity.fromModel(model.transaction!),
    );
  }
}
