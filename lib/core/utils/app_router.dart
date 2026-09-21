import 'package:go_router/go_router.dart';
import '../../presentation/screens/welcome/welcome_screen.dart';
import '../../presentation/screens/login/login_screen.dart';
import '../../presentation/screens/otp/otp_screen.dart';
import '../../presentation/screens/otp/product_screen.dart'; 
import '../../presentation/screens/settings/settings_screen.dart'; 

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final extra = state.extra;
          String email = '';
          String? password;

          if (extra is Map<String, dynamic>) {
            email = extra['email'] ?? '';
            password = extra['password'];
          } else if (extra is String) {
            email = extra;
          }

          return OtpScreen(
            email: email,
            password: password,
          );
        },
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) {
          final token = state.extra as String?;
          return ProductScreen(token: token);
        },
      ),
      
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}