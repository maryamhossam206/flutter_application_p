class ServerException implements Exception {
  final String? message;

  ServerException({this.message});
}

class NoInternetConnectionException implements Exception {
  final String? message;

  NoInternetConnectionException({this.message});
}

class BadCertificateException implements Exception {
  final String? message;

  BadCertificateException({this.message});
}