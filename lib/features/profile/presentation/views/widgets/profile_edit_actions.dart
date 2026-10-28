import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skann_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:skann_app/features/profile/presentation/cubit/profile_state.dart';

class ProfileEditActions extends StatelessWidget {
  const ProfileEditActions({required this.onSave, super.key});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final isSaving = state is ProfileLoaded && state.isUpdating;
        return Container(
          padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(top: BorderSide(color: Color(0xFFE7ECF3))),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E3854).withValues(alpha: 0.05),
                blurRadius: 14.r,
                offset: Offset(0, -4.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 49.h,
                child: FilledButton.icon(
                  onPressed: isSaving ? null : onSave,
                  icon: isSaving
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    isSaving ? 'جارٍ حفظ التعديلات...' : 'حفظ التعديلات',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF075BC5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    textStyle: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                height: 43.h,
                child: TextButton(
                  onPressed: isSaving ? null : () => context.pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFE5EEFF),
                    foregroundColor: const Color(0xFF53657D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: const Text('إلغاء والرجوع'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
