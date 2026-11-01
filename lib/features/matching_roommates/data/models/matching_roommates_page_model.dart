import 'package:equatable/equatable.dart';
import 'package:skann_app/features/matching_roommates/data/models/roommate_model.dart';

class MatchingRoommatesPageModel extends Equatable {
  const MatchingRoommatesPageModel({
    required this.items,
    required this.pagination,
  });

  final List<RoommateModel> items;
  final RoommatePaginationModel pagination;

  factory MatchingRoommatesPageModel.fromJson(
    Map<String, dynamic> json, {
    required int fallbackPage,
    required int fallbackLimit,
  }) {
    final rawData = json['data'];
    if (rawData is! Map) {
      throw const FormatException('Roommates response data is missing.');
    }

    final data = Map<String, dynamic>.from(rawData);
    final rawItems = data['items'];
    final rawPagination = data['pagination'];
    if (rawItems is! List || rawPagination is! Map) {
      throw const FormatException('Roommates page is malformed.');
    }

    return MatchingRoommatesPageModel(
      items: List.unmodifiable(
        rawItems.map(
          (item) => RoommateModel.fromJson(_asMap(item, 'roommate')),
        ),
      ),
      pagination: RoommatePaginationModel.fromJson(
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

class RoommatePaginationModel extends Equatable {
  const RoommatePaginationModel({
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

  factory RoommatePaginationModel.fromJson(
    Map<String, dynamic> json, {
    required int fallbackPage,
    required int fallbackLimit,
  }) {
    return RoommatePaginationModel(
      page: _intOrNull(json['page']) ?? fallbackPage,
      limit: _intOrNull(json['limit']) ?? fallbackLimit,
      totalItems: _intOrNull(json['totalItems']) ?? 0,
      totalPages: _intOrNull(json['totalPages']) ?? fallbackPage,
      hasNextPage: json['hasNextPage'] == true,
      hasPreviousPage: json['hasPreviousPage'] == true,
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
