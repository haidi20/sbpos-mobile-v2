import 'package:core/core.dart';
// Domain entity import removed; support dynamic payloads

class DetailInfo extends StatelessWidget {
  final dynamic tx;

  const DetailInfo({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    // support both domain entity 'details' and old 'items' payloads
    final rawList =
        tx.details ?? (tx is Map ? tx['items'] : null) ?? <dynamic>[];
    final items = (rawList as List).cast<dynamic>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Detail Item', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...items.map((it) {
          final name = it.productName ?? it.name ?? '-';
          final qty = (it.qty ?? it['qty']) ?? 0;
          final priceRaw = it.productPrice ?? it.price ?? it['price'] ?? 0;
          final price = priceRaw is num
              ? priceRaw.toDouble()
              : double.tryParse(priceRaw.toString()) ?? 0.0;
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(name),
            trailing: Text('$qty x ${formatRupiah(price)}'),
          );
        }),
      ],
    );
  }
}
