import 'package:go_router/go_router.dart';
import '../../presentation/screens/welcome/welcome_screen.dart';
import '../../presentation/screens/login/login_screen.dart';
import '../../presentation/screens/otp/otp_screen.dart';
import '../../presentation/screens/otp/product_screen.dart'; // 🟢 استيراد شاشة المنتجات

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
          final email = state.extra as String? ?? '';
          return OtpScreen(email: email);
        },
      ),
      // 🟢 تسجيل مسار صفحة المنتجات
      GoRoute(
        path: '/products',
        builder: (context, state) {
          final token = state.extra as String?;
          return ProductScreen(token: token);
        },
      ),
    ],
  );
}