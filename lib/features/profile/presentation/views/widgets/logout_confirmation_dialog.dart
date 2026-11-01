import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/errors/failure.dart';

class LogoutConfirmationResult {
  const LogoutConfirmationResult({required this.didLogout, this.message});

  final bool didLogout;
  final String? message;
}

Future<LogoutConfirmationResult?> showLogoutConfirmationDialog(
  BuildContext context, {
  required Future<Failure?> Function() onConfirm,
}) async {
  return showDialog<LogoutConfirmationResult>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _LogoutConfirmationDialog(onConfirm: onConfirm),
  );
}

class _LogoutConfirmationDialog extends StatefulWidget {
  const _LogoutConfirmationDialog({required this.onConfirm});

  final Future<Failure?> Function() onConfirm;

  @override
  State<_LogoutConfirmationDialog> createState() =>
      _LogoutConfirmationDialogState();
}

class _LogoutConfirmationDialogState extends State<_LogoutConfirmationDialog> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF14263F).withValues(alpha: 0.18),
              blurRadius: 28.r,
              offset: Offset(0, 12.h),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Padding(
              padding: EdgeInsets.fromLTRB(22.w, 20.h, 22.w, 22.h),
              child: Column(
                children: [
                  Text(
                    'هل أنت متأكد من تسجيل الخروج؟',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF172A43),
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'سننهي جلستك الحالية، ويمكنك العودة في أي وقت بتسجيل الدخول مرة أخرى.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF71809A),
                      fontSize: 12.sp,
                      height: 1.65,
                    ),
                  ),
                  SizedBox(height: 21.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF53657D),
                            side: const BorderSide(color: Color(0xFFE1E8F0)),
                            padding: EdgeInsets.symmetric(vertical: 13.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: const Text('البقاء'),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _isLoading ? null : _confirmLogout,
                          icon: _isLoading
                              ? SizedBox(
                                  width: 17.w,
                                  height: 17.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.logout_rounded, size: 18),
                          label: Text(
                            _isLoading ? 'جارٍ الخروج' : 'تسجيل الخروج',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFD63E3E),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 13.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            textStyle: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 25.h, bottom: 20.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFFFF1EF), Color(0xFFFFE6E2)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -25.h,
            right: 24.w,
            child: Container(
              width: 75.w,
              height: 75.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.34),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -34.h,
            left: 32.w,
            child: Container(
              width: 86.w,
              height: 86.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.28),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            width: 76.w,
            height: 76.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD63E3E).withValues(alpha: 0.12),
                  blurRadius: 16.r,
                  offset: Offset(0, 5.h),
                ),
              ],
            ),
            child: Icon(
              Icons.logout_rounded,
              color: const Color(0xFFD63E3E),
              size: 34.sp,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
    setState(() {
      _isLoading = true;
    });

    final failure = await widget.onConfirm();
    if (!mounted) return;
    if (failure != null) {
      Navigator.of(context).pop(
        LogoutConfirmationResult(didLogout: false, message: failure.message),
      );
      return;
    }

    Navigator.of(context).pop(
      const LogoutConfirmationResult(
        didLogout: true,
        message: 'تم تسجيل الخروج بنجاح',
      ),
    );
  }
}
