class OperationalCheckEntity {
  final bool isAllowed;
  final String message;

  const OperationalCheckEntity({
    required this.isAllowed,
    this.message = '',
  });
}
