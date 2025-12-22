import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:product/domain/entities/product.entity.dart';

// File ini berisi fungsi-fungsi kalkulasi murni (pure) yang dipisahkan
// dari ViewModel agar mudah dibaca, diuji, dan direuse oleh bagian lain.

// Mengembalikan indeks produk pertama yang cocok dengan kategori `name`
// pada daftar produk yang sudah difilter. `products` diasumsikan sudah
// berisi daftar yang relevan (sudah difilter) sebelum dipanggil.
int calcIndexOfFirstProductForCategory(
    List<ProductEntity> products, String name) {
  return products.indexWhere((p) => (p.category?.name ?? 'Semua') == name);
}

/// Hitung target scroll vertikal (dalam piksel) untuk sebuah indeks produk.
/// Penjelasan parameter:
/// - `index`: indeks produk dalam daftar gabungan/tersaring.
/// - `screenWidth`: lebar layar yang dipakai untuk menghitung lebar item.
/// - `columns`: jumlah kolom grid (default 2).
/// - `horizontalPadding`: total padding horizontal (default 32.0 => 16+16).
/// - `spacing`: jarak antar item (default 12.0).
/// - `childAspectRatio`: aspect ratio anak (width/height) pada grid.
/// Fungsi mengembalikan jarak vertical yang perlu discroll agar baris yang
/// memuat indeks tersebut berada di puncak area scroll.
double calcComputeScrollTargetForIndex(
  int index,
  double screenWidth, {
  int columns = 2,
  double horizontalPadding = 32.0,
  double spacing = 12.0,
  double childAspectRatio = 0.75,
}) {
  if (index < 0) return 0.0;
  final pItemWidth = (screenWidth - horizontalPadding - spacing) / columns;
  final childHeight = pItemWidth / childAspectRatio;
  final rowHeight = childHeight + spacing;
  final row = (index / columns).floor();
  return row * rowHeight;
}

// --- Kalkulasi terkait keranjang (cart) ---

// Hitung total keranjang. Jika `TransactionDetailEntity.subtotal` tersedia
// gunakan nilai tersebut; jika tidak, gunakan `productPrice * qty`.
int calculateCartTotal(List<TransactionDetailEntity> details) {
  return details.fold<int>(0, (sum, item) {
    if (item.subtotal != null) return sum + (item.subtotal ?? 0);
    final price = item.productPrice ?? 0;
    final qty = item.qty ?? 0;
    return sum + (price * qty);
  });
}

// Hitung jumlah total item (kuantitas) di keranjang.
int calculateCartCount(List<TransactionDetailEntity> details) =>
    details.fold(0, (sum, item) => sum + (item.qty ?? 0));

// Hitung total nilai keranjang sebagai integer (menggunakan subtotal jika ada).
int calculateCartTotalValue(List<TransactionDetailEntity> details) {
  return details.fold<int>(0, (s, d) {
    final price = d.productPrice ?? 0;
    final qty = d.qty ?? 1;
    final subtotal = d.subtotal ?? (price * qty);
    return s + subtotal;
  });
}

// Hitung nilai pajak berdasarkan rate (default 10%). Mengembalikan int.
int calculateTaxValue(List<TransactionDetailEntity> details,
    {double rate = 0.1}) {
  final cartTotal = calculateCartTotalValue(details);
  return (cartTotal * rate).round();
}

// Hitung grand total = cart total + pajak.
int calculateGrandTotalValue(List<TransactionDetailEntity> details) {
  final cart = calculateCartTotalValue(details);
  final tax = calculateTaxValue(details);
  return cart + tax;
}

// Hitung kembalian dari uang yang diterima dikurangi grand total.
int calculateChangeValue(
    int cashReceived, List<TransactionDetailEntity> details) {
  final grand = calculateGrandTotalValue(details);
  return cashReceived - grand;
}
