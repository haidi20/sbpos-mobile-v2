import 'package:core/core.dart'; // Asumsi: berisi impor standar Flutter (seperti material.dart)
import 'package:customer/domain/entities/customer.entity.dart';

// Definisikan tipe untuk callback aksi ketika kartu diklik
typedef CustomerTapCallback = void Function(CustomerEntity customer);
typedef CustomerLongPressCallback = void Function(CustomerEntity customer);

class CustomerListTileCard extends StatelessWidget {
  final CustomerEntity customer;
  // Tambahkan callback untuk menangani aksi tap
  final CustomerTapCallback? onTapCallback;
  // Callback untuk tekan lama
  final CustomerLongPressCallback? onLongPressCallback;

  const CustomerListTileCard({
    super.key,
    required this.customer, // Membuat customer wajib (lebih aman)
    this.onTapCallback,
    this.onLongPressCallback,
  });

  @override
  Widget build(BuildContext context) {
    // Pastikan properti customer tidak null sebelum diakses
    final customerData = customer;

    return ListTile(
      // Content padding sudah cukup baik
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),

      // --- Leading Widget: CircleAvatar ---
      leading: CircleAvatar(
        backgroundColor: Colors.blueAccent,
        child: Text(
          customer.getFirstName, // Panggil helper method
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // --- Title: Nama Customer ---
      // Gunakan operator null-aware (??) untuk menangani nama null
      title: Text(customerData.name ?? 'Nama Tidak Ada'),

      // --- Subtitle: Telepon Customer ---
      subtitle: Text(customerData.phone ?? 'Nomor Tidak Ada'),

      // --- Trailing Widget ---
      trailing: const Icon(Icons.chevron_right),

      // --- Aksi OnTap ---
      onTap: onTapCallback == null
          ? null // Jika callback null, onTap dinonaktifkan
          : () {
              // Panggil callback, serahkan penanganan aksi ke parent widget
              onTapCallback!(customerData);
            },
      // --- Aksi OnLongPress ---
      onLongPress: onLongPressCallback == null
          ? null
          : () {
              onLongPressCallback!(customerData);
            },
    );
  }
}
