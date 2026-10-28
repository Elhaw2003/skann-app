import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skann_app/features/auth/presentation/views/widgets/registration_dropdown_field.dart';

class ProfileEditInput {
  const ProfileEditInput({
    required this.keyName,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.hintText,
  });

  final String keyName;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? hintText;
}

class ProfileEditTextSection extends StatelessWidget {
  const ProfileEditTextSection({
    required this.title,
    required this.icon,
    required this.inputs,
    required this.controllers,
    required this.accentColor,
    super.key,
  });

  final String title;
  final IconData icon;
  final List<ProfileEditInput> inputs;
  final Map<String, TextEditingController> controllers;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(15.w, 15.h, 15.w, 5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21.r),
        border: Border.all(color: const Color(0xFFE7ECF3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF20344F),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...inputs.map(
            (input) => Padding(
              padding: EdgeInsets.only(bottom: 11.h),
              child: TextFormField(
                controller: controllers[input.keyName],
                keyboardType: input.keyboardType,
                maxLines: input.maxLines,
                textDirection: TextDirection.rtl,
                validator: input.keyName == 'fullName'
                    ? (value) => value == null || value.trim().isEmpty
                          ? 'يرجى إدخال الاسم بالكامل'
                          : null
                    : null,
                decoration: _decoration(
                  label: input.label,
                  icon: input.icon,
                  accentColor: accentColor,
                  hintText: input.hintText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileEditDropdownCard extends StatelessWidget {
  const ProfileEditDropdownCard({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
  });

  final String label;
  final String hint;
  final String? value;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21.r),
        border: Border.all(color: const Color(0xFFE7ECF3)),
      ),
      child: RegistrationDropdownField(
        label: label,
        hint: hint,
        value: value,
        items: items,
        requiredSelection: false,
        onChanged: onChanged,
      ),
    );
  }
}

class ProfileEditEmailField extends StatelessWidget {
  const ProfileEditEmailField({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      keyboardType: TextInputType.emailAddress,
      textDirection: TextDirection.ltr,
      decoration: _decoration(
        label: 'البريد الإلكتروني',
        icon: Icons.alternate_email_rounded,
        accentColor: const Color(0xFF7C8BA0),
        helperText: 'لا يمكن تغيير البريد الإلكتروني من هذه الصفحة',
      ),
    );
  }
}

InputDecoration _decoration({
  required String label,
  required IconData icon,
  required Color accentColor,
  String? hintText,
  String? helperText,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hintText,
    helperText: helperText,
    prefixIcon: Icon(icon, color: accentColor, size: 19.sp),
    filled: true,
    fillColor: const Color(0xFFFAFBFD),
    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 15.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.r),
      borderSide: const BorderSide(color: Color(0xFFE4EAF1)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.r),
      borderSide: const BorderSide(color: Color(0xFFE4EAF1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.r),
      borderSide: BorderSide(color: accentColor, width: 1.4),
    ),
    labelStyle: TextStyle(color: const Color(0xFF718096), fontSize: 12.sp),
  );
}
