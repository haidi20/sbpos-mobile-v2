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
  bool _isSearching = false;

  late final TransactionPosController _controller;
  final FocusNode _appBarSearchFocus = FocusNode();
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
    _appBarSearchFocus.dispose();
    _productGridController.dispose();
    _categoryScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionPosViewModelProvider);
    final viewModel = ref.read(transactionPosViewModelProvider.notifier);

    // Trigger refresh when this route becomes visible (each access).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      // load data setiap akses layar
      Future.microtask(() async {
        await _controller.maybeRefreshOnVisible(route?.isCurrent ?? false);
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller.searchController,
                      focusNode: _appBarSearchFocus,
                      onChanged: (v) => _controller.onSearchChanged(val: v),
                      decoration: const InputDecoration(
                        hintText: 'Cari produk...',
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),
                ],
              )
            : const Text('POS'),
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                  });
                  // clear search and reset filter
                  try {
                    _controller.searchController.clear();
                    _controller.onSearchChanged(val: '');
                  } catch (_) {}
                },
              )
            : null,
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: _isSearching
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      try {
                        _appBarSearchFocus.requestFocus();
                      } catch (_) {}
                    });
                  },
                ),
              ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                CategoryBar(
                  controller: _controller,
                  categoryScrollController: _categoryScrollController,
                  productGridController: _productGridController,
                  viewModel: viewModel,
                  state: state,
                ),
                Expanded(
                  child: ContentArea(
                    controller: _controller,
                    productGridController: _productGridController,
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
