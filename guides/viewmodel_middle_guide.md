# Guide: ViewModel Middle — Transaction POS

Panduan ini menjelaskan aturan, pola, dan praktik terbaik untuk membuat "middle" ViewModel (VM) untuk fitur Transaction POS di repo ini. Tujuan: agar setiap fitur baru yang butuh VM middle mengikuti konvensi yang konsisten, mudah dibaca, dan mudah diuji.

Ringkas, padat, informatif — fokus hanya pada Transaction POS. Jangan ubah struktur package global; ikuti `core/` untuk utilitas bersama.

---
1) Struktur file dan penamaan
- Folder: `features/<feature>/lib/presentation/view_models`
- Untuk Transaction POS, pisahkan file menjadi: `transaction_pos.state.dart`, `transaction_pos.vm.dart`, `transaction_pos.getters.dart`, `transaction_pos.setters.dart`, `transaction_pos.actions.dart`, `transaction_pos.persistence.dart`, `transaction_pos.calculations.dart`.
- Tujuan: satu file = satu tanggung jawab (state, getters, setters, actions, persistence, pure calculations).

2) Tanggung jawab tiap file (singkat)
- `*.state.dart`: deklarasi `State` immutable dengan `copyWith()` dan factory `cleared()`.
- `*.vm.dart`: deklarasi `StateNotifier<State>` + injeksi usecases; hanyainisialisasi & wiring. Gunakan `part` untuk bagian lain.
- `*.getters.dart`: fungsi murni/derived-state dan builder (tidak melakukan side-effect). Contoh: filter, kalkulasi format, buildCombinedContent.
- `*.setters.dart`: mutator yang mengubah state (sync/async) dan memanggil persistence bila perlu. Gunakan `persistAndUpdateState` untuk operasi yang harus mengubah `state.transaction` dengan hasil persistence, `persistOnly` untuk background write tanpa menimpa state.
- `*.actions.dart`: user actions/flows (onAddToCart, onClearCart, onStore). Koordinasikan guards, completer, dan debounce di sini.
- `*.persistence.dart`: semua logika read/write ke usecase/repository yang berhubungan dengan penyimpanan (create/update/delete/load). Return void/Result sesuai usecase; isolate effect dari VM sebanyak mungkin.
- `*.calculations.dart`: fungsi pure untuk hitungan (total, tax, change, scroll target) agar mudah diuji.

3) Prinsip desain utama
- Single Responsibility: setiap file punya tanggung jawab tunggal.
- Pure vs Effectful: pisahkan fungsi murni (kalkulasi, filtering) dari yang menimbulkan efek (persistence, logging).
- Persistence semantics:
	- `persistAndUpdateState`: gunakan ketika hasil persistence (created/updated transaction) harus disimpan kembali ke `state`.
	- `persistOnly`: gunakan untuk write background yang tidak boleh menimpa state UI (mis. hanya menyimpan local cache);
	- Jangan `unawait` tanpa alasan; jika memilih `unawait`, tambahkan komentar yang menjelaskan alasan dan risiko.
- Concurrency guards: gunakan booleans + `Completer` untuk mencegah double-create/update (contoh: `_isCreatingTx`, `_createTxCompleter`). Pastikan completer selalu diselesaikan dalam `finally`.
- Debounce & timers: untuk input yang sering berubah (order note, item note) gunakan `Timer` debouncing. Selalu batalkan timer di `dispose()`.

4) Lifecycle & resources
- Implement `dispose()` pada `StateNotifier` (VM) bila Anda membuat `Timer`, `Completer`, atau sumber daya lain. Di `dispose()`:
	- cancel `_orderNoteDebounce` jika non-null
	- cancel semua timers di `_itemNoteDebounces`
	- jika `_createTxCompleter` belum completed, complete/completeError sesuai konteks
	- panggil `super.dispose()` di akhir

5) Caching & derived UI data
- VM boleh menyimpan cache internal (mis. `_cachedProducts`, `_combinedCache`) untuk menghindari komputasi ulang.
- Bila cache berubah, perbarui state minimal (mis. `state = state.copyWith()` untuk trigger notifyListeners) — jangan simpan data view-only besar di `state` jika tidak perlu.

6) Error handling & logging
- Tangkap error di level persistence/actions dan log dengan `Logger`. Put user-visible errors ke `state.error` bila perlu.
- Hindari menelan error tanpa logging.

7) Filter & matching rules
- Untuk konsistensi, gunakan sumber data yang sama saat memfilter: products memakai `product.category?.name`, details sebaiknya memakai `productName`/`packetName` bukan `note` untuk kategori. Jika `note` digunakan sebagai kategori, dokumentasikan mapping-nya.

8) Testing
- Tulis unit test untuk:
	- Semua fungsi pada `transaction_pos.calculations.dart` (pure functions).
	- Aksi penting: `onAddToCart`, `setUpdateQuantity`, `onAddPacketToCart`. Mock usecases sehingga `persistAndUpdateState`/`persistOnly` dapat diuji.
	- Race conditions: test pembuatan transaksi ganda (gunakan completer-mock atau fake repository).

9) Checklist singkat sebelum PR
- [ ] State immutable, ada `copyWith()` dan `cleared()` factory
- [ ] File dipisah sesuai tanggung jawab
- [ ] Persistence semantics diputuskan (persistAndUpdateState vs persistOnly)
- [ ] Timers & completers di-cleanup di `dispose()`
- [ ] Logging untuk semua error significant
- [ ] Unit tests untuk pure functions dan flows utama
- [ ] Komentar singkat di jalur `unawaited` yang menjelaskan alasan

10) Snippet contoh (pattern penting)
- Guard create transaction (pattern):

```
if (_isCreatingTx) {
	await (_createTxCompleter?.future);
	unawaited(_persistence.persistOnly(state, updated));
	return;
}
_isCreatingTx = true;
_createTxCompleter = Completer<void>();
try {
	await _persistence.persistAndUpdateState(() => state, (s) => state = s, updated);
} finally {
	_isCreatingTx = false;
	_createTxCompleter?.complete();
	_createTxCompleter = null;
}
```

11) Catatan singkat tentang common bug/pitfall
- Jangan pakai `unawaited(persistOnly(...))` jika state perlu sinkron dengan hasil remote/local persistence.
- Pastikan debounced persist memanggil `persistAndUpdateState` bila perubahan memengaruhi metadata transaksi (notes, paymentMethod, isPaid).

12) Mixins dan Extension (extend) — cara pakai
- Tujuan: gunakan `mixin` untuk pengelompokan perilaku VM (actions/getters/setters) tanpa menambah state lokal, dan `extension` untuk menambah helper pada tipe existing (State, List, Entity) agar kode lebih ekspresif.

- Mixin (ketentuan):
	- Gunakan `mixin X on Y` untuk mengikat mixin ke `StateNotifier<TransactionPosState>` (atau tipe VM konkret).
	- Jangan simpan state internal yang mutable di mixin; letakkan state di VM atau gunakan getter pada mixin untuk mengakses VM (`YourViewModel get _vm => this as YourViewModel;`).
	- Pisahkan `actions`, `setters`, dan `getters` ke file mixin masing-masing (sudah konvensi di repo: `transaction_pos.actions.dart`, dll.).

	Contoh singkat (Transaction POS):

	```dart
	// transaction_pos.actions.dart
	part of 'transaction_pos.vm.dart';

	mixin TransactionPosViewModelActions on StateNotifier<TransactionPosState> {
		TransactionPosViewModel get _vm => this as TransactionPosViewModel;

		Future<void> onAddToCart(ProductEntity p) async {
			// akses state via `state`, gunakan _vm untuk akses private field
			final updated = addOrUpdateProductInDetails(state.details, p);
			state = state.copyWith(details: updated);
			await _vm._persistence.persistAndUpdateState(
				() => state,
				(s) => state = s,
				updated,
			);
		}
	}
	```

- Extension methods / library (ketentuan):
	- Kapan pakai: untuk helper pure yang memperkaya tipe yang ada (mis. `List<TransactionDetailEntity>` atau `TransactionPosState`).
	- Buat file `transaction_pos.extensions.dart` atau letakkan di `transaction_pos.calculations.dart` jika pure.
	- Ekstensi harus bebas efek samping (pure) sehingga mudah diuji.

	Contoh extension pada list detail:

	```dart
	extension TransactionDetailListX on List<TransactionDetailEntity> {
		int totalValue() => fold(0, (s, d) => s + (d.subtotal ?? (d.productPrice ?? 0) * (d.qty ?? 0)));
		int totalCount() => fold(0, (s, d) => s + (d.qty ?? 0));
	}
	```

	Penggunaan di getter:

	```dart
	int get getCartTotalValue => state.details.totalValue();
	```

- Export & discoverability:
	- Jika ekstensi umum (dipakai di banyak fitur), tambahkan ke `core/lib/core.dart` export agar konsisten.
	- Jika spesifik untuk Transaction POS, simpan di folder feature dan import relatif (mis. `part` atau `import`).

- Best practice ringkas:
	- Mixins: gunakan untuk grouping method yang butuh akses `state`/`_persistence`, bukan untuk menyimpan timer/completer sendiri (letakkan resource di VM dan akses melalui getter).
	- Extensions: hanya fungsi pure, mudah diuji, dan ringkas; hindari efek samping.
	- Dokumentasikan kontrak: tuliskan comment pendek di atas mixin/extension tentang asumsi (mis. "expects VM to expose `_persistence` and `_logger`").

13) Aturan penamaan fungsi (getter / setter / event)
- Tujuan: konsistensi nama agar mudah dicari dan langsung menggambarkan peran fungsi.
- Konvensi nama:
	- Getter: awali nama dengan `get` diikuti nama deskriptif dalam PascalCase/camelCase: contoh `getCartTotal`, `getFilteredProducts`.
	- Setter: awali nama dengan `set` diikuti nama field/aksi: contoh `setActiveCategory`, `setCashReceived`.
	- Event / handler (user action): awali nama dengan `on` diikuti aksi yang terjadi: contoh `onAddToCart`, `onClearCart`, `onStore`.

- Rules & contoh singkat:
	- Gunakan `get` untuk fungsi yang hanya membaca/mereturn derived state tanpa side-effect.
	- Gunakan `set` untuk fungsi yang memodifikasi state atau menyebabkan side-effect persistence (walau implementasinya async boleh mengembalikan `Future<void>`).
	- Gunakan `on` untuk fungsi yang merepresentasikan event/aksi yang dipicu UI (biasanya dipanggil oleh controller/widget).
	- Contoh tidak benar: `fetchCartTotal` boleh dipakai, tapi prefer `getCartTotal` bila hanya read/derived; hindari `setSetX` atau `onSetX` (do not double-prefix).

- Integrasi ke checklist PR: tambahkan verifikasi nama fungsi sesuai konvensi.
