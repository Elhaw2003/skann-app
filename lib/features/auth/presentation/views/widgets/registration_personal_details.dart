import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/features/auth/presentation/views/widgets/registration_form_fields.dart';

class RegistrationPersonalDetails extends StatelessWidget {
  const RegistrationPersonalDetails({
    required this.isStudent,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmation,
    required this.onTogglePassword,
    required this.onToggleConfirmation,
    required this.requiredValidator,
    required this.emailValidator,
    required this.phoneValidator,
    required this.confirmationValidator,
    super.key,
  });

  final bool isStudent;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmation;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmation;
  final String? Function(String?) requiredValidator;
  final String? Function(String?) emailValidator;
  final String? Function(String?) phoneValidator;
  final String? Function(String?) confirmationValidator;

  @override
  Widget build(BuildContext context) {
    return RegistrationSectionCard(
      icon: Icons.badge_outlined,
      title: 'البيانات الشخصية',
      subtitle: 'معلوماتك الأساسية للتواصل معك',
      children: [
        RegistrationTextField(
          label: 'الاسم بالكامل',
          hint: 'مثال: أحمد محمد إبراهيم',
          controller: fullNameController,
          icon: Icons.person_outline,
          validator: requiredValidator,
        ),
        SizedBox(height: 12.h),
        RegistrationTextField(
          label: 'رقم الهاتف المحمول',
          hint: '01012345678',
          controller: phoneController,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: phoneValidator,
        ),
        SizedBox(height: 12.h),
        RegistrationTextField(
          label: 'البريد الإلكتروني',
          hint: isStudent ? 'student@university.edu.eg' : 'name@example.com',
          controller: emailController,
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          validator: emailValidator,
        ),
        SizedBox(height: 12.h),
        RegistrationTextField(
          label: 'كلمة المرور',
          hint: 'أدخل كلمة المرور',
          controller: passwordController,
          icon: Icons.lock_outline_rounded,
          obscureText: obscurePassword,
          suffixIcon: obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          onSuffixPressed: onTogglePassword,
          validator: requiredValidator,
        ),
        if (isStudent) ...[
          SizedBox(height: 12.h),
          RegistrationTextField(
            label: 'تأكيد كلمة المرور',
            hint: 'أعد إدخال كلمة المرور',
            controller: confirmPasswordController,
            icon: Icons.verified_user_outlined,
            obscureText: obscureConfirmation,
            suffixIcon: obscureConfirmation
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            onSuffixPressed: onToggleConfirmation,
            validator: confirmationValidator,
          ),
        ],
      ],
    );
  }
}
