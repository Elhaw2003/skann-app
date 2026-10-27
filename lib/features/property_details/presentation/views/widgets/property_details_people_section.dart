import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skann_app/features/home/data/models/property_model.dart';
import 'package:skann_app/features/property_details/presentation/views/widgets/property_details_common_widgets.dart';

class PropertyResidentsSection extends StatelessWidget {
  const PropertyResidentsSection({required this.residents, super.key});

  final List<PropertyResidentModel> residents;

  @override
  Widget build(BuildContext context) {
    return PropertySectionCard(
      title: 'المقيمون حاليًا',
      child: Column(
        children: [
          for (var index = 0; index < residents.length; index++) ...[
            if (index > 0)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: const Divider(height: 1, color: Color(0xFFEEF1F5)),
              ),
            _ResidentRow(resident: residents[index]),
          ],
        ],
      ),
    );
  }
}

class _ResidentRow extends StatelessWidget {
  const _ResidentRow({required this.resident});

  final PropertyResidentModel resident;

  @override
  Widget build(BuildContext context) {
    final academicInfo = [
      resident.university,
      resident.faculty,
      resident.major,
      resident.academicYear,
      resident.roomName,
    ].where(hasPropertyText).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PersonAvatar(imageUrl: resident.profileImage, radius: 24.r),
        SizedBox(width: 11.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasPropertyText(resident.fullName))
                Text(
                  resident.fullName!,
                  style: TextStyle(
                    color: const Color(0xFF1D3553),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (academicInfo.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  academicInfo.join(' · '),
                  style: TextStyle(
                    color: const Color(0xFF71839A),
                    fontSize: 11.sp,
                    height: 1.5,
                  ),
                ),
              ],
              if (resident.interests.isNotEmpty) ...[
                SizedBox(height: 7.h),
                Wrap(
                  spacing: 5.w,
                  runSpacing: 5.h,
                  children: resident.interests
                      .map((interest) => PropertyAmenityChip(label: interest))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class PropertyOwnerSection extends StatelessWidget {
  const PropertyOwnerSection({required this.owner, super.key});

  final PropertyOwnerModel owner;

  @override
  Widget build(BuildContext context) {
    return PropertySectionCard(
      title: 'صاحب السكن',
      child: Row(
        children: [
          _PersonAvatar(imageUrl: owner.profileImage, radius: 25.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              hasPropertyText(owner.name) ? owner.name! : 'مالك السكن',
              style: TextStyle(
                color: const Color(0xFF1D3553),
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Icon(
            Icons.verified_user_outlined,
            color: const Color(0xFF8293A6),
            size: 20.sp,
          ),
        ],
      ),
    );
  }
}

class _PersonAvatar extends StatelessWidget {
  const _PersonAvatar({required this.imageUrl, required this.radius});

  final String? imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final uri = validPropertyImageUri(imageUrl);
    if (uri == null) return _avatarPlaceholder();
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFEAF1F8),
      child: CachedNetworkImage(
        imageUrl: uri.toString(),
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: radius,
          backgroundColor: const Color(0xFFEAF1F8),
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => _avatarPlaceholder(),
        errorWidget: (context, url, error) => _avatarPlaceholder(),
      ),
    );
  }

  Widget _avatarPlaceholder() => CircleAvatar(
    radius: radius,
    backgroundColor: const Color(0xFFEAF1F8),
    child: const Icon(Icons.person_outline_rounded, color: Color(0xFF8293A6)),
  );
}
