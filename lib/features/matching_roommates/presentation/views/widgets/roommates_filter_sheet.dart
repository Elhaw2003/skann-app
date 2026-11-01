import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/theme/app_colors.dart';
import 'package:skann_app/features/auth/presentation/views/widgets/registration_form_fields.dart'
    show registrationGovernorates;
import 'package:skann_app/features/matching_roommates/data/models/roommates_directory_filters.dart';
import 'package:skann_app/features/matching_roommates/presentation/cubit/roommates_directory_cubit.dart';
import 'package:skann_app/features/matching_roommates/presentation/cubit/roommates_directory_state.dart';

Future<void> showRoommatesFilterSheet(
  BuildContext context, {
  required RoommatesDirectoryCubit cubit,
  required RoommatesDirectoryFilters filters,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BlocProvider.value(
      value: cubit,
      child: _RoommatesFilterSheet(filters: filters),
    ),
  );
}

class _RoommatesFilterSheet extends StatefulWidget {
  const _RoommatesFilterSheet({required this.filters});

  final RoommatesDirectoryFilters filters;

  @override
  State<_RoommatesFilterSheet> createState() => _RoommatesFilterSheetState();
}

class _RoommatesFilterSheetState extends State<_RoommatesFilterSheet> {
  late final TextEditingController _universityController;
  late final TextEditingController _facultyController;
  late String? _governorate;

  @override
  void initState() {
    super.initState();
    _universityController = TextEditingController(
      text: widget.filters.university ?? '',
    );
    _facultyController = TextEditingController(
      text: widget.filters.faculty ?? '',
    );
    _governorate = widget.filters.governorate;
  }

  @override
  void dispose() {
    _universityController.dispose();
    _facultyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final governorates = {
      for (final governorate in registrationGovernorates)
        governorate: governorate,
    };
    final selectedGovernorate = governorates.containsKey(_governorate)
        ? _governorate
        : null;
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.76,
      padding: EdgeInsets.only(
        left: 18.w,
        right: 18.w,
        top: 14.h,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'تصفية زملاء السكن',
                  style: TextStyle(
                    color: const Color(0xFF20344F),
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(onPressed: _reset, child: const Text('إعادة ضبط')),
            ],
          ),
          SizedBox(height: 10.h),
          Expanded(
            child: ListView(
              children: [
                _GovernorateField(
                  value: selectedGovernorate,
                  options: governorates,
                  onChanged: (value) => setState(() => _governorate = value),
                ),
                SizedBox(height: 18.h),
                _FilterTextField(
                  label: 'الجامعة',
                  hint: 'اكتب اسم الجامعة',
                  controller: _universityController,
                  icon: Icons.school_outlined,
                ),
                SizedBox(height: 18.h),
                _FilterTextField(
                  label: 'الكلية',
                  hint: 'اكتب اسم الكلية',
                  controller: _facultyController,
                  icon: Icons.menu_book_outlined,
                ),
              ],
            ),
          ),
          BlocBuilder<RoommatesDirectoryCubit, RoommatesDirectoryState>(
            builder: (context, state) {
              final isUpdating =
                  state is RoommatesDirectoryLoaded && state.isUpdating;
              return SizedBox(
                width: double.infinity,
                height: 50.h,
                child: FilledButton(
                  onPressed: isUpdating ? null : _apply,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13.r),
                    ),
                  ),
                  child: isUpdating
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('تطبيق الفلاتر'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _reset() {
    setState(() {
      _governorate = null;
      _universityController.clear();
      _facultyController.clear();
    });
  }

  Future<void> _apply() async {
    final filters = RoommatesDirectoryFilters(
      governorate: _governorate,
      university: _normalizedText(_universityController.text),
      faculty: _normalizedText(_facultyController.text),
    );
    final cubit = context.read<RoommatesDirectoryCubit>();
    await cubit.applyFilters(filters);
    if (!mounted) return;

    final state = cubit.state;
    if (state is RoommatesDirectoryLoaded &&
        state.filters == filters &&
        state.requestError == null) {
      Navigator.of(context).pop();
      return;
    }

    final message = state is RoommatesDirectoryLoaded
        ? state.requestError
        : null;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    }
  }
}

class _GovernorateField extends StatelessWidget {
  const _GovernorateField({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String? value;
  final Map<String, String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return _FilterField(
      label: 'المحافظة',
      icon: Icons.location_on_outlined,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        decoration: _filterDecoration('اختر المحافظة'),
        items: options.entries
            .map(
              (entry) => DropdownMenuItem<String>(
                value: entry.key,
                child: Text(
                  entry.value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
            )
            .toList(growable: false),
        onChanged: onChanged,
      ),
    );
  }
}

class _FilterTextField extends StatelessWidget {
  const _FilterTextField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _FilterField(
      label: label,
      icon: icon,
      child: TextFormField(
        controller: controller,
        textDirection: TextDirection.rtl,
        decoration: _filterDecoration(hint),
      ),
    );
  }
}

class _FilterField extends StatelessWidget {
  const _FilterField({
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(icon, size: 17.sp, color: const Color(0xFF53657D)),
            SizedBox(width: 7.w),
            Text(
              label,
              style: TextStyle(
                color: const Color(0xFF344A63),
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }
}

String? _normalizedText(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}

InputDecoration _filterDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: const Color(0xFF8995A7), fontSize: 11.sp),
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 13.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13.r),
      borderSide: const BorderSide(color: Color(0xFFE1E7EF)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13.r),
      borderSide: const BorderSide(color: Color(0xFFE1E7EF)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13.r),
      borderSide: const BorderSide(color: AppColors.primaryColor),
    ),
  );
}
