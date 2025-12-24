import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/domain/entities/product.entity.dart';

/// Combined content model used by the UI: either a `PacketEntity` or a `ProductEntity`.
class ContentItemEntity {
  final PacketEntity? packet;
  final ProductEntity? product;

  const ContentItemEntity._({this.packet, this.product});

  factory ContentItemEntity.packet(PacketEntity p) =>
      ContentItemEntity._(packet: p);
  factory ContentItemEntity.product(ProductEntity p) =>
      ContentItemEntity._(product: p);

  bool get isPacket => packet != null;
  bool get isProduct => product != null;
}
