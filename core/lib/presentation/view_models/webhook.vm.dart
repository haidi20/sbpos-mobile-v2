import 'package:core/core.dart';

class WebhookState {
  final bool isConnected;
  final bool isReconnecting;
  final List<WebhookEvent> events;
  final String? error;

  WebhookState({
    this.isConnected = false,
    this.isReconnecting = false,
    this.events = const [],
    this.error,
  });

  WebhookState copyWith({
    bool? isConnected,
    bool? isReconnecting,
    List<WebhookEvent>? events,
    String? error,
    bool clearError = false,
  }) {
    return WebhookState(
      isConnected: isConnected ?? this.isConnected,
      isReconnecting: isReconnecting ?? this.isReconnecting,
      events: events ?? this.events,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class WebhookViewModel extends StateNotifier<WebhookState> {
  final WebhookRepository _repository;
  StreamSubscription<WebhookEvent>? _subscription;
  String? _lastUrl;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;

  WebhookViewModel(this._repository) : super(WebhookState());

  void connect(String url) {
    _lastUrl = url;
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    
    state = state.copyWith(
      isConnected: false, 
      isReconnecting: _reconnectAttempts > 0,
      error: null
    );

    try {
      _subscription = _repository.listenToEvents(url).listen(
        (event) {
          _reconnectAttempts = 0;
          state = state.copyWith(
            isConnected: true,
            isReconnecting: false,
            events: [event, ...state.events],
          );
        },
        onError: (err) {
          state = state.copyWith(
            isConnected: false,
            isReconnecting: false,
            error: err.toString(),
          );
          _scheduleReconnect();
        },
        onDone: () {
          state = state.copyWith(isConnected: false, isReconnecting: false);
          _scheduleReconnect();
        },
      );
    } catch (e) {
      state = state.copyWith(
        isConnected: false,
        isReconnecting: false,
        error: e.toString(),
      );
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_lastUrl == null) return;
    
    _reconnectTimer?.cancel();
    _reconnectAttempts++;
    
    // Max delay 30 seconds
    final delay = Duration(seconds: (_reconnectAttempts * 2).clamp(2, 30));
    
    _reconnectTimer = Timer(delay, () {
      if (!state.isConnected) {
        connect(_lastUrl!);
      }
    });
  }

  void disconnect() {
    _lastUrl = null;
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    state = state.copyWith(isConnected: false, isReconnecting: false);
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
