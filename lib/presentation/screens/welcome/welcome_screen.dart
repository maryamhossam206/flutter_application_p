import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/cubit_theme/theme_cubit.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, bool>(
      builder: (context, isDark) {
        final textColor = isDark ? Colors.white : Colors.black;
        final subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
        final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 10),
                  Text(
                    'Explore now',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join SO today.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const Spacer(),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
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
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4FA0FF),
                      minimumSize: const Size(double.infinity, 50),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Create account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Already have an account?',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      context.go('/login');
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      side: BorderSide(color: borderColor),
                    ),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        color: Color(0xFF4FA0FF),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.center,
                    child: Text.rich(
                      TextSpan(
                        text: 'By signing up, you agree to the ',
                        style: TextStyle(color: subTextColor, fontSize: 10),
                        children: [
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              decorationColor: subTextColor,
                            ),
                          ),
                          const TextSpan(text: ' and\n'),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              decorationColor: subTextColor,
                            ),
                          ),
                          const TextSpan(text: ', including '),
                          TextSpan(
                            text: 'Cookie Use.',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              decorationColor: subTextColor,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}