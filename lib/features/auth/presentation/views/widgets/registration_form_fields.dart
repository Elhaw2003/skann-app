import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/shared_widgets/custom_text_field_widget.dart';
import 'package:skann_app/core/theme/app_colors.dart';
import 'package:skann_app/core/theme/app_text_styles.dart';

const List<String> registrationGovernorates = [
  'القاهرة',
  'الجيزة',
  'الإسكندرية',
  'القليوبية',
  'الشرقية',
  'الدقهلية',
  'البحيرة',
  'الغربية',
  'المنوفية',
  'كفر الشيخ',
  'دمياط',
  'بورسعيد',
  'الإسماعيلية',
  'السويس',
  'الفيوم',
  'بني سويف',
  'المنيا',
  'أسيوط',
  'سوهاج',
  'قنا',
  'الأقصر',
  'أسوان',
  'البحر الأحمر',
  'الوادي الجديد',
  'مطروح',
  'شمال سيناء',
  'جنوب سيناء',
];

class RegistrationSectionCard extends StatelessWidget {
  const RegistrationSectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17314F).withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFECF5FF),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: const Color(0xFF1176DC), size: 20.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.primaryTextW500S17.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: AppTextStyles.splashSubtitle.copyWith(
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          ...children,
        ],
      ),
    );
  }
}

class RegistrationFieldLabel extends StatelessWidget {
  const RegistrationFieldLabel({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: label,
        style: AppTextStyles.primaryTextW500S17.copyWith(fontSize: 12.sp),
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: AppColors.redColor),
          ),
        ],
      ),
    );
  }
}

class RegistrationTextField extends StatelessWidget {
  const RegistrationTextField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.textDirection,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixPressed,
    super.key,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final TextDirection? textDirection;
  final bool obscureText;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RegistrationFieldLabel(label: label),
        SizedBox(height: 6.h),
        CustomTextFieldWidget(
          controller: controller,
          hintText: hint,
          prefixIcon: icon,
          prefixColor: const Color(0xFF8C9BB3),
          suffixIcon: suffixIcon,
          suffixOnPressed: onSuffixPressed,
          suffixColor: const Color(0xFF8C9BB3),
          obscureText: obscureText,
          keyboardType: keyboardType,
          textDirection: textDirection,
          validator: validator,
          enableBorderRadius: 14,
          focusBorderRadius: 14,
          errorBorderRadius: 14,
          enableBorderColor: const Color(0xFFE5EAF2),
          focusBorderColor: const Color(0xFF1780E8),
          fillColor: const Color(0xFFFBFCFE),
        ),
      ],
    );
  }
}
