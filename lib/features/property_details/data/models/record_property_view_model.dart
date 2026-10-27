import 'package:equatable/equatable.dart';

class RecordPropertyViewModel extends Equatable {
  const RecordPropertyViewModel({
    this.propertyId,
    this.viewsCount,
    required this.isNewView,
  });

  final String? propertyId;
  final int? viewsCount;
  final bool isNewView;

  factory RecordPropertyViewModel.fromJson(Map<String, dynamic> json) {
    final isNewView = json['isNewView'];
    if (isNewView is! bool) {
      throw const FormatException(
        'Record view response has no valid isNewView value.',
      );
    }

    return RecordPropertyViewModel(
      propertyId: _optionalString(json['propertyId']),
      viewsCount: _optionalInt(json['viewsCount']),
      isNewView: isNewView,
    );
  }

  @override
  List<Object?> get props => [propertyId, viewsCount, isNewView];
}

String? _optionalString(Object? value) => value is String ? value : null;

int? _optionalInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
