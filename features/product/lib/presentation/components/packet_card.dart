// ignore_for_file: prefer_const_constructors

import 'package:core/core.dart';
import 'package:product/domain/entities/packet.entity.dart';

class PacketCard extends StatelessWidget {
  final PacketEntity packet;
  final VoidCallback onTap;

  const PacketCard({super.key, required this.packet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Container(
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: Icon(Icons.widgets, size: 32, color: Colors.grey),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.sbBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.label_important,
                              size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Paket',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              packet.name ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatRupiah((packet.price ?? 0).toDouble()),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.sbOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
