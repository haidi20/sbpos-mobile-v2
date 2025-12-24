import 'package:core/core.dart';
import 'package:product/data/models/packet.model.dart';
import 'package:product/data/dummies/packet.dummy.dart';
import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/data/models/packet_item.model.dart';
import 'package:product/domain/repositories/packet.repository.dart';
import 'package:product/data/datasources/packet_local.datasource.dart';

class PacketRepositoryImpl implements PacketRepository {
  final PacketLocalDataSource local;

  static final Logger _logger = Logger('PacketRepositoryImpl');

  PacketRepositoryImpl({required this.local});

  Future<List<PacketEntity>> _getLocalEntities() async {
    final localResp = await local.getPackets();
    return localResp.map((m) => m.toEntity()).toList();
  }

  Future<void> _ensureSeededLocal() async {
    try {
      _logger.info('[WEB] Packet seeding: checking local DB');
      final existing = await local.getPackets(limit: 1);
      if (existing.isEmpty) {
        int success = 0;
        for (final p in initialPackets) {
          final model = PacketModel.fromEntity(p);
          try {
            final res = await local.upsertPacket(model,
                items: model.items?.map((it) => it.toInsertDbLocal()).toList());
            if (res != null) {
              success++;
              _logger
                  .info('[WEB] Seeded packet: id=${res.id} name=${res.name}');
            } else {
              _logger.warning(
                  '[WEB] Packet seed returned null for packet name=${p.name}');
            }
          } catch (e, st) {
            _logger.warning('[WEB] Gagal insert seed packet: ${p.name}', e, st);
          }
        }
        if (success == 0) {
          _logger
              .severe('[WEB] Packet seeding failed: nothing saved to local DB');
        } else {
          _logger.info('[WEB] Packet seeding success: $success packets saved');
        }
      } else {
        _logger.info(
            '[WEB] Packet local DB already seeded (${existing.length} packets)');
      }
    } catch (e, st) {
      _logger.severe('[WEB] Gagal cek/seed packet lokal', e, st);
    }
  }

  @override
  Future<Either<Failure, List<PacketEntity>>> getPackets(
      {String? query, bool? isOffline}) async {
    try {
      var local = await _getLocalEntities();
      if (local.isEmpty) {
        await _ensureSeededLocal();
        local = await _getLocalEntities();
      }
      return Right(local);
    } catch (e, st) {
      _logger.severe('Error getPackets', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, PacketEntity>> getPacket(int id,
      {bool? isOffline}) async {
    try {
      final model = await local.getPacketById(id);
      if (model == null) return const Left(UnknownFailure());
      return Right(model.toEntity());
    } catch (e, st) {
      _logger.severe('Error getPacket', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, PacketEntity>> createPacket(PacketEntity packet,
      {bool? isOffline}) async {
    try {
      final model = PacketModel.fromEntity(packet);
      final inserted = await local.insertPacket(model,
          items: packet.items
              ?.map((it) => PacketItemModel(
                    productId: it.productId,
                    qty: it.qty,
                    subtotal: it.subtotal,
                    discount: it.discount,
                  ).toInsertDbLocal())
              .toList());
      if (inserted == null) return const Left(UnknownFailure());
      return Right(inserted.toEntity());
    } catch (e, st) {
      _logger.severe('Error createPacket', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, PacketEntity>> updatePacket(PacketEntity packet,
      {bool? isOffline}) async {
    try {
      final model = PacketModel.fromEntity(packet);
      final map = model.toInsertDbLocal()..['id'] = packet.id;
      final items = packet.items
          ?.map((it) => PacketItemModel(
                id: it.id,
                packetId: it.packetId,
                productId: it.productId,
                qty: it.qty,
                subtotal: it.subtotal,
                discount: it.discount,
              ).toInsertDbLocal())
          .toList();
      final updated = await local.updatePacket(map, items: items);
      if (updated == 0) return const Left(UnknownFailure());
      final newModel = await local.getPacketById(packet.id ?? 0);
      if (newModel == null) return const Left(UnknownFailure());
      return Right(newModel.toEntity());
    } catch (e, st) {
      _logger.severe('Error updatePacket', e, st);
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deletePacket(int id, {bool? isOffline}) async {
    try {
      await local.deletePacket(id);
      return const Right(true);
    } catch (e, st) {
      _logger.severe('Error deletePacket', e, st);
      return const Left(UnknownFailure());
    }
  }
}
