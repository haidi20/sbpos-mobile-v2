import 'package:core/core.dart';
import 'package:expense/presentation/providers/expense.providers.dart';
import 'package:expense/presentation/widgets/expense_form.widget.dart';
import 'package:expense/presentation/widgets/expense_list_tile.dart';

class ExpenseScreen extends HookConsumerWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expenseViewModelProvider);
    final vm = ref.read(expenseViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Kelola Pengeluaran',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: Colors.black87)),
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 0.5,
        actions: [
          IconButton(
            onPressed: () => vm.getExpenses(),
            icon: const Icon(Icons.refresh, color: AppColors.sbBlue),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.expenses.isEmpty
              ? _buildEmptyState(context, vm)
              : _buildExpenseList(state.expenses, vm),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          vm.resetDraft();
          _showAddExpenseForm(context);
        },
        backgroundColor: AppColors.sbBlue,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Pengeluaran',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, dynamic vm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10))
              ],
            ),
            child: Icon(Icons.receipt_long_rounded,
                size: 64, color: AppColors.sbBlue.withOpacity(0.2)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum ada catatan pengeluaran.',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54),
          ),
          const SizedBox(height: 8),
          const Text(
            'Catat pengeluaran harian outlet untuk\nrekonsiliasi saldo yang akurat.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              vm.resetDraft();
              _showAddExpenseForm(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sbBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              elevation: 4,
              shadowColor: AppColors.sbBlue.withOpacity(0.4),
            ),
            child: const Text('Catat Sekarang',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseList(List<dynamic> items, dynamic vm) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final expense = items[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: ExpenseListTile(expense: expense),
        );
      },
    );
  }

  void _showAddExpenseForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ExpenseFormWidget(),
    );
  }
}
