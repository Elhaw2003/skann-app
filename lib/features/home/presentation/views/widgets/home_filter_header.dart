import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeFilterHeader extends StatelessWidget {
  const HomeFilterHeader({required this.onReset, super.key});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 13.h, 18.w, 10.h),
      child: Column(
        children: [
          Container(
            width: 42.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFD8E0EA),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 15.h),
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(13.r),
                ),
                child: const Icon(Icons.tune_rounded, color: Color(0xFF0B67C8)),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ظبّط اختياراتك',
                      style: TextStyle(
                        color: const Color(0xFF203A59),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'اختار اللي يناسب احتياجك',
                      style: TextStyle(
                        color: const Color(0xFF8794A5),
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onReset,
                child: Text(
                  'مسح الكل',
                  style: TextStyle(
                    color: const Color(0xFF0B67C8),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeFilterActions extends StatelessWidget {
  const HomeFilterActions({required this.onApply, super.key});

  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 11.h, 18.w, 12.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8EDF3))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52.h,
        child: FilledButton.icon(
          onPressed: onApply,
          icon: const Icon(Icons.check_rounded),
          label: const Text('عرض السكنات المناسبة'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0B67C8),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.r),
            ),
            textStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
