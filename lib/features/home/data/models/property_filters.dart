import 'package:equatable/equatable.dart';

class PropertyFilters extends Equatable {
  const PropertyFilters({
    this.governorate,
    this.city,
    this.area,
    this.university,
    this.faculty,
    this.propertyType,
    this.genderPolicy,
    this.minPrice,
    this.maxPrice,
    this.amenities = const [],
  });

  final String? governorate;
  final String? city;
  final String? area;
  final String? university;
  final String? faculty;
  final String? propertyType;
  final String? genderPolicy;
  final int? minPrice;
  final int? maxPrice;
  final List<String> amenities;

  bool get isEmpty =>
      _isBlank(governorate) &&
      _isBlank(city) &&
      _isBlank(area) &&
      _isBlank(university) &&
      _isBlank(faculty) &&
      _isBlank(propertyType) &&
      _isBlank(genderPolicy) &&
      minPrice == null &&
      maxPrice == null &&
      amenities.isEmpty;

  int get activeCount =>
      [
        governorate,
        city,
        area,
        university,
        faculty,
        propertyType,
        genderPolicy,
      ].where((value) => !_isBlank(value)).length +
      (minPrice != null ? 1 : 0) +
      (maxPrice != null ? 1 : 0) +
      amenities.length;

  PropertyFilters copyWith({
    String? governorate,
    bool clearGovernorate = false,
    String? city,
    bool clearCity = false,
    String? area,
    bool clearArea = false,
    String? university,
    bool clearUniversity = false,
    String? faculty,
    bool clearFaculty = false,
    String? propertyType,
    bool clearPropertyType = false,
    String? genderPolicy,
    bool clearGenderPolicy = false,
    int? minPrice,
    bool clearMinPrice = false,
    int? maxPrice,
    bool clearMaxPrice = false,
    List<String>? amenities,
  }) {
    return PropertyFilters(
      governorate: clearGovernorate ? null : governorate ?? this.governorate,
      city: clearCity ? null : city ?? this.city,
      area: clearArea ? null : area ?? this.area,
      university: clearUniversity ? null : university ?? this.university,
      faculty: clearFaculty ? null : faculty ?? this.faculty,
      propertyType: clearPropertyType
          ? null
          : propertyType ?? this.propertyType,
      genderPolicy: clearGenderPolicy
          ? null
          : genderPolicy ?? this.genderPolicy,
      minPrice: clearMinPrice ? null : minPrice ?? this.minPrice,
      maxPrice: clearMaxPrice ? null : maxPrice ?? this.maxPrice,
      amenities: amenities ?? this.amenities,
    );
  }

  Map<String, dynamic> toQueryParameters({
    required int page,
    required int limit,
    String? search,
  }) {
    final parameters = <String, dynamic>{'page': page, 'limit': limit};
    _addText(parameters, 'governorate', governorate);
    _addText(parameters, 'city', city);
    _addText(parameters, 'area', area);
    _addText(parameters, 'university', university);
    _addText(parameters, 'faculty', faculty);
    _addText(parameters, 'search', search);
    _addText(parameters, 'propertyType', propertyType);
    _addText(parameters, 'genderPolicy', genderPolicy);
    if (minPrice != null) parameters['minPrice'] = minPrice;
    if (maxPrice != null) parameters['maxPrice'] = maxPrice;
    final selectedAmenities = amenities
        .map((amenity) => amenity.trim())
        .where((amenity) => amenity.isNotEmpty)
        .toList(growable: false);
    if (selectedAmenities.isNotEmpty) {
      parameters['amenities'] = selectedAmenities.join(',');
    }
    return parameters;
  }

  static void _addText(
    Map<String, dynamic> parameters,
    String key,
    String? value,
  ) {
    final normalizedValue = value?.trim();
    if (normalizedValue != null && normalizedValue.isNotEmpty) {
      parameters[key] = normalizedValue;
    }
  }

  static bool _isBlank(String? value) => value == null || value.trim().isEmpty;

  @override
  List<Object?> get props => [
    governorate,
    city,
    area,
    university,
    faculty,
    propertyType,
    genderPolicy,
    minPrice,
    maxPrice,
    amenities,
  ];
}
