import 'package:flutter_application_p/core/network/api/api_consumer.dart';
import 'package:flutter_application_p/core/network/api/endpoints.dart';

abstract class AuthRemoteDataSource {
  Future<dynamic> register({
    required String email,
    required String password,
    required String fullName,
  });

  // 🟢 التعديل: تغيير اسم الدالة والمسمى من confirmEmail إلى verifyEmail
  Future<dynamic> verifyEmail({
    required String email,
    required String otp,
  });

  Future<dynamic> login({
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiConsumer api;

  AuthRemoteDataSourceImpl(this.api);

  @override
  Future<dynamic> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final nameParts = fullName.trim().split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : firstName;

    return await api.post(
      Endpoints.register,
      data: {
        ApiKeys.email: email,
        ApiKeys.password: password,
        ApiKeys.confirmPassword: password,
        ApiKeys.fullName: fullName,
        ApiKeys.firstName: firstName,
        ApiKeys.lastName: lastName,
      },
    );
  }

  // 🟢 التعديل: استخدام verifyEmail وتمرير المفتاح الصحيح للـ OTP
  @override
  Future<dynamic> verifyEmail({
    required String email,
    required String otp,
  }) async {
    return await api.post(
      Endpoints.verifyEmail, // تم التغيير من Endpoints.confirmEmail
      data: {
        ApiKeys.email: email,
        ApiKeys.otp: otp, // تم التغيير لاستخدام مفتاح الـ OTP المباشر
      },
    );
  }

  @override
  Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    return await api.post(
      Endpoints.login,
      data: {
        ApiKeys.email: email,
        ApiKeys.password: password,
      },
    );
  }
}