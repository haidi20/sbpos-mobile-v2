// lib/widgets/landing_page_widgets.dart
import 'package:flutter/material.dart';

// Logo Section
class LogoSectionWidget extends StatelessWidget {
  const LogoSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.arrow_back, color: Colors.white),
                Text(
                  'SB\nPOS',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
                Row(
                  children: [
                    Icon(Icons.search, color: Colors.white),
                    SizedBox(width: 10),
                    Icon(Icons.menu, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Resto Title Section
class TitleRestoSectionWidget extends StatelessWidget {
  const TitleRestoSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12,
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const ListTile(
          title: Text(
            'ayam dan bebek goreng bengkuring',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('Open today, 08:00-00:00'),
          trailing: Icon(Icons.arrow_forward),
        ),
      ),
    );
  }
}

// Order Type Dropdown Section
class OrderTypeDropdownWidget extends StatelessWidget {
  final void Function(String?)? onOrderTypeChanged;

  const OrderTypeDropdownWidget({
    super.key,
    this.onOrderTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tipe Pesanan',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  DropdownButton<String>(
                    value: 'pickup',
                    items: const [
                      DropdownMenuItem(
                        value: 'pickup',
                        child: Text('Ambil di Tempat'),
                      ),
                      DropdownMenuItem(
                        value: 'delivery',
                        child: Text('Antar'),
                      ),
                    ],
                    onChanged: onOrderTypeChanged,
                    underline: Container(),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Pickup Now
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const ListTile(
              leading: Icon(Icons.local_shipping, color: Colors.grey),
              title: Text('Pickup Now'),
            ),
          ),
        ),
      ],
    );
  }
}

// Paket Section
class PaketSectionWidget extends StatelessWidget {
  const PaketSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PAKET',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'PAKET FEST TAKE AWAY',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
