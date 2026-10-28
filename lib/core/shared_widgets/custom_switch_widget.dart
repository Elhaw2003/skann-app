import 'package:flutter/material.dart';
import 'package:skann_app/core/theme/app_colors.dart';

class CustomSwitchWidget extends StatelessWidget {
  const CustomSwitchWidget({
    super.key,
    this.value,
    this.onChanged,
    this.activeThumbColor,
    this.inactiveThumbColor,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.overlayColor,
    this.trackOutlineColor,
    this.trackOutlineWidth,
  });
  final bool? value;
  final void Function(bool)? onChanged;
  final Color? activeThumbColor;
  final Color? inactiveThumbColor;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final WidgetStateProperty<Color?>? overlayColor;
  final WidgetStateProperty<Color?>? trackOutlineColor;
  final WidgetStateProperty<double?>? trackOutlineWidth;
  @override
  Widget build(BuildContext context) {
    return Switch(
      overlayColor:
          overlayColor ??
          WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryColor.withValues(
                alpha: 0.1,
              ); // تأثير أزرق خفيف للـ Active
            }
            return AppColors.grey200Color.withValues(
              alpha: 0.1,
            ); // تأثير رمادي خفيف للـ Inactive
          }),
      thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return activeThumbColor ?? AppColors.primaryColor;
        }
        return inactiveThumbColor ??
            AppColors.blackColor; // أسود لما يكون False
      }),

      trackColor: WidgetStateProperty.all(
        AppColors.whiteColor,
      ), // تراك أبيض ثابت
      // التحديد الخارجي (البرواز)
      trackOutlineColor:
          trackOutlineColor ??
          WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryColor.withValues(
                alpha: 0.5,
              ); // تحديد أزرق خفيف للـ Active
            }
            return AppColors.grey200Color; // تحديد رمادي للـ Inactive
          }),

      trackOutlineWidth: trackOutlineWidth ?? const WidgetStatePropertyAll(1.0),
      value: value ?? false,
      onChanged: onChanged,
    );
  }
}
