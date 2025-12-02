import 'package:core/core.dart';
import 'package:transaction/data/data/transaction_data.dart';
import 'package:transaction/data/models/transaction_model.dart';
import 'package:transaction/presentation/components/transaction_card.dart';
import 'package:transaction/presentation/screens/backup/transaction_detail_screen_021225.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String _searchQuery = "";

  void _showTransactionDetail(BuildContext context, TransactionModel tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailScreen(tx: tx),
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
