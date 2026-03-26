import 'package:core/domain/entities/webhook_event.entity.dart';

abstract class WebhookRepository {
  Stream<WebhookEvent> listenToEvents(String url);
}
