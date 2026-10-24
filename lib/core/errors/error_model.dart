import 'package:skann_app/core/network/api_constants.dart';

class ErrorModel {
  final int statusCode;
  final String message;
  final List<String> generalErrors;

  ErrorModel({
    required this.statusCode,
    required this.message,
    required this.generalErrors,
  });

  factory ErrorModel.fromJson(Map<String, dynamic> jsonData) {
    // Extract all errors from different formats
    List<String> extractedErrors = [];

    // Check if there's an errors object
    if (jsonData['errors'] != null && jsonData['errors'] is Map) {
      final errors = jsonData['errors'] as Map<String, dynamic>;

      // Check for generalErrors array first
      if (errors['generalErrors'] != null && errors['generalErrors'] is List) {
        extractedErrors.addAll(
          List<String>.from(errors['generalErrors'] as List),
        );
      } else {
        // Extract errors from field-specific errors (e.g., password, email)
        for (var entry in errors.entries) {
          if (entry.value is List && (entry.value as List).isNotEmpty) {
            extractedErrors.addAll(List<String>.from(entry.value as List));
          } else if (entry.value is String) {
            extractedErrors.add(entry.value as String);
          }
        }
      }
    }

    return ErrorModel(
      statusCode: jsonData[ApiKey.statusCode] ?? 0,
      message: jsonData['message'] ?? 'An error occurred',
      generalErrors: extractedErrors,
    );
  }

  /// Get the first error message (for display)
  String get errorMessage {
    if (generalErrors.isNotEmpty) {
      return generalErrors.first;
    }
    return message;
  }
}
