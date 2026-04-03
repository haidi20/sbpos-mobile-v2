import 'package:core/core.dart';

class FakeWebhookRepository implements WebhookRepository {
  @override
  Stream<WebhookEvent> listenToEvents(String url) async* {
    // Mode stress test jika URL mengandung 'stress'
    final isStressTest = url.contains('stress') || const bool.fromEnvironment('STRESS_TEST', defaultValue: false);
    final delayDuration = isStressTest ? const Duration(milliseconds: 100) : const Duration(seconds: 5);

    // Simulasi koneksi tertunda
    await Future.delayed(const Duration(milliseconds: 500));

    // Kirim event pertama saat terkoneksi
    yield WebhookEvent(
      id: "sim-start",
      topic: "connection",
      data: {"status": "connected", "url": url},
      timestamp: DateTime.now(),
    );

    // Simulasikan event acak setiap beberapa detik
    final topics = ["order_created", "payment_received", "stock_updated"];
    int count = 1;

    while (true) {
      await Future.delayed(delayDuration);
      final topic = topics[count % topics.length];
      
      yield WebhookEvent(
        id: "sim-$count",
        topic: topic,
        data: {
          "order_id": 1000 + count,
          "amount": (count * 5000).toDouble(),
          "note": "Simulated event $count"
        },
        timestamp: DateTime.now(),
      );
      count++;
      
      if (count > 20) break; // Batasi simulasi
    }
  }
}
