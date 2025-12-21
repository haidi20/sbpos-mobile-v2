import 'package:core/core.dart';
import 'package:transaction/presentation/ui_models/order_type_item.um.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/view_models/transaction_pos.vm.dart';
import 'package:flutter/services.dart';
import 'package:transaction/presentation/ui_models/payment_method.um.dart';

class OrderTypeSelector extends StatelessWidget {
  final void Function(String) onChanged;
  final List<OrderTypeItemUiModel> orderTypes;

  const OrderTypeSelector({
    super.key,
    required this.onChanged,
    required this.orderTypes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: orderTypes.map((t) {
            final id = t.id;
            final label = t.label;
            final icon = t.icon;
            final selected = t.selected;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selected ? Colors.blue.shade50 : Colors.white,
                    foregroundColor: selected ? Colors.blue : Colors.grey[800],
                    elevation: selected ? 2 : 0,
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: selected ? Colors.blue : Colors.grey.shade200,
                      ),
                    ),
                  ),
                  onPressed: () => onChanged(id),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 22),
                      const SizedBox(height: 6),
                      Flexible(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class OjolProviderSelector extends StatelessWidget {
  final String value;
  final void Function(String) onChanged;
  final TransactionPosViewModel vm;
  const OjolProviderSelector({
    super.key,
    required this.value,
    required this.onChanged,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final providers = vm.ojolProviders;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Pilih Jenis Ojol',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: providers.map(
              (p) {
                final sel = p.name == value;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: sel ? p.color : Colors.white,
                        foregroundColor: sel ? Colors.white : Colors.grey[800],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => onChanged(p.name),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(p.icon,
                              size: 18, color: sel ? Colors.white : p.color),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              p.name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodSelector extends StatelessWidget {
  final EPaymentMethod value;
  final void Function(EPaymentMethod) onChanged;
  final List<PaymentMethodUiModel> methods;
  const PaymentMethodSelector({
    super.key,
    required this.value,
    required this.onChanged,
    required this.methods,
  });

  @override
  Widget build(BuildContext context) {
    // use methods passed from parent (VM)
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text(
        'Metode Pembayaran',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: methods.map(
            (m) {
              final id = m.id;
              final sel = id == value.name;
              return Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: sel ? Colors.blue : Colors.grey[700],
                    backgroundColor: sel ? Colors.white : Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => onChanged(
                      EPaymentMethod.values.firstWhere((e) => e.name == id)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        m.icon,
                        size: 16,
                        color: sel ? Colors.blue : m.color,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          m.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ),
    ]);
  }
}

class PaymentDetails extends StatelessWidget {
  final int cashReceived;
  final List cartDetails;
  final EPaymentMethod paymentMethod;
  final void Function(int) onCashChanged;
  final int Function() computeCartTotal;
  final int Function() computeGrandTotal;
  final int Function(int) suggestQuickCash;
  final int Function() computeChange;
  final TextEditingController cashController;

  const PaymentDetails({
    super.key,
    required this.cartDetails,
    required this.cashReceived,
    required this.paymentMethod,
    required this.onCashChanged,
    required this.computeCartTotal,
    required this.computeGrandTotal,
    required this.suggestQuickCash,
    required this.computeChange,
    required this.cashController,
  });

  @override
  Widget build(BuildContext context) {
    final grandTotal = computeGrandTotal();
    final change = computeChange();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: paymentMethod == EPaymentMethod.cash
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                'Uang Diterima',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: cashController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  prefixText: 'Rp ',
                  hintText: '0',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  )),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  ElevatedButton(
                    onPressed: () => onCashChanged(computeGrandTotal()),
                    child: const Text('Uang Pas'),
                  ),
                  const SizedBox(width: 8),
                  Builder(builder: (c) {
                    final sug = suggestQuickCash(grandTotal);
                    return ElevatedButton(
                      onPressed: () => onCashChanged(sug),
                      child: Text(formatRupiah(sug.toDouble())),
                    );
                  }),
                ]),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      change >= 0 ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kembalian',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(formatRupiah(change.toDouble()))
                    ]),
              ),
            ])
          : paymentMethod == EPaymentMethod.qris
              ? Column(children: [
                  Container(
                    width: 160,
                    height: 160,
                    color: Colors.white,
                    child: Image.network(
                      'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=PAY-$grandTotal',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatRupiah(grandTotal.toDouble()),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ])
              : const Column(
                  children: [
                    BankRow(bankName: 'BCA', account: '123 456 7890'),
                    SizedBox(height: 8),
                    BankRow(bankName: 'BNI', account: '987 654 3210'),
                  ],
                ),
    );
  }
}

class BankRow extends StatelessWidget {
  final String account;
  final String bankName;

  const BankRow({
    super.key,
    required this.account,
    required this.bankName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                  child: Text(
                bankName.substring(0, 3),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Bank $bankName',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                account,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              )
            ])
          ]),
          Text(
            'Salin',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.blue.shade700,
            ),
          )
        ],
      ),
    );
  }
}

class FooterSummary extends ConsumerWidget {
  final List details;
  final bool isPaid;
  final VoidCallback onProcess;
  final void Function(bool) onIsPaidChanged;
  final int Function() computeCartTotal;
  final int Function() computeTax;
  final int Function() computeGrandTotal;

  const FooterSummary({
    super.key,
    required this.details,
    required this.isPaid,
    required this.onProcess,
    required this.onIsPaidChanged,
    required this.computeCartTotal,
    required this.computeTax,
    required this.computeGrandTotal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionPosViewModelProvider);
    // final viewModel = ref.read(transactionPosViewModelProvider.notifier);
    final cartTotal = computeCartTotal();
    final grandTotal = computeGrandTotal();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade100,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              'Subtotal',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            Text(
              formatRupiah(cartTotal.toDouble()),
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            )
          ]),
          // const SizedBox(height: 6),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(
          //       'Pajak (10%)',
          //       style: TextStyle(color: Colors.grey.shade600),
          //     ),
          //     Text(
          //       formatRupiah(tax.toDouble()),
          //       style: TextStyle(
          //         color: Colors.grey.shade600,
          //       ),
          //     )
          //   ],
          // ),
          // const SizedBox(height: 8),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formatRupiah(grandTotal.toDouble()),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          // Langsung Bayar checkbox — tappable single-row label
          InkWell(
            onTap: () => onIsPaidChanged(!state.isPaid),
            child: Row(
              children: [
                Checkbox(
                  value: state.isPaid,
                  onChanged: (v) => onIsPaidChanged(v ?? false),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Langsung Bayar',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onProcess,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: state.isPaid ? Colors.green : Colors.orange,
            ),
            child: Text(
              state.isPaid ? 'Bayar' : 'Pesan',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorSnackbar extends StatelessWidget {
  const ErrorSnackbar({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade500,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.error_outline, color: Colors.white),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perhatian',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Silahkan memilih Jenis Ojol diatas untuk melanjutkan.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
