import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final Map<String, List<String>>? fieldErrors;

  const Failure(this.message, {this.code, this.fieldErrors});

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code, super.fieldErrors});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code, super.fieldErrors});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code, super.fieldErrors});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code, super.fieldErrors});
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code, super.fieldErrors});
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.fieldErrors, super.code});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code, super.fieldErrors});
}

class LocationFailure extends Failure {
  const LocationFailure(super.message, {super.code, super.fieldErrors});
}

class StorageFailure extends Failure {
  const StorageFailure(super.message, {super.code, super.fieldErrors});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, {super.code, super.fieldErrors});
}
