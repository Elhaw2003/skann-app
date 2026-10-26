import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/features/auth/presentation/views/widgets/registration_dropdown_field.dart';
import 'package:skann_app/features/auth/presentation/views/widgets/registration_form_fields.dart';

class RegistrationAcademicDetails extends StatelessWidget {
  const RegistrationAcademicDetails({
    required this.governorate,
    required this.gender,
    required this.universityController,
    required this.facultyController,
    required this.majorController,
    required this.academicYearController,
    required this.onGovernorateChanged,
    required this.onGenderChanged,
    required this.requiredValidator,
    super.key,
  });

  final String? governorate;
  final String? gender;
  final TextEditingController universityController;
  final TextEditingController facultyController;
  final TextEditingController majorController;
  final TextEditingController academicYearController;
  final ValueChanged<String?> onGovernorateChanged;
  final ValueChanged<String?> onGenderChanged;
  final String? Function(String?) requiredValidator;

  @override
  Widget build(BuildContext context) {
    return RegistrationSectionCard(
      icon: Icons.school_outlined,
      title: 'البيانات الأكاديمية والجغرافية',
      subtitle: 'ساعدنا في اقتراح السكن الأقرب لك',
      children: [
        RegistrationDropdownField(
          label: 'النوع / الجنس',
          hint: 'اختر النوع',
          value: gender,
          items: const {'MALE': 'ذكر', 'FEMALE': 'أنثى'},
          onChanged: onGenderChanged,
        ),
        SizedBox(height: 12.h),
        RegistrationDropdownField(
          label: 'المحافظة',
          hint: 'اختر المحافظة',
          value: governorate,
          items: {for (final item in registrationGovernorates) item: item},
          onChanged: onGovernorateChanged,
        ),
        SizedBox(height: 12.h),
        RegistrationTextField(
          label: 'الجامعة',
          hint: 'مثال: جامعة عين شمس',
          controller: universityController,
          icon: Icons.account_balance_outlined,
          validator: requiredValidator,
        ),
        SizedBox(height: 12.h),
        RegistrationTextField(
          label: 'الكلية',
          hint: 'مثال: كلية الهندسة',
          controller: facultyController,
          icon: Icons.menu_book_outlined,
          validator: requiredValidator,
        ),
        SizedBox(height: 12.h),
        RegistrationTextField(
          label: 'التخصص',
          hint: 'مثال: هندسة مدنية',
          controller: majorController,
          icon: Icons.category_outlined,
          validator: requiredValidator,
        ),
        SizedBox(height: 12.h),
        RegistrationTextField(
          label: 'الفرقة / السنة الدراسية',
          hint: 'مثال: الفرقة الأولى',
          controller: academicYearController,
          icon: Icons.calendar_month_outlined,
          validator: requiredValidator,
        ),
      ],
    );
  }
}
