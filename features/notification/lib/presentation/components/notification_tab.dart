import 'package:flutter/material.dart';

class NotificationTabs extends StatelessWidget {
  final String activeTab;
  final Function(String) onTabChanged;

  const NotificationTabs(
      {super.key, required this.activeTab, required this.onTabChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _buildTab('all', 'Semua'),
          _buildTab('unread', 'Belum Dibaca'),
        ],
      ),
    );
  }

  Widget _buildTab(String key, String label) {
    final bool isActive = activeTab == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }
}
