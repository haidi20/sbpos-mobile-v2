import 'package:core/core.dart';

class PaymentSettingsPage extends StatefulWidget {
  const PaymentSettingsPage({super.key});

  @override
  State<PaymentSettingsPage> createState() => _PaymentSettingsPageState();
}

class _PaymentSettingsPageState extends State<PaymentSettingsPage> {
  final List<Map<String, dynamic>> methods = [
    {'id': 1, 'name': 'Tunai (Cash)', 'active': true},
    {'id': 2, 'name': 'QRIS', 'active': true},
    {'id': 3, 'name': 'Kartu Debit', 'active': true},
    {'id': 4, 'name': 'Kartu Kredit', 'active': false},
    {'id': 5, 'name': 'Transfer Bank', 'active': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Metode Pembayaran',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // Aksi: Pop halaman saat ini dari tumpukan
                  context.pop();
                },
              )
            : null, // Jika tidak ada history, tombol leading tidak muncul
        shadowColor: Colors.grey.shade50,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: methods.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = methods[index];
          final bool active = item['active'];

          return InkWell(
            onTap: () {
              setState(() {
                methods[index]['active'] = !active;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: active ? Colors.blue.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: active ? AppColors.sbBlue : Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              active ? AppColors.sbBlue : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.credit_card,
                            size: 18,
                            color:
                                active ? Colors.white : Colors.grey.shade400),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item['name'],
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color:
                                active ? Colors.black87 : Colors.grey.shade400),
                      ),
                    ],
                  ),
                  if (active)
                    const Icon(Icons.check_circle, color: AppColors.sbBlue)
                  else
                    Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.grey.shade300, width: 2))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
