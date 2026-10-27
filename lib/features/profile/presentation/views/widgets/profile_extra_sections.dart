import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/features/profile/presentation/views/widgets/profile_information_section.dart';

class ProfileInterestsSection extends StatelessWidget {
  const ProfileInterestsSection({required this.interests, super.key});

  final List<String> interests;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFE8EDF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Color(0xFF0D8B83)),
              SizedBox(width: 8.w),
              Text(
                'اهتماماتي',
                style: TextStyle(
                  color: const Color(0xFF20344F),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: interests
                .map(
                  (interest) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF8F6),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Text(
                      interest.trim(),
                      style: TextStyle(
                        color: const Color(0xFF0D706B),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class ProfileAccountSection extends StatelessWidget {
  const ProfileAccountSection({
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    super.key,
  });

  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  Widget build(BuildContext context) {
    final accountFields = <ProfileField>[
      if (isActive case final active?)
        ProfileField(
          label: 'حالة الحساب',
          value: active ? 'نشط' : 'غير نشط',
          icon: active ? Icons.check_circle_outline : Icons.info_outline,
        ),
      if (createdAt case final creationDate?)
        ProfileField(
          label: 'تاريخ الانضمام',
          value: _formatDate(creationDate),
          icon: Icons.event_available_outlined,
        ),
      if (updatedAt case final updateDate?)
        ProfileField(
          label: 'آخر تحديث للبيانات',
          value: _formatDate(updateDate),
          icon: Icons.update_rounded,
        ),
    ];
    return ProfileInformationSection(
      title: 'الحساب',
      icon: Icons.verified_user_outlined,
      fields: accountFields,
      accentColor: const Color(0xFF59718D),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class ProfileLogoutButton extends StatelessWidget {
  const ProfileLogoutButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54.h,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.logout_rounded),
        label: const Text('تسجيل الخروج'),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFFFEEEE),
          foregroundColor: const Color(0xFFD63E3E),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17.r),
          ),
          textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
