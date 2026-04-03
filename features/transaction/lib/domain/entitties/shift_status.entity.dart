import 'package:transaction/domain/entitties/shift.entity.dart';

class ShiftStatusEntity {
  final bool isOpen;
  final String message;
  final ShiftEntity? shift;

  const ShiftStatusEntity({
    required this.isOpen,
    this.message = '',
    this.shift,
  });

  ShiftStatusEntity copyWith({
    bool? isOpen,
    String? message,
    ShiftEntity? shift,
  }) {
    return ShiftStatusEntity(
      isOpen: isOpen ?? this.isOpen,
      message: message ?? this.message,
      shift: shift ?? this.shift,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShiftStatusEntity &&
        other.isOpen == isOpen &&
        other.message == message &&
        other.shift == shift;
  }

  @override
  int get hashCode => Object.hash(isOpen, message, shift);
}
