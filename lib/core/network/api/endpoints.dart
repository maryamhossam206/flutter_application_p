class Endpoints {
  static const String baseUrl = 'https://accessories-eshop.runasp.net';

  static const String register = '/api/Auth/register';
  static const String verifyEmail = '/api/Auth/verify-email';
  static const String login = '/api/Auth/login';

  static const String getProfile = '/api/User/profile';

  static const String createProduct = '/api/Products';
  static const String products = '/api/Products';
  static const String productDetails = '/api/Products/';

  static const String categories = '/api/Categories';

  static const String cart = '/api/Cart';
  static const String orders = '/api/Orders';
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

  static const String productName = 'name';
  static const String productDescription = 'description';
  static const String categoryName = 'categoryName';
  static const String categoryId = 'categoryId';
}