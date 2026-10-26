import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/shared_widgets/custom_button_widget.dart';
import 'package:skann_app/core/theme/app_colors.dart';
import 'package:skann_app/core/theme/app_text_styles.dart';
import 'package:skann_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:skann_app/features/auth/presentation/cubit/auth_states.dart';

class LoginSubmitSection extends StatelessWidget {
  const LoginSubmitSection({required this.onSubmit, super.key});

  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _LoginErrorMessage(),
        BlocBuilder<AuthCubit, AuthStates>(
          buildWhen: (previous, current) =>
              previous.runtimeType != current.runtimeType,
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return CustomButtonWidget(
              title: 'تسجيل الدخول',
              buttonWidth: double.infinity,
              buttonHeight: 56,
              buttonColor: const Color(0xFF0868CE),
              titleStyle: AppTextStyles.whiteW500S20,
              suffixIcon: Icons.arrow_forward_rounded,
              suffixIconSize: 20,
              borderRadiusButton: 15,
              onPressed: isLoading ? null : onSubmit,
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
          },
        ),
      ],
    );
  }
}

class _LoginErrorMessage extends StatelessWidget {
  const _LoginErrorMessage();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthStates>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType || previous != current,
      builder: (context, state) {
        if (state is! AuthFailureState) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Container(
            padding: EdgeInsets.all(11.w),
            decoration: BoxDecoration(
              color: AppColors.redColor.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.redColor,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    state.message,
                    style: TextStyle(
                      color: AppColors.redColor,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
