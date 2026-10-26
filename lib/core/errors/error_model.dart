class ErrorModel {
  final int statusCode;
  final String message;
  final String? code;
  final List<String> generalErrors;
  final Map<String, List<String>> fieldErrors;

  const ErrorModel({
    required this.statusCode,
    required this.message,
    this.code,
    required this.generalErrors,
    this.fieldErrors = const {},
  });

  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    final String mainMessage =
        (json['message'] ?? json['detail'] ?? json['title'] ?? '')
            .toString()
            .trim();

    final List<String> extractedErrors = [];
    final Map<String, List<String>> extractedFieldErrors = {};

    // Only treat explicit `errors` as field/general errors — not `data`
    // (API uses `data` for payloads, not validation maps).
    final errors = json['errors'];

    if (errors != null) {
      if (errors is Map) {
        final errorsMap = Map<String, dynamic>.from(errors);
        for (final entry in errorsMap.entries) {
          if (entry.value is List) {
            final values = (entry.value as List)
                .map((e) => e?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList();

            extractedErrors.addAll(values);
            extractedFieldErrors[entry.key] = values;
          } else if (entry.value is String) {
            extractedErrors.add(entry.value);

            extractedFieldErrors[entry.key] = [entry.value];
          }
        }
      } else if (errors is List) {
        extractedErrors.addAll(
          errors.map((e) => e.toString()).where((e) => e.isNotEmpty),
        );
      } else if (errors is String && errors.isNotEmpty) {
        extractedErrors.add(errors);
      }
    }

    final resolvedMessage = mainMessage.isNotEmpty
        ? mainMessage
        : (extractedErrors.isNotEmpty
              ? extractedErrors.first
              : 'An error occurred');

    if (extractedErrors.isEmpty && resolvedMessage.isNotEmpty) {
      extractedErrors.add(resolvedMessage);
    }

    return ErrorModel(
      statusCode: json['statusCode'] as int? ?? json['status'] as int? ?? 0,
      message: resolvedMessage,
      code: json['code']?.toString(),
      generalErrors: extractedErrors,
      fieldErrors: extractedFieldErrors,
    );
  }

  String get errorMessage {
    if (generalErrors.isNotEmpty) {
      return generalErrors.first;
    }

    return message;
  }
}
