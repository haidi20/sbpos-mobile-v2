import 'package:core/core.dart';
import 'package:transaction/data/models/close_cashier_request.model.dart';
import 'package:transaction/data/models/shift.model.dart';
import 'package:transaction/data/responses/close_cashier.response.dart';
import 'package:transaction/data/responses/close_cashier_status.response.dart';
import 'package:transaction/data/models/open_cashier_request.model.dart';
import 'package:transaction/data/responses/open_cashier.response.dart';
import 'package:transaction/data/responses/shift_status.response.dart';

class ShiftRemoteDataSource with BaseErrorHelper {
  final String host;
  final String api;
  final ApiHelper _apiHelper;
  final _logger = Logger('ShiftRemoteDataSource');
  final bool isShowLog = false;

  ShiftRemoteDataSource({
    String? host,
    String? api,
    ApiHelper? apiHelper,
  })  : host = host ?? HOST,
        api = api ?? API,
        _apiHelper = apiHelper ?? ApiHelper();

  Future<ShiftStatusResponseModel> getShiftStatus() async {
    try {
      final response = await handleApiResponse(
        () async => _apiHelper.get(
          url: '$host/$api/shift/check',
        ),
      );
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return ShiftStatusResponseModel.fromJson(decoded);
    } catch (e, s) {
      if (isShowLog) _logger.severe('getShiftStatus error: $e', e, s);
      rethrow;
    }
  }

  Future<ShiftModel?> getLatestShift() async {
    try {
      final response = await handleApiResponse(
        () async => _apiHelper.get(
          url: '$host/$api/shift/latest',
        ),
      );
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'];

      if (data is Map<String, dynamic>) {
        final shiftJson = data['shift'];
        if (shiftJson is Map<String, dynamic>) {
          return ShiftModel.fromJson(shiftJson);
        }
        return ShiftModel.fromJson(data);
      }

      if (data is List && data.isNotEmpty && data.first is Map<String, dynamic>) {
        return ShiftModel.fromJson(data.first as Map<String, dynamic>);
      }

      return null;
    } catch (e, s) {
      if (isShowLog) _logger.severe('getLatestShift error: $e', e, s);
      rethrow;
    }
  }

  Future<OpenCashierResponseModel> openCashier(
    OpenCashierRequestModel request,
  ) async {
    try {
      final response = await handleApiResponse(
        () async => _apiHelper.post(
          url: '$host/$api/shift/open',
          body: request.toJson(),
        ),
      );
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return OpenCashierResponseModel.fromJson(decoded);
    } catch (e, s) {
      if (isShowLog) _logger.severe('openCashier error: $e', e, s);
      rethrow;
    }
  }

  Future<CloseCashierStatusResponseModel> getCloseCashierStatus() async {
    try {
      final response = await handleApiResponse(
        () async => _apiHelper.get(
          url: '$host/$api/shift/closable',
        ),
      );
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return CloseCashierStatusResponseModel.fromJson(decoded);
    } catch (e, s) {
      if (isShowLog) {
        _logger.severe('getCloseCashierStatus error: $e', e, s);
      }
      rethrow;
    }
  }

  Future<CloseCashierResponseModel> closeCashier(
    CloseCashierRequestModel request,
  ) async {
    try {
      final response = await handleApiResponse(
        () async => _apiHelper.post(
          url: '$host/$api/close_cashier/close',
          body: request.toJson(),
        ),
      );
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return CloseCashierResponseModel.fromJson(decoded);
    } catch (e, s) {
      if (isShowLog) _logger.severe('closeCashier error: $e', e, s);
      rethrow;
    }
  }
}
