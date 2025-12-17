import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/domain/entities/packet_item.entity.dart';

final List<PacketEntity> initialPackets = [
  PacketEntity(
    id: 1,
    name: 'Paket Sarapan',
    price: 25000,
    items: [
      // packetId akan diatur oleh DB saat dimasukkan secara lokal
      PacketItemEntity(packetId: 0, productId: 1, qty: 1),
      PacketItemEntity(packetId: 0, productId: 3, qty: 1),
    ],
  ),
  PacketEntity(
    id: 2,
    name: 'Paket Kopi & Croissant',
    price: 43000,
    items: [
      PacketItemEntity(packetId: 0, productId: 1, qty: 1),
      PacketItemEntity(packetId: 0, productId: 6, qty: 1),
    ],
  ),
  PacketEntity(
    id: 3,
    name: 'Paket Hemat Ayam Goreng',
    price: 35000,
    items: [
      PacketItemEntity(packetId: 0, productId: 11, qty: 1), // Ayam Goreng
      PacketItemEntity(packetId: 0, productId: 5, qty: 1), // Es Teh Manis
    ],
  ),
];
