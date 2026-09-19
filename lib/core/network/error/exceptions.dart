class ServerException implements Exception {
  final String? message;
  const ServerException([this.message]);
  @override
  String toString() => message ?? 'ServerException';
}

class FetchDataException implements Exception {
  final String? message;
  const FetchDataException([this.message]);
  @override
  String toString() => message ?? 'FetchDataException';
}

class BadRequestException implements Exception {
  final String? message;
  const BadRequestException([this.message]);
  @override
  String toString() => message ?? 'BadRequestException';
}

class UnauthorizedException implements Exception {
  final String? message;
  const UnauthorizedException([this.message]);
  @override
  String toString() => message ?? 'UnauthorizedException';
}

class NotFoundException implements Exception {
  final String? message;
  const NotFoundException([this.message]);
  @override
  String toString() => message ?? 'NotFoundException';
}

class ConflictException implements Exception {
  final String? message;
  const ConflictException([this.message]);
  @override
  String toString() => message ?? 'ConflictException';
}

class InternalServerErrorException implements Exception {
  final String? message;
  const InternalServerErrorException([this.message]);
  @override
  String toString() => message ?? 'InternalServerErrorException';
}

class NoInternetConnectionException implements Exception {
  final String? message;
  const NoInternetConnectionException([this.message]);
  @override
  String toString() => message ?? 'NoInternetConnectionException';
}

class BadCertificateException implements Exception {
  final String? message;
  const BadCertificateException([this.message]);
  @override
  String toString() => message ?? 'BadCertificateException';
}