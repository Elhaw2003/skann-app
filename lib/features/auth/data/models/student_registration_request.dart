import 'package:equatable/equatable.dart';

class StudentRegistrationRequest extends Equatable {
  const StudentRegistrationRequest({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword,
    required this.gender,
    required this.governorate,
    required this.university,
    required this.faculty,
    required this.major,
    required this.academicYear,
  });

  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;
  final String gender;
  final String governorate;
  final String university;
  final String faculty;
  final String major;
  final String academicYear;

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'password': password,
    'confirmPassword': confirmPassword,
    'role': 'STUDENT',
    'gender': gender,
    'governorate': governorate,
    'university': university,
    'faculty': faculty,
    'major': major,
    'academicYear': academicYear,
  };

  @override
  List<Object?> get props => [
    fullName,
    email,
    phone,
    password,
    confirmPassword,
    gender,
    governorate,
    university,
    faculty,
    major,
    academicYear,
  ];
}
