import 'package:core/core.dart';
import 'package:product/presentation/view_models/product_pos.state.dart';
import 'package:product/presentation/view_models/product_pos.vm.dart';

final productPosViewModelProvider =
    StateNotifierProvider<ProductPosViewModel, ProductPosState>(
  (ref) => ProductPosViewModel(),
);
