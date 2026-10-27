import 'package:equatable/equatable.dart';

class LocationModel extends Equatable {
  const LocationModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.areas,
  });

  final String id;
  final String nameAr;
  final String nameEn;
  final List<AreaModel> areas;

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    final rawAreas = json['areas'];
    if (rawAreas != null && rawAreas is! List) {
      throw const FormatException('Location areas must be a list.');
    }
    return LocationModel(
      id: _requiredText(json['id'], 'id'),
      nameAr: _requiredText(json['nameAr'], 'nameAr'),
      nameEn: _optionalText(json['nameEn']) ?? '',
      areas: List.unmodifiable(
        (rawAreas as List? ?? const []).map(
          (area) => AreaModel.fromJson(_asMap(area)),
        ),
      ),
    );
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const FormatException('Location area entry is malformed.');
  }

  @override
  List<Object?> get props => [id, nameAr, nameEn, areas];
}

class AreaModel extends Equatable {
  const AreaModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });

  final String id;
  final String nameAr;
  final String nameEn;

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: _requiredText(json['id'], 'area id'),
      nameAr: _requiredText(json['nameAr'], 'area nameAr'),
      nameEn: _optionalText(json['nameEn']) ?? '',
    );
  }

  @override
  List<Object?> get props => [id, nameAr, nameEn];
}

String _requiredText(Object? value, String field) {
  if (value is String && value.isNotEmpty) return value;
  throw FormatException('Location field "$field" is missing.');
}

String? _optionalText(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  throw const FormatException('Location text field is invalid.');
}
