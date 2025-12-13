import 'package:flutter/material.dart';

const Map<String, IconData> _orderTypeIconMap = {
  'restaurant': Icons.restaurant,
  'shopping_bag': Icons.shopping_bag,
  'directions_bike': Icons.directions_bike,
};

IconData resolveOrderTypeIcon(String? key) =>
    _orderTypeIconMap[key] ?? Icons.help_outline;
