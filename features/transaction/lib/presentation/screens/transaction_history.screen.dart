import 'package:core/core.dart';
import 'package:transaction/data/dummy/transaction.dummy.dart';
import 'package:transaction/data/models/transaction.model.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/presentation/components/transaction.card.dart';
import 'package:transaction/domain/entitties/transaction_detail.entity.dart';
import 'package:transaction/presentation/screens/transaction_history_detail.screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _searchQuery = "";

  void _showTransactionDetail(BuildContext context, TransactionModel tx) {
    // Convert model to domain entity and extract details if available
    final entity = TransactionEntity.fromModel(tx);
    final rawItems = (tx as dynamic).items as List<dynamic>?;
    final details = (rawItems ?? []).map((it) {
      final dyn = it as dynamic;
      final int? productPrice = dyn.productPrice is double
          ? (dyn.productPrice as double).toInt()
          : dyn.productPrice as int?;
      final int? subtotal = dyn.subtotal is double
          ? (dyn.subtotal as double).toInt()
          : dyn.subtotal as int?;
      return TransactionDetailEntity(
        id: dyn.id,
        transactionId: dyn.transactionId,
        productId: dyn.productId,
        productName: dyn.productName,
        productPrice: productPrice,
        qty: dyn.qty,
        subtotal: subtotal,
        note: dyn.note,
      );
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionHistoryDetailScreen(
        tx: entity,
        details: details,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter logic
    final filteredTransactions = transactionList.where((tx) {
      final query = _searchQuery.toLowerCase();
      final seq = tx.sequenceNumber?.toString() ?? '';
      final notes = tx.notes?.toLowerCase() ?? '';
      return seq.contains(query) || notes.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.sbBg,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER & SEARCH ---
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              color: AppColors.sbBg,
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
                          icon: const Icon(
                            Icons.filter_list,
                            color: AppColors.sbBlue,
                          ),
                          onPressed: () {
                            //
                          },
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
                            color: AppColors.sbBlue.withOpacity(0.2), width: 2),
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
                  return TransactionCard(
                    tx: tx,
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
