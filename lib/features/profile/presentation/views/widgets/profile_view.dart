import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/routing/app_routes.dart';
import 'package:skann_app/core/theme/app_colors.dart';
import 'package:skann_app/features/home/presentation/views/widgets/student_bottom_navigation_bar.dart';
import 'package:skann_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:skann_app/features/profile/presentation/cubit/profile_state.dart';
import 'package:skann_app/features/profile/presentation/views/widgets/profile_header_card.dart';
import 'package:skann_app/features/profile/presentation/views/widgets/profile_information_section.dart';
import 'package:skann_app/features/profile/presentation/views/widgets/profile_extra_sections.dart';
import 'package:skann_app/features/profile/presentation/views/widgets/profile_state_views.dart';
import 'package:skann_app/features/profile/presentation/views/edit_profile_screen.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FB),
        bottomNavigationBar: StudentBottomNavigationBar(
          selectedIndex: 4,
          onDestinationSelected: (index) {
            if (index == 0) context.go(AppRoutes.studentHome);
          },
        ),
        body: SafeArea(
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) => switch (state) {
              ProfileInitial() ||
              ProfileLoading() => const ProfileLoadingView(),
              ProfileFailure(:final message, :final requiresLogin) =>
                ProfileErrorView(
                  message: message,
                  requiresLogin: requiresLogin,
                  onRetry: context.read<ProfileCubit>().load,
                  onLogin: () => _logoutAndOpenLogin(context),
                ),
              ProfileLoaded() => _buildProfile(context, state),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, ProfileLoaded state) {
    final user = state.user;
    final interests =
        user.interests?.map(_cleanText).whereType<String>().toList() ?? [];
    final personalFields = <ProfileField>[
      if (_cleanText(user.bio) case final bio?)
        ProfileField(label: 'نبذة عني', value: bio, icon: Icons.notes),
      if (_cleanText(user.gender) case final gender?)
        ProfileField(
          label: 'النوع',
          value: gender,
          icon: Icons.person_outline_rounded,
        ),
      if (_cleanText(user.governorate) case final governorate?)
        ProfileField(
          label: 'المحافظة',
          value: governorate,
          icon: Icons.location_on_outlined,
        ),
      if (_cleanText(user.housingStatus) case final housingStatus?)
        ProfileField(
          label: 'حالة السكن',
          value: _readableValue(housingStatus),
          icon: Icons.apartment_rounded,
        ),
    ];
    final academicFields = <ProfileField>[
      if (_cleanText(user.university) case final university?)
        ProfileField(
          label: 'الجامعة',
          value: university,
          icon: Icons.account_balance_rounded,
        ),
      if (_cleanText(user.faculty) case final faculty?)
        ProfileField(
          label: 'الكلية',
          value: faculty,
          icon: Icons.school_outlined,
        ),
      if (_cleanText(user.major) case final major?)
        ProfileField(
          label: 'التخصص',
          value: major,
          icon: Icons.menu_book_rounded,
        ),
      if (_cleanText(user.academicYear) case final academicYear?)
        ProfileField(
          label: 'السنة الدراسية',
          value: academicYear,
          icon: Icons.calendar_month_outlined,
        ),
    ];

    return RefreshIndicator(
      onRefresh: context.read<ProfileCubit>().refresh,
      color: AppColors.primaryColor,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 26.h),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'الملف الشخصي',
                  style: TextStyle(
                    color: const Color(0xFF14263F),
                    fontSize: 23.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'تعديل الملف الشخصي',
                onPressed: () => context.push(
                  AppRoutes.editProfile,
                  extra: ProfileEditRouteData(
                    cubit: context.read<ProfileCubit>(),
                    user: user,
                  ),
                ),
                icon: const Icon(Icons.edit_rounded),
                style: IconButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFE7ECF3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ProfileHeaderCard(user: user),
          if (state.isRefreshing) ...[
            SizedBox(height: 10.h),
            const LinearProgressIndicator(
              minHeight: 2,
              color: AppColors.primaryColor,
              backgroundColor: Color(0xFFE1EAF5),
            ),
          ],
          if (state.refreshError case final refreshError?) ...[
            SizedBox(height: 10.h),
            ProfileRefreshError(message: refreshError),
          ],
          if (personalFields.isNotEmpty) ...[
            SizedBox(height: 20.h),
            ProfileInformationSection(
              title: 'معلوماتي',
              icon: Icons.person_pin_circle_outlined,
              fields: personalFields,
            ),
          ],
          if (academicFields.isNotEmpty) ...[
            SizedBox(height: 14.h),
            ProfileInformationSection(
              title: 'الحياة الجامعية',
              icon: Icons.school_rounded,
              fields: academicFields,
              accentColor: const Color(0xFF0D8B83),
            ),
          ],
          if (interests.isNotEmpty) ...[
            SizedBox(height: 14.h),
            ProfileInterestsSection(interests: interests),
          ],
          if (user.isActive != null ||
              user.createdAt != null ||
              user.updatedAt != null) ...[
            SizedBox(height: 14.h),
            ProfileAccountSection(
              isActive: user.isActive,
              createdAt: user.createdAt,
              updatedAt: user.updatedAt,
            ),
          ],
          SizedBox(height: 22.h),
          ProfileLogoutButton(onPressed: () => _logoutAndOpenLogin(context)),
          SizedBox(height: 6.h),
        ],
      ),
    );
  }

  Future<void> _logoutAndOpenLogin(BuildContext context) async {
    try {
      await context.read<ProfileCubit>().logout();
      if (context.mounted) context.go(AppRoutes.login);
    } on PlatformException {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تسجيل الخروج. حاول مرة أخرى.'),
          behavior: SnackBarBehavior.floating,
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

  String _readableValue(String value) =>
      value.replaceAll('_', ' ').trim().toLowerCase();
}
