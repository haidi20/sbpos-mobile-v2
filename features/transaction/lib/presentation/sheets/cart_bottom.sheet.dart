import 'package:core/core.dart';
import 'package:transaction/presentation/screens/cart.screen.dart';
import 'package:transaction/presentation/screens/cart_payment.screen.dart';
import 'package:transaction/presentation/providers/transaction.provider.dart';
import 'package:transaction/presentation/controllers/cart_screen.controller.dart';
import 'package:transaction/presentation/view_models/transaction_pos/transaction_pos.state.dart';

class CartBottomSheet extends ConsumerStatefulWidget {
  const CartBottomSheet({super.key});

  @override
  ConsumerState<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends ConsumerState<CartBottomSheet> {
  late final CartScreenController _controller;
  ScrollController? _sheetScrollController;
  bool _listenerRegistered = false;

  @override
  void initState() {
    super.initState();
    _controller = CartScreenController(ref, context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Daftarkan listener saat build (sekali). Riverpod mewajibkan `ref.listen`
    // dipanggil saat build untuk ConsumerState.
    if (!_listenerRegistered) {
      _listenerRegistered = true;
      ref.listen<TransactionPosState>(transactionPosViewModelProvider,
          (previous, next) {
        _controller.onStateChanged(previous, next);

        // Gulir ke atas saat tipe tampilan cart berubah.
        if (previous?.typeCart != next.typeCart &&
            _sheetScrollController != null) {
          try {
            _sheetScrollController!.animateTo(
              0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          } catch (_) {
            // Abaikan jika controller belum terpasang.
          }
        }
      });
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Tidak melakukan apa-apa: gunakan onTapDown untuk menentukan apakah tap di luar
        unawaited(_controller.setActiveItemNoteId(null));
      },
      // Menghapus pembersihan global onTapDown untuk mencegah fokus hilang saat mengetik.
      // Jangan bersihkan saat pan; hindari kehilangan fokus saat scroll
      child: DraggableScrollableSheet(
        controller: _controller.sheetController,
        expand: false,
        // Buka hampir penuh saat diakses. Izinkan expand penuh agar konten
        // tidak terpotong saat daftar atau footer tinggi.
        minChildSize: 0.35,
        // Mulai dalam keadaan penuh agar sheet tampil layar penuh.
        // Pegangan (grab handle) akan muncul saat pengguna menarik sheet
        // dan `sheetSize` turun di bawah ambang visibilitas.
        initialChildSize: 1.0,
        // Izinkan penuh saat di-drag agar tidak memotong konten.
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          // Ambil scroll controller internal dari sheet agar listener
          // yang didaftarkan di `initState` dapat menganimasikannya saat diperlukan.
          _sheetScrollController = scrollController;

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            // Membuat sheet menempati tinggi yang tersedia dan hanya
            // konten di dalamnya (hasil Builder) yang bisa discroll.
            // Grab handle (area atas) tetap fixed sementara konten di bawahnya bisa discroll.
            // Bungkus Column dengan AnimatedSize agar perubahan tinggi konten
            // (saat footer muncul/hilang) dianimasikan dengan halus.
            child: SizedBox.expand(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tampilkan grab handle hanya saat sheet tidak penuh.
                    ValueListenableBuilder<double>(
                      valueListenable: _controller.sheetSize,
                      builder: (_, size, __) {
                        if (size <= 0.95) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 15, left: 12, right: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: 48,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: AppColors.gray300,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const SizedBox(height: 16);
                        }
                      },
                    ),

                    Builder(
                      builder: (context) {
                        final state =
                            ref.watch(transactionPosViewModelProvider);

                        // Area konten harus fleksibel mengisi sisa ruang
                        // antara grab handle dan footer. Gunakan Expanded
                        // agar footer (jika muncul) otomatis mengurangi tinggi konten
                        // dan mencegah overflow.
                        if (state.typeCart == ETypeCart.main) {
                          return Expanded(
                            child: CartScreen(
                              outerScrollController: scrollController,
                            ),
                          );
                        }

                        if (state.typeCart == ETypeCart.confirm) {
                          return Expanded(
                            child: CartScreen(
                              readOnly: true,
                              outerScrollController: scrollController,
                            ),
                          );
                        }

                        return Expanded(
                          child: CartPaymentScreen(
                            outerScrollController: scrollController,
                          ),
                        );
                      },
                    ),
                    // Footer tetap (fixed) yang muncul ketika bukan mode utama cart.
                    // Tombol ini mengembalikan tampilan ke mode `main`.
                    Builder(
                      builder: (context) {
                        final state =
                            ref.watch(transactionPosViewModelProvider);
                        if (state.typeCart != ETypeCart.main) {
                          final vm = ref
                              .read(transactionPosViewModelProvider.notifier);
                          return SafeArea(
                            top: false,
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 12, 16, 16),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  top: BorderSide(
                                    color: AppColors.gray100,
                                  ),
                                ),
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final target =
                                        state.typeCart == ETypeCart.checkout
                                            ? ETypeCart.confirm
                                            : ETypeCart.main;
                                    vm.setTypeCart(target);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.sbBlue,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                          color: AppColors.sbBlue),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Kembali',
                                    style: TextStyle(
                                      color: AppColors.sbBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
