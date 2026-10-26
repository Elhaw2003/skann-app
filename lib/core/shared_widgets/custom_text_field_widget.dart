import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/theme/app_colors.dart';
import 'package:skann_app/core/theme/app_text_styles.dart';

class CustomTextFieldWidget extends StatelessWidget {
  const CustomTextFieldWidget({
    super.key,
    this.controller,
    this.minLines,
    this.maxLines,
    this.helperMaxLines,
    this.keyboardType,
    this.obscureText,
    this.validator,
    this.keyboardAppearance,
    this.cursorColor,
    this.obscuringCharacter,
    this.selectionColor,
    this.selectionHandleColor,
    this.enableBorderRadius,
    this.focusBorderRadius,
    this.errorBorderRadius,
    this.enableBorderSide,
    this.focusBorderSide,
    this.errorBorderSide,
    this.fillColor,
    this.enableBorderColor,
    this.errorBorderColor,
    this.focusBorderColor,
    this.hintText,
    this.hintTextStyle,
    this.helperText,
    this.helperTextStyle,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixColor,
    this.prefixColor,
    this.suffixSize,
    this.prefixSize,
    this.suffixOnPressed,
    this.prefixOnPressed,
    this.textDirection,
    this.hintTextDirection,
    this.width,
    this.fieldEnabled,
    this.inputFormatters,
    this.onChanged,
    this.focusNode,
    this.autoFocus,
  });

  final TextEditingController? controller;
  final int? minLines;
  final int? maxLines;
  final int? helperMaxLines;
  final TextInputType? keyboardType;
  final bool? obscureText;
  final String? Function(String?)? validator;
  final Brightness? keyboardAppearance;
  final Color? fillColor;
  final Color? cursorColor;
  final Color? selectionColor;
  final Color? selectionHandleColor;
  final Color? enableBorderColor;
  final Color? errorBorderColor;
  final Color? focusBorderColor;
  final String? obscuringCharacter;
  final double? enableBorderRadius;
  final double? focusBorderRadius;
  final double? errorBorderRadius;
  final double? enableBorderSide;
  final double? focusBorderSide;
  final double? errorBorderSide;
  final String? hintText;
  final String? helperText;
  final TextStyle? hintTextStyle;
  final TextStyle? helperTextStyle;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Color? suffixColor;
  final Color? prefixColor;
  final double? suffixSize;
  final double? prefixSize;
  final void Function()? suffixOnPressed;
  final void Function()? prefixOnPressed;
  final TextDirection? textDirection;
  final TextDirection? hintTextDirection;
  final double? width;
  final bool? fieldEnabled;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final bool? autoFocus;
  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return SizedBox(
      width: width ?? double.infinity,
      child: Theme(
        data: ThemeData(
          textSelectionTheme: TextSelectionThemeData(
            selectionColor:
                selectionColor ?? AppColors.primaryColor.withOpacity(0.5),
            selectionHandleColor:
                selectionHandleColor ?? AppColors.primaryColor,
          ),
        ),
        child: TextFormField(
          autofocus: autoFocus ?? false,
          focusNode: focusNode,
          enabled: fieldEnabled ?? true,
          scrollPadding: EdgeInsets.only(
            bottom: 150.h,
          ), // 👈 بيزود مساحة وهمية تحت الفيلد في السكرول
          controller: controller,
          onChanged: onChanged,
          minLines: minLines ?? 1,
          maxLines: obscureText == true ? 1 : (maxLines ?? minLines ?? 1),
          keyboardType: keyboardType ?? TextInputType.text,
          obscureText: obscureText ?? false,
          validator: validator,
          keyboardAppearance: keyboardAppearance ?? Brightness.light,
          cursorColor: cursorColor ?? AppColors.primaryColor,
          obscuringCharacter: obscuringCharacter ?? "•",
          textDirection: textDirection,
          inputFormatters: inputFormatters,
          textAlign: isRTL ? TextAlign.right : TextAlign.left,
          decoration: InputDecoration(
            hintTextDirection:
                hintTextDirection ??
                (isRTL ? TextDirection.rtl : TextDirection.ltr),
            helperText: helperText,
            helperStyle: helperTextStyle ?? AppTextStyles.grey300W400S16,
            helperMaxLines: helperMaxLines ?? 1,
            hintText: hintText,
            hintStyle: hintTextStyle ?? AppTextStyles.grey300W400S16,
            fillColor: fillColor ?? AppColors.whiteColor,
            filled: true,

            // Prefix Icon
            prefixIcon: prefixIcon != null
                ? IconButton(
                    onPressed: prefixOnPressed,
                    icon: Icon(
                      prefixIcon,
                      color: prefixColor ?? AppColors.primaryTextColor,
                      size: prefixSize?.sp ?? 25.sp,
                    ),
                  )
                : null,

            // Suffix Icon
            suffixIcon: suffixIcon != null
                ? IconButton(
                    onPressed: suffixOnPressed,
                    highlightColor: AppColors.primaryColor.withOpacity(0.3),
                    icon: Icon(
                      suffixIcon,
                      color: suffixColor ?? AppColors.secondaryTextColor,
                      size: suffixSize?.sp ?? 25.sp,
                    ),
                  )
                : null,

            // Borders
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(enableBorderRadius?.r ?? 8.r),
              borderSide: BorderSide(
                color: enableBorderColor ?? AppColors.grey100Color,
                width: enableBorderSide ?? 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(focusBorderRadius?.r ?? 8.r),
              borderSide: BorderSide(
                color: focusBorderColor ?? AppColors.primaryColor,
                width: focusBorderSide ?? 1.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(errorBorderRadius?.r ?? 8.r),
              borderSide: BorderSide(
                color: errorBorderColor ?? AppColors.redColor,
                width: errorBorderSide ?? 1.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(errorBorderRadius?.r ?? 8.r),
              borderSide: BorderSide(
                color: errorBorderColor ?? AppColors.redColor,
                width: errorBorderSide ?? 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
