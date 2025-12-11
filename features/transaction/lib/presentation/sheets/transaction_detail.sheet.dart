import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/presentation/widgets/dashed_line_painter.dart';
import 'package:transaction/presentation/components/transaction_detail.card.dart';
// Asumsi DashedLinePainter dan TransactionEntity/Status sudah benar di-import
// --- END DUMMY IMPLEMENTASI ---

// --- WIDGET UTAMA (BOTTOM SHEET) ---
class TransactionDetailSheet extends StatelessWidget {
  final TransactionEntity tx;

  const TransactionDetailSheet({super.key, required this.tx});

  // Metode untuk menampilkan sheet
  static void show(BuildContext context, TransactionEntity tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // backgroundColor:
      //     Colors.transparent, // Transparan agar rounded corner terlihat
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: const BoxDecoration(
            color: Colors.white, // Dominan Putih
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                blurRadius: 10.0,
                spreadRadius: 1.0,
                color: Colors.black12,
              ),
            ],
          ),
          child: TransactionDetailSheet(tx: tx),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: AppColors.sbBg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sheet Header (Sticky)
            _buildStickyHeader(context),

            // Konten Utama Sheet
            Flexible(
              child: SingleChildScrollView(
                // Padding bawah ditambahkan di sini
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoGrid(),
                    const SizedBox(height: 24),

                    _buildItemDetails(),
                    const SizedBox(height: 24),

                    _buildPaymentSummary(),
                    const SizedBox(height: 24),

                    if (tx.notes != null && tx.notes!.isNotEmpty) ...[
                      _buildNotesBox(),
                      const SizedBox(height: 24),
                    ],

                    // Cetak Struk Button (Full Width)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Logic Cetak Struk
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          // Menggunakan AppColors.sbBlue untuk aksen CTA
                          backgroundColor: AppColors.sbBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        child: const Text('Cetak Struk'),
                      ),
                    ),
                    const SizedBox(height: 10), // Padding ekstra di bawah
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET PEMBANGUN ---

  Widget _buildStickyHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white, // Dominan Putih
        border: Border(
          bottom: BorderSide(
            color: AppColors.gray200,
            width: 1.0,
          ),
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle (handle)
          Center(
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.circular(3),
              ),
              margin: const EdgeInsets.only(bottom: 16),
            ),
          ), // Letakkan di tengah (seperti mx-auto)

          // Title and Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Detail Transaksi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray800,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color:
                        AppColors.gray100, // Background tombol putih/abu muda
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: AppColors.gray500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Total Pembayaran Box (Header Utama)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              // Menggunakan Putih / Abu Muda untuk dominasi
              color: AppColors.sbBg, // Sesuai bg-sb-bg di React
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  const Text(
                    'Total Pembayaran',
                    style: TextStyle(
                      color: AppColors.gray500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${formatRupiah(tx.totalAmount.toDouble())}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.sbBlue, // Aksen Biru
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        // Mengganti Lucide Icons dengan Icons bawaan Flutter
        _buildGridItem(
          Icons.receipt,
          'No. Order',
          '#${tx.sequenceNumber}',
        ),
        _buildGridItem(
          Icons.access_time,
          'Tanggal',
          tx.date.dateTimeReadable(),
        ),
        _buildGridItem(
          Icons.person,
          'Kasir (ID)',
          'User #${tx.userId}',
        ),
        _buildGridItem(
          Icons.location_on,
          'Warehouse',
          'WH-${tx.outletId}',
        ),
        _buildGridItem(
          null,
          'Tipe Order',
          tx.categoryOrder ?? '-',
        ),
        _buildGridItem(
          null,
          'Metode Bayar',
          (tx.paymentMethod ?? '-').toUpperCase(),
        ),
      ],
    );
  }

  Widget _buildGridItem(IconData? icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Icon(icon, size: 12, color: AppColors.gray400),
              ),
            Text(
              label,
              style: const TextStyle(color: AppColors.gray400, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            // Warna teks dominan (bukan abu-abu terang)
            color: AppColors.gray700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildItemDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rincian Item',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.gray800,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        // Item List
        ...(tx.details ?? []).map(
          (item) => TransactionDetailCard(
            item: item,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      // Dominan Putih: Menggunakan warna abu-abu sangat muda
      decoration: BoxDecoration(
        color:
            AppColors.gray100, // bg-gray-50 di Tailwind setara dengan abu muda
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Subtotal
          _buildSummaryRow(
              'Subtotal', tx.totalAmount, AppColors.gray700, false),
          const SizedBox(height: 8),

          // Divider Dashed
          const CustomPaint(
            painter: DashedLinePainter(color: AppColors.gray200),
            size: Size(double.infinity, 1),
          ),
          const SizedBox(height: 8),

          // Paid Amount
          _buildSummaryRow('Bayar (${tx.paymentMethod ?? '-'})', tx.paidAmount,
              AppColors.gray700, false),
          const SizedBox(height: 8),

          // Change Money (Kembalian) - Aksen Biru
          _buildSummaryRow('Kembalian', tx.changeMoney, AppColors.sbBlue, true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, num? amount, Color color, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          formatRupiah((amount ?? 0).toDouble()),
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesBox() {
    // Menggunakan aksen AppColors.sbOrange untuk Notifikasi
    return Container(
      // bg-yellow-50 border border-yellow-100 rounded-xl p-3
      decoration: BoxDecoration(
        color:
            AppColors.sbOrange.withOpacity(0.05), // Latar belakang sangat muda
        border:
            Border.all(color: AppColors.sbOrange.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catatan:',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.sbOrange, // Aksen Orange
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tx.notes!,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.sbOrange.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
