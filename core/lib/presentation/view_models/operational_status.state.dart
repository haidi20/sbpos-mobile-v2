class OperationalStatusState {
  final bool isChecking;
  final bool isServiceAvailable;
  final bool isSubscriptionActive;
  final String errorMessage;
  final String blockTitle;
  final String blockMessage;

  const OperationalStatusState({
    this.isChecking = false,
    this.isServiceAvailable = true,
    this.isSubscriptionActive = true,
    this.errorMessage = '',
    this.blockTitle = '',
    this.blockMessage = '',
  });

  bool get isBlocked => !isServiceAvailable || !isSubscriptionActive;

  OperationalStatusState copyWith({
    bool? isChecking,
    bool? isServiceAvailable,
    bool? isSubscriptionActive,
    String? errorMessage,
    String? blockTitle,
    String? blockMessage,
  }) {
    return OperationalStatusState(
      isChecking: isChecking ?? this.isChecking,
      isServiceAvailable: isServiceAvailable ?? this.isServiceAvailable,
      isSubscriptionActive: isSubscriptionActive ?? this.isSubscriptionActive,
      errorMessage: errorMessage ?? this.errorMessage,
      blockTitle: blockTitle ?? this.blockTitle,
      blockMessage: blockMessage ?? this.blockMessage,
    );
  }
}
