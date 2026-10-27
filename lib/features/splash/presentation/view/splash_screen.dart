import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skann_app/core/services/secure_storage_helper.dart';
import 'package:skann_app/core/routing/app_routes.dart';
import 'package:skann_app/core/theme/app_colors.dart';
import 'package:skann_app/core/theme/app_text_styles.dart';
import 'package:skann_app/core/utils/app_strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({required this.secureStorageHelper, super.key});

  final SecureStorageHelper secureStorageHelper;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scaleAnimation = Tween<double>(
      begin: 0.75,
      end: 1,
    ).chain(CurveTween(curve: Curves.easeOutBack)).animate(_controller);

    _controller.forward();

    _navigationTimer = Timer(const Duration(seconds: 4), () {
      unawaited(_navigateToInitialRoute());
    });
  }

  Future<void> _navigateToInitialRoute() async {
    if (!mounted) return;

    try {
      final isLoggedIn = await widget.secureStorageHelper.isLoggedIn();
      final userType = await widget.secureStorageHelper.getUserType();
      if (!mounted) return;

      context.go(
        isLoggedIn && userType == 'STUDENT'
            ? AppRoutes.studentHome
            : AppRoutes.login,
      );
    } on PlatformException catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'splash screen',
          context: ErrorDescription('while reading saved authentication'),
        ),
      );
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 106.w,
                  height: 106.h,
                  decoration: BoxDecoration(
                    color: AppColors.splashLogoBackgroundColor,
                    borderRadius: BorderRadius.circular(26.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.home_rounded,
                    color: AppColors.primaryColor,
                    size: 54.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  AppStrings.appNameArabic,
                  style: AppTextStyles.splashTitle.copyWith(
                    fontSize: 42.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28.w),
                  child: Text(
                    AppStrings.splashSubtitle,
                    style: AppTextStyles.splashSubtitle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
