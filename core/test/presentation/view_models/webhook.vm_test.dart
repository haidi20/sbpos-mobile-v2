import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';
import 'dart:async';

class MockWebhookRepository extends Mock implements WebhookRepository {}

void main() {
  late MockWebhookRepository mockRepository;
  late WebhookViewModel viewModel;

  setUp(() {
    mockRepository = MockWebhookRepository();
    viewModel = WebhookViewModel(mockRepository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('status awal harus terputus dan daftar event kosong', () {
    expect(viewModel.debugState.isConnected, false);
    expect(viewModel.debugState.events, isEmpty);
  });

  test('error harus memperbarui state dan memicu logika reconnect otomatis', () async {
    int callCount = 0;
    
    // Gunakan Completer untuk menunggu pemanggilan reconnect kedua
    final reconnectCompleter = Completer<void>();

    when(() => mockRepository.listenToEvents(any())).thenAnswer((_) {
      callCount++;
      if (callCount >= 2) {
        // Jika sudah pemanggilan kedua (reconnect), selesaikan completer
        if (!reconnectCompleter.isCompleted) reconnectCompleter.complete();
        return const Stream.empty();
      }
      // Pemanggilan pertama mensimulasikan kegagalan koneksi
      return Stream.error("Koneksi gagal");
    });

    viewModel.connect("ws://test-reconnect");

    // Tunggu hingga error pertama diproses
    await Future.delayed(Duration.zero);
    expect(viewModel.debugState.error, "Koneksi gagal");
    expect(callCount, 1);

    // Tunggu proses auto-reconnect (Timer default 2 detik)
    // Kita berikan batas waktu maksimal 5 detik
    await reconnectCompleter.future.timeout(const Duration(seconds: 5));
    
    expect(callCount, 2);
    expect(viewModel.debugState.isReconnecting, true);
  });

  test('koneksi normal harus memperbarui state dan menerima event', () async {
    final controller = StreamController<WebhookEvent>();
    when(() => mockRepository.listenToEvents(any()))
        .thenAnswer((_) => controller.stream);

    viewModel.connect("ws://test");
    
    final event = WebhookEvent(
      id: "1",
      topic: "test",
      data: {"msg": "halo"},
      timestamp: DateTime.now(),
    );

    controller.add(event);
    // Tunggu hingga stream memancarkan data
    await Future.delayed(Duration.zero);

    expect(viewModel.debugState.isConnected, true);
    controller.close();
  });
}
