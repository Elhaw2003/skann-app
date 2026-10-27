import 'package:equatable/equatable.dart';

class RegistrationResponseModel extends Equatable {
  const RegistrationResponseModel({
    required this.success,
    required this.code,
    required this.message,
    required this.data,
  });

  final bool success;
  final String code;
  final String message;
  final RegistrationDataModel data;

  factory RegistrationResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    if (rawData is! Map) {
      throw const FormatException('Registration response data is missing.');
    }

    return RegistrationResponseModel(
      success: _requiredBool(json, 'success'),
      code: _requiredString(json, 'code'),
      message: _requiredString(json, 'message'),
      data: RegistrationDataModel.fromJson(Map<String, dynamic>.from(rawData)),
    );
  }

  @override
  List<Object?> get props => [success, code, message, data];
}

class RegistrationDataModel extends Equatable {
  const RegistrationDataModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final UserModel user;
  final String accessToken;
  final String refreshToken;

  factory RegistrationDataModel.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    if (rawUser is! Map) {
      throw const FormatException('Registered user is missing.');
    }

    return RegistrationDataModel(
      user: UserModel.fromJson(Map<String, dynamic>.from(rawUser)),
      accessToken: _requiredString(json, 'accessToken'),
      refreshToken: _requiredString(json, 'refreshToken'),
    );
  }

  @override
  List<Object?> get props => [user, accessToken, refreshToken];
}

class UserModel extends Equatable {
  const UserModel({
    this.id,
    this.fullName,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    required this.role,
    this.profileImage,
    this.bio,
    this.gender,
    this.governorate,
    this.university,
    this.faculty,
    this.major,
    this.academicYear,
    this.housingStatus,
    this.interests,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? fullName;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String role;
  final String? profileImage;
  final String? bio;
  final String? gender;
  final String? governorate;
  final String? university;
  final String? faculty;
  final String? major;
  final String? academicYear;
  final String? housingStatus;
  final List<String>? interests;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get displayName {
    final name = _cleanString(fullName);
    if (name != null) return name;

    return [
      _cleanString(firstName),
      _cleanString(lastName),
    ].whereType<String>().join(' ');
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final user = UserModel.fromProfileJson(json);
    for (final key in [
      'id',
      'fullName',
      'firstName',
      'lastName',
      'email',
      'phone',
    ]) {
      _requiredString(json, key);
    }
    _requiredBool(json, 'isActive');
    if (user.createdAt == null || user.updatedAt == null) {
      throw const FormatException(
        'Required user dates are missing or invalid.',
      );
    }
    return user;
  }

  factory UserModel.fromProfileJson(Map<String, dynamic> json) {
    return UserModel(
      id: _optionalString(json, 'id'),
      fullName: _optionalString(json, 'fullName'),
      firstName: _optionalString(json, 'firstName'),
      lastName: _optionalString(json, 'lastName'),
      email: _optionalString(json, 'email'),
      phone: _optionalString(json, 'phone'),
      role: _requiredString(json, 'role'),
      profileImage: _optionalString(json, 'profileImage'),
      bio: _optionalString(json, 'bio'),
      gender: _optionalString(json, 'gender'),
      governorate: _optionalString(json, 'governorate'),
      university: _optionalString(json, 'university'),
      faculty: _optionalString(json, 'faculty'),
      major: _optionalString(json, 'major'),
      academicYear: _optionalString(json, 'academicYear'),
      housingStatus: _optionalString(json, 'housingStatus'),
      interests: _optionalStringList(json['interests']),
      isActive: _optionalBool(json['isActive']),
      createdAt: _optionalDateTime(json['createdAt']),
      updatedAt: _optionalDateTime(json['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    firstName,
    lastName,
    email,
    phone,
    role,
    profileImage,
    bio,
    gender,
    governorate,
    university,
    faculty,
    major,
    academicYear,
    housingStatus,
    interests,
    isActive,
    createdAt,
    updatedAt,
  ];
}

List<String>? _optionalStringList(Object? value) {
  if (value is! List) return null;
  return value.whereType<String>().toList(growable: false);
}

DateTime? _optionalDateTime(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

bool? _optionalBool(Object? value) => value is bool ? value : null;

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) return value;
  throw FormatException('Required string "$key" is missing or invalid.');
}

bool _requiredBool(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is bool) return value;
  throw FormatException('Required boolean "$key" is missing or invalid.');
}

String? _optionalString(Map<String, dynamic> json, String key) {
  final value = json[key];
  return _cleanString(value);
}

String? _cleanString(Object? value) {
  if (value is! String) return null;
  final normalized = value.trim();
  return normalized.isEmpty || normalized.toLowerCase() == 'null'
      ? null
      : normalized;
}
