import 'package:flutter/material.dart';
import '../../domain/entities/outlet_entity.dart';

class OutletCard extends StatelessWidget {
  final OutletEntity outlet;
  final VoidCallback? onTap;

  const OutletCard({super.key, required this.outlet, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(outlet.name ?? '-'),
      subtitle: Text(outlet.address ?? '-'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
