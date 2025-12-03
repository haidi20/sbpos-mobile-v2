import 'package:flutter/material.dart';
import '../components/notification_tab.dart';
import '../components/notification_item.dart';
import 'package:notification/data/data/notification_data.dart';
import 'package:notification/data/models/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String activeTab = 'all';

  // Use the typed model list
  List<NotificationModel> notifications = [];

  @override
  void initState() {
    super.initState();
    // Inisialisasi data (pakai mock list yang sudah berisi NotificationModel)
    notifications = List.from(notificationList);
  }

  void handleMarkAllRead() {
    setState(() {
      for (var i = 0; i < notifications.length; i++) {
        notifications[i] = notifications[i].copyWith(read: true);
      }
    });
  }

  void markAsRead(int id) {
    setState(() {
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(read: true);
      }
    });
  }

  List<NotificationModel> get filteredNotifications {
    if (activeTab == 'all') return notifications;
    return notifications.where((n) => n.read == false).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Logic filter manual karena Dart List dynamic butuh cast
    final displayList = activeTab == 'all'
        ? notifications
        : notifications.where((n) => n.read == false).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50], // bg-sb-bg equivalent
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              color: Colors.grey[50],
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        "Notifikasi",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937), // gray-800
                        ),
                      ),
                      TextButton.icon(
                        onPressed: handleMarkAllRead,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue, // text-sb-blue
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text(
                          "Tandai dibaca semua",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tabs Component
                  NotificationTabs(
                    activeTab: activeTab,
                    onTabChanged: (val) => setState(() => activeTab = val),
                  ),
                ],
              ),
            ),

            // List Section
            Expanded(
              child: displayList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off_outlined,
                              size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            "Tidak ada notifikasi",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        final notif = displayList[index];
                        return NotificationItem(
                          notification: notif,
                          onTap: () => markAsRead(notif.id ?? 0),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
