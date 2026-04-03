import 'package:transaction/data/models/ojol_option.model.dart';

class OjolOptionEntity {
  final String id;
  final String name;
  final double? feePercent;
  final bool isActive;

  const OjolOptionEntity({
    required this.id,
    required this.name,
    this.feePercent,
    this.isActive = true,
  });

  OjolOptionEntity copyWith({
    String? id,
    String? name,
    double? feePercent,
    bool? isActive,
  }) {
    return OjolOptionEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      feePercent: feePercent ?? this.feePercent,
      isActive: isActive ?? this.isActive,
    );
  }

  factory OjolOptionEntity.fromModel(OjolOptionModel model) {
    return OjolOptionEntity(
      id: model.id,
      name: model.name,
      feePercent: model.feePercent,
      isActive: model.isActive,
    );
  }

  OjolOptionModel toModel() {
    return OjolOptionModel(
      id: id,
      name: name,
      feePercent: feePercent,
      isActive: isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OjolOptionEntity &&
        other.id == id &&
        other.name == name &&
        other.feePercent == feePercent &&
        other.isActive == isActive;
  }

  @override
  int get hashCode => Object.hash(id, name, feePercent, isActive);
}
