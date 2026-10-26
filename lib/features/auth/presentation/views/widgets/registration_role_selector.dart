import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/theme/app_colors.dart';
import 'package:skann_app/core/theme/app_text_styles.dart';

enum RegistrationRole { student, owner }

class RegistrationRoleSelector extends StatelessWidget {
  const RegistrationRoleSelector({
    required this.selectedRole,
    required this.onChanged,
    super.key,
  });

  final RegistrationRole selectedRole;
  final ValueChanged<RegistrationRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          _RoleButton(
            title: 'طالب سكن',
            icon: Icons.school_outlined,
            role: RegistrationRole.student,
            isSelected: selectedRole == RegistrationRole.student,
            onTap: onChanged,
          ),
          _RoleButton(
            title: 'صاحب سكن',
            icon: Icons.apartment_rounded,
            role: RegistrationRole.owner,
            isSelected: selectedRole == RegistrationRole.owner,
            onTap: onChanged,
          ),
        ],
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.title,
    required this.icon,
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final RegistrationRole role;
  final bool isSelected;
  final ValueChanged<RegistrationRole> onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        selected: isSelected,
        button: true,
        child: GestureDetector(
          onTap: () => onTap(role),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(vertical: 11.h),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEAF3FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 17.sp,
                  color: isSelected
                      ? const Color(0xFF0864D8)
                      : AppColors.splashSubtitleColor,
                ),
                SizedBox(width: 6.w),
                Text(
                  title,
                  style: AppTextStyles.primaryTextW500S17.copyWith(
                    fontSize: 12.sp,
                    color: isSelected
                        ? const Color(0xFF0864D8)
                        : AppColors.splashSubtitleColor,
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
