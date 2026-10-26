import 'package:equatable/equatable.dart';

class OwnerRegistrationRequest extends Equatable {
  const OwnerRegistrationRequest({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.governorate,
    required this.gender,
  });

  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String governorate;
  final String gender;

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'password': password,
    'role': 'OWNER',
    'governorate': governorate,
    'gender': gender,
  };

  @override
  List<Object?> get props => [
    fullName,
    email,
    phone,
    password,
    governorate,
    gender,
  ];
}
