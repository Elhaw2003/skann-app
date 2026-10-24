import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomHeightSpacingWidget extends StatelessWidget {
  const CustomHeightSpacingWidget({super.key, required this.height});
  final double height;
  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height.h);
  }
}

class CustomWidthSpacingWidget extends StatelessWidget {
  const CustomWidthSpacingWidget({super.key, required this.width});
  final double width;
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width.w);
  }
}
