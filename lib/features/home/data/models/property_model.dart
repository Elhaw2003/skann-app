import 'package:equatable/equatable.dart';

class PropertyModel extends Equatable {
  const PropertyModel({
    required this.id,
    required this.title,
    this.thumbnail,
    this.city,
    this.area,
    this.address,
    this.propertyType,
    this.genderPolicy,
    this.startingPrice,
    this.currency,
    this.rating,
    this.reviewsCount,
    this.viewsCount,
    this.favoritesCount,
    this.isVerified,
    this.distanceFromUniversity,
    this.availableRooms,
    this.currentOccupants,
    this.amenities = const [],
    this.isFavorite,
  });

  final String id;
  final String title;
  final String? thumbnail;
  final String? city;
  final String? area;
  final String? address;
  final String? propertyType;
  final String? genderPolicy;
  final num? startingPrice;
  final String? currency;
  final num? rating;
  final int? reviewsCount;
  final int? viewsCount;
  final int? favoritesCount;
  final bool? isVerified;
  final String? distanceFromUniversity;
  final int? availableRooms;
  final int? currentOccupants;
  final List<String> amenities;
  final bool? isFavorite;

  Uri? get thumbnailUri {
    final value = thumbnail;
    if (value == null || value.isEmpty) return null;

    final uri = Uri.tryParse(value);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }
    return uri;
  }

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: _requiredString(json, 'id'),
      title: _requiredString(json, 'title'),
      thumbnail: _optionalString(json['thumbnail']),
      city: _optionalString(json['city']),
      area: _optionalString(json['area']),
      address: _optionalString(json['address']),
      propertyType: _optionalString(json['propertyType']),
      genderPolicy: _optionalString(json['genderPolicy']),
      startingPrice: _optionalNumber(json['startingPrice']),
      currency: _optionalString(json['currency']),
      rating: _optionalNumber(json['rating']),
      reviewsCount: _optionalInt(json['reviewsCount']),
      viewsCount: _optionalInt(json['viewsCount']),
      favoritesCount: _optionalInt(json['favoritesCount']),
      isVerified: _optionalBool(json['isVerified']),
      distanceFromUniversity: _optionalDisplayValue(
        json['distanceFromUniversity'],
      ),
      availableRooms: _optionalInt(json['availableRooms']),
      currentOccupants: _optionalInt(json['currentOccupants']),
      amenities: _stringList(json['amenities']),
      isFavorite: _optionalBool(json['isFavorite']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    thumbnail,
    city,
    area,
    address,
    propertyType,
    genderPolicy,
    startingPrice,
    currency,
    rating,
    reviewsCount,
    viewsCount,
    favoritesCount,
    isVerified,
    distanceFromUniversity,
    availableRooms,
    currentOccupants,
    amenities,
    isFavorite,
  ];
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) return value;
  throw FormatException('Required property field "$key" is missing.');
}

String? _optionalString(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  throw const FormatException('Property text field has an invalid value.');
}

String? _optionalDisplayValue(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num) return value.toString();
  throw const FormatException('Property display value has an invalid value.');
}

num? _optionalNumber(Object? value) {
  if (value == null) return null;
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  throw const FormatException('Property numeric field has an invalid value.');
}

int? _optionalInt(Object? value) {
  final number = _optionalNumber(value);
  return number?.toInt();
}

bool? _optionalBool(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;
  throw const FormatException('Property boolean field has an invalid value.');
}

List<String> _stringList(Object? value) {
  if (value == null) return const [];
  if (value is! List) {
    throw const FormatException('Property amenities must be a list.');
  }
  return List.unmodifiable(value.whereType<String>());
}
