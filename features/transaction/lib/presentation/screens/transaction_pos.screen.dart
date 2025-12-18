import 'package:core/core.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/widgets/transaction_pos_screen.widget.dart';
import 'package:transaction/presentation/controllers/transaction_pos.controller.dart';

class TransactionPosScreen extends ConsumerStatefulWidget {
  const TransactionPosScreen({super.key});

  @override
  ConsumerState<TransactionPosScreen> createState() =>
      _TransactionPosScreenState();
}

class _TransactionPosScreenState extends ConsumerState<TransactionPosScreen> {
  late final TransactionPosController _controller;
  final ScrollController _categoryScrollController = ScrollController();
  final ScrollController _productGridController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = TransactionPosController(ref, context);
    _controller.init();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _productGridController.dispose();
    _categoryScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionPosViewModelProvider);
    final viewModel = ref.read(transactionPosViewModelProvider.notifier);

    // Trigger refresh when this route becomes visible (each access).
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // final route = ModalRoute.of(context);
    //   // load data setiap akses layar
    //   Future.microtask(() async {
    //     // await _controller.maybeRefreshOnVisible(route?.isCurrent ?? false);
    //   });
    // });

    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<bool>(
          valueListenable: _controller.isSearching,
          builder: (_, searching, __) {
            if (searching) {
              return Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller.searchController,
                      focusNode: _controller.appBarSearchFocus,
                      onChanged: (v) => _controller.onSearchChanged(val: v),
                      decoration: const InputDecoration(
                        hintText: 'Cari produk...',
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),
                ],
              );
            }
            return const Text('POS');
          },
        ),
        leading: ValueListenableBuilder<bool>(
          valueListenable: _controller.isSearching,
          builder: (_, searching, __) => searching
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    _controller.exitSearch();
                  },
                )
              : const SizedBox.shrink(),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _controller.isSearching,
            builder: (_, searching, __) => searching
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _controller.enterSearch(),
                  ),
          )
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  color: Colors.white,
                  child: CategoryTab(
                    controller: _controller,
                    categoryScrollController: _categoryScrollController,
                    productGridController: _productGridController,
                    viewModel: viewModel,
                    state: state,
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      // Ensure pending transaction loaded and refresh products/packets
                      await viewModel.ensureLocalPendingTransactionLoaded();
                      await viewModel.refreshProductsAndPackets();
                    },
                    child: ContentArea(
                      controller: _controller,
                      productGridController: _productGridController,
                    ),
                  ),
                ),
              ],
            ),
            // cart bottom button (overlaid)
            CartBottomButton(
              state: state,
              viewModel: viewModel,
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                _controller.onShowCartSheet();
              },
            ),
          ],
        ),
      ),
    );
  }
}
