import 'package:core/core.dart';
import 'package:product/data/responses/packet.response.dart';

class PacketRemoteDataSource with BaseErrorHelper {
  final String host;
  final String api;
  final ApiHelper _apiHelper;
  final _logger = Logger('PacketRemoteDataSource');
  final bool isShowLog = false;

  PacketRemoteDataSource({String? host, String? api, ApiHelper? apiHelper})
      : host = host ?? HOST,
        api = api ?? API,
        _apiHelper = apiHelper ?? ApiHelper();

  void _logSevere(String msg, [Object? e, StackTrace? st]) {
    if (isShowLog) _logger.severe(msg, e, st);
  }

  Future<PacketResponse> fetchPackets({Map<String, dynamic>? params}) async {
    try {
      final response = await handleApiResponse(() async =>
          _apiHelper.get(url: '$host/$api/packets', params: params ?? {}));
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return PacketResponse.fromJson(decoded);
    } catch (e, st) {
      _logSevere('Error fetchPackets', e, st);
      rethrow;
    }
  }

  Future<PacketResponse> postPacket(Map<String, dynamic> payload) async {
    try {
      final response = await handleApiResponse(() async =>
          _apiHelper.post(url: '$host/$api/packets', body: payload));
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return PacketResponse.fromJson(decoded);
    } catch (e, st) {
      _logSevere('Error postPacket', e, st);
      rethrow;
    }
  }

  Future<PacketResponse> getPacket(int id) async {
    try {
      final response = await handleApiResponse(
          () async => _apiHelper.get(url: '$host/$api/packets/$id'));
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return PacketResponse.fromJson(decoded);
    } catch (e, st) {
      _logSevere('Error getPacket', e, st);
      rethrow;
    }
  }

  Future<PacketResponse> updatePacket(
      int id, Map<String, dynamic> payload) async {
    try {
      final response = await handleApiResponse(() async =>
          _apiHelper.put(url: '$host/$api/packets/$id', body: payload));
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return PacketResponse.fromJson(decoded);
    } catch (e, st) {
      _logSevere('Error updatePacket', e, st);
      rethrow;
    }
  }

  Future<PacketResponse> deletePacket(int id) async {
    try {
      final response = await handleApiResponse(
          () async => _apiHelper.delete(url: '$host/$api/packets/$id'));
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return PacketResponse.fromJson(decoded);
    } catch (e, st) {
      _logSevere('Error deletePacket', e, st);
      rethrow;
    }
  }
}
