import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skann_app/core/routing/app_routes.dart';
import 'package:skann_app/core/theme/app_text_styles.dart';

class LoginRegistrationLink extends StatelessWidget {
  const LoginRegistrationLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'لسه معندكش حساب؟ ',
          style: AppTextStyles.secondaryTextW400S17.copyWith(fontSize: 12.sp),
        ),
        TextButton(
          onPressed: () => context.push(AppRoutes.register),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'أنشئ حساب جديد',
            style: AppTextStyles.primaryW500S16.copyWith(fontSize: 12.sp),
          ),
        ),
      ],
    );
  }
}
