// Riverpod provider for landing_page_menuViewModel
import 'package:core/core.dart';
import 'package:landing_page_menu/presentation/view_models/landing_page_menu.vm.dart';
import 'package:product/presentation/providers/product.provider.dart';

final landingPageMenuViewModelProvider =
    StateNotifierProvider<LandingPageMenuViewModel, LandingPageMenuState>(
        (ref) {
  final getProducts = ref.watch(productGetProductsProvider);
  return LandingPageMenuViewModel(getProducts);
});
