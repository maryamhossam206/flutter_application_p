import 'package:dio/dio.dart';
import 'package:flutter_application_p/core/network/api/api_consumer.dart';
import 'package:flutter_application_p/core/network/api/endpoints.dart';
import 'package:flutter_application_p/core/network/error/exceptions.dart';

class DioConsumer implements ApiConsumer {
  final Dio dio;

  DioConsumer({required this.dio}) {
    dio.options.baseUrl = Endpoints.baseUrl;
    dio.options.responseType = ResponseType.json;
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );
  }

  Options _setOptions(Options? options, String? token) {
    final newOptions = options ?? Options();
    newOptions.headers = Map<String, dynamic>.from(dio.options.headers)
      ..addAll(newOptions.headers ?? {});

    if (token != null && token.isNotEmpty) {
      newOptions.headers?['Authorization'] = 'Bearer $token';
    }
    return newOptions;
  }

@override
  Future<dynamic> get(
    String path, {
    Object? data, 
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? token,
  }) async {
    try {
      final response = await dio.get(
        path,
        // 🟢 إجبار إرسال Body فارغ بصيغة JSON حتى مع طلب الـ GET لإرضاء السيرفر المعلق
        data: data ?? {}, 
        queryParameters: queryParameters,
        options: _setOptions(options, token),
      );
      return response.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }
  @override
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
    Options? options,
    String? token,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: isFormData && data is Map<String, dynamic>
            ? FormData.fromMap(data)
            : data,
        queryParameters: queryParameters,
        options: _setOptions(options, token),
      );
      return response.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<dynamic> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
    Options? options,
    String? token,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: isFormData && data is Map<String, dynamic>
            ? FormData.fromMap(data)
            : data,
        queryParameters: queryParameters,
        options: _setOptions(options, token),
      );
      return response.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool isFormData = false,
    Options? options,
    String? token,
  }) async {
    try {
      final response = await dio.patch(
        path,
        data: isFormData && data is Map<String, dynamic>
            ? FormData.fromMap(data)
            : data,
        queryParameters: queryParameters,
        options: _setOptions(options, token),
      );
      return response.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? token,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _setOptions(options, token),
      );
      return response.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  void handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        throw FetchDataException("Connection Timeout / Connection Error");
      case DioExceptionType.badResponse:
        final errorMessage = _extractErrorMessage(e.response?.data);
        switch (e.response?.statusCode) {
          case 400:
            throw BadRequestException(errorMessage ?? "Bad Request");
          case 401:
          case 403:
            throw UnauthorizedException(errorMessage ?? "Unauthorized");
          case 404:
            throw NotFoundException(errorMessage ?? "Not Found");
          case 409:
            throw ConflictException(errorMessage ?? "Conflict");
          case 500:
          default:
            throw InternalServerErrorException(errorMessage ?? "Server Error");
        }
      case DioExceptionType.cancel:
        throw FetchDataException("Request Canceled");
      case DioExceptionType.unknown:
      default:
        if (e.response != null && e.response?.data != null) {
          final errorMessage = _extractErrorMessage(e.response?.data);
          throw BadRequestException(errorMessage ?? "Network Request Error");
        }
        throw FetchDataException("Unexpected Network Error");
    }
  }

  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map) {
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
      if (data['title'] != null) return data['title'].toString();
      if (data['errors'] != null && data['errors'] is Map) {
        final Map errorsMap = data['errors'];
        if (errorsMap.isNotEmpty) {
          final firstKey = errorsMap.keys.first;
          final firstError = errorsMap[firstKey];
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
        }
      }
    }
    return data.toString();
  }
}