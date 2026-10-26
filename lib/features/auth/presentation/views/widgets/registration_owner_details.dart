import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/features/auth/presentation/views/widgets/registration_dropdown_field.dart';
import 'package:skann_app/features/auth/presentation/views/widgets/registration_form_fields.dart';

class RegistrationOwnerDetails extends StatelessWidget {
  const RegistrationOwnerDetails({
    required this.governorate,
    required this.gender,
    required this.onGovernorateChanged,
    required this.onGenderChanged,
    super.key,
  });

  final String? governorate;
  final String? gender;
  final ValueChanged<String?> onGovernorateChanged;
  final ValueChanged<String?> onGenderChanged;

  @override
  Widget build(BuildContext context) {
    return RegistrationSectionCard(
      icon: Icons.location_city_outlined,
      title: 'المحافظة والبيانات الأساسية',
      subtitle: 'حدد موقع السكن ومعلوماتك الأساسية',
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
      ],
    );
  }
}
