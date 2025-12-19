import 'package:core/core.dart';

class DetailInfoCard extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;
  final Widget? valueWidget;

  const DetailInfoCard({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.grey.shade400),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        valueWidget != null
            ? DefaultTextStyle.merge(
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: valueWidget!,
              )
            : Text(
                value ?? '-',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
      ],
    );
  }
}
