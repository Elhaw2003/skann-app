import 'package:equatable/equatable.dart';

class AmenityModel extends Equatable {
  const AmenityModel({
    required this.id,
    required this.name,
    this.icon,
    this.category,
  });

  final String id;
  final String name;
  final String? icon;
  final String? category;

  factory AmenityModel.fromJson(Map<String, dynamic> json) {
    return AmenityModel(
      id: _requiredString(json['id'], 'id'),
      name: _requiredString(json['name'], 'name'),
      icon: _optionalString(json['icon']),
      category: _optionalString(json['category']),
    );
  }

  @override
  List<Object?> get props => [id, name, icon, category];
}

String _requiredString(Object? value, String field) {
  if (value is String && value.isNotEmpty) return value;
  throw FormatException('Amenity field "$field" is missing.');
}

String? _optionalString(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  throw const FormatException('Amenity text field is invalid.');
}
