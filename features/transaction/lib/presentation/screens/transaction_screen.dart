import 'package:core/core.dart';
// --- 1. MODELS ---

class TransactionItem {
  final int id;
  final int transactionId;
  final int productId;
  final String productName;
  final double productPrice;
  final int qty;
  final double subtotal;

  TransactionItem({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.qty,
    required this.subtotal,
  });
}

class Transaction {
  final int id;
  final int shiftId;
  final int warehouseId;
  final int sequenceNumber;
  final int orderTypeId;
  final String categoryOrder;
  final int userId;
  final String paymentMethod;
  final String date;
  final String notes;
  final double totalAmount;
  final int totalQty;
  final double paidAmount;
  final double changeMoney;
  final String status;
  final List<TransactionItem> items;

  Transaction({
    required this.id,
    required this.shiftId,
    required this.warehouseId,
    required this.sequenceNumber,
    required this.orderTypeId,
    required this.categoryOrder,
    required this.userId,
    required this.paymentMethod,
    required this.date,
    required this.notes,
    required this.totalAmount,
    required this.totalQty,
    required this.paidAmount,
    required this.changeMoney,
    required this.status,
    required this.items,
  });
}

// --- 2. MOCK DATA ---

final List<Transaction> mockTransactions = [
  Transaction(
    id: 1,
    shiftId: 101,
    warehouseId: 1,
    sequenceNumber: 202310240001,
    orderTypeId: 1,
    categoryOrder: 'Dine In',
    userId: 5,
    paymentMethod: 'QRIS',
    date: '2023-10-24',
    notes: 'Meja 5, Jangan pedas',
    totalAmount: 58000,
    totalQty: 3,
    paidAmount: 58000,
    changeMoney: 0,
    status: 'completed',
    items: [
      TransactionItem(
          id: 1,
          transactionId: 1,
          productId: 1,
          productName: 'Kopi Susu Gula Aren',
          productPrice: 18000,
          qty: 2,
          subtotal: 36000),
      TransactionItem(
          id: 2,
          transactionId: 1,
          productId: 6,
          productName: 'Croissant Butter',
          productPrice: 22000,
          qty: 1,
          subtotal: 22000),
    ],
  ),
  Transaction(
    id: 2,
    shiftId: 101,
    warehouseId: 1,
    sequenceNumber: 202310240002,
    orderTypeId: 2,
    categoryOrder: 'Take Away',
    userId: 5,
    paymentMethod: 'CASH',
    date: '2023-10-24',
    notes: '-',
    totalAmount: 35000,
    totalQty: 1,
    paidAmount: 50000,
    changeMoney: 15000,
    status: 'completed',
    items: [
      TransactionItem(
          id: 3,
          transactionId: 2,
          productId: 3,
          productName: 'Nasi Goreng Spesial',
          productPrice: 35000,
          qty: 1,
          subtotal: 35000),
    ],
  ),
  Transaction(
    id: 3,
    shiftId: 102,
    warehouseId: 2,
    sequenceNumber: 202310230998,
    orderTypeId: 1,
    categoryOrder: 'Delivery',
    userId: 3,
    paymentMethod: 'CASH',
    date: '2023-10-23',
    notes: 'Titip di satpam',
    totalAmount: 120000,
    totalQty: 4,
    paidAmount: 120000,
    changeMoney: 0,
    status: 'completed',
    items: [
      TransactionItem(
          id: 4,
          transactionId: 3,
          productId: 4,
          productName: 'Mie Goreng Jawa',
          productPrice: 32000,
          qty: 2,
          subtotal: 64000),
      TransactionItem(
          id: 5,
          transactionId: 3,
          productId: 5,
          productName: 'Es Teh Manis',
          productPrice: 8000,
          qty: 2,
          subtotal: 16000),
      TransactionItem(
          id: 6,
          transactionId: 3,
          productId: 2,
          productName: 'Cappuccino Panas',
          productPrice: 20000,
          qty: 2,
          subtotal: 40000),
    ],
  ),
];

// --- 3. HELPER ---
String formatRupiah(double amount) {
  final formatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  return formatter.format(amount);
}

// --- 4. MAIN SCREEN ---

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String _searchQuery = "";

  // Warna Brand
  final Color sbBlue = const Color(0xFF1E40AF);
  final Color sbOrange = const Color(0xFFF97316);
  final Color sbBg = const Color(0xFFF8FAFC);

  void _showTransactionDetail(BuildContext context, Transaction tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar bisa full height / custom height
      backgroundColor: Colors.transparent,
      builder: (context) => _TransactionDetailSheet(
          tx: tx, sbBlue: sbBlue, sbOrange: sbOrange, sbBg: sbBg),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter logic
    final filteredTransactions = mockTransactions.where((tx) {
      final query = _searchQuery.toLowerCase();
      return tx.sequenceNumber.toString().contains(query) ||
          tx.notes.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: sbBg,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER & SEARCH ---
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              color: sbBg,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      // IconButton(
                      //   icon: Icon(Icons.arrow_back, color: sbBlue),
                      //   onPressed: () {
                      //     // Di dalam onPressed
                      //     context.go(AppRoutes.dashboard);
                      //   },
                      // ),
                      const Expanded(
                        child: Text(
                          'Riwayat Transaksi',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.filter_list, color: sbBlue),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Cari No. Order atau Catatan...',
                      hintStyle:
                          TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon:
                          Icon(Icons.search, color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: sbBlue.withOpacity(0.2), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),

            // --- LIST ---
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: filteredTransactions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final tx = filteredTransactions[index];
                  return _TransactionCard(
                    tx: tx,
                    sbBlue: sbBlue,
                    sbOrange: sbOrange,
                    onTap: () => _showTransactionDetail(context, tx),
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

// --- 5. COMPONENTS ---

class _TransactionCard extends StatelessWidget {
  final Transaction tx;
  final Color sbBlue;
  final Color sbOrange;
  final VoidCallback onTap;

  const _TransactionCard({
    required this.tx,
    required this.sbBlue,
    required this.sbOrange,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isQris = tx.paymentMethod == 'QRIS';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Payment
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isQris ? Colors.blue.shade50 : Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isQris ? Icons.receipt_long : Icons.credit_card,
                    color: isQris ? sbBlue : Colors.green.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Order Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${tx.sequenceNumber}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            tx.date,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: CircleAvatar(
                                radius: 2,
                                backgroundColor: Colors.grey.shade300),
                          ),
                          Text(
                            tx.categoryOrder,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Amount & Status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatRupiah(tx.totalAmount),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: sbBlue),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Success',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Dashed Line Separator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: CustomPaint(
                painter: _DashedLinePainter(color: Colors.grey.shade200),
                size: const Size(double.infinity, 1),
              ),
            ),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.description_outlined,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      '${tx.totalQty} Item',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Lihat Detail',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: sbOrange),
                    ),
                    Icon(Icons.chevron_right, size: 16, color: sbOrange),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- 6. DETAIL BOTTOM SHEET ---

class _TransactionDetailSheet extends StatelessWidget {
  final Transaction tx;
  final Color sbBlue;
  final Color sbOrange;
  final Color sbBg;

  const _TransactionDetailSheet({
    required this.tx,
    required this.sbBlue,
    required this.sbOrange,
    required this.sbBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      child: Column(
        children: [
          // Handle & Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Column(
              children: [
                Container(
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(3))),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Detail Transaksi',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle),
                        child: Icon(Icons.close,
                            size: 20, color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: sbBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text('Total Pembayaran',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500)),
                      const SizedBox(height: 4),
                      Text(formatRupiah(tx.totalAmount),
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: sbBlue)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _DetailInfo(
                          icon: Icons.receipt,
                          label: 'No. Order',
                          value: '#${tx.sequenceNumber}'),
                      _DetailInfo(
                          icon: Icons.access_time,
                          label: 'Tanggal',
                          value: tx.date),
                      _DetailInfo(
                          icon: Icons.person_outline,
                          label: 'Kasir (ID)',
                          value: 'User #${tx.userId}'),
                      _DetailInfo(
                          icon: Icons.store_outlined,
                          label: 'Warehouse',
                          value: 'WH-${tx.warehouseId}'),
                      _DetailInfo(
                          icon: Icons.category_outlined,
                          label: 'Tipe Order',
                          value: tx.categoryOrder),
                      _DetailInfo(
                          icon: Icons.payments_outlined,
                          label: 'Metode Bayar',
                          value: tx.paymentMethod),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text('Rincian Item',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),

                  // Items List
                  ...tx.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.productName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Text(
                                      '${item.qty} x ${formatRupiah(item.productPrice)}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500)),
                                ],
                              ),
                            ),
                            Text(formatRupiah(item.subtotal),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 14)),
                          ],
                        ),
                      )),

                  const SizedBox(height: 24),

                  // Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _SummaryRow(
                            label: 'Subtotal',
                            value: formatRupiah(tx.totalAmount)),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: CustomPaint(
                              painter: _DashedLinePainter(
                                  color: Colors.grey.shade300),
                              size: const Size(double.infinity, 1)),
                        ),
                        _SummaryRow(
                            label: 'Bayar (${tx.paymentMethod})',
                            value: formatRupiah(tx.paidAmount)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Kembalian',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                            Text(formatRupiah(tx.changeMoney),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: sbBlue)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Notes
                  if (tx.notes.isNotEmpty && tx.notes != '-') ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        border: Border.all(color: Colors.orange.shade100),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Catatan:',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800)),
                          const SizedBox(height: 4),
                          Text(tx.notes,
                              style: TextStyle(
                                  fontSize: 13, color: Colors.orange.shade900)),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  // Print Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: sbBlue),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.white,
                      ),
                      child: Text('Cetak Struk',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: sbBlue)),
                    ),
                  ),
                  const SizedBox(height: 20), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailInfo(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.grey.shade400),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black87),
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        Text(value,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      ],
    );
  }
}

// Custom Painter for Dotted Line
class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    var max = size.width;
    var dashWidth = 5.0;
    var dashSpace = 3.0;
    double startX = 0;

    while (startX < max) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
