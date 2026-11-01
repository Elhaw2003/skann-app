import 'package:equatable/equatable.dart';

class RoommateModel extends Equatable {
  const RoommateModel({
    required this.id,
    required this.fullName,
    this.profileImage,
    this.gender,
    this.university,
    this.faculty,
    this.major,
    this.academicYear,
    this.governorate,
    this.housingStatus,
    this.bio,
    this.interests = const [],
    this.phone,
  });

  final String id;
  final String fullName;
  final String? profileImage;
  final String? gender;
  final String? university;
  final String? faculty;
  final String? major;
  final String? academicYear;
  final String? governorate;
  final String? housingStatus;
  final String? bio;
  final List<String> interests;
  final String? phone;

  factory RoommateModel.fromJson(Map<String, dynamic> json) {
    return RoommateModel(
      id: _cleanString(json['id']) ?? '',
      fullName: _cleanString(json['fullName']) ?? '',
      profileImage: _cleanString(json['profileImage']),
      gender: _cleanString(json['gender']),
      university: _cleanString(json['university']),
      faculty: _cleanString(json['faculty']),
      major: _cleanString(json['major']),
      academicYear: _cleanString(json['academicYear']),
      governorate: _cleanString(json['governorate']),
      housingStatus: _cleanString(json['housingStatus']),
      bio: _cleanString(json['bio']),
      interests: _stringList(json['interests']),
      phone: _cleanString(json['phone']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    profileImage,
    gender,
    university,
    faculty,
    major,
    academicYear,
    governorate,
    housingStatus,
    bio,
    interests,
    phone,
  ];
}

String? _cleanString(Object? value) {
  if (value is! String) return null;
  final normalized = value.trim();
  return normalized.isEmpty || normalized.toLowerCase() == 'null'
      ? null
      : normalized;
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable(
    value
        .whereType<String>()
        .map((interest) => interest.trim())
        .where((interest) => interest.isNotEmpty),
  );
}
