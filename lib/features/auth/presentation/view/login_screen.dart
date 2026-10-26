import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/shared_widgets/custom_button_widget.dart';
import 'package:skann_app/core/shared_widgets/custom_text_field_widget.dart';
import 'package:skann_app/core/theme/app_colors.dart';
import 'package:skann_app/core/theme/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 420.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90.w,
                      height: 90.h,
                      decoration: BoxDecoration(
                        color: AppColors.splashLogoBackgroundColor,
                        borderRadius: BorderRadius.circular(26.r),
                      ),
                      child: Icon(
                        Icons.home_rounded,
                        color: AppColors.primaryColor,
                        size: 46.sp,
                      ),
                    ),
                    SizedBox(height: 26.h),
                    Text(
                      'مرحبًا بعودتك',
                      style: AppTextStyles.primaryTextW600S22,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'سجل دخولك للوصول إلى السكن المناسب لك',
                      style: AppTextStyles.splashSubtitle,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'البريد الإلكتروني',
                        style: AppTextStyles.primaryTextW500S17,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    CustomTextFieldWidget(
                      controller: _emailController,
                      hintText: 'example@email.com',
                      prefixIcon: Icons.email_outlined,
                      prefixColor: AppColors.primaryColor,
                      enableBorderRadius: 16,
                      focusBorderRadius: 16,
                      enableBorderColor: AppColors.grey100Color,
                      focusBorderColor: AppColors.primaryColor,
                      fillColor: AppColors.whiteColor,
                    ),
                    SizedBox(height: 20.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'كلمة المرور',
                        style: AppTextStyles.primaryTextW500S17,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    CustomTextFieldWidget(
                      controller: _passwordController,
                      hintText: '••••••••',
                      prefixIcon: Icons.lock_outline_rounded,
                      prefixColor: AppColors.primaryColor,
                      obscureText: true,
                      enableBorderRadius: 16,
                      focusBorderRadius: 16,
                      enableBorderColor: AppColors.grey100Color,
                      focusBorderColor: AppColors.primaryColor,
                      fillColor: AppColors.whiteColor,
                    ),
                    SizedBox(height: 12.h),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryColor,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'هل نسيت كلمة المرور؟',
                          style: AppTextStyles.primaryW500S16,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    CustomButtonWidget(
                      title: 'تسجيل الدخول',
                      buttonWidth: double.infinity,
                      buttonColor: AppColors.primaryColor,
                      titleStyle: AppTextStyles.whiteW500S20,
                      onPressed: () {},
                      borderRadiusButton: 16,
                    ),
                    SizedBox(height: 22.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ليس لديك حساب؟',
                          style: AppTextStyles.secondaryTextW400S17,
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'إنشاء حساب جديد',
                            style: AppTextStyles.primaryW500S16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
