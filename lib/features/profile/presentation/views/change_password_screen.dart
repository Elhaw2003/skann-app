import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skann_app/core/di.dart';
import 'package:skann_app/core/shared_widgets/custom_text_field_widget.dart';
import 'package:skann_app/core/theme/app_colors.dart';
import 'package:skann_app/features/profile/presentation/cubit/change_password_cubit.dart';
import 'package:skann_app/features/profile/presentation/cubit/change_password_state.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChangePasswordCubit>(),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _hasValidated = false;

  @override
  void dispose() {
    _currentPasswordController
      ..clear()
      ..dispose();
    _newPasswordController
      ..clear()
      ..dispose();
    _confirmPasswordController
      ..clear()
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocListener<ChangePasswordCubit, ChangePasswordState>(
        listener: (context, state) {
          if (state is ChangePasswordSuccess) {
            TextInput.finishAutofillContext();
            _clearFields();
            _showMessage(context, 'تم تغيير كلمة المرور بنجاح');
          } else if (state is ChangePasswordFailure) {
            _showMessage(context, state.message);
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F7FB),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF4F7FB),
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            title: Text(
              'تغيير كلمة المرور',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
            ),
            leading: IconButton(
              tooltip: 'رجوع',
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          body: SafeArea(
            top: false,
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
                  children: [
                    Container(
                      padding: EdgeInsets.all(18.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22.r),
                        border: Border.all(color: const Color(0xFFE7EDF5)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48.w,
                            height: 48.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF2FC),
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            child: Icon(
                              Icons.shield_outlined,
                              color: AppColors.primaryColor,
                              size: 25.sp,
                            ),
                          ),
                          SizedBox(width: 13.w),
                          Expanded(
                            child: Text(
                              'حدّث كلمة المرور للمساعدة في الحفاظ على أمان حسابك.',
                              style: TextStyle(
                                color: const Color(0xFF52647A),
                                fontSize: 13.sp,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 25.h),
                    _PasswordField(
                      label: 'كلمة المرور الحالية',
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrentPassword,
                      autofillHint: AutofillHints.password,
                      textInputAction: TextInputAction.next,
                      onToggleVisibility: () => setState(
                        () =>
                            _obscureCurrentPassword = !_obscureCurrentPassword,
                      ),
                      onChanged: _revalidate,
                      validator: (value) => _requiredError(value),
                    ),
                    SizedBox(height: 19.h),
                    _PasswordField(
                      label: 'كلمة المرور الجديدة',
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      autofillHint: AutofillHints.newPassword,
                      textInputAction: TextInputAction.next,
                      onToggleVisibility: () => setState(
                        () => _obscureNewPassword = !_obscureNewPassword,
                      ),
                      onChanged: _revalidate,
                      validator: _requiredError,
                    ),
                    SizedBox(height: 19.h),
                    _PasswordField(
                      label: 'تأكيد كلمة المرور الجديدة',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      autofillHint: AutofillHints.newPassword,
                      textInputAction: TextInputAction.done,
                      onToggleVisibility: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                      onChanged: _revalidate,
                      validator: (value) {
                        final requiredError = _requiredError(value);
                        if (requiredError != null) return requiredError;
                        if (value != _newPasswordController.text) {
                          return 'كلمتا المرور غير متطابقتين.';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _submit(context),
                    ),
                    SizedBox(height: 28.h),
                    BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
                      builder: (context, state) {
                        final isLoading = state is ChangePasswordLoading;
                        return SizedBox(
                          height: 54.h,
                          child: FilledButton(
                            onPressed: isLoading
                                ? null
                                : () => _submit(context),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              textStyle: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: isLoading
                                ? SizedBox(
                                    width: 22.w,
                                    height: 22.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('تغيير كلمة المرور'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    _hasValidated = true;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    context.read<ChangePasswordCubit>().changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );
  }

  void _revalidate(String _) {
    if (_hasValidated) _formKey.currentState?.validate();
  }

  String? _requiredError(String? value) =>
      value == null || value.isEmpty ? 'هذا الحقل مطلوب.' : null;

  void _clearFields() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    _hasValidated = false;
    _formKey.currentState?.reset();
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscureText,
    required this.autofillHint,
    required this.textInputAction,
    required this.onToggleVisibility,
    required this.onChanged,
    required this.validator,
    this.onFieldSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final String autofillHint;
  final TextInputAction textInputAction;
  final VoidCallback onToggleVisibility;
  final ValueChanged<String> onChanged;
  final FormFieldValidator<String> validator;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Text(
            label,
            style: TextStyle(
              color: const Color(0xFF20344F),
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        CustomTextFieldWidget(
          controller: controller,
          hintText: label,
          prefixIcon: Icons.lock_outline_rounded,
          prefixColor: const Color(0xFF8194AE),
          suffixIcon: obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          suffixTooltip: obscureText
              ? 'إظهار كلمة المرور'
              : 'إخفاء كلمة المرور',
          suffixColor: const Color(0xFF8194AE),
          suffixOnPressed: onToggleVisibility,
          obscureText: obscureText,
          keyboardType: TextInputType.visiblePassword,
          autofillHints: [autofillHint],
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          enableSuggestions: false,
          autocorrect: false,
          validator: validator,
          enableBorderRadius: 15,
          focusBorderRadius: 15,
          errorBorderRadius: 15,
          enableBorderColor: const Color(0xFFE5EAF2),
          focusBorderColor: AppColors.primaryColor,
          fillColor: const Color(0xFFFBFCFE),
        ),
      ],
    );
  }
}
