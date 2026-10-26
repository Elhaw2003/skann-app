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
    required this.id,
    required this.fullName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    required this.profileImage,
    required this.bio,
    required this.gender,
    required this.governorate,
    required this.university,
    required this.faculty,
    required this.major,
    required this.academicYear,
    required this.housingStatus,
    required this.interests,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String fullName;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
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
  final Object? interests;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _requiredString(json, 'id'),
      fullName: _requiredString(json, 'fullName'),
      firstName: _requiredString(json, 'firstName'),
      lastName: _requiredString(json, 'lastName'),
      email: _requiredString(json, 'email'),
      phone: _requiredString(json, 'phone'),
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
      interests: json['interests'],
      isActive: _requiredBool(json, 'isActive'),
      createdAt: DateTime.parse(_requiredString(json, 'createdAt')),
      updatedAt: DateTime.parse(_requiredString(json, 'updatedAt')),
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

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) return value;
  throw FormatException('Required string "$key" is missing or invalid.');
}

String? _optionalString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is String) return value;
  throw FormatException('Optional string "$key" has an invalid value.');
}

bool _requiredBool(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is bool) return value;
  throw FormatException('Required boolean "$key" is missing or invalid.');
}
