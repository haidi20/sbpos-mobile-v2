import 'package:core/core.dart';

class SummaryRowCard extends StatelessWidget {
  final String label;
  final String value;

  const SummaryRowCard({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
