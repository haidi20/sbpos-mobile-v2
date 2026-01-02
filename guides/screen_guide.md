**Screen Widget Guide**

Panduan singkat ini menunjukkan pola memecah UI layar menjadi private `StatelessWidget` yang informatif dan mudah di-test. Contoh ditulis untuk Flutter (Dart) dan mengikuti prinsip:
- UI kecil, terpisah, dan memiliki `Key` serta constructor untuk mempermudah testing.
- Komponen: list, card, empty, loading, error.
- Penanganan response: tampilkan loading, success (data), atau error beserta message/data error.

**Principles**
- Pisahkan widget ke unit kecil (`_List`, `_CardItem`, `_Empty`, `_Loading`, `_Error`).
- Buat semua widget sebagai `StatelessWidget` private (prefix `_`) agar mudah di-reuse di file yang sama namun tetap terisolasi.
- Tambahkan `Key` dan parameter yang diperlukan agar test mudah melakukan pump dan verifikasi.

**Contoh Kode**

Berikut contoh file widget sederhana. Simpan di file feature Anda, mis: `features/transaction/lib/presentation/transaction_list_screen.dart`.

```dart
import 'package:flutter/material.dart';

// Model sederhana untuk contoh
class Item {
	final String id;
	final String title;
	final String subtitle;

	Item({required this.id, required this.title, required this.subtitle});
}

// Response wrapper sederhana — bisa diganti dengan AsyncValue / Result dari project Anda
enum ResponseStatus { loading, success, failure }

class Response<T> {
	final ResponseStatus status;
	final T? data;
	final String? message;

	Response.loading() : status = ResponseStatus.loading, data = null, message = null;
	Response.success(this.data) : status = ResponseStatus.success, message = null;
	Response.failure(this.message) : status = ResponseStatus.failure, data = null;
}

class TransactionListScreen extends StatelessWidget {
	final Response<List<Item>> response;
	final VoidCallback? onRetry;

	const TransactionListScreen({Key? key, required this.response, this.onRetry}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		switch (response.status) {
			case ResponseStatus.loading:
				return const Scaffold(body: Center(child: _Loading(key: Key('loading'))));
			case ResponseStatus.failure:
				return Scaffold(body: Center(child: _Error(message: response.message ?? 'Unknown', onRetry: onRetry, key: Key('error'))));
			case ResponseStatus.success:
				final items = response.data ?? [];
				if (items.isEmpty) {
					return const Scaffold(body: Center(child: _Empty(key: Key('empty'))));
				}
				return Scaffold(
					appBar: AppBar(title: const Text('Items')),
					body: _List(items: items, key: Key('list')),
				);
		}
	}
}

// Private, small widgets — each StatelessWidget, injection-friendly for tests

class _List extends StatelessWidget {
	final List<Item> items;

	const _List({Key? key, required this.items}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return ListView.separated(
			itemCount: items.length,
			separatorBuilder: (_, __) => const Divider(height: 1),
			itemBuilder: (context, index) => _CardItem(item: items[index], key: Key('card-\u007f$index')),
		);
	}
}

class _CardItem extends StatelessWidget {
	final Item item;

	const _CardItem({Key? key, required this.item}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return ListTile(
			key: Key('card-${item.id}'),
			title: Text(item.title),
			subtitle: Text(item.subtitle),
			leading: const Icon(Icons.receipt_long),
			onTap: () {
				// navigation or callback, injected via closure if needed
			},
		);
	}
}

class _Empty extends StatelessWidget {
	const _Empty({Key? key}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return Column(
			mainAxisSize: MainAxisSize.min,
			children: const [
				Icon(Icons.inbox, size: 64, color: Colors.grey),
				SizedBox(height: 12),
				Text('Tidak ada data', style: TextStyle(color: Colors.grey)),
			],
		);
	}
}

class _Loading extends StatelessWidget {
	const _Loading({Key? key}) : super(key: key);

	@override
	Widget build(BuildContext context) => const CircularProgressIndicator();
}

class _Error extends StatelessWidget {
	final String message;
	final VoidCallback? onRetry;

	const _Error({Key? key, required this.message, this.onRetry}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return Column(
			mainAxisSize: MainAxisSize.min,
			children: [
				const Icon(Icons.error_outline, size: 48, color: Colors.red),
				const SizedBox(height: 8),
				Text(message, textAlign: TextAlign.center),
				const SizedBox(height: 12),
				if (onRetry != null)
					ElevatedButton(onPressed: onRetry, child: const Text('Coba lagi'))
			],
		);
	}
}
```

**Testing Guidance**

- Karena semua widget kecil adalah `StatelessWidget` dengan `Key` dan parameter, Anda bisa menulis widget tests yang mem-pump widget dan memeriksa keberadaan elemen dengan key atau teks.
- Contoh test untuk memastikan `_Empty`, `_Loading`, `_CardItem` dan `TransactionListScreen` merespon status yang berbeda.

Contoh file test: `test/presentation/screens/transaction_list_screen_test.dart`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// import file screen Anda di sini
import 'package:your_feature/transaction_list_screen.dart';

void main() {
	testWidgets('shows loading when response is loading', (tester) async {
		final widget = MaterialApp(home: TransactionListScreen(response: Response.loading()));
		await tester.pumpWidget(widget);
		expect(find.byKey(Key('loading')), findsOneWidget);
	});

	testWidgets('shows empty when success with empty list', (tester) async {
		final widget = MaterialApp(home: TransactionListScreen(response: Response.success(<Item>[])));
		await tester.pumpWidget(widget);
		expect(find.byKey(Key('empty')), findsOneWidget);
	});

	testWidgets('shows list and card items when success with data', (tester) async {
		final items = [Item(id: '1', title: 'A', subtitle: 'sub')];
		final widget = MaterialApp(home: TransactionListScreen(response: Response.success(items)));
		await tester.pumpWidget(widget);
		expect(find.byKey(Key('list')), findsOneWidget);
		expect(find.byKey(Key('card-1')), findsOneWidget);
	});

	testWidgets('shows error and retry button', (tester) async {
		var called = false;
		final widget = MaterialApp(
			home: TransactionListScreen(
				response: Response.failure('Gagal'),
				onRetry: () => called = true,
			),
		);
		await tester.pumpWidget(widget);
		expect(find.byKey(Key('error')), findsOneWidget);
		await tester.tap(find.text('Coba lagi'));
		expect(called, true);
	});
}
```

Catatan:
- Sesuaikan import test dengan path feature Anda.
- Gunakan `Key` konsisten untuk memudahkan pencarian widget di test.

**Rekomendasi struktur file**
- `features/<feature>/lib/presentation/screens/transaction_list_screen.dart` — layar utama + private widgets.
- `features/<feature>/lib/presentation/widgets/` — jika beberapa widget ingin dipakai ulang di file lain, buat file terpisah dan export internal yang diperlukan.
- `test/presentation/transaction_list_screen_test.dart` — contoh test.

Dengan pola ini, widget kecil mudah di-mock, di-inject dependence-nya (mis: callback), dan langsung bisa diuji oleh `flutter_test`.

---
Jika Anda mau, saya bisa:
1) buat contoh file test nyata di repo (`test/presentation/transaction_list_screen_test.dart`), atau
2) adaptasikan contoh ini ke feature spesifik Anda (mis: `transaction`), tinggal tunjukkan nama package/paths.
