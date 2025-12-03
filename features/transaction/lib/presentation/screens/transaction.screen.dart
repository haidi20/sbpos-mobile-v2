import 'package:core/core.dart';
import 'package:transaction/domain/entitties/transaction.entity.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/components/transaction.card.dart';
import 'package:transaction/presentation/sheets/transaction_detail.sheet.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  String _searchQuery = "";

  // Warna Brand
  final Color sbBg = AppColors.sbBg;
  final Color sbBlue = AppColors.sbBlue;
  final Color sbOrange = AppColors.sbOrange;

  void _showTransactionDetail(BuildContext context, TransactionEntity tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar bisa full height / custom height
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailSheet(tx: tx),
    );
  }

  @override
  void initState() {
    super.initState();
    // call refresh once after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = ref.read(transactionViewModelProvider.notifier);
      vm.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vmState = ref.watch(transactionViewModelProvider);

    // merge search with vm state
    final filtered = vmState.transactions.where((tx) {
      final query = _searchQuery.toLowerCase();
      final notes = tx.notes?.toLowerCase() ?? '';
      return tx.sequenceNumber.toString().contains(query) ||
          notes.contains(query);
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
              child: vmState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final tx = filtered[index];
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // when this route becomes current (e.g., after navigating back), schedule refresh
    // delay the actual provider modification until after build/frame completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      if (route != null && route.isCurrent) {
        final vm = ref.read(transactionViewModelProvider.notifier);
        vm.refresh();
      }
    });
  }
}
