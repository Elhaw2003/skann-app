import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skann_app/core/di.dart';
import 'package:skann_app/core/routing/app_routes.dart';
import 'package:skann_app/core/theme/app_colors.dart';
import 'package:skann_app/features/auth/data/models/owner_registration_request.dart';
import 'package:skann_app/features/auth/data/models/student_registration_request.dart';
import 'package:skann_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:skann_app/features/auth/presentation/cubit/auth_states.dart';
import 'package:skann_app/features/auth/presentation/views/widgets/registration_academic_details.dart';
import 'package:skann_app/features/auth/presentation/views/widgets/registration_actions.dart';
import 'package:skann_app/features/auth/presentation/views/widgets/registration_header.dart';
import 'package:skann_app/features/auth/presentation/views/widgets/registration_owner_details.dart';
import 'package:skann_app/features/auth/presentation/views/widgets/registration_personal_details.dart';
import 'package:skann_app/features/auth/presentation/views/widgets/registration_role_selector.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: BlocListener<AuthCubit, AuthStates>(
        listenWhen: (previous, current) =>
            previous is! AuthSuccess && current is AuthSuccess,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('تم إنشاء الحساب بنجاح، يمكنك تسجيل الدخول الآن'),
                backgroundColor: AppColors.greenColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          context.go(AppRoutes.login);
        },
        child: const _RegistrationForm(),
      ),
    );
  }
}

class _RegistrationForm extends StatefulWidget {
  const _RegistrationForm();

  @override
  State<_RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<_RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _universityController = TextEditingController();
  final _facultyController = TextEditingController();
  final _majorController = TextEditingController();
  final _academicYearController = TextEditingController();

  RegistrationRole _role = RegistrationRole.student;
  String? _governorate;
  String? _gender;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  bool get _isStudent => _role == RegistrationRole.student;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _universityController.dispose();
    _facultyController.dispose();
    _majorController.dispose();
    _academicYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 560.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RegistrationHeader(isStudent: _isStudent),
                      SizedBox(height: 14.h),
                      RegistrationRoleSelector(
                        selectedRole: _role,
                        onChanged: _selectRole,
                      ),
                      SizedBox(height: 14.h),
                      RegistrationPersonalDetails(
                        isStudent: _isStudent,
                        fullNameController: _fullNameController,
                        emailController: _emailController,
                        phoneController: _phoneController,
                        passwordController: _passwordController,
                        confirmPasswordController: _confirmPasswordController,
                        obscurePassword: _obscurePassword,
                        obscureConfirmation: _obscureConfirmation,
                        onTogglePassword: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        onToggleConfirmation: () => setState(
                          () => _obscureConfirmation = !_obscureConfirmation,
                        ),
                        requiredValidator: _requiredValidator,
                        emailValidator: _emailValidator,
                        phoneValidator: _phoneValidator,
                        confirmationValidator: _confirmationValidator,
                      ),
                      SizedBox(height: 14.h),
                      if (_isStudent)
                        RegistrationAcademicDetails(
                          governorate: _governorate,
                          gender: _gender,
                          universityController: _universityController,
                          facultyController: _facultyController,
                          majorController: _majorController,
                          academicYearController: _academicYearController,
                          onGovernorateChanged: (value) =>
                              setState(() => _governorate = value),
                          onGenderChanged: (value) =>
                              setState(() => _gender = value),
                          requiredValidator: _requiredValidator,
                        )
                      else
                        RegistrationOwnerDetails(
                          governorate: _governorate,
                          gender: _gender,
                          onGovernorateChanged: (value) =>
                              setState(() => _governorate = value),
                          onGenderChanged: (value) =>
                              setState(() => _gender = value),
                        ),
                      SizedBox(height: 12.h),
                      RegistrationStatusMessage(
                        state: context.select((AuthCubit cubit) => cubit.state),
                      ),
                      RegistrationSubmitButton(
                        title: 'إنشاء حساب',
                        isLoading: context.select(
                          (AuthCubit cubit) => cubit.state is AuthLoading,
                        ),
                        onPressed: () => _submit(context),
                      ),
                      SizedBox(height: 16.h),
                      const RegistrationLoginLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectRole(RegistrationRole role) {
    final cubit = context.read<AuthCubit>();
    if (_role == role || cubit.state is AuthLoading) {
      return;
    }

    setState(() => _role = role);
    cubit.reset();
  }

  void _submit(BuildContext context) {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final governorate = _governorate;
    final gender = _gender;
    if (governorate == null || gender == null) return;

    final cubit = context.read<AuthCubit>();
    if (_isStudent) {
      cubit.registerStudent(
        StudentRegistrationRequest(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          gender: gender,
          governorate: governorate,
          university: _universityController.text.trim(),
          faculty: _facultyController.text.trim(),
          major: _majorController.text.trim(),
          academicYear: _academicYearController.text.trim(),
        ),
      );
      return;
    }

    cubit.registerOwner(
      OwnerRegistrationRequest(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        governorate: governorate,
        gender: gender,
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'هذا الحقل مطلوب';
    return null;
  }

  String? _emailValidator(String? value) {
    final requiredError = _requiredValidator(value);
    if (requiredError != null) return requiredError;

    final email = value!.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  String? _phoneValidator(String? value) {
    final requiredError = _requiredValidator(value);
    if (requiredError != null) return requiredError;
    if (!RegExp(r'^01[0125]\d{8}$').hasMatch(value!.trim())) {
      return 'أدخل رقم هاتف مصري صحيحًا يبدأ بـ 010 أو 011 أو 012 أو 015';
    }
    return null;
  }

  String? _confirmationValidator(String? value) {
    final requiredError = _requiredValidator(value);
    if (requiredError != null) return requiredError;
    if (value != _passwordController.text) {
      return 'كلمتا المرور غير متطابقتين';
    }
    return null;
  }
}
