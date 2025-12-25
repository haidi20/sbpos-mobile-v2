import 'package:core/core.dart';
import 'package:landing_page_menu/presentation/components/product.card.dart';
import 'package:landing_page_menu/presentation/providers/landing_page_menu_provider.dart';
import 'package:landing_page_menu/presentation/widgets/landing_page_menu_add_widget.dart';
import 'package:landing_page_menu/presentation/widgets/shopping_cart_summary_bar_widget.dart';

class LandingPageMenuScreen extends ConsumerStatefulWidget {
  final int? appId;
  final String? modeName;

  // appId and mode name
  const LandingPageMenuScreen({
    super.key,
    this.appId,
    this.modeName,
  });

  @override
  ConsumerState<LandingPageMenuScreen> createState() =>
      _LandingPageMenuScreenState();
}

class _LandingPageMenuScreenState extends ConsumerState<LandingPageMenuScreen> {
  // late LandingPageMenuController _controller;
  // static final Logger _logger = Logger('LandingPageMenuScreen');

  @override
  void initState() {
    super.initState();
    // _controller = LandingPageMenuController(ref, context);
    final viewModel = ref.read(landingPageMenuViewModelProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.clearState();
      viewModel.fetchProducts();
    });
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(landingPageMenuViewModelProvider);
    final viewModel = ref.read(landingPageMenuViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MIE TAKE AWAY',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        scrolledUnderElevation:
            4, // Tambahkan agar background tetap solid saat scroll
        surfaceTintColor:
            Colors.white, // Pastikan warna tetap putih saat scroll
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: PaketSectionWidget(),
          ),
          const SizedBox(height: 24),

          // ✅ Expanded membungkus SEMUA kondisi
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.warning,
                                color: Colors.amber,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: viewModel.fetchProducts,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        )
                      : state.products.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Tidak ada data produk.'),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: viewModel.fetchProducts,
                                    child: const Text('Refresh'),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              padding: EdgeInsets.zero,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.56,
                              ),
                              itemCount: state.products.length,
                              itemBuilder: (context, index) => ProductCard(
                                product: state.products[index],
                              ),
                            ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ShoppingCartSummaryBarWidget(),
    );
  }

//
}
