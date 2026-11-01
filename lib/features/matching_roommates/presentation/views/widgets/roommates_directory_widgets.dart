import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/theme/app_colors.dart';
import 'package:skann_app/features/matching_roommates/data/models/roommates_directory_filters.dart';
import 'package:skann_app/features/matching_roommates/presentation/cubit/roommates_directory_state.dart';

class RoommatesDirectoryToolbar extends StatelessWidget {
  const RoommatesDirectoryToolbar({
    required this.controller,
    required this.filters,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onOpenFilters,
    required this.onFiltersChanged,
    this.state,
    super.key,
  });

  final TextEditingController controller;
  final RoommatesDirectoryFilters filters;
  final RoommatesDirectoryLoaded? state;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback? onOpenFilters;
  final ValueChanged<RoommatesDirectoryFilters> onFiltersChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textDirection: TextDirection.rtl,
                  textInputAction: TextInputAction.search,
                  enabled: state != null,
                  onChanged: state == null ? null : onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'ابحث بالاسم أو الجامعة أو الكلية...',
                    hintStyle: TextStyle(
                      color: const Color(0xFF8995A7),
                      fontSize: 11.sp,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: controller.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'مسح البحث',
                            onPressed: onClearSearch,
                            icon: const Icon(Icons.close_rounded),
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 13.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13.r),
                      borderSide: const BorderSide(color: Color(0xFFE7ECF3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13.r),
                      borderSide: const BorderSide(color: Color(0xFFE7ECF3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13.r),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              SizedBox(
                width: 48.w,
                height: 48.w,
                child: OutlinedButton(
                  onPressed: onOpenFilters,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryColor,
                    side: const BorderSide(color: Color(0xFFE7ECF3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13.r),
                    ),
                  ),
                  child: Badge(
                    isLabelVisible: filters.activeCount > 0,
                    label: Text('${filters.activeCount}'),
                    child: const Icon(Icons.tune_rounded),
                  ),
                ),
              ),
            ],
          ),
          if (controller.text.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 5.h, right: 4.w),
              child: Text(
                'البحث ضمن النتائج التي تم تحميلها',
                style: TextStyle(
                  color: const Color(0xFF8995A7),
                  fontSize: 10.sp,
                ),
              ),
            ),
          if (!filters.isEmpty) ...[
            SizedBox(height: 9.h),
            Wrap(
              spacing: 7.w,
              runSpacing: 4.h,
              children: [
                if (_cleanText(filters.governorate) case final value?)
                  RoommatesDirectoryFilterChip(
                    label: 'المحافظة: $value',
                    onDeleted: () => onFiltersChanged(
                      filters.copyWith(clearGovernorate: true),
                    ),
                  ),
                if (_cleanText(filters.university) case final value?)
                  RoommatesDirectoryFilterChip(
                    label: 'الجامعة: $value',
                    onDeleted: () => onFiltersChanged(
                      filters.copyWith(clearUniversity: true),
                    ),
                  ),
                if (_cleanText(filters.faculty) case final value?)
                  RoommatesDirectoryFilterChip(
                    label: 'الكلية: $value',
                    onDeleted: () =>
                        onFiltersChanged(filters.copyWith(clearFaculty: true)),
                  ),
              ],
            ),
          ],
          if (state?.requestError case final error?) ...[
            SizedBox(height: 9.h),
            RoommatesDirectoryInlineError(message: error),
          ],
          if (state?.refreshError case final error?) ...[
            SizedBox(height: 9.h),
            RoommatesDirectoryInlineError(message: error),
          ],
          if (state != null) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'الطلاب المتاحون للتواصل',
                    style: TextStyle(
                      color: const Color(0xFF20344F),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  state!.search.isEmpty
                      ? '${state!.roommates.length} من ${state!.pagination.totalItems} طالب'
                      : '${state!.visibleRoommates.length} نتيجة محلية',
                  style: TextStyle(
                    color: const Color(0xFF71809A),
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class RoommatesDirectoryStatus extends StatelessWidget {
  const RoommatesDirectoryStatus({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19.r),
        border: Border.all(color: const Color(0xFFE8EDF4)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40.sp, color: AppColors.primaryColor),
          SizedBox(height: 11.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF20344F),
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF71809A),
              fontSize: 11.sp,
              height: 1.6,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: 13.h),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class RoommatesDirectoryInlineError extends StatelessWidget {
  const RoommatesDirectoryInlineError({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F0),
        borderRadius: BorderRadius.circular(11.r),
      ),
      child: Text(
        message,
        style: TextStyle(color: const Color(0xFFB42318), fontSize: 10.sp),
      ),
    );
  }
}

class RoommatesDirectoryPaginationFooter extends StatelessWidget {
  const RoommatesDirectoryPaginationFooter({
    required this.isLoading,
    required this.hasNextPage,
    required this.onRetry,
    this.error,
    super.key,
  });

  final bool isLoading;
  final bool hasNextPage;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 17.h),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryColor,
          ),
        ),
      );
    }
    if (error != null) {
      return Column(
        children: [
          RoommatesDirectoryInlineError(message: error!),
          TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      );
    }
    if (hasNextPage) return SizedBox(height: 12.h);
    return const SizedBox.shrink();
  }
}

class RoommatesDirectoryFilterChip extends StatelessWidget {
  const RoommatesDirectoryFilterChip({
    required this.label,
    required this.onDeleted,
    super.key,
  });

  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(label),
      onDeleted: onDeleted,
      backgroundColor: const Color(0xFFEAF2FC),
      deleteIconColor: AppColors.primaryColor,
      labelStyle: TextStyle(
        color: const Color(0xFF245A96),
        fontSize: 10.sp,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}

String? _cleanText(String? value) {
  if (value == null || value.trim().isEmpty || value.trim() == 'null') {
    return null;
  }
  return value.trim();
}
