import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/shared_widgets/custom_text_field_widget.dart';
import 'package:skann_app/core/theme/app_text_styles.dart';

class LoginFormFields extends StatelessWidget {
  const LoginFormFields({
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.emailValidator,
    required this.passwordValidator,
    super.key,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final FormFieldValidator<String> emailValidator;
  final FormFieldValidator<String> passwordValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LoginFieldLabel('البريد الإلكتروني'),
        SizedBox(height: 7.h),
        CustomTextFieldWidget(
          controller: emailController,
          hintText: 'example@email.com',
          prefixIcon: Icons.alternate_email_rounded,
          prefixColor: const Color(0xFF8194AE),
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          validator: emailValidator,
          enableBorderRadius: 15,
          focusBorderRadius: 15,
          errorBorderRadius: 15,
          enableBorderColor: const Color(0xFFE5EAF2),
          focusBorderColor: const Color(0xFF1780E8),
          fillColor: const Color(0xFFFBFCFE),
        ),
        SizedBox(height: 17.h),
        _LoginFieldLabel('كلمة المرور'),
        SizedBox(height: 7.h),
        CustomTextFieldWidget(
          controller: passwordController,
          hintText: 'أدخل كلمة المرور',
          prefixIcon: Icons.lock_outline_rounded,
          prefixColor: const Color(0xFF8194AE),
          suffixIcon: obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          suffixColor: const Color(0xFF8194AE),
          suffixOnPressed: onTogglePassword,
          obscureText: obscurePassword,
          validator: passwordValidator,
          enableBorderRadius: 15,
          focusBorderRadius: 15,
          errorBorderRadius: 15,
          enableBorderColor: const Color(0xFFE5EAF2),
          focusBorderColor: const Color(0xFF1780E8),
          fillColor: const Color(0xFFFBFCFE),
        ),
        SizedBox(height: 6.h),
      ],
    );
  }
}

class _LoginFieldLabel extends StatelessWidget {
  const _LoginFieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.primaryTextW500S17.copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
