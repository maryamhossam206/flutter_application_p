class Endpoints {
  // Base URL الأساسي للسيرفر
  static const String baseUrl = 'https://accessories-eshop.runasp.net';

  // مسارات المصادقة (Auth)
  static const String register = '/api/Auth/register';
  static const String verifyEmail = '/api/Auth/verify-email'; 
  static const String login = '/api/Auth/login';

  // مسارات المستخدم
  static const String getProfile = '/api/User/profile';
  
  // مسارات المنتجات
  // 🟢 المسار المخصص لإنشاء أو إضافة منتج جديد (POST)
  static const String createProduct = '/api/Products'; 
  
  // 🟢 المسار المخصص لجلب وعرض المنتجات (GET) - يرجى التأكد من مطور الباك إند إذا كان المسار مختلفاً مثل /api/Products/all
  static const String products = '/api/Products'; 
}

class ApiKeys {
  static const String email = 'email';
  static const String password = 'password';
  static const String confirmPassword = 'confirmPassword';
  static const String fullName = 'fullName';
  static const String firstName = 'firstName';
  static const String lastName = 'lastName';
  
  static const String otp = 'otp'; 
  static const String code = 'code'; 
  
  static const String token = 'token';
  static const String message = 'message';
  static const String error = 'error';
  static const String errors = 'errors';
  
  // مفاتيح خاصة بالمنتجات لو احتجتها لاحقاً للإضافة
  static const String productName = 'name';
  static const String productDescription = 'description';
}