import 'exceptions.dart';
import 'failure.dart';

Failure mapExceptionToFailure(AppException exception) {
  if (exception is AuthException) {
    return AuthFailure(
      exception.message,
      code: exception.code,
      fieldErrors: exception.fieldErrors,
    );
  }

  if (exception is NetworkException) {
    return NetworkFailure(
      exception.message,
      code: exception.code,
      fieldErrors: exception.fieldErrors,
    );
  }

  if (exception is ValidationException) {
    return ValidationFailure(
      exception.message,
      code: exception.code,
      fieldErrors: exception.fieldErrors,
    );
  }

  if (exception is PermissionException) {
    return PermissionFailure(
      exception.message,
      code: exception.code,
      fieldErrors: exception.fieldErrors,
    );
  }

  if (exception is CacheException) {
    return CacheFailure(
      exception.message,
      code: exception.code,
      fieldErrors: exception.fieldErrors,
    );
  }

  if (exception is StorageException) {
    return StorageFailure(
      exception.message,
      code: exception.code,
      fieldErrors: exception.fieldErrors,
    );
  }

  if (exception is LocationException) {
    return LocationFailure(
      exception.message,
      code: exception.code,
      fieldErrors: exception.fieldErrors,
    );
  }

  if (exception is NotFoundException) {
    return NotFoundFailure(
      exception.message,
      code: exception.code,
      fieldErrors: exception.fieldErrors,
    );
  }

  if (exception is ServerException) {
    return ServerFailure(
      exception.message,
      code: exception.code,
      fieldErrors: exception.fieldErrors,
    );
  }

  return UnexpectedFailure(
    exception.message,
    code: exception.code,
    fieldErrors: exception.fieldErrors,
  );
}
