class NotificationModel {
  final int? id;
  final String? type;
  final String? title;
  final String? message;
  final String? time;
  final bool? read;

  const NotificationModel({
    this.id,
    this.type,
    this.title,
    this.message,
    this.time,
    this.read,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int?,
      type: json['type'] as String?,
      title: json['title'] as String?,
      message: json['message'] as String?,
      time: json['time'] as String?,
      read: json['read'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'time': time,
      'read': read,
    };
  }

  NotificationModel copyWith({
    int? id,
    String? type,
    String? title,
    String? message,
    String? time,
    bool? read,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      read: read ?? this.read,
    );
  }
}
