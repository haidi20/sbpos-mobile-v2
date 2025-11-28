import 'package:core/core.dart';
import 'package:dashboard/presentation/widgets/quirk_button.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildHeroCard(),
            const SizedBox(height: 24),
            _buildQuickActions(
              context: context,
            ),
            const SizedBox(height: 24),
            _buildAnalyticsChart(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      // height: 220,
      height: 130,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00529C),
            Color(0xFF003B73),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00529C).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withOpacity(0.2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Saldo Hari Ini',
                          style: TextStyle(
                            color: Color(0xFFDBEAFE),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Rp 12.500.000',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.account_balance_wallet,
                          color: Colors.white),
                    ),
                  ],
                ),
                // Row(
                //   children: [
                //     Expanded(
                //       child: ElevatedButton.icon(
                //         onPressed: () {},
                //         icon: const Icon(Icons.qr_code_scanner, size: 18),
                //         label: const Text('Scan QRIS'),
                //         style: ElevatedButton.styleFrom(
                //           backgroundColor: const Color(0xFFF97316),
                //           foregroundColor: Colors.white,
                //           elevation: 0,
                //           padding: const EdgeInsets.symmetric(vertical: 12),
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(12),
                //           ),
                //         ),
                //       ),
                //     ),
                //     const SizedBox(width: 12),
                //     Expanded(
                //       child: ElevatedButton.icon(
                //         onPressed: () {},
                //         icon: const Icon(Icons.north_east, size: 18),
                //         label: const Text('Tarik Dana'),
                //         style: ElevatedButton.styleFrom(
                //           backgroundColor: Colors.white.withOpacity(0.1),
                //           foregroundColor: Colors.white,
                //           elevation: 0,
                //           padding: const EdgeInsets.symmetric(vertical: 12),
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(12),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ],
                // )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions({
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Menu Cepat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuickActionButton(
                icon: Icons.description_outlined,
                label: 'Laporan',
                iconColor: const Color(0xFF00529C),
                bgColor: const Color(0xFFEFF6FF),
                onTap: () {
                  context.pushNamed(AppRoutes.report);
                },
              ),
              QuickActionButton(
                icon: Icons.inventory_2_outlined,
                label: 'Stok',
                iconColor: const Color(0xFFF97316),
                bgColor: const Color(0xFFFFF7ED),
                onTap: () {
                  context.pushNamed(AppRoutes.inventory);
                },
              ),
              QuickActionButton(
                icon: Icons.fastfood_outlined,
                label: 'Menu',
                iconColor: const Color(0xFF16A34A),
                bgColor: const Color(0xFFF0FDF4),
                onTap: () {
                  context.pushNamed(AppRoutes.productManagement);
                },
              ),
              QuickActionButton(
                icon: Icons.settings_outlined,
                label: 'Pengaturan',
                iconColor: const Color(0xFF4B5563),
                bgColor: const Color(0xFFF3F4F6),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tren Penjualan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.trending_up, size: 14, color: Color(0xFF22C55E)),
                    SizedBox(width: 4),
                    Text(
                      '+12.5%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun'
                        ];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              days[value.toInt()],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 4500,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 4000),
                      FlSpot(1, 3000),
                      FlSpot(2, 2000),
                      FlSpot(3, 2780),
                      FlSpot(4, 1890),
                      FlSpot(5, 2390),
                      FlSpot(6, 3490),
                    ],
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00529C), Color(0xFF003B73)],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF00529C).withOpacity(0.2),
                          const Color(0xFF00529C).withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
