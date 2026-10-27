import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/features/auth/data/models/registration_response_model.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({required this.user, super.key});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final displayName = user.displayName;
    final email = _nonEmpty(user.email);
    final phone = _nonEmpty(user.phone);
    final imageUrl = _nonEmpty(user.profileImage);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.r),
        border: Border.all(color: const Color(0xFFE7EDF5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF294663).withValues(alpha: 0.06),
            blurRadius: 18.r,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 86.h,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFFE6F0FF), Color(0xFFE2F8F3)],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: -20.w,
                  top: -50.h,
                  child: Container(
                    width: 130.w,
                    height: 130.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.34),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: Offset(0, -44.h),
            child: Column(
              children: [
                _ProfileAvatar(imageUrl: imageUrl),
                SizedBox(height: 7.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D756D),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    _roleLabel(user.role),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    displayName.isEmpty ? 'مرحبًا بك' : displayName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: const Color(0xFF162B45),
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (email != null || phone != null) ...[
                  SizedBox(height: 15.h),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F6FB),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      runSpacing: 9.h,
                      children: [
                        if (email != null)
                          _ContactDetail(
                            icon: Icons.alternate_email_rounded,
                            value: email,
                          ),
                        if (phone != null)
                          _ContactDetail(
                            icon: Icons.phone_outlined,
                            value: phone,
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: email != null || phone != null ? 0 : 10.h),
        ],
      ),
    );
  }

  String? _nonEmpty(String? value) {
    if (value == null || value.trim().isEmpty || value.trim() == 'null') {
      return null;
    }
    return value.trim();
  }

  String _roleLabel(String role) {
    return switch (role.toUpperCase()) {
      'STUDENT' => 'طالب سكن',
      'OWNER' => 'مالك سكن',
      _ => role.replaceAll('_', ' ').toLowerCase(),
    };
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: const Color(0xFFEAF2FC),
      alignment: Alignment.center,
      child: Icon(
        Icons.person_rounded,
        size: 42.sp,
        color: const Color(0xFF7C91AB),
      ),
    );

    return Container(
      width: 88.w,
      height: 88.w,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF203A59).withValues(alpha: 0.12),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl == null
            ? fallback
            : CachedNetworkImage(
                imageUrl: imageUrl!,
                width: 80.w,
                height: 80.w,
                fit: BoxFit.cover,
                placeholder: (context, url) => fallback,
                errorWidget: (context, url, error) => fallback,
              ),
      ),
    );
  }
}

class _ContactDetail extends StatelessWidget {
  const _ContactDetail({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15.sp, color: const Color(0xFF0B75C9)),
        SizedBox(width: 5.w),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 190.w),
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF52647A),
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
