import 'package:core/core.dart';
import '../../domain/entities/outlet.entity.dart';

class OutletCard extends StatelessWidget {
  final OutletEntity outlet;
  final VoidCallback? onTap;

  const OutletCard({super.key, required this.outlet, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(outlet.name ?? '-'),
      subtitle: Text(outlet.address ?? '-'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SyncStatus(idServer: outlet.idServer, syncedAt: outlet.syncedAt),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }
}
