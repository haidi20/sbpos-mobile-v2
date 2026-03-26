import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'package:core/presentation/view_models/order_feature_example.vm.dart';
import 'dart:async';

class MockWebhookRepository extends Mock implements WebhookRepository {}

void main() {
  late MockWebhookRepository mockRepository;
  late OrderFeatureViewModel orderViewModel;

  setUp(() {
    mockRepository = MockWebhookRepository();
    orderViewModel = OrderFeatureViewModel(mockRepository);
  });

  test('fitur lain harus bisa menerima data pesanan dari repository webhook', () async {
    final controller = StreamController<WebhookEvent>();
    when(() => mockRepository.listenToEvents(any()))
        .thenAnswer((_) => controller.stream);

    // Mulai monitoring di fitur order
    orderViewModel.startMonitoringOrders();

    // Simulasikan event pesanan masuk
    final orderEvent = WebhookEvent(
      id: "ord-123",
      topic: "order_created",
      data: {"item": "Kopi Susu", "price": 15000},
      timestamp: DateTime.now(),
    );

    // Simulasikan event lain yang bukan pesanan (harus difilter oleh fitur order)
    final pingEvent = WebhookEvent(
      id: "ping-1",
      topic: "ping",
      data: {"status": "alive"},
      timestamp: DateTime.now(),
    );

    controller.add(orderEvent);
    controller.add(pingEvent);

    // Tunggu pemrosesan
    await Future.delayed(Duration.zero);

    // Verifikasi fitur order hanya menerima event pesanan
    expect(orderViewModel.state.length, 1);
    expect(orderViewModel.state.first.id, "ord-123");
    expect(orderViewModel.state.first.topic, "order_created");

    controller.close();
  });
}
