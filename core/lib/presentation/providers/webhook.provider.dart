import 'package:core/core.dart';
import 'package:core/data/repositories/webhook_repository_impl.dart';
import 'package:core/data/repositories/fake_webhook_repository.dart';
import 'package:core/domain/repositories/webhook_repository.dart';
import 'package:core/presentation/view_models/webhook.vm.dart';

final webhookRepositoryProvider = Provider<WebhookRepository>((ref) {
  // Gunakan FakeWebhookRepository jika dalam mode simulasi
  const isSimulation = bool.fromEnvironment('WEBHOOK_SIMULATION', defaultValue: false);
  if (isSimulation) return FakeWebhookRepository();
  return WebhookRepositoryImpl();
});

final fakeWebhookRepositoryProvider = Provider<WebhookRepository>((ref) {
  return FakeWebhookRepository();
});

final webhookViewModelProvider = StateNotifierProvider<WebhookViewModel, WebhookState>((ref) {
  final repository = ref.watch(webhookRepositoryProvider);
  return WebhookViewModel(repository);
});
