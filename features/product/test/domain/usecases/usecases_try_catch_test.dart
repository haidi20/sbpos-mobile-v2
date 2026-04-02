import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product/domain/entities/packet.entity.dart';
import 'package:product/domain/entities/packet_item.entity.dart';
import 'package:product/domain/entities/product.entity.dart';
import 'package:product/domain/repositories/packet.repository.dart';
import 'package:product/domain/repositories/product.repository.dart';
import 'package:product/domain/usecases/create_packet.usecase.dart';
import 'package:product/domain/usecases/create_product.usecase.dart';
import 'package:product/domain/usecases/delete_packet.usecase.dart';
import 'package:product/domain/usecases/delete_product.usecase.dart';
import 'package:product/domain/usecases/get_packet.usecase.dart';
import 'package:product/domain/usecases/get_packets.usecase.dart';
import 'package:product/domain/usecases/get_product.usecase.dart';
import 'package:product/domain/usecases/get_products.usecase.dart';
import 'package:product/domain/usecases/update_packet.usecase.dart';
import 'package:product/domain/usecases/update_product.usecase.dart';

class FakeProductRepository implements ProductRepository {
  FakeProductRepository({
    this.onCreateProduct,
    this.onDeleteProduct,
    this.onGetProduct,
    this.onGetProducts,
    this.onUpdateProduct,
  });

  final Future<Either<Failure, ProductEntity>> Function(
    ProductEntity product, {
    bool? isOffline,
  })? onCreateProduct;
  final Future<Either<Failure, bool>> Function(
    int id, {
    bool? isOffline,
  })? onDeleteProduct;
  final Future<Either<Failure, ProductEntity>> Function(
    int id, {
    bool? isOffline,
  })? onGetProduct;
  final Future<Either<Failure, List<ProductEntity>>> Function({
    String? query,
    bool? isOffline,
  })? onGetProducts;
  final Future<Either<Failure, ProductEntity>> Function(
    ProductEntity product, {
    bool? isOffline,
  })? onUpdateProduct;

  static const sampleProduct = ProductEntity(
    id: 1,
    idServer: 12,
    name: 'Es Teh',
    price: 12000,
    qty: 1,
  );

  @override
  Future<Either<Failure, ProductEntity>> createProduct(
    ProductEntity product, {
    bool? isOffline,
  }) {
    final handler = onCreateProduct;
    if (handler == null) {
      return Future.value(Right(product));
    }
    return handler(product, isOffline: isOffline);
  }

  @override
  Future<Either<Failure, bool>> deleteProduct(int id, {bool? isOffline}) {
    final handler = onDeleteProduct;
    if (handler == null) {
      return Future.value(const Right(true));
    }
    return handler(id, isOffline: isOffline);
  }

  @override
  Future<Either<Failure, ProductEntity>> getProduct(
    int id, {
    bool? isOffline,
  }) {
    final handler = onGetProduct;
    if (handler == null) {
      return Future.value(const Right(sampleProduct));
    }
    return handler(id, isOffline: isOffline);
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? query,
    bool? isOffline,
  }) {
    final handler = onGetProducts;
    if (handler == null) {
      return Future.value(const Right([sampleProduct]));
    }
    return handler(query: query, isOffline: isOffline);
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct(
    ProductEntity product, {
    bool? isOffline,
  }) {
    final handler = onUpdateProduct;
    if (handler == null) {
      return Future.value(Right(product));
    }
    return handler(product, isOffline: isOffline);
  }
}

class FakePacketRepository implements PacketRepository {
  FakePacketRepository({
    this.onCreatePacket,
    this.onDeletePacket,
    this.onGetPacket,
    this.onGetPackets,
    this.onUpdatePacket,
  });

  final Future<Either<Failure, PacketEntity>> Function(
    PacketEntity packet, {
    bool? isOffline,
  })? onCreatePacket;
  final Future<Either<Failure, bool>> Function(
    int id, {
    bool? isOffline,
  })? onDeletePacket;
  final Future<Either<Failure, PacketEntity>> Function(
    int id, {
    bool? isOffline,
  })? onGetPacket;
  final Future<Either<Failure, List<PacketEntity>>> Function({
    String? query,
    bool? isOffline,
  })? onGetPackets;
  final Future<Either<Failure, PacketEntity>> Function(
    PacketEntity packet, {
    bool? isOffline,
  })? onUpdatePacket;

  static final samplePacket = PacketEntity(
    id: 1,
    idServer: 21,
    name: 'Paket Hemat',
    price: 25000,
    discount: 3000,
    isActive: true,
    items: [
      PacketItemEntity(
        id: 1,
        packetId: 1,
        productId: 1,
        productName: 'Es Teh',
        qty: 1,
        subtotal: 12000,
      ),
    ],
  );

  @override
  Future<Either<Failure, PacketEntity>> createPacket(
    PacketEntity packet, {
    bool? isOffline,
  }) {
    final handler = onCreatePacket;
    if (handler == null) {
      return Future.value(Right(packet));
    }
    return handler(packet, isOffline: isOffline);
  }

  @override
  Future<Either<Failure, bool>> deletePacket(int id, {bool? isOffline}) {
    final handler = onDeletePacket;
    if (handler == null) {
      return Future.value(const Right(true));
    }
    return handler(id, isOffline: isOffline);
  }

  @override
  Future<Either<Failure, PacketEntity>> getPacket(int id, {bool? isOffline}) {
    final handler = onGetPacket;
    if (handler == null) {
      return Future.value(Right(samplePacket));
    }
    return handler(id, isOffline: isOffline);
  }

  @override
  Future<Either<Failure, List<PacketEntity>>> getPackets({
    String? query,
    bool? isOffline,
  }) {
    final handler = onGetPackets;
    if (handler == null) {
      return Future.value(Right([samplePacket]));
    }
    return handler(query: query, isOffline: isOffline);
  }

  @override
  Future<Either<Failure, PacketEntity>> updatePacket(
    PacketEntity packet, {
    bool? isOffline,
  }) {
    final handler = onUpdatePacket;
    if (handler == null) {
      return Future.value(Right(packet));
    }
    return handler(packet, isOffline: isOffline);
  }
}

Future<void> expectLeftFailure<T>(
  Future<Either<Failure, T>> Function() action,
  Matcher matcher,
) async {
  final result = await action();
  result.fold(
    (failure) => expect(failure, matcher),
    (_) => fail('Expected Left result'),
  );
}

void main() {
  final packet = FakePacketRepository.samplePacket;
  const product = FakeProductRepository.sampleProduct;

  group('Product usecases try/catch', () {
    test('CreatePacket returns repository entity on success', () async {
      final repository = FakePacketRepository();

      final result = await CreatePacket(repository)(packet);

      result.fold(
        (_) => fail('Expected Right result'),
        (value) => expect(value, packet),
      );
    });

    test('CreatePacket maps thrown Failure into Left', () async {
      const failure = ServerFailure();
      final repository = FakePacketRepository(
        onCreatePacket: (packet, {isOffline}) => Future.error(failure),
      );

      await expectLeftFailure(
        () => CreatePacket(repository)(packet),
        same(failure),
      );
    });

    test('CreatePacket maps unexpected exception into UnknownFailure',
        () async {
      final repository = FakePacketRepository(
        onCreatePacket: (packet, {isOffline}) =>
            Future.error(Exception('boom')),
      );

      await expectLeftFailure(
        () => CreatePacket(repository)(packet),
        isA<UnknownFailure>(),
      );
    });

    test('DeletePacket returns repository bool on success', () async {
      final repository = FakePacketRepository();

      final result = await DeletePacket(repository)(1);

      result.fold(
        (_) => fail('Expected Right result'),
        (value) => expect(value, isTrue),
      );
    });

    test('DeletePacket maps thrown Failure into Left', () async {
      const failure = NetworkFailure();
      final repository = FakePacketRepository(
        onDeletePacket: (id, {isOffline}) => Future.error(failure),
      );

      await expectLeftFailure(
        () => DeletePacket(repository)(1),
        same(failure),
      );
    });

    test('DeletePacket maps unexpected exception into UnknownFailure',
        () async {
      final repository = FakePacketRepository(
        onDeletePacket: (id, {isOffline}) => Future.error(Exception('boom')),
      );

      await expectLeftFailure(
        () => DeletePacket(repository)(1),
        isA<UnknownFailure>(),
      );
    });

    test('GetPackets returns repository list on success', () async {
      final repository = FakePacketRepository();

      final result = await GetPackets(repository)();

      result.fold(
        (_) => fail('Expected Right result'),
        (value) => expect(value, [packet]),
      );
    });

    test('GetPackets maps thrown Failure into Left', () async {
      const failure = ServerFailure();
      final repository = FakePacketRepository(
        onGetPackets: ({query, isOffline}) => Future.error(failure),
      );

      await expectLeftFailure(
        () => GetPackets(repository)(),
        same(failure),
      );
    });

    test('GetPackets maps unexpected exception into UnknownFailure', () async {
      final repository = FakePacketRepository(
        onGetPackets: ({query, isOffline}) => Future.error(Exception('boom')),
      );

      await expectLeftFailure(
        () => GetPackets(repository)(),
        isA<UnknownFailure>(),
      );
    });

    test('GetProduct returns repository entity on success', () async {
      final repository = FakeProductRepository();

      final result = await GetProduct(repository)(1);

      result.fold(
        (_) => fail('Expected Right result'),
        (value) => expect(value, product),
      );
    });

    test('GetProduct maps thrown Failure into Left', () async {
      const failure = LocalValidation('id produk kosong');
      final repository = FakeProductRepository(
        onGetProduct: (id, {isOffline}) => Future.error(failure),
      );

      await expectLeftFailure(
        () => GetProduct(repository)(1),
        same(failure),
      );
    });

    test('GetProduct maps unexpected exception into UnknownFailure', () async {
      final repository = FakeProductRepository(
        onGetProduct: (id, {isOffline}) => Future.error(Exception('boom')),
      );

      await expectLeftFailure(
        () => GetProduct(repository)(1),
        isA<UnknownFailure>(),
      );
    });

    test('UpdateProduct returns repository entity on success', () async {
      final repository = FakeProductRepository();

      final result = await UpdateProduct(repository)(product);

      result.fold(
        (_) => fail('Expected Right result'),
        (value) => expect(value, product),
      );
    });

    test('UpdateProduct maps thrown Failure into Left', () async {
      const failure = ServerFailure();
      final repository = FakeProductRepository(
        onUpdateProduct: (product, {isOffline}) => Future.error(failure),
      );

      await expectLeftFailure(
        () => UpdateProduct(repository)(product),
        same(failure),
      );
    });

    test('UpdateProduct maps unexpected exception into UnknownFailure',
        () async {
      final repository = FakeProductRepository(
        onUpdateProduct: (product, {isOffline}) =>
            Future.error(Exception('boom')),
      );

      await expectLeftFailure(
        () => UpdateProduct(repository)(product),
        isA<UnknownFailure>(),
      );
    });

    test('CreateProduct maps thrown Failure into Left', () async {
      const failure = NetworkFailure();
      final repository = FakeProductRepository(
        onCreateProduct: (product, {isOffline}) => Future.error(failure),
      );

      await expectLeftFailure(
        () => CreateProduct(repository)(product),
        same(failure),
      );
    });

    test('CreateProduct maps unexpected exception into UnknownFailure',
        () async {
      final repository = FakeProductRepository(
        onCreateProduct: (product, {isOffline}) =>
            Future.error(Exception('boom')),
      );

      await expectLeftFailure(
        () => CreateProduct(repository)(product),
        isA<UnknownFailure>(),
      );
    });

    test('DeleteProduct maps thrown Failure into Left', () async {
      const failure = ServerFailure();
      final repository = FakeProductRepository(
        onDeleteProduct: (id, {isOffline}) => Future.error(failure),
      );

      await expectLeftFailure(
        () => DeleteProduct(repository)(1),
        same(failure),
      );
    });

    test('DeleteProduct maps unexpected exception into UnknownFailure',
        () async {
      final repository = FakeProductRepository(
        onDeleteProduct: (id, {isOffline}) => Future.error(Exception('boom')),
      );

      await expectLeftFailure(
        () => DeleteProduct(repository)(1),
        isA<UnknownFailure>(),
      );
    });

    test('GetPacket maps thrown Failure into Left', () async {
      const failure = LocalValidation('packet tidak valid');
      final repository = FakePacketRepository(
        onGetPacket: (id, {isOffline}) => Future.error(failure),
      );

      await expectLeftFailure(
        () => GetPacket(repository)(1),
        same(failure),
      );
    });

    test('GetPacket maps unexpected exception into UnknownFailure', () async {
      final repository = FakePacketRepository(
        onGetPacket: (id, {isOffline}) => Future.error(Exception('boom')),
      );

      await expectLeftFailure(
        () => GetPacket(repository)(1),
        isA<UnknownFailure>(),
      );
    });

    test('GetProducts maps thrown Failure into Left', () async {
      const failure = ServerFailure();
      final repository = FakeProductRepository(
        onGetProducts: ({query, isOffline}) => Future.error(failure),
      );

      await expectLeftFailure(
        () => GetProducts(repository)(),
        same(failure),
      );
    });

    test('GetProducts maps unexpected exception into UnknownFailure', () async {
      final repository = FakeProductRepository(
        onGetProducts: ({query, isOffline}) => Future.error(Exception('boom')),
      );

      await expectLeftFailure(
        () => GetProducts(repository)(),
        isA<UnknownFailure>(),
      );
    });

    test('UpdatePacket maps thrown Failure into Left', () async {
      const failure = NetworkFailure();
      final repository = FakePacketRepository(
        onUpdatePacket: (packet, {isOffline}) => Future.error(failure),
      );

      await expectLeftFailure(
        () => UpdatePacket(repository)(packet),
        same(failure),
      );
    });

    test('UpdatePacket maps unexpected exception into UnknownFailure',
        () async {
      final repository = FakePacketRepository(
        onUpdatePacket: (packet, {isOffline}) =>
            Future.error(Exception('boom')),
      );

      await expectLeftFailure(
        () => UpdatePacket(repository)(packet),
        isA<UnknownFailure>(),
      );
    });
  });
}
