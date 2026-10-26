import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skann_app/core/routing/app_routes.dart';
import 'package:skann_app/core/shared_widgets/custom_button_widget.dart';
import 'package:skann_app/core/theme/app_colors.dart';
import 'package:skann_app/core/theme/app_text_styles.dart';
import 'package:skann_app/features/auth/presentation/cubit/auth_states.dart';

class RegistrationStatusMessage extends StatelessWidget {
  const RegistrationStatusMessage({required this.state, super.key});

  final AuthStates state;

  @override
  Widget build(BuildContext context) {
    if (state is! AuthSuccess && state is! AuthFailureState) {
      return const SizedBox.shrink();
    }

    final isSuccess = state is AuthSuccess;
    final color = isSuccess ? const Color(0xFF14804A) : AppColors.redColor;
    final message = switch (state) {
      AuthSuccess() => 'تم إنشاء الحساب بنجاح.',
      AuthFailureState(:final message) => message,
      _ => '',
    };
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.error_outline,
            color: color,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(message, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
}

class RegistrationSubmitButton extends StatelessWidget {
  const RegistrationSubmitButton({
    required this.title,
    required this.isLoading,
    required this.onPressed,
    super.key,
  });

  final String title;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CustomButtonWidget(
      title: title,
      buttonWidth: double.infinity,
      buttonHeight: 60.h,
      borderRadiusButton: 15,
      suffixIcon: Icons.arrow_forward,
      suffixIconSize: 20,
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              width: 22.w,
              height: 22.h,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.whiteColor,
              ),
            )
          : null,
    );
  }
}

class RegistrationLoginLink extends StatelessWidget {
  const RegistrationLoginLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('لديك حساب بالفعل؟ ', style: AppTextStyles.splashSubtitle),
        TextButton(
          onPressed: () => context.go(AppRoutes.login),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text('تسجيل الدخول', style: AppTextStyles.primaryW500S16),
        ),
      ],
    );
  }
}
