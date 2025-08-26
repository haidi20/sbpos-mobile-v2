import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };

  @override
  TargetPlatform get platform => defaultTargetPlatform;

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    // Opsional: Tambahkan scrollbar jika diinginkan
    return child;
  }
}
