import 'package:core/core.dart';
import 'package:product/domain/usecases/get_packets.usecase.dart';
import 'package:product/domain/usecases/get_packet.usecase.dart';
import 'package:product/domain/usecases/create_packet.usecase.dart';
import 'package:product/domain/usecases/update_packet.usecase.dart';
import 'package:product/domain/usecases/delete_packet.usecase.dart';
import 'package:product/presentation/view_models/packet_management.vm.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:product/presentation/view_models/packet_management.state.dart';
import 'package:product/presentation/providers/product_repository.provider.dart';
import 'package:product/presentation/providers/product.provider.dart'
    show productGetProductsProvider;

final packetGetPacketsProvider = Provider<GetPackets>((ref) {
  final repo = ref.watch(packetRepositoryProvider);
  return GetPackets(repo);
});

final packetCreatePacketProvider = Provider<CreatePacket>((ref) {
  final repo = ref.watch(packetRepositoryProvider);
  return CreatePacket(repo);
});

final packetGetPacketProvider = Provider<GetPacket>((ref) {
  final repo = ref.watch(packetRepositoryProvider);
  return GetPacket(repo);
});

final packetUpdatePacketProvider = Provider<UpdatePacket>((ref) {
  final repo = ref.watch(packetRepositoryProvider);
  return UpdatePacket(repo);
});

final packetDeletePacketProvider = Provider<DeletePacket>((ref) {
  final repo = ref.watch(packetRepositoryProvider);
  return DeletePacket(repo);
});

final packetManagementViewModelProvider =
    StateNotifierProvider<PacketManagementViewModel, PacketManagementState>(
        (ref) {
  final get = ref.watch(packetGetPacketsProvider);
  final getProducts = ref.watch(productGetProductsProvider);
  final create = ref.watch(packetCreatePacketProvider);
  final update = ref.watch(packetUpdatePacketProvider);
  final delete = ref.watch(packetDeletePacketProvider);
  Timer? packetRefreshDebounce;

  Future<void> onAfterCrudWrapper() async {
    packetRefreshDebounce?.cancel();
    packetRefreshDebounce = Timer(const Duration(milliseconds: 300), () {
      final f =
          ref.read(transactionPosViewModelProvider.notifier).refreshPackets();
      unawaited(f.catchError((e, st) =>
          Logger('PacketProvider').warning('refreshPackets failed', e, st)));
    });
    return Future.value();
  }

  return PacketManagementViewModel(
    getPacketsUsecase: get,
    getProductsUsecase: getProducts,
    createPacketUsecase: create,
    updatePacketUsecase: update,
    deletePacketUsecase: delete,
    onAfterCrud: onAfterCrudWrapper,
  );
});
