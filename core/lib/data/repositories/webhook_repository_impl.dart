import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:core/domain/entities/webhook_event.entity.dart';
import 'package:core/domain/repositories/webhook_repository.dart';

class WebhookRepositoryImpl implements WebhookRepository {
  @override
  Stream<WebhookEvent> listenToEvents(String url) {
    final channel = WebSocketChannel.connect(Uri.parse(url));

    return channel.stream.map((event) {
      if (event is String) {
        final Map<String, dynamic> json = jsonDecode(event);
        return WebhookEvent.fromJson(json);
      } else {
        // Handle binary data if necessary
        return WebhookEvent(
          id: 'binary',
          topic: 'binary',
          data: {'content': event.toString()},
          timestamp: DateTime.now(),
        );
      }
    });
  }
}
