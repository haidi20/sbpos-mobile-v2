import 'package:core/core.dart';
import 'package:expense/domain/entities/expense.entity.dart';
import 'package:expense/domain/entities/expense_constants.dart';
import 'package:expense/presentation/providers/expense.providers.dart';

class ExpenseFormWidget extends HookConsumerWidget {
  const ExpenseFormWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(expenseViewModelProvider);
    final vm = ref.read(expenseViewModelProvider.notifier);
    final qtyController = useTextEditingController(
        text: state.draftExpense?.qty?.toString() ?? '1');
    final amountController = useTextEditingController(
        text: state.draftExpense?.totalAmount?.toString() ?? '');
    final notesController =
        useTextEditingController(text: state.draftExpense?.notes ?? '');

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tambah Pengeluaran',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kategori Pengeluaran',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.grey)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: state.draftExpense?.categoryName,
                  items: ExpenseConstants.categories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ))
                      .toList(),
                  onChanged: (v) => vm.setDraftExpense(
                    (state.draftExpense ?? const ExpenseEntity())
                        .copyWith(categoryName: v),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Pilih Kategori',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildTextField(
                    controller: qtyController,
                    label: 'Qty',
                    hint: '1',
                    keyboardType: TextInputType.number,
                    onChanged: (v) => vm.setDraftExpense(
                      (state.draftExpense ?? const ExpenseEntity()).copyWith(qty: int.tryParse(v)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: amountController,
                    label: 'Total Harga',
                    hint: '0',
                    prefixText: 'Rp ',
                    keyboardType: TextInputType.number,
                    onChanged: (v) => vm.setDraftExpense(
                      (state.draftExpense ?? const ExpenseEntity()).copyWith(totalAmount: int.tryParse(v)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: notesController,
              label: 'Catatan (Opsional)',
              hint: 'Keterangan tambahan...',
              maxLines: 3,
              onChanged: (v) => vm.setDraftExpense(
                (state.draftExpense ?? const ExpenseEntity()).copyWith(notes: v),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (state.isSubmitting || !vm.isValid)
                    ? null
                    : () async {
                        final success = await vm.onCreateExpense();
                        if (success && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Pengeluaran berhasil dicatat')),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sbBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: state.isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Pengeluaran', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? prefixText,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}
