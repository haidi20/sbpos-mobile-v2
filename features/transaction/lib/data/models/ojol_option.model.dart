import 'package:transaction/domain/entitties/ojol_option.entity.dart';

class OjolOptionModel {
  final String id;
  final String name;
  final double? feePercent;
  final bool isActive;

  const OjolOptionModel({
    required this.id,
    required this.name,
    this.feePercent,
    this.isActive = true,
  });

  factory OjolOptionModel.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? json['title'] ?? json['provider'] ?? '')
        .toString()
        .trim();
    final id = (json['id'] ??
            json['code'] ??
            json['slug'] ??
            json['provider_code'] ??
            name.toLowerCase().replaceAll(' ', '_'))
        .toString();

    return OjolOptionModel(
      id: id,
      name: name,
      feePercent: _toDouble(
        json['fee_percent'] ??
            json['fee_percentage'] ??
            json['commission_percent'] ??
            json['percent'],
      ),
      isActive: _toBool(json['is_active']) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fee_percent': feePercent,
      'is_active': isActive,
    };
  }

  OjolOptionEntity toEntity() {
    return OjolOptionEntity(
      id: id,
      name: name,
      feePercent: feePercent,
      isActive: isActive,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      if (value == '1') return true;
      if (value == '0') return false;
      return value.toLowerCase() == 'true';
    }
    return null;
  }
}
