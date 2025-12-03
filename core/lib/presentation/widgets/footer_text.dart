import 'package:flutter/material.dart';

class FooterText extends StatelessWidget {
  const FooterText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'SB POS App v2.0 • Build 20260101',
      style: TextStyle(
        color: Colors.grey,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
