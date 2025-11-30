import 'package:core/core.dart';

class SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subLabel;
  final Color? iconColor;
  final VoidCallback onTap;

  const SettingItem({
    required this.icon,
    required this.label,
    this.subLabel,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? Colors.grey.shade600;

    return InkWell(
      onTap: onTap,
      // Handle rounded corners logic implicitly via parent clipping or explicit definition if it's first/last item
      // Simplified here by relying on parent container clipping
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: effectiveIconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (subLabel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subLabel!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
