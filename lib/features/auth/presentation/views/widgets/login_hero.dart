import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/theme/app_colors.dart';
import 'package:skann_app/core/theme/app_text_styles.dart';

class LoginHero extends StatelessWidget {
  const LoginHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22.w, 24.h, 22.w, 25.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0877E8), Color(0xFF0646A8)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(26.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0756B8).withValues(alpha: 0.2),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: -25.w,
            top: -42.h,
            child: _HeroCircle(size: 130.w, opacity: 0.07),
          ),
          PositionedDirectional(
            start: 4.w,
            bottom: -62.h,
            child: _HeroCircle(size: 104.w, opacity: 0.06),
          ),
          Column(
            children: [
              Container(
                width: 66.w,
                height: 66.h,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(21.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  Icons.home_work_rounded,
                  color: AppColors.whiteColor,
                  size: 34.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'أهلاً بيك في سكن',
                textAlign: TextAlign.center,
                style: AppTextStyles.whiteW500S22.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 7.h),
              Text(
                'سجّل دخولك واكمل رحلتك لسكنك المناسب',
                textAlign: TextAlign.center,
                style: AppTextStyles.whiteW500S17.copyWith(
                  fontSize: 12.sp,
                  color: Colors.white.withValues(alpha: 0.88),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroCircle extends StatelessWidget {
  const _HeroCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
