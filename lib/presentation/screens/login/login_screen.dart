import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/cubit_theme/theme_cubit.dart';
import '../../../core/utils/app_assets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final dio = Dio();
    const String baseUrl = 'https://accessories-eshop.runasp.net';
    final userEmail = _emailController.text.trim();

    try {
      final response = await dio.post(
        '$baseUrl/api/Auth/register',
        data: {
          'email': userEmail,
          'password': _passwordController.text,
          'firstName': 'User',
          'lastName': 'Test',
        },
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200 || response.statusCode == 201) {
          // تمرير الإيميل لشاشة الـ OTP عبر extra
          context.go('/otp', extra: userEmail);
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage = 'Failed to connect to the server';
        if (e.response != null && e.response?.data != null) {
          final data = e.response?.data;
          if (data is Map && data['message'] != null) {
            errorMessage = data['message'].toString();
          } else {
            errorMessage = data.toString();
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, isDark) {
        final textColor = isDark ? Colors.white : Colors.black;
        final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;
        final fieldFillColor = isDark ? Colors.black : Colors.grey.shade100;
        final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode : Icons.dark_mode,
                        color: textColor,
                      ),
                      onPressed: () {
                        context.read<ThemeCubit>().toggleTheme();
                      },
                    ),
                  ),
                  Container(
                    height: 120,
                    width: 180,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: AssetImage(AppAssets.headerImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Let's Connect With Us!",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            style: TextStyle(color: textColor),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email is required';
                              }
                              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Email Address',
                              hintStyle: TextStyle(color: subTextColor, fontSize: 14),
                              filled: true,
                              fillColor: fieldFillColor,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFF4FA0FF)),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.redAccent),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.redAccent),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            style: TextStyle(color: textColor),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              if (value.length < 8) {
                                return 'Password must be at least 8 characters';
                              }
                              if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                return 'Password must contain at least one uppercase letter';
                              }
                              if (!RegExp(r'[0-9]').hasMatch(value)) {
                                return 'Password must contain at least one number';
                              }
                              if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_]').hasMatch(value)) {
                                return 'Password must contain at least one special character';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(color: subTextColor, fontSize: 14),
                              filled: true,
                              fillColor: fieldFillColor,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: borderColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFF4FA0FF)),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.redAccent),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Colors.redAccent),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(color: subTextColor, fontSize: 12),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4FA0FF),
                              minimumSize: const Size(double.infinity, 50),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Row(
                              children: [
                                Expanded(child: Divider(color: borderColor)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text('or', style: TextStyle(color: subTextColor, fontSize: 12)),
                                ),
                                Expanded(child: Divider(color: borderColor)),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              side: BorderSide(color: borderColor),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.apple, color: textColor, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  'Sign up with Apple',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              side: BorderSide(color: borderColor),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'G ',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade600,
                                  ),
                                ),
                                Text(
                                  'Sign up with Google',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(color: subTextColor, fontSize: 13),
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.go('/');
                                },
                                child: const Text(
                                  'Sign up',
                                  style: TextStyle(
                                    color: Color(0xFF4FA0FF),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}