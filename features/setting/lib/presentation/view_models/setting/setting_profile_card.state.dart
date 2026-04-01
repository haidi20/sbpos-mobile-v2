import 'package:core/core.dart';

@immutable
class SettingProfileCardState {
  final String name;
  final String role;
  final String statusLabel;
  final String avatarUrl;

  const SettingProfileCardState({
    required this.name,
    required this.role,
    required this.statusLabel,
    required this.avatarUrl,
  });

  const SettingProfileCardState.initial()
      : name = 'Budi Santoso',
        role = 'Kasir - Shift Pagi',
        statusLabel = 'Online',
        avatarUrl = 'https://picsum.photos/200/200?random=user';

  SettingProfileCardState copyWith({
    String? name,
    String? role,
    String? statusLabel,
    String? avatarUrl,
  }) {
    return SettingProfileCardState(
      name: name ?? this.name,
      role: role ?? this.role,
      statusLabel: statusLabel ?? this.statusLabel,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
