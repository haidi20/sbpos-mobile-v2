import 'package:core/core.dart';
import 'package:customer/domain/entities/customer.entity.dart';
import 'package:customer/presentation/view_models/customer.vm.dart';
import 'package:customer/presentation/controllers/customer_list.controller.dart';

/// Reusable bottom sheet for customer actions: edit and delete
Future<void> showCustomerActionSheet(
  BuildContext context,
  CustomerViewModel vm,
  CustomerEntity customer,
) async {
  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                customer.name ?? 'Pelanggan',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.sbLightBlue),
                title: const Text('Ubah'),
                onTap: () => vm.onEditCustomer(ctx, customer),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Hapus'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  CustomerListController.confirmAndDelete(
                    vm: vm,
                    context: context,
                    customer: customer,
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
