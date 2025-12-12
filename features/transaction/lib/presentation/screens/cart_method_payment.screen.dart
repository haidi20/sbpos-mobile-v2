import 'package:core/core.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/controllers/cart_bottom_sheet.controller.dart';

class CartMethodPaymentScreen extends ConsumerStatefulWidget {
  const CartMethodPaymentScreen({super.key});

  @override
  ConsumerState<CartMethodPaymentScreen> createState() =>
      _CartMethodPaymentScreenState();
}

// ----------------------- Widgets -----------------------

class _OrderTypeSelector extends StatelessWidget {
  final String value;
  final void Function(String) onChanged;
  const _OrderTypeSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const types = [
      {'id': 'dine_in', 'label': 'Makan di Tempat', 'icon': Icons.restaurant},
      {'id': 'take_away', 'label': 'Bungkus', 'icon': Icons.shopping_bag},
      {'id': 'online', 'label': 'Online / Ojol', 'icon': Icons.directions_bike},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: types.map((t) {
            final id = t['id'] as String;
            final label = t['label'] as String;
            final icon = t['icon'] as IconData;
            final selected = id == value;
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
                            fontSize: 12, fontWeight: FontWeight.w700),
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

class _OjolProviderSelector extends StatelessWidget {
  final String value;
  final void Function(String) onChanged;
  const _OjolProviderSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const providers = ['GoFood', 'GrabFood', 'ShopeeFood'];
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text(
          'Pilih Jenis Ojol',
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w800, color: Colors.orange),
        ),
        const SizedBox(height: 8),
        Row(
          children: providers.map((p) {
            final sel = p == value;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      backgroundColor: sel ? Colors.orange : Colors.white,
                      foregroundColor: sel ? Colors.white : Colors.grey[700]),
                  onPressed: () => onChanged(p),
                  child: Text(
                    p,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }
}

class _PaymentMethodSelector extends StatelessWidget {
  final String value;
  final void Function(String) onChanged;
  const _PaymentMethodSelector({required this.value, required this.onChanged});

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
            final sel = id == value;
            return Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: sel ? Colors.blue : Colors.grey[700],
                  backgroundColor: sel ? Colors.white : Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => onChanged(id),
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(m['icon'] as IconData, size: 16),
                      const SizedBox(width: 8),
                      Text(m['label'] as String)
                    ]),
              ),
            );
          }).toList(),
        ),
      ),
    ]);
  }
}

class _PaymentDetails extends StatelessWidget {
  final String paymentMethod;
  final int cashReceived;
  final void Function(int) onCashChanged;
  final List cartDetails;
  const _PaymentDetails(
      {required this.paymentMethod,
      required this.cashReceived,
      required this.onCashChanged,
      required this.cartDetails});

  int _computeCartTotal() {
    try {
      return cartDetails.fold<int>(0, (s, d) {
        final subtotal =
            (d.subtotal ?? ((d.productPrice ?? 0) * (d.qty ?? 1))) as int;
        return s + subtotal;
      });
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartTotal = _computeCartTotal();
    final tax = (cartTotal * 0.1).round();
    final grandTotal = cartTotal + tax;
    final change = cashReceived - grandTotal;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: paymentMethod == 'cash'
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
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                onChanged: (v) => onCashChanged(int.tryParse(v) ?? 0),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  ElevatedButton(
                    onPressed: () => onCashChanged(grandTotal),
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
          : paymentMethod == 'qris'
              ? Column(children: [
                  Container(
                    width: 160,
                    height: 160,
                    color: Colors.white,
                    child: Image.network(
                        'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=PAY-$grandTotal',
                        fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${grandTotal.toString()}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ])
              : const Column(
                  children: [
                    _BankRow(bankName: 'BCA', account: '123 456 7890'),
                    SizedBox(height: 8),
                    _BankRow(bankName: 'BNI', account: '987 654 3210'),
                  ],
                ),
    );
  }
}

class _BankRow extends StatelessWidget {
  final String bankName;
  final String account;
  const _BankRow({required this.bankName, required this.account});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                  child: Text(bankName.substring(0, 3),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                'Bank $bankName',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(account, style: const TextStyle(fontWeight: FontWeight.bold))
            ])
          ]),
          Text('Salin',
              style: TextStyle(
                  color: Colors.blue.shade700, fontWeight: FontWeight.w700))
        ]));
  }
}

class _FooterSummary extends StatelessWidget {
  final List details;
  final String viewMode;
  final VoidCallback onToggleView;
  final VoidCallback onProcess;

  const _FooterSummary({
    required this.details,
    required this.viewMode,
    required this.onToggleView,
    required this.onProcess,
  });

  int _computeCartTotal() {
    try {
      return details.fold<int>(0, (s, d) {
        final subtotal =
            (d.subtotal ?? ((d.productPrice ?? 0) * (d.qty ?? 1))) as int;
        return s + subtotal;
      });
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartTotal = _computeCartTotal();
    final tax = (cartTotal * 0.1).round();
    final grandTotal = cartTotal + tax;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              'Subtotal',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            Text('Rp ${cartTotal.toString()}',
                style: TextStyle(color: Colors.grey.shade600))
          ]),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              'Pajak (10%)',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            Text('Rp ${tax.toString()}',
                style: TextStyle(color: Colors.grey.shade600))
          ]),
          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text(
              'Total',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('Rp ${grandTotal.toString()}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: viewMode == 'cart' ? onToggleView : onProcess,
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor:
                    viewMode == 'cart' ? Colors.orange : Colors.blue),
            child: Text(
              viewMode == 'cart' ? 'Lanjut Pembayaran' : 'Bayar Sekarang',
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

class _ErrorSnackbar extends StatelessWidget {
  const _ErrorSnackbar();
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
                Text('Silahkan memilih Jenis Ojol diatas untuk melanjutkan.',
                    style: TextStyle(color: Colors.white, fontSize: 12))
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Note: The helper widgets are intentionally kept here for easy maintenance; move
// them to separate files when the UI grows.

class _CartMethodPaymentScreenState
    extends ConsumerState<CartMethodPaymentScreen> {
  late final CartBottomSheetController _controller;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _controller = CartBottomSheetController(ref, context);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateTransaction = ref.watch(transactionPosViewModelProvider);

    // Return the inner column only — this widget is intended to be
    // included inside the bottom sheet `cart_bottom.sheet.dart`.
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _OrderTypeSelector(
              onChanged: (v) => setState(() => _orderType = v),
              value: _orderType),
          const SizedBox(height: 12),
          if (_orderType == 'online')
            _OjolProviderSelector(
              value: _ojolProvider,
              onChanged: (v) => setState(() => _ojolProvider = v),
            ),
          const SizedBox(height: 12),
          _PaymentMethodSelector(
            value: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v),
          ),
          const SizedBox(height: 12),
          _PaymentDetails(
            paymentMethod: _paymentMethod,
            cashReceived: _cashReceived,
            onCashChanged: (v) => setState(() => _cashReceived = v),
            cartDetails: stateTransaction.details,
          ),
          const SizedBox(height: 12),
          _FooterSummary(
            details: stateTransaction.details,
            viewMode: _viewMode,
            onToggleView: () => setState(
                () => _viewMode = _viewMode == 'cart' ? 'checkout' : 'cart'),
            onProcess: () {
              if (_orderType == 'online' && _ojolProvider.isEmpty) {
                setState(() => _showErrorSnackbar = true);
                Future.delayed(const Duration(seconds: 3),
                    () => setState(() => _showErrorSnackbar = false));
                return;
              }
              // Hook point: call viewModel to process payment if available
            },
          ),
          if (_showErrorSnackbar) const SizedBox(height: 8),
          if (_showErrorSnackbar) const _ErrorSnackbar(),
        ],
      ),
    );
  }

  // Local UI state
  String _orderType = 'dine_in';
  String _ojolProvider = '';
  String _paymentMethod = 'cash';
  int _cashReceived = 0;
  String _viewMode = 'cart';
  bool _showErrorSnackbar = false;
}
