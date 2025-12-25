import 'package:core/core.dart';

class SyncStatus extends StatelessWidget {
  final double size;
  final int? idServer;
  final DateTime? syncedAt;

  const SyncStatus({
    super.key,
    this.idServer,
    this.syncedAt,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    final isSynced = (idServer != null) || (syncedAt != null);
    final color = isSynced ? Colors.green : Colors.orange;
    final icon = isSynced ? Icons.cloud_done : Icons.cloud_off;

    return Icon(
      icon,
      size: size,
      color: color,
    );
  }
}
