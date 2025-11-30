import 'package:core/core.dart';
import 'package:dashboard/presentation/component/hero_card.dart';
import 'package:dashboard/presentation/widgets/quick_action.dart';
import 'package:dashboard/presentation/widgets/analytic_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  final double distance = 24.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            SizedBox(height: distance),
            HeroCard(),
            SizedBox(height: distance),
            QuickAction(),
            SizedBox(height: distance),
            AnalyticChart(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
