import 'package:equatable/equatable.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';

class PropertyPageModel extends Equatable {
  const PropertyPageModel({required this.items, required this.pagination});

  final List<PropertyModel> items;
  final PropertyPaginationModel pagination;

  factory PropertyPageModel.fromJson(
    Map<String, dynamic> json, {
    required int fallbackPage,
    required int fallbackLimit,
  }) {
    final rawData = json['data'];
    if (rawData is! Map) {
      throw const FormatException('Properties response data is missing.');
    }
    final data = Map<String, dynamic>.from(rawData);
    final rawItems = data['items'];
    final rawPagination = data['pagination'];
    if (rawItems is! List || rawPagination is! Map) {
      throw const FormatException('Properties page is malformed.');
    }

    return PropertyPageModel(
      items: List.unmodifiable(
        rawItems.map(
          (item) => PropertyModel.fromJson(_asMap(item, 'property')),
        ),
      ),
      pagination: PropertyPaginationModel.fromJson(
        Map<String, dynamic>.from(rawPagination),
        fallbackPage: fallbackPage,
        fallbackLimit: fallbackLimit,
      ),
    );
  }

  static Map<String, dynamic> _asMap(Object? value, String label) {
    if (value is Map) return Map<String, dynamic>.from(value);
    throw FormatException('The $label entry is malformed.');
  }

  @override
  List<Object?> get props => [items, pagination];
}

class PropertyPaginationModel extends Equatable {
  const PropertyPaginationModel({
    required this.page,
    required this.limit,
    required this.totalItems,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  final int page;
  final int limit;
  final int totalItems;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  factory PropertyPaginationModel.fromJson(
    Map<String, dynamic> json, {
    required int fallbackPage,
    required int fallbackLimit,
  }) {
    final page = _intOrNull(json['page']) ?? fallbackPage;
    final totalPages = _intOrNull(json['totalPages']) ?? page;
    return PropertyPaginationModel(
      page: page,
      limit: _intOrNull(json['limit']) ?? fallbackLimit,
      totalItems: _intOrNull(json['totalItems']) ?? 0,
      totalPages: totalPages,
      hasNextPage: _boolOrNull(json['hasNextPage']) ?? page < totalPages,
      hasPreviousPage:
          _boolOrNull(json['hasPreviousPage']) ?? page > fallbackPage,
    );
  }

  @override
  List<Object?> get props => [
    page,
    limit,
    totalItems,
    totalPages,
    hasNextPage,
    hasPreviousPage,
  ];
}

int? _intOrNull(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

bool? _boolOrNull(Object? value) => value is bool ? value : null;
