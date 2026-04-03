import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/domain/facades/printer.facade.dart';

final printerFacadeProvider = Provider<PrinterFacade>(
  (ref) => throw UnimplementedError(
    'printerFacadeProvider must be overridden in the app composition root.',
  ),
);
