import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/outlet.provider.dart';
import '../widgets/outlet.card.dart';

class OutletScreen extends ConsumerWidget {
  const OutletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(outletViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Outlets')),
      body: state.outlets.isEmpty
          ? const Center(child: Text('Tidak ada data outlet.'))
          : ListView.builder(
              itemCount: state.outlets.length,
              itemBuilder: (context, index) {
                final outlet = state.outlets[index];
                return OutletCard(
                  outlet: outlet,
                  onTap: () {},
                );
              },
            ),
    );
  }
}
