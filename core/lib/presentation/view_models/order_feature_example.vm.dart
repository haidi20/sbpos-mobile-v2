import 'package:core/core.dart';

/// Contoh ViewModel di fitur lain (misal: fitur Order) yang menggunakan WebhookRepository
class OrderFeatureViewModel extends StateNotifier<List<WebhookEvent>> {
  final WebhookRepository _repository;
  StreamSubscription? _subscription;

  OrderFeatureViewModel(this._repository) : super([]);

  void startMonitoringOrders() {
    _subscription?.cancel();
    
    // Mendengarkan stream dari repository untuk topik spesifik 'order'
    _subscription = _repository.listenToEvents("ws://api.pos/orders").listen((event) {
      if (event.topic.contains('order')) {
        state = [event, ...state];
      }
    });
  }

  void stopMonitoring() {
    _subscription?.cancel();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// Provider untuk fitur Order
final orderFeatureProvider = StateNotifierProvider<OrderFeatureViewModel, List<WebhookEvent>>((ref) {
  // Mengambil repository dari core provider
  final repository = ref.watch(webhookRepositoryProvider);
  return OrderFeatureViewModel(repository);
});
