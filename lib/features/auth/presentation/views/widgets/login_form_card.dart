import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/theme/app_colors.dart';
import 'package:skann_app/core/theme/app_text_styles.dart';
import 'package:skann_app/features/auth/presentation/views/widgets/login_form_fields.dart';
import 'package:skann_app/features/auth/presentation/views/widgets/login_submit_section.dart';

class LoginFormCard extends StatelessWidget {
  const LoginFormCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.emailValidator,
    required this.passwordValidator,
    required this.onSubmit,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final FormFieldValidator<String> emailValidator;
  final FormFieldValidator<String> passwordValidator;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF193B66).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'تسجيل الدخول',
              style: AppTextStyles.primaryTextW600S22.copyWith(
                color: const Color(0xFF17385F),
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              'استخدم بريدك الإلكتروني وكلمة المرور',
              style: AppTextStyles.splashSubtitle.copyWith(fontSize: 11.sp),
            ),
            SizedBox(height: 22.h),
            LoginFormFields(
              emailController: emailController,
              passwordController: passwordController,
              obscurePassword: obscurePassword,
              onTogglePassword: onTogglePassword,
              emailValidator: emailValidator,
              passwordValidator: passwordValidator,
            ),
            SizedBox(height: 15.h),
            LoginSubmitSection(onSubmit: onSubmit),
          ],
        ),
      ),
    );
  }
}
