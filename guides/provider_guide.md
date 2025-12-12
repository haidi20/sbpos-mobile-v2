**Panduan Provider (berpatokan pada folder `features/transaction/lib/presentation/providers`)**

- **Ringkasan pola:**
	- `data source providers`: expose remote/local datasources sebagai `Provider`.
	- `repository provider`: buat `Provider<Repository?>` yang membangun repository dengan `ref.read(dataSourceProvider)`.
	- `usecase providers`: buat `Provider` ringan yang `ref.watch(repositoryProvider)` lalu mengembalikan instance usecase.
	- `viewmodel providers`: `StateNotifierProvider` yang `watch` usecase provider dan mengembalikan ViewModel.

- **Contoh file dan lokasi:**
	- Datasources: `features/transaction/lib/data/datasources/transaction_remote.data_source.dart`
	- Repository impl: `features/transaction/lib/data/repositories/transaction.repository_impl.dart`
	- Repository provider: `features/transaction/lib/presentation/providers/transaction_repository.provider.dart`
	- Usecase providers + ViewModel providers: `features/transaction/lib/presentation/providers/transaction.provider.dart`

- **Contoh ringkas (pola yang dipakai di repo):**

	- Repository provider (menggabungkan datasource):

		```dart
		final transactionRemoteDataSourceProvider = Provider<TransactionRemoteDataSource>((ref) => TransactionRemoteDataSource());
		final transactionLocalDataSourceProvider = Provider<TransactionLocalDataSource>((ref) => TransactionLocalDataSource());

		final transactionRepositoryProvider = Provider<TransactionRepository?>((ref) => TransactionRepositoryImpl(
			remote: ref.read(transactionRemoteDataSourceProvider),
			local: ref.read(transactionLocalDataSourceProvider),
		));
		```

	- Usecase provider (membaca repository provider):

		```dart
		final getTransactions = Provider((ref) {
			final repo = ref.watch(transactionRepositoryProvider);
			return GetTransactionsUsecase(repo!);
		});
		```

	- ViewModel provider (menggabungkan beberapa usecase):

		```dart
		final transactionPosViewModelProvider = StateNotifierProvider<TransactionPosViewModel, TransactionPosState>((ref) {
			final createTxn = ref.watch(createTransaction);
			final updateTxn = ref.watch(updateTransaction);
			final deleteTxn = ref.watch(deleteTransaction);
			final getTxnActive = ref.watch(getTransactionActive);

			return TransactionPosViewModel(
				createTxn,
				updateTxn,
				deleteTxn,
				getTxnActive,
			);
		});
		```

- **Aturan singkat dan best-practices:**
	- Letakkan semua provider feature di `presentation/providers`.
	- Gunakan `ref.read` untuk menginisialisasi repositori dari datasource di repository provider, dan `ref.watch` saat usecase/ViewModel membutuhkan repository/usecase.
	- Gunakan `Repository?` dengan nilai default `null` pada provider repository agar mudah dioverride di composition root; cast `repo!` di usecase provider bila anda memastikan override dilakukan.
	- Pisahkan usecase ringan menjadi provider tersendiri sehingga viewmodels mudah diuji dan di-mock.

- **Testing & Composition root:**
	- Override `transactionRepositoryProvider` di `main.dart` atau di test `ProviderScope(overrides:[...])` untuk menyuntikkan implementasi nyata atau mock.

Dokumen ini menegaskan pola provider di folder `features/transaction/lib/presentation/providers`.
