enum AppTab { dashboard, orders }

class DashboardState {
  final bool isLoading;
  final String? error;
  final AppTab activeTab;

  DashboardState({
    this.error,
    this.isLoading = false,
    this.activeTab = AppTab.dashboard,
  });

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    AppTab? activeTab,
  }) {
    return DashboardState(
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}
