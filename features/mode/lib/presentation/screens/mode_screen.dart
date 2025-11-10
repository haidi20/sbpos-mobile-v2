// mode/presentation/screens/mode_screen.dart
import 'package:core/core.dart';
import 'package:core/presentation/controllers/auth_controller.dart';
import 'package:mode/data/data/order_type_data.dart';

class ModeScreen extends ConsumerStatefulWidget {
  final int? appId; // 🔼 Tambahkan parameter appId (opsional)

  const ModeScreen({super.key, this.appId});

  @override
  ConsumerState<ModeScreen> createState() => _ModeScreenState();
}

class _ModeScreenState extends ConsumerState<ModeScreen> {
  late AuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AuthController(ref, context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final state = ref.watch(authViewModelProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'SB POS Samarinda',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            context.goNamed(AppRoutes.warehouse);
          },
        ),
        backgroundColor: AppSetting.primaryColor,
        automaticallyImplyLeading: false, // Hilangkan tombol back
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.language, color: Colors.white),
          //   onPressed: () {},
          // ),
          IconButton(
            icon: const Icon(
              Icons.login,
              color: Colors.white,
            ),
            onPressed: () => _controller.onLogout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeaderShop(),

            // How to use ESB Order
            const Center(
              child: Text(
                'Cara pesan pada aplikasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),

            // Step-by-step icons
            _buildStepByStepIcons(),

            const SizedBox(height: 50),

            // Question
            const Text(
              'Pilih jenis pesanan :',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            _buildOption(),

            // Tampilkan App ID (opsional, untuk debugging atau info)
            if (widget.appId != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Text(
                    'Outlet ID: ${widget.appId}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),

            // Footer
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Powered by Utama Web',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    )),
                // Image.asset('assets/images/esb_logo.png',
                //     width: 60), // Ganti jika ada file
                // Jika tidak ada file, gunakan Text atau Icon
                // const Text('ESB', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderShop() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppSetting.primaryColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'GB',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Ayam Goreng Dan Bebek Goreng Bengkuring',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          // const Icon(Icons.arrow_forward_ios,
          //     size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStepByStepIcons() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 40,
              color: Colors.pink,
            ),
            SizedBox(height: 8),
            Text(
              'Order',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          '→',
          style: TextStyle(
            fontSize: 30,
          ),
        ),
        Column(
          children: [
            Icon(
              Icons.credit_card,
              size: 40,
              color: Colors.blue,
            ),
            SizedBox(height: 8),
            Text('Pay', style: TextStyle(fontSize: 14)),
          ],
        ),
        Text('→', style: TextStyle(fontSize: 30)),
        Column(
          children: [
            Icon(Icons.local_dining, size: 40, color: Colors.orange),
            SizedBox(height: 8),
            Text('Eat', style: TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildOption() {
    return ListView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // jika di dalam scrollable lain
      itemCount: orderTypeData.length,
      itemBuilder: (context, index) {
        final orderType = orderTypeData[index];
        return _buildOptionButton(
          text: orderType.name,
          modeId: orderType.id ?? 1,
          icon: orderType.icon ?? "restaurant",
          context: context,
        );
      },
    );
  }

  Widget _buildOptionButton({
    required String text,
    required int modeId,
    required String icon, // tetap String — sesuai kebutuhan Anda
    required BuildContext context,
  }) {
    return OutlinedButton(
      onPressed: () {
        final int getAppId = widget.appId ?? 1;
        GoRouter.of(context).go('/app/$getAppId/order', extra: {
          'mode_id': modeId,
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        side: BorderSide(
          color: Colors.grey[300]!,
          width: 1.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 25,
        ),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        animationDuration: const Duration(milliseconds: 150),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            getIconData(icon), // ✅ helper untuk konversi string → IconData
            size: 20,
            color: Colors.black,
          ),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }
}
