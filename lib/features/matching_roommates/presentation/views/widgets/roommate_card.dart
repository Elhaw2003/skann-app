import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/theme/app_colors.dart';
import 'package:skann_app/features/matching_roommates/data/models/roommate_model.dart';

class RoommateCard extends StatelessWidget {
  const RoommateCard({required this.roommate, super.key});

  final RoommateModel roommate;

  @override
  Widget build(BuildContext context) {
    final gender = _genderLabel(roommate.gender);
    final housingStatus = _cleanText(roommate.housingStatus);
    final bio = _cleanText(roommate.bio);
    final interests = roommate.interests
        .map(_cleanText)
        .whereType<String>()
        .toList(growable: false);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE8EDF4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF20344F).withValues(alpha: 0.035),
            blurRadius: 12.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RoommateAvatar(imageUrl: roommate.profileImage),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_cleanText(roommate.fullName) case final name?)
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF172A43),
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    if (gender != null) ...[
                      SizedBox(height: 3.h),
                      Text(
                        gender,
                        style: TextStyle(
                          color: const Color(0xFF71809A),
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                    if (housingStatus != null) ...[
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF8F6),
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: Text(
                          housingStatus,
                          style: TextStyle(
                            color: const Color(0xFF0D706B),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (_hasAcademicOrLocationDetails) ...[
            SizedBox(height: 13.h),
            const Divider(height: 1, color: Color(0xFFEFF2F6)),
            SizedBox(height: 11.h),
            if (_cleanText(roommate.university) case final university?)
              _RoommateInfoRow(
                icon: Icons.account_balance_outlined,
                text: university,
              ),
            if (_cleanText(roommate.faculty) case final faculty?)
              _RoommateInfoRow(icon: Icons.school_outlined, text: faculty),
            if (_cleanText(roommate.major) case final major?)
              _RoommateInfoRow(icon: Icons.menu_book_outlined, text: major),
            if (_cleanText(roommate.academicYear) case final academicYear?)
              _RoommateInfoRow(
                icon: Icons.calendar_month_outlined,
                text: academicYear,
              ),
            if (_cleanText(roommate.governorate) case final governorate?)
              _RoommateInfoRow(
                icon: Icons.location_on_outlined,
                text: governorate,
              ),
          ],
          if (bio != null) ...[
            SizedBox(height: 11.h),
            Text(
              bio,
              style: TextStyle(
                color: const Color(0xFF52647A),
                fontSize: 12.sp,
                height: 1.6,
              ),
            ),
          ],
          if (interests.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: interests
                  .map(
                    (interest) => Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 9.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4FA),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        interest,
                        style: TextStyle(
                          color: const Color(0xFF52647A),
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
          if (_cleanText(roommate.phone) case final phone?) ...[
            SizedBox(height: 11.h),
            _RoommateInfoRow(
              icon: Icons.phone_outlined,
              text: phone,
              textColor: AppColors.primaryColor,
            ),
          ],
        ],
      ),
    );
  }

  bool get _hasAcademicOrLocationDetails =>
      _cleanText(roommate.university) != null ||
      _cleanText(roommate.faculty) != null ||
      _cleanText(roommate.major) != null ||
      _cleanText(roommate.academicYear) != null ||
      _cleanText(roommate.governorate) != null;
}

class _RoommateAvatar extends StatelessWidget {
  const _RoommateAvatar({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = _cleanText(imageUrl);
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.r),
      child: SizedBox(
        width: 58.w,
        height: 58.w,
        child: url == null
            ? const _FallbackAvatar()
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const _FallbackAvatar(),
                placeholder: (context, url) => const _FallbackAvatar(),
              ),
      ),
    );
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFEAF2FC),
      child: Icon(
        Icons.person_rounded,
        color: AppColors.primaryColor,
        size: 31.sp,
      ),
    );
  }
}

class _RoommateInfoRow extends StatelessWidget {
  const _RoommateInfoRow({
    required this.icon,
    required this.text,
    this.textColor = const Color(0xFF52647A),
  });

  final IconData icon;
  final String text;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 7.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15.sp, color: const Color(0xFF7F90A6)),
          SizedBox(width: 7.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: textColor, fontSize: 11.sp, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

String? _cleanText(String? value) {
  if (value == null || value.trim().isEmpty || value.trim() == 'null') {
    return null;
  }
  return value.trim();
}

String? _genderLabel(String? value) {
  final gender = _cleanText(value)?.toUpperCase();
  return switch (gender) {
    'MALE' => 'ذكر',
    'FEMALE' => 'أنثى',
    null => null,
    _ => _cleanText(value),
  };
}
