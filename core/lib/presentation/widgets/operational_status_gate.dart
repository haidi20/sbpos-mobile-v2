import 'package:core/core.dart';

class OperationalStatusGate extends ConsumerStatefulWidget {
  const OperationalStatusGate({
    required this.child,
    this.refreshInterval = const Duration(minutes: 5),
    super.key,
  });

  final Widget child;
  final Duration refreshInterval;

  @override
  ConsumerState<OperationalStatusGate> createState() =>
      _OperationalStatusGateState();
}

class _OperationalStatusGateState extends ConsumerState<OperationalStatusGate> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(
        ref.read(operationalStatusViewModelProvider.notifier).refreshStatus(),
      );
    });

    _refreshTimer = Timer.periodic(widget.refreshInterval, (_) {
      if (!mounted) {
        return;
      }
      unawaited(
        ref.read(operationalStatusViewModelProvider.notifier).refreshStatus(),
      );
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(operationalStatusViewModelProvider);

    return Stack(
      children: [
        widget.child,
        if (state.isBlocked)
          Positioned.fill(
            child: _OperationalStatusBlockedView(
              state: state,
              onRetry: () => unawaited(
                ref.read(operationalStatusViewModelProvider.notifier).refreshStatus(),
              ),
            ),
          ),
      ],
    );
  }
}

class _OperationalStatusBlockedView extends StatelessWidget {
  const _OperationalStatusBlockedView({
    required this.state,
    required this.onRetry,
  });

  final OperationalStatusState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.96),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 64,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.blockTitle.isEmpty
                        ? 'Aplikasi POS Sedang Dibatasi'
                        : state.blockTitle,
                    key: const Key('operational-status-title'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.blockMessage.isEmpty
                        ? 'Silakan hubungi tim terkait untuk mengaktifkan kembali layanan SB POS.'
                        : state.blockMessage,
                    key: const Key('operational-status-message'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    key: const Key('operational-status-retry'),
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Cek Ulang'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
