import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skann_app/core/utils/app_colors.dart';
import 'package:skann_app/core/utils/app_text_style.dart';

class CustomButtonWidget extends StatelessWidget {
  const CustomButtonWidget({
    super.key,
    this.buttonColor,
    this.title,
    this.titleStyle,
    this.prefixIcon,
    this.prefixIconColor,
    this.prefixIconSize,
    this.prefixSvgIcon,
    this.suffixIcon,
    this.suffixIconColor,
    this.suffixIconSize,
    this.suffixSvgIcon,
    this.overlayColor,
    this.borderRadiusButton,
    this.borderSideColor,
    this.borderSideWidth,
    this.onPressed,
    required this.buttonWidth,
    this.buttonHeight,
    this.child,
  });

  final Color? buttonColor;
  final Color? overlayColor;
  final Color? borderSideColor;
  final String? title;
  final TextStyle? titleStyle;

  final IconData? prefixIcon;
  final Color? prefixIconColor;
  final double? prefixIconSize;
  final IconData? suffixIcon;
  final Color? suffixIconColor;
  final double? suffixIconSize;

  final String? prefixSvgIcon;
  final String? suffixSvgIcon;

  final double? borderRadiusButton;
  final double? borderSideWidth;
  final double buttonWidth;
  final double? buttonHeight;
  final void Function()? onPressed;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonHeight?.h ?? 55.h,
      width: buttonWidth.w,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(
            buttonColor ?? AppColors.primaryColor,
          ),
          overlayColor: WidgetStatePropertyAll(
            overlayColor ?? AppColors.whiteColor.withValues(alpha: 0.5),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                borderRadiusButton?.r ?? 12.r,
              ),
              side: BorderSide(
                color: borderSideColor ?? Colors.transparent,
                width: borderSideWidth ?? 1.w,
              ),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildPrefixIcon(),
            if (prefixIcon != null || prefixSvgIcon != null)
              SizedBox(width: 8.w),
            Expanded(
              child: Center(
                child:
                    child ??
                    Text(
                      title ?? "",
                      textAlign: TextAlign.center,
                      style: titleStyle ?? AppTextStyle.whiteW500S27,
                    ),
              ),
            ),

            if (suffixIcon != null || suffixSvgIcon != null)
              SizedBox(width: 8.w),
            buildSuffixIcon(),
          ],
        ),
      ),
    );
  }

  Widget buildPrefixIcon() {
    if (prefixSvgIcon != null) {
      return SvgPicture.asset(
        prefixSvgIcon!,
        width: prefixIconSize?.w ?? 24.w,
        height: prefixIconSize?.h ?? 24.h,
        colorFilter: prefixIconColor != null
            ? ColorFilter.mode(prefixIconColor!, BlendMode.srcIn)
            : null,
      );
    } else if (prefixIcon != null) {
      return Icon(
        prefixIcon,
        color: prefixIconColor ?? AppColors.whiteColor,
        size: prefixIconSize ?? 24.sp,
      );
    }
    return const SizedBox.shrink();
  }

  Widget buildSuffixIcon() {
    if (suffixSvgIcon != null) {
      return SvgPicture.asset(
        suffixSvgIcon!,
        width: suffixIconSize?.w ?? 24.w,
        height: suffixIconSize?.h ?? 24.h,
        colorFilter: suffixIconColor != null
            ? ColorFilter.mode(suffixIconColor!, BlendMode.srcIn)
            : null,
      );
    } else if (suffixIcon != null) {
      return Icon(
        suffixIcon,
        color: suffixIconColor ?? AppColors.whiteColor,
        size: suffixIconSize ?? 24.sp,
      );
    }
    return const SizedBox.shrink();
  }
}
