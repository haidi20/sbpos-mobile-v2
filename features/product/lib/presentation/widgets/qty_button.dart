import 'package:core/core.dart';

class QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isBlue;
  final Color? color;

  const QtyBtn(
      {required this.icon,
      required this.onTap,
      this.isBlue = false,
      this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isBlue ? color : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isBlue
              ? [BoxShadow(color: color!.withOpacity(0.3), blurRadius: 4)]
              : [BoxShadow(color: Colors.grey.shade200, blurRadius: 2)],
        ),
        child: Icon(icon,
            size: 16, color: isBlue ? Colors.white : Colors.grey.shade600),
      ),
    );
  }
}
