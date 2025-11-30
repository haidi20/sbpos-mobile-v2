import 'package:notification/data/models/notification_model.dart';

const List<NotificationModel> notificationList = [
  NotificationModel(
    id: 1,
    type: 'alert',
    title: 'Stok Menipis',
    message:
        'Stok Biji Kopi Arabica tersisa kurang dari 1kg. Segera lakukan restock.',
    time: '5 menit yang lalu',
    read: false,
  ),
  NotificationModel(
    id: 2,
    type: 'transaction',
    title: 'Pembayaran Diterima',
    message: 'Transaksi #202310240005 sebesar Rp 150.000 via QRIS berhasil.',
    time: '15 menit yang lalu',
    read: false,
  ),
  NotificationModel(
    id: 3,
    type: 'system',
    title: 'Update Aplikasi',
    message:
        'Versi baru SB POS v1.3.0 tersedia. Perbaikan bug printer bluetooth.',
    time: '2 jam yang lalu',
    read: true,
  ),
  NotificationModel(
    id: 4,
    type: 'promo',
    title: 'Promo Akhir Pekan',
    message: 'Diskon 20% untuk semua menu kopi berlaku mulai besok.',
    time: '1 hari yang lalu',
    read: true,
  ),
  NotificationModel(
    id: 5,
    type: 'transaction',
    title: 'Transaksi Dibatalkan',
    message: 'Transaksi #202310240001 dibatalkan oleh Kasir (Budi).',
    time: '1 hari yang lalu',
    read: true,
  ),
];
