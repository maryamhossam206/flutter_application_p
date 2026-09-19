import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_application_p/core/network/api/api_consumer.dart';
import 'package:flutter_application_p/data/datasources/dio_consumer.dart';
import 'package:flutter_application_p/core/network/api/endpoints.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final pinController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late final ApiConsumer _apiConsumer;

  @override
  void initState() {
    super.initState();
    _apiConsumer = DioConsumer(dio: Dio());
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_isLoading) return;
    if (!formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final inputCode = pinController.text.trim();

      // 🟢 إرسال طلب الـ OTP واستقبال الـ Response
      final response = await _apiConsumer.post(
        Endpoints.verifyEmail,
        data: {
          ApiKeys.email: widget.email,
          ApiKeys.code: inputCode,
          ApiKeys.token: inputCode,
          ApiKeys.otp: inputCode,
        },
      );

      // 🟢 استخراج الـ token من استجابة السيرفر
      String? userToken;
      if (response is Map<String, dynamic>) {
        userToken = response[ApiKeys.token] ??
            response['token'] ??
            response['data']?['token'];
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification Successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // 🟢 التوجيه لصفحة المنتجات وتمرير الـ Token المقروء
        context.go('/products', extra: userToken);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Colors.red, width: 1.5),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Enter Verification Code',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a code to ${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              Pinput(
                length: 6,
                controller: pinController,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                errorPinTheme: errorPinTheme,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Please enter full code';
                  }
                  return null;
                },
                onCompleted: (pin) => _verifyOtp(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Verify'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}