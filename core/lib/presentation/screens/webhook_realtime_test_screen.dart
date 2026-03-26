import 'package:core/core.dart';

class WebhookRealtimeTestScreen extends HookConsumerWidget {
  const WebhookRealtimeTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final webhookState = ref.watch(webhookViewModelProvider);
    final webhookVM = ref.read(webhookViewModelProvider.notifier);

    // Auto-connect to simulation if disconnected
    useEffect(() {
      if (!webhookState.isConnected) {
        webhookVM.connect("ws://simulation.pos");
      }
      return () => webhookVM.disconnect();
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-time Order Monitoring'),
        actions: [
          if (webhookState.isReconnecting)
            const Center(child: Padding(padding: EdgeInsets.all(8.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))),
          IconButton(
            icon: Icon(webhookState.isConnected ? Icons.cloud_done : (webhookState.isReconnecting ? Icons.cloud_sync : Icons.cloud_off)),
            color: webhookState.isConnected ? Colors.green : (webhookState.isReconnecting ? Colors.orange : Colors.red),
            onPressed: () {
              if (webhookState.isConnected || webhookState.isReconnecting) {
                webhookVM.disconnect();
              } else {
                webhookVM.connect("ws://simulation.pos");
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: webhookState.isReconnecting ? Colors.orange[50] : (webhookState.isConnected ? Colors.blue[50] : Colors.grey[200]),
            child: Row(
              children: [
                Icon(
                  webhookState.isReconnecting ? Icons.sync : (webhookState.isConnected ? Icons.cloud_done : Icons.cloud_off),
                  color: webhookState.isReconnecting ? Colors.orange : (webhookState.isConnected ? Colors.blue : Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    webhookState.isReconnecting
                      ? 'Koneksi terputus. Mencoba menyambung kembali...'
                      : (webhookState.isConnected 
                          ? 'Menerima data pesanan real-time dari server...'
                          : 'WebSocket Non-aktif (Menu tidak aktif)'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          if (webhookState.error != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.red[100],
              width: double.infinity,
              child: Text('Error: ${webhookState.error}', style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: webhookState.events.isEmpty
              ? const Center(child: Text('Belum ada pesanan masuk.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: webhookState.events.length,
                  itemBuilder: (context, index) {
                    final event = webhookState.events[index];
                    final isOrder = event.topic.contains('order');
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isOrder ? Colors.orange[100] : Colors.green[100],
                          child: Icon(
                            isOrder ? Icons.shopping_basket : Icons.payment,
                            color: isOrder ? Colors.orange : Colors.green,
                          ),
                        ),
                        title: Text(
                          '${event.topic.toUpperCase()} - ${event.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.data.toString()),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('HH:mm:ss').format(event.timestamp),
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Manual trigger sim jika dibutuhkan (opsional)
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
