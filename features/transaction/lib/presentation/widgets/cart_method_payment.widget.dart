import 'package:core/core.dart';
import 'package:transaction/presentation/ui_models/order_type_item.um.dart';
import 'package:transaction/presentation/view_models/transaction_pos.state.dart';

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
                    foregroundColor: selected ? Colors.blue : Colors.grey[700],
                    elevation: selected ? 2 : 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                      Icon(icon, size: 20),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
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
  const OjolProviderSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const providers = [
      'Go Food',
      'Grab Food',
      'Shopee Food',
    ];

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
                final sel = p == value;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: sel ? Colors.orange : Colors.white,
                        foregroundColor: sel ? Colors.white : Colors.grey[700],
                      ),
                      onPressed: () => onChanged(p),
                      child: Text(
                        p,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
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
  const PaymentMethodSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const methods = [
      {'id': 'cash', 'label': 'Tunai', 'icon': Icons.money},
      {'id': 'qris', 'label': 'QRIS', 'icon': Icons.qr_code},
      {'id': 'transfer', 'label': 'Transfer', 'icon': Icons.credit_card},
    ];

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
          children: methods.map((m) {
            final id = m['id'] as String;
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
                    Icon(m['icon'] as IconData, size: 16),
                    const SizedBox(width: 8),
                    Text(m['label'] as String),
                  ],
                ),
              ),
            );
          }).toList(),
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
  final int Function() computeChange;

  const PaymentDetails({
    super.key,
    required this.cartDetails,
    required this.cashReceived,
    required this.paymentMethod,
    required this.onCashChanged,
    required this.computeCartTotal,
    required this.computeGrandTotal,
    required this.computeChange,
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
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixText: 'Rp ',
                  hintText: '0',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                    Radius.circular(
                      12,
                    ),
                  )),
                ),
                onChanged: (v) => onCashChanged(int.tryParse(v) ?? 0),
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
                  ElevatedButton(
                    onPressed: () => onCashChanged(50000),
                    child: const Text('50.000'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => onCashChanged(100000),
                    child: const Text('100.000'),
                  ),
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
                      Text('Rp ${change.toString()}')
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
                    'Rp ${grandTotal.toString()}',
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

class FooterSummary extends StatelessWidget {
  final List details;
  final EViewMode viewMode;
  final bool isPaid;
  final VoidCallback onProcess;
  final VoidCallback onToggleView;
  final void Function(bool) onIsPaidChanged;
  final int Function() computeCartTotal;
  final int Function() computeTax;
  final int Function() computeGrandTotal;

  const FooterSummary({
    super.key,
    required this.details,
    required this.viewMode,
    required this.isPaid,
    required this.onProcess,
    required this.onToggleView,
    required this.onIsPaidChanged,
    required this.computeCartTotal,
    required this.computeTax,
    required this.computeGrandTotal,
  });

  @override
  Widget build(BuildContext context) {
    final cartTotal = computeCartTotal();
    final tax = computeTax();
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
              'Rp ${cartTotal.toString()}',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            )
          ]),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pajak (10%)',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              Text(
                'Rp ${tax.toString()}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
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
                'Rp ${grandTotal.toString()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          // Langsung Bayar checkbox
          Row(
            children: [
              Checkbox(
                value: isPaid,
                onChanged: (v) => onIsPaidChanged(v ?? false),
              ),
              const SizedBox(width: 8),
              const Expanded(child: Text('Langsung Bayar')),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: viewMode == EViewMode.cart ? onToggleView : onProcess,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor:
                  viewMode == EViewMode.cart ? Colors.orange : Colors.blue,
            ),
            child: Text(
              viewMode == EViewMode.cart
                  ? 'Lanjut Pembayaran'
                  : 'Bayar Sekarang',
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
