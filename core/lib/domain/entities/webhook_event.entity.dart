import 'package:uuid/uuid.dart';

class WebhookEvent {
  final String id;
  final String topic;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  WebhookEvent({
    required this.id,
    required this.topic,
    required this.data,
    required this.timestamp,
  });

  factory WebhookEvent.fromJson(Map<String, dynamic> json) {
    const uuid = Uuid();
    return WebhookEvent(
      id: json['id'] ?? uuid.v4(),
      topic: json['topic'] ?? 'unknown',
      data: json['data'] ?? {},
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic': topic,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
