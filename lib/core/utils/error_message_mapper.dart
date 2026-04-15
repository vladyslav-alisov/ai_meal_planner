import '../errors/app_exceptions.dart';

String mapExceptionToMessage(Object error) {
  if (error is AppException) {
    return error.message;
  }

  return 'Something went wrong. Please try again.';
}
