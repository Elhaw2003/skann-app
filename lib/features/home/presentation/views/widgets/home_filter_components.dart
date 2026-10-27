import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/core/theme/app_colors.dart';

class HomeFilterTextField extends StatelessWidget {
  const HomeFilterTextField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    super.key,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeFilterSectionLabel(label: label, icon: icon),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          textDirection: TextDirection.rtl,
          decoration: homeFilterInputDecoration(hint),
        ),
      ],
    );
  }
}

class HomeFilterDropdownField extends StatelessWidget {
  const HomeFilterDropdownField({
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.hint,
    required this.onChanged,
    super.key,
  });

  final String label;
  final IconData icon;
  final String? value;
  final Map<String, String> options;
  final String hint;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeFilterSectionLabel(label: label, icon: icon),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          decoration: homeFilterInputDecoration(hint),
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
              .toList(),
          onChanged: options.isEmpty ? null : onChanged,
        ),
      ],
    );
  }
}

class HomeFilterChoiceChips extends StatelessWidget {
  const HomeFilterChoiceChips({
    required this.title,
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
    super.key,
  });

  final String title;
  final IconData icon;
  final String? value;
  final Map<String, String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeFilterSectionLabel(label: title, icon: icon),
        SizedBox(height: 9.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: options.entries.map((entry) {
            final selected = value == entry.key;
            return ChoiceChip(
              label: Text(entry.value),
              selected: selected,
              onSelected: (isSelected) =>
                  onChanged(isSelected ? entry.key : null),
              selectedColor: const Color(0xFFEAF3FF),
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected
                    ? const Color(0xFF7DB6F0)
                    : const Color(0xFFE1E7EF),
              ),
              labelStyle: TextStyle(
                color: selected
                    ? const Color(0xFF0B67C8)
                    : const Color(0xFF5F7084),
                fontSize: 11.sp,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class HomePriceRangeFields extends StatelessWidget {
  const HomePriceRangeFields({
    required this.minimumController,
    required this.maximumController,
    required this.minimumValidator,
    required this.maximumValidator,
    super.key,
  });

  final TextEditingController minimumController;
  final TextEditingController maximumController;
  final FormFieldValidator<String> minimumValidator;
  final FormFieldValidator<String> maximumValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HomeFilterSectionLabel(
          label: 'نطاق السعر',
          icon: Icons.payments_outlined,
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _PriceInput(
                label: 'من السعر',
                controller: minimumController,
                validator: minimumValidator,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _PriceInput(
                label: 'إلى السعر',
                controller: maximumController,
                validator: maximumValidator,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PriceInput extends StatelessWidget {
  const _PriceInput({
    required this.label,
    required this.controller,
    required this.validator,
  });

  final String label;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textDirection: TextDirection.ltr,
      decoration: homeFilterInputDecoration(label).copyWith(
        suffixText: 'ج.م',
        suffixStyle: TextStyle(color: const Color(0xFF7E8DA0), fontSize: 10.sp),
      ),
      validator: validator,
    );
  }
}

class HomeFilterSectionLabel extends StatelessWidget {
  const HomeFilterSectionLabel({
    required this.label,
    required this.icon,
    this.trailing,
    super.key,
  });

  final String label;
  final IconData icon;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: const Color(0xFF0B67C8)),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: const Color(0xFF374F6B),
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing ?? '',
            style: TextStyle(color: const Color(0xFF0B67C8), fontSize: 9.sp),
          ),
      ],
    );
  }
}

class HomeLookupError extends StatelessWidget {
  const HomeLookupError({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 7.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: AppColors.redColor, fontSize: 9.sp),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}

InputDecoration homeFilterInputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: const Color(0xFF9AA7B7), fontSize: 11.sp),
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 13.h),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13.r),
      borderSide: const BorderSide(color: Color(0xFFE3E9F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13.r),
      borderSide: const BorderSide(color: Color(0xFF5CA0E8)),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13.r),
      borderSide: const BorderSide(color: AppColors.redColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13.r),
      borderSide: const BorderSide(color: AppColors.redColor),
    ),
  );
}
