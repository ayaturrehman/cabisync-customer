import 'package:cabisync_customer/services/api_service.dart';
import 'package:cabisync_customer/services/booking_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _Api implements ApiService {
  final requests = <String>[];
  @override
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    requests.add('GET $path');
    return Response(
      requestOptions: RequestOptions(path: path),
      data: {
        'booking': {'id': 42, 'status': 'pending'},
      },
    );
  }

  @override
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    requests.add('POST $path');
    return Response(requestOptions: RequestOptions(path: path), data: {});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'tracking and cancellation use the backend rider booking routes',
    () async {
      final api = _Api();
      final service = BookingService(api);
      await service.getBooking(42);
      await service.getCurrentBooking();
      await service.cancelBooking(42, reason: 'Changed plans');
      expect(api.requests, [
        'GET /booking/42',
        'GET /booking/current',
        'POST /booking/42/cancel',
      ]);
    },
  );
}
