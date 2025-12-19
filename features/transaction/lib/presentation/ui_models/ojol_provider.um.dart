import 'package:flutter/material.dart';

class OjolProviderUiModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const OjolProviderUiModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

// List of available Ojol providers
final List<OjolProviderUiModel> ojolProviderList = [
  OjolProviderUiModel(
    id: 'go',
    name: 'Go Food',
    icon: Icons.delivery_dining,
    color: Colors.red.shade600,
  ),
  OjolProviderUiModel(
    id: 'grab',
    name: 'Grab Food',
    icon: Icons.pedal_bike,
    color: Colors.green.shade600,
  ),
  OjolProviderUiModel(
    id: 'shopee',
    name: 'Shopee Food',
    icon: Icons.shopping_bag,
    color: Colors.orange.shade700,
  ),
];
