import 'package:app/foundation/constants.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_firebase_performance/dio_firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:ua_client_hints/ua_client_hints.dart';

final dioProvider = Provider((_) => AppDio.getInstance());

// ignore: prefer_mixin
class AppDio with DioMixin implements Dio {
  AppDio._([BaseOptions? options]) {
    options = BaseOptions(
      baseUrl: Constants.of().endpoint,
      contentType: 'application/json',
      connectTimeout: 30000,
      sendTimeout: 30000,
      receiveTimeout: 30000,
    );

    this.options = options;
    interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
      options.headers.addAll(await userAgentClientHintsHeader());
      handler.next(options);
    }));

    // Firebase Performance
    interceptors.add(DioFirebasePerformanceInterceptor());

    if (kDebugMode) {
      // Local Log
      interceptors.add(PrettyDioLogger(responseBody: true, requestBody: true));
    }

    httpClientAdapter = DefaultHttpClientAdapter();
  }

  static Dio getInstance() => AppDio._();
}
