import 'package:equatable/equatable.dart';

class RoommatesDirectoryFilters extends Equatable {
  const RoommatesDirectoryFilters({
    this.governorate,
    this.university,
    this.faculty,
  });

  final String? governorate;
  final String? university;
  final String? faculty;

  bool get isEmpty =>
      _isBlank(governorate) && _isBlank(university) && _isBlank(faculty);

  int get activeCount => [
    governorate,
    university,
    faculty,
  ].where((value) => !_isBlank(value)).length;

  RoommatesDirectoryFilters copyWith({
    String? governorate,
    bool clearGovernorate = false,
    String? university,
    bool clearUniversity = false,
    String? faculty,
    bool clearFaculty = false,
  }) {
    return RoommatesDirectoryFilters(
      governorate: clearGovernorate ? null : governorate ?? this.governorate,
      university: clearUniversity ? null : university ?? this.university,
      faculty: clearFaculty ? null : faculty ?? this.faculty,
    );
  }

  @override
  List<Object?> get props => [governorate, university, faculty];
}

bool _isBlank(String? value) => value == null || value.trim().isEmpty;
