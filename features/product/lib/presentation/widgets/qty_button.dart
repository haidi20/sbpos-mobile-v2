import 'package:flutter/material.dart';

class QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isBlue;
  final Color? color;

  const QtyButton(
      {super.key,
      required this.icon,
      required this.onTap,
      this.isBlue = false,
      this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isBlue ? color : Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1))
          ],
        ),
        child: Icon(icon,
            size: 16, color: isBlue ? Colors.white : Colors.grey.shade600),
      ),
    );
  }
}
