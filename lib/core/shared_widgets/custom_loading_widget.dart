import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/utils/app_colors.dart';

class CustomLoadingWidget extends StatelessWidget {
  const CustomLoadingWidget({
    super.key,
    this.color,
    this.strokeWidth,
    this.strokeAlign,
    this.cicleHeight,
    this.cicleWidth,
  });
  final Color? color;
  final double? strokeWidth;
  final double? strokeAlign;
  final double? cicleHeight;
  final double? cicleWidth;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: cicleHeight?.sp ?? 30.sp,
        width: cicleWidth?.sp ?? 30.sp,
        child: CircularProgressIndicator(
          color: color ?? AppColors.primaryColor,
          strokeWidth: strokeWidth?.w ?? 4.w,
          strokeAlign: strokeAlign,
        ),
      ),
    );
  }
}
