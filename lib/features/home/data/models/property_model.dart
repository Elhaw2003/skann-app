import 'package:equatable/equatable.dart';

class PropertyModel extends Equatable {
  const PropertyModel({
    this.id,
    this.title,
    this.thumbnail,
    this.description,
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
    this.city,
    this.area,
    this.address,
    this.location,
    this.images = const [],
    this.amenities = const [],
    this.owner,
    this.rooms = const [],
    this.currentResidents = const [],
    this.isFavorite,
  });

  final String? id;
  final String? title;
  final String? thumbnail;
  final String? description;
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
  final String? city;
  final String? area;
  final String? address;
  final PropertyLocationModel? location;
  final List<PropertyImageModel> images;
  final List<PropertyAmenityModel> amenities;
  final PropertyOwnerModel? owner;
  final List<PropertyRoomModel> rooms;
  final List<PropertyResidentModel> currentResidents;
  final bool? isFavorite;

  Uri? get thumbnailUri {
    final value = thumbnail ?? (images.isEmpty ? null : images.first.url);
    if (value == null || value.isEmpty) return null;

    final uri = Uri.tryParse(value);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }
    return uri;
  }

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    final images =
        _objectList(json['images']).map(PropertyImageModel.fromJson).toList()
          ..sort((first, second) {
            final firstOrder = first.sortOrder;
            final secondOrder = second.sortOrder;
            if (firstOrder == null) return secondOrder == null ? 0 : 1;
            if (secondOrder == null) return -1;
            return firstOrder.compareTo(secondOrder);
          });
    final location = _optionalObject(
      json['location'],
      PropertyLocationModel.fromJson,
    );

    return PropertyModel(
      id: _optionalString(json['id']),
      title: _optionalString(json['title']),
      thumbnail: _optionalString(json['thumbnail']),
      description: _optionalString(json['description']),
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
      city: _optionalString(json['city']) ?? location?.city,
      area: _optionalString(json['area']) ?? location?.area,
      address: _optionalString(json['address']) ?? location?.address,
      location: location,
      images: List.unmodifiable(images),
      amenities: List.unmodifiable(
        _amenityList(json['amenities']).map(PropertyAmenityModel.fromValue),
      ),
      owner: _optionalObject(json['owner'], PropertyOwnerModel.fromJson),
      rooms: List.unmodifiable(
        _objectList(json['rooms']).map(PropertyRoomModel.fromJson),
      ),
      currentResidents: List.unmodifiable(
        _objectList(
          json['currentResidents'],
        ).map(PropertyResidentModel.fromJson),
      ),
      isFavorite: _optionalBool(json['isFavorite']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    thumbnail,
    description,
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
    city,
    area,
    address,
    location,
    images,
    amenities,
    owner,
    rooms,
    currentResidents,
    isFavorite,
  ];
}

class PropertyImageModel extends Equatable {
  const PropertyImageModel({this.id, this.url, this.sortOrder});

  final String? id;
  final String? url;
  final int? sortOrder;

  factory PropertyImageModel.fromJson(Map<String, dynamic> json) =>
      PropertyImageModel(
        id: _optionalString(json['id']),
        url: _optionalString(json['url']),
        sortOrder: _optionalInt(json['sortOrder']),
      );

  factory PropertyImageModel.fromValue(Object? value) {
    if (value is String) return PropertyImageModel(url: value);
    final json = _asMap(value);
    return json == null
        ? const PropertyImageModel()
        : PropertyImageModel.fromJson(json);
  }

  @override
  List<Object?> get props => [id, url, sortOrder];
}

class PropertyLocationModel extends Equatable {
  const PropertyLocationModel({
    this.city,
    this.area,
    this.address,
    this.latitude,
    this.longitude,
  });

  final String? city;
  final String? area;
  final String? address;
  final num? latitude;
  final num? longitude;

  factory PropertyLocationModel.fromJson(Map<String, dynamic> json) =>
      PropertyLocationModel(
        city: _optionalString(json['city']),
        area: _optionalString(json['area']),
        address: _optionalString(json['address']),
        latitude: _optionalNumber(json['latitude']),
        longitude: _optionalNumber(json['longitude']),
      );

  @override
  List<Object?> get props => [city, area, address, latitude, longitude];
}

class PropertyAmenityModel extends Equatable {
  const PropertyAmenityModel({this.id, this.name, this.icon, this.category});

  final String? id;
  final String? name;
  final String? icon;
  final String? category;

  factory PropertyAmenityModel.fromJson(Map<String, dynamic> json) =>
      PropertyAmenityModel(
        id: _optionalString(json['id']),
        name: _optionalString(json['name']),
        icon: _optionalString(json['icon']),
        category: _optionalString(json['category']),
      );

  factory PropertyAmenityModel.fromValue(Object? value) {
    if (value is String) return PropertyAmenityModel(name: value);
    final json = _asMap(value);
    return json == null
        ? const PropertyAmenityModel()
        : PropertyAmenityModel.fromJson(json);
  }

  @override
  List<Object?> get props => [id, name, icon, category];
}

class PropertyOwnerModel extends Equatable {
  const PropertyOwnerModel({this.id, this.name, this.profileImage});

  final String? id;
  final String? name;
  final String? profileImage;

  factory PropertyOwnerModel.fromJson(Map<String, dynamic> json) =>
      PropertyOwnerModel(
        id: _optionalString(json['id']),
        name: _optionalString(json['name']),
        profileImage: _optionalString(json['profileImage']),
      );

  @override
  List<Object?> get props => [id, name, profileImage];
}

class PropertyRoomModel extends Equatable {
  const PropertyRoomModel({
    this.id,
    this.name,
    this.description,
    this.capacity,
    this.occupiedBeds,
    this.availableBeds,
    this.monthlyPrice,
    this.images = const [],
    this.amenities = const [],
    this.property,
  });

  final String? id;
  final String? name;
  final String? description;
  final int? capacity;
  final int? occupiedBeds;
  final int? availableBeds;
  final num? monthlyPrice;
  final List<PropertyImageModel> images;
  final List<PropertyAmenityModel> amenities;
  final PropertyRoomPropertyModel? property;

  factory PropertyRoomModel.fromJson(Map<String, dynamic> json) {
    final images =
        _valueList(json['images']).map(PropertyImageModel.fromValue).toList()
          ..sort((first, second) {
            final firstOrder = first.sortOrder;
            final secondOrder = second.sortOrder;
            if (firstOrder == null) return secondOrder == null ? 0 : 1;
            if (secondOrder == null) return -1;
            return firstOrder.compareTo(secondOrder);
          });
    return PropertyRoomModel(
      id: _optionalString(json['id']),
      name: _optionalString(json['name']),
      description: _optionalString(json['description']),
      capacity: _optionalInt(json['capacity']),
      occupiedBeds: _optionalInt(json['occupiedBeds']),
      availableBeds: _optionalInt(json['availableBeds']),
      monthlyPrice: _optionalNumber(json['monthlyPrice']),
      images: List.unmodifiable(images),
      amenities: List.unmodifiable(
        _amenityList(json['amenities']).map(PropertyAmenityModel.fromValue),
      ),
      property: _optionalObject(
        json['property'],
        PropertyRoomPropertyModel.fromJson,
      ),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    capacity,
    occupiedBeds,
    availableBeds,
    monthlyPrice,
    images,
    amenities,
    property,
  ];
}

class PropertyRoomPropertyModel extends Equatable {
  const PropertyRoomPropertyModel({
    this.id,
    this.title,
    this.city,
    this.area,
    this.address,
    this.genderPolicy,
  });

  final String? id;
  final String? title;
  final String? city;
  final String? area;
  final String? address;
  final String? genderPolicy;

  factory PropertyRoomPropertyModel.fromJson(Map<String, dynamic> json) =>
      PropertyRoomPropertyModel(
        id: _optionalString(json['id']),
        title: _optionalString(json['title']),
        city: _optionalString(json['city']),
        area: _optionalString(json['area']),
        address: _optionalString(json['address']),
        genderPolicy: _optionalString(json['genderPolicy']),
      );

  @override
  List<Object?> get props => [id, title, city, area, address, genderPolicy];
}

class PropertyResidentModel extends Equatable {
  const PropertyResidentModel({
    this.fullName,
    this.profileImage,
    this.university,
    this.faculty,
    this.major,
    this.academicYear,
    this.roomName,
    this.interests = const [],
  });

  final String? fullName;
  final String? profileImage;
  final String? university;
  final String? faculty;
  final String? major;
  final String? academicYear;
  final String? roomName;
  final List<String> interests;

  factory PropertyResidentModel.fromJson(Map<String, dynamic> json) =>
      PropertyResidentModel(
        fullName: _optionalString(json['fullName']),
        profileImage: _optionalString(json['profileImage']),
        university: _optionalString(json['university']),
        faculty: _optionalString(json['faculty']),
        major: _optionalString(json['major']),
        academicYear: _optionalDisplayValue(json['academicYear']),
        roomName: _optionalString(json['roomName']),
        interests: List.unmodifiable(_stringList(json['interests'])),
      );

  @override
  List<Object?> get props => [
    fullName,
    profileImage,
    university,
    faculty,
    major,
    academicYear,
    roomName,
    interests,
  ];
}

Map<String, dynamic>? _asMap(Object? value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<Map<String, dynamic>> _objectList(Object? value) {
  if (value is! List) return const [];
  return value.map(_asMap).whereType<Map<String, dynamic>>().toList();
}

List<Object?> _valueList(Object? value) {
  if (value is! List) return const [];
  return value.where((item) => item is String || item is Map).toList();
}

List<Object?> _amenityList(Object? value) {
  if (value is! List) return const [];
  return value.where((item) => item is String || item is Map).toList();
}

T? _optionalObject<T>(Object? value, T Function(Map<String, dynamic>) parser) {
  final json = _asMap(value);
  return json == null ? null : parser(json);
}

String? _optionalString(Object? value) => value is String ? value : null;

String? _optionalDisplayValue(Object? value) {
  if (value is String) return value;
  if (value is num) return value.toString();
  return null;
}

num? _optionalNumber(Object? value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

int? _optionalInt(Object? value) => _optionalNumber(value)?.toInt();

bool? _optionalBool(Object? value) => value is bool ? value : null;

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value.whereType<String>().toList();
}
