import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileEditIntroCard extends StatelessWidget {
  const ProfileEditIntroCard({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(17.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE9F1FF), Color(0xFFE8F8F5)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              color: Color(0xFF3B82F6),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حدّث بياناتك بسهولة',
                  style: TextStyle(
                    color: const Color(0xFF20344F),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  name.isEmpty
                      ? 'غيّر الحقول التي تريد تحديثها فقط'
                      : 'مرحبًا $name، يمكنك تعديل أي بيانات ترغب بها',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF64758B),
                    fontSize: 11.sp,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
