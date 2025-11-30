import 'package:flutter/material.dart';
import '../components/notification_item.dart';
import '../components/notification_tab.dart';
// import 'package:app_anda/models/notification_model.dart';

// MOCK DATA GENERATOR (Hapus ini jika Anda fetch dari API/Database)
// Pastikan struktur ini sesuai dengan Model Anda yang sudah ada
List<Map<String, dynamic>> notificationList = [
  {
    'id': 1,
    'type': 'alert',
    'title': 'Stok Menipis',
    'message':
        'Stok Biji Kopi Arabica tersisa kurang dari 1kg. Segera lakukan restock.',
    'time': '5 menit yang lalu',
    'read': false,
  },
  {
    'id': 2,
    'type': 'transaction',
    'title': 'Pembayaran Diterima',
    'message': 'Transaksi #202310240005 sebesar Rp 150.000 via QRIS berhasil.',
    'time': '15 menit yang lalu',
    'read': false,
  },
  {
    'id': 3,
    'type': 'system',
    'title': 'Update Aplikasi',
    'message':
        'Versi baru SB POS v1.3.0 tersedia. Perbaikan bug printer bluetooth.',
    'time': '2 jam yang lalu',
    'read': true,
  },
  {
    'id': 4,
    'type': 'promo',
    'title': 'Promo Akhir Pekan',
    'message': 'Diskon 20% untuk semua menu kopi berlaku mulai besok.',
    'time': '1 hari yang lalu',
    'read': true,
  },
  {
    'id': 5,
    'type': 'transaction',
    'title': 'Transaksi Dibatalkan',
    'message': 'Transaksi #202310240001 dibatalkan oleh Kasir (Budi).',
    'time': '1 hari yang lalu',
    'read': true,
  },
];

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String activeTab = 'all';

  // Ubah tipe List<dynamic> ini menjadi List<NotificationModel> sesuai model Anda
  List<dynamic> notifications = [];

  @override
  void initState() {
    super.initState();
    // Inisialisasi data (disini pakai mock, nanti ganti dengan fetch data)
    // Jika model Anda adalah class, lakukan mapping di sini:
    // notifications = notificationList.map((e) => NotificationModel.fromJson(e)).toList();
    notifications = List.from(notificationList);
  }

  void handleMarkAllRead() {
    setState(() {
      for (var n in notifications) {
        // Asumsi model Anda mutable, jika immutable gunakan copyWith
        // n.read = true;

        // Pendekatan Map (karena pakai Mock Map):
        n['read'] = true;
      }
    });
  }

  void markAsRead(int id) {
    setState(() {
      final index = notifications
          .indexWhere((n) => n['id'] == id); // ganti ['id'] dgn .id
      if (index != -1) {
        notifications[index]['read'] = true; // ganti ['read'] dgn .read = true
      }
    });
  }

  List<dynamic> get filteredNotifications {
    if (activeTab == 'all') return notifications;
    return notifications
        .where((n) => n['read'] == false)
        .toList(); // ganti ['read'] dgn .read
  }

  @override
  Widget build(BuildContext context) {
    // Logic filter manual karena Dart List dynamic butuh cast
    final displayList = activeTab == 'all'
        ? notifications
        : notifications.where((n) => n['read'] == false).toList();

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
                          onTap: () =>
                              markAsRead(notif['id']), // ganti ['id'] dgn .id
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
