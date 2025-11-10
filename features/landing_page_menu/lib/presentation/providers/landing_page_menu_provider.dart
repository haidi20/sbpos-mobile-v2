// Riverpod provider for landing_page_menuViewModel
import 'package:core/core.dart';
import 'package:landing_page_menu/domain/usecases/get_products.dart';
import 'package:landing_page_menu/presentation/viewmodels/landing_page_menu_viewmodel.dart';
import 'package:landing_page_menu/presentation/providers/landing_page_menu_repository_provider.dart';

final getProductsProvider = Provider<GetProducts>((ref) {
  final repo = ref.read(landingPageMenuRepositoryProvider);
  return GetProducts(repo);
});

final landingPageMenuViewModelProvider =
    StateNotifierProvider<LandingPageMenuViewModel, LandingPageMenuState>(
        (ref) {
  final getProducts = ref.watch(getProductsProvider);
  return LandingPageMenuViewModel(getProducts);
});
