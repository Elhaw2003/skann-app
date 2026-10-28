import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/theme/app_colors.dart';
import 'package:skann_app/core/theme/app_text_styles.dart';
import 'package:skann_app/features/auth/presentation/views/widgets/registration_form_fields.dart';

class RegistrationDropdownField extends StatelessWidget {
  const RegistrationDropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.requiredSelection = true,
    super.key,
  });

  final String label;
  final String hint;
  final String? value;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;
  final bool requiredSelection;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: value,
      validator: (selectedValue) => requiredSelection && selectedValue == null
          ? 'يرجى اختيار $label'
          : null,
      builder: (field) {
        final selectedLabel = items[field.value];
        final hasError = field.errorText != null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RegistrationFieldLabel(label: label, isRequired: requiredSelection),
            SizedBox(height: 6.h),
            Semantics(
              button: true,
              label: '$label، ${selectedLabel ?? hint}',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15.r),
                  onTap: () async {
                    final selection = await showModalBottomSheet<String>(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _RegistrationOptionSheet(
                        title: label,
                        items: items,
                        selectedValue: field.value,
                      ),
                    );
                    if (selection == null) return;
                    field.didChange(selection);
                    onChanged(selection);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    constraints: BoxConstraints(minHeight: 58.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: field.value == null
                          ? const Color(0xFFFBFCFE)
                          : const Color(0xFFF2F7FF),
                      borderRadius: BorderRadius.circular(15.r),
                      border: Border.all(
                        color: hasError
                            ? AppColors.redColor
                            : field.value == null
                            ? const Color(0xFFE5EAF2)
                            : const Color(0xFFB9D6FF),
                        width: field.value == null ? 1 : 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36.w,
                          height: 36.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFECF5FF),
                            borderRadius: BorderRadius.circular(11.r),
                          ),
                          child: Icon(
                            _fieldIcon(label),
                            color: const Color(0xFF1176DC),
                            size: 19.sp,
                          ),
                        ),
                        SizedBox(width: 11.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                selectedLabel ?? hint,
                                style:
                                    (selectedLabel == null
                                            ? AppTextStyles.splashSubtitle
                                            : AppTextStyles.primaryTextW500S17)
                                        .copyWith(
                                          fontSize: 12.sp,
                                          color: selectedLabel == null
                                              ? AppColors.splashSubtitleColor
                                              : const Color(0xFF16477D),
                                          fontWeight: selectedLabel == null
                                              ? FontWeight.w400
                                              : FontWeight.w600,
                                        ),
                              ),
                              if (selectedLabel != null) ...[
                                SizedBox(height: 2.h),
                                Text(
                                  'تم الاختيار',
                                  style: AppTextStyles.splashSubtitle.copyWith(
                                    fontSize: 9.sp,
                                    color: const Color(0xFF25835A),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        AnimatedRotation(
                          turns: 0.5,
                          duration: const Duration(milliseconds: 180),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: selectedLabel == null
                                ? const Color(0xFF8C9BB3)
                                : const Color(0xFF1176DC),
                            size: 24.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (field.errorText != null) ...[
              SizedBox(height: 5.h),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 10.w),
                child: Text(
                  field.errorText!,
                  style: TextStyle(color: AppColors.redColor, fontSize: 10.sp),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  IconData _fieldIcon(String text) {
    if (text.contains('نوع') || text.contains('جنس')) {
      return Icons.wc_rounded;
    }
    return Icons.location_on_outlined;
  }
}

class _RegistrationOptionSheet extends StatefulWidget {
  const _RegistrationOptionSheet({
    required this.title,
    required this.items,
    required this.selectedValue,
  });

  final String title;
  final Map<String, String> items;
  final String? selectedValue;

  @override
  State<_RegistrationOptionSheet> createState() =>
      _RegistrationOptionSheetState();
}

class _RegistrationOptionSheetState extends State<_RegistrationOptionSheet> {
  static const Color _navy = Color(0xFF123B68);
  static const Color _blue = Color(0xFF1477DE);

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  bool get _isSearchable => widget.items.length > 4;

  List<MapEntry<String, String>> get _filteredItems {
    final query = _query.trim().toLowerCase();
    return widget.items.entries
        .where((entry) => entry.value.toLowerCase().contains(query))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.78;
    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFD5DDE8),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE7F3FF), Color(0xFFD7EAFE)],
                  ),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Icon(
                  widget.title.contains('نوع') || widget.title.contains('جنس')
                      ? Icons.wc_rounded
                      : Icons.location_on_outlined,
                  color: _blue,
                  size: 23.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اختار ${widget.title}',
                      style: AppTextStyles.primaryTextW500S17.copyWith(
                        color: _navy,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'اختار الأنسب ليك من القائمة',
                      style: AppTextStyles.splashSubtitle.copyWith(
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${filteredItems.length} اختيار',
                  style: TextStyle(
                    color: _blue,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (_isSearchable) ...[
            SizedBox(height: 18.h),
            TextField(
              controller: _searchController,
              onChanged: (query) => setState(() => _query = query),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'دور على المحافظة...',
                hintStyle: AppTextStyles.splashSubtitle.copyWith(
                  fontSize: 12.sp,
                ),
                prefixIcon: const Icon(Icons.search_rounded, color: _blue),
                filled: true,
                fillColor: AppColors.whiteColor,
                contentPadding: EdgeInsets.symmetric(vertical: 13.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.r),
                  borderSide: const BorderSide(color: Color(0xFFE6EBF2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.r),
                  borderSide: const BorderSide(color: Color(0xFFE6EBF2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.r),
                  borderSide: const BorderSide(color: _blue, width: 1.4),
                ),
              ),
            ),
          ],
          SizedBox(height: 14.h),
          Flexible(
            child: filteredItems.isEmpty
                ? Center(
                    child: Text(
                      'مفيش نتائج مطابقة',
                      style: AppTextStyles.splashSubtitle,
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(bottom: 4.h),
                    itemCount: filteredItems.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 9.h,
                      crossAxisSpacing: 9.w,
                      mainAxisExtent: 54.h,
                    ),
                    itemBuilder: (context, index) {
                      final entry = filteredItems[index];
                      final isSelected = entry.key == widget.selectedValue;
                      return _OptionTile(
                        title: entry.value,
                        isSelected: isSelected,
                        onTap: () => Navigator.of(context).pop(entry.key),
                      );
                    },
                  ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(horizontal: 11.w),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEAF3FF) : AppColors.whiteColor,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF7FB6F5)
                  : const Color(0xFFE8EDF4),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 18.sp,
                color: isSelected
                    ? const Color(0xFF1477DE)
                    : const Color(0xFFC2CBD8),
              ),
              SizedBox(width: 7.w),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.primaryTextW500S17.copyWith(
                    fontSize: 11.sp,
                    color: isSelected
                        ? const Color(0xFF16477D)
                        : const Color(0xFF45556B),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
