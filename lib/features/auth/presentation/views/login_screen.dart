import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:skann_app/core/di.dart';
import 'package:skann_app/core/routing/app_routes.dart';
import 'package:skann_app/core/theme/app_colors.dart';
import 'package:skann_app/features/auth/data/models/login_request_model.dart';
import 'package:skann_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:skann_app/features/auth/presentation/cubit/auth_states.dart';
import 'package:skann_app/features/auth/presentation/views/widgets/login_form_card.dart';
import 'package:skann_app/features/auth/presentation/views/widgets/login_hero.dart';
import 'package:skann_app/features/auth/presentation/views/widgets/login_registration_link.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthStates>(
      listenWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      listener: _showAuthenticationFeedback,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F7FC),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 24.h),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 440.w,
                      minHeight: constraints.maxHeight - 42.h,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const LoginHero(),
                          SizedBox(height: 20.h),
                          LoginFormCard(
                            formKey: _formKey,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            obscurePassword: _obscurePassword,
                            onTogglePassword: _togglePasswordVisibility,
                            emailValidator: _validateEmail,
                            passwordValidator: _validatePassword,
                            onSubmit: _submit,
                          ),
                          const Spacer(),
                          SizedBox(height: 18.h),
                          const LoginRegistrationLink(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAuthenticationFeedback(BuildContext context, AuthStates state) {
    final messenger = ScaffoldMessenger.of(context);
    if (state is AuthSuccess) {
      final message = state.response.message.isNotEmpty
          ? state.response.message
          : 'تم تسجيل الدخول بنجاح';
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFF168354),
            behavior: SnackBarBehavior.floating,
          ),
        );
      if (state.response.data.user.role == 'STUDENT') {
        context.go(AppRoutes.studentHome);
      }
    } else if (state is AuthFailureState) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.redColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    context.read<AuthCubit>().login(
      LoginRequestModel(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    return null;
  }
}
