import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/theme/app_colors.dart';
import 'package:skann_app/features/auth/data/models/registration_response_model.dart';
import 'package:skann_app/features/auth/presentation/views/widgets/registration_form_fields.dart'
    show registrationGovernorates;
import 'package:skann_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:skann_app/features/profile/presentation/views/widgets/profile_edit_actions.dart';
import 'package:skann_app/features/profile/presentation/views/widgets/profile_edit_fields.dart';
import 'package:skann_app/features/profile/presentation/views/widgets/profile_edit_image_picker.dart';
import 'package:skann_app/features/profile/presentation/views/widgets/profile_edit_intro_card.dart';

class ProfileEditRouteData {
  const ProfileEditRouteData({required this.cubit, required this.user});

  final ProfileCubit cubit;
  final UserModel user;
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({required this.arguments, super.key});

  final ProfileEditRouteData arguments;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  late final String _initialGender;
  late String _gender;
  late final String? _initialGovernorate;
  String? _governorate;
  XFile? _pickedImage;

  static const _personalInputs = <ProfileEditInput>[
    ProfileEditInput(
      keyName: 'fullName',
      label: 'الاسم بالكامل',
      icon: Icons.person_outline_rounded,
    ),
    ProfileEditInput(
      keyName: 'phone',
      label: 'رقم الهاتف المحمول',
      icon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
    ),
    ProfileEditInput(
      keyName: 'housingStatus',
      label: 'حالة السكن',
      icon: Icons.apartment_rounded,
    ),
    ProfileEditInput(
      keyName: 'bio',
      label: 'نبذة عني',
      icon: Icons.notes_rounded,
      maxLines: 3,
    ),
  ];

  static const _academicInputs = <ProfileEditInput>[
    ProfileEditInput(
      keyName: 'university',
      label: 'الجامعة',
      icon: Icons.account_balance_outlined,
    ),
    ProfileEditInput(
      keyName: 'faculty',
      label: 'الكلية',
      icon: Icons.school_outlined,
    ),
    ProfileEditInput(
      keyName: 'major',
      label: 'التخصص',
      icon: Icons.menu_book_rounded,
    ),
    ProfileEditInput(
      keyName: 'academicYear',
      label: 'السنة الدراسية',
      icon: Icons.calendar_month_outlined,
    ),
    ProfileEditInput(
      keyName: 'interests',
      label: 'الاهتمامات',
      icon: Icons.auto_awesome_outlined,
      hintText: 'افصل بين الاهتمامات بفاصلة',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final user = widget.arguments.user;
    final governorate = registrationGovernorates.contains(user.governorate)
        ? user.governorate
        : null;
    _initialGovernorate = governorate;
    _governorate = governorate;
    _controllers = {
      'fullName': TextEditingController(
        text: user.fullName ?? user.displayName,
      ),
      'phone': TextEditingController(text: user.phone ?? ''),
      'email': TextEditingController(text: user.email ?? ''),
      'housingStatus': TextEditingController(text: user.housingStatus ?? ''),
      'bio': TextEditingController(text: user.bio ?? ''),
      'university': TextEditingController(text: user.university ?? ''),
      'faculty': TextEditingController(text: user.faculty ?? ''),
      'major': TextEditingController(text: user.major ?? ''),
      'academicYear': TextEditingController(text: user.academicYear ?? ''),
      'interests': TextEditingController(
        text: user.interests?.join('، ') ?? '',
      ),
    };
    _initialGender = user.gender ?? '';
    _gender = _initialGender;
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.arguments.cubit,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F7FB),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF4F7FB),
            surfaceTintColor: Colors.transparent,
            title: Text(
              'تعديل الملف الشخصي',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            top: false,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(18.w, 6.h, 18.w, 20.h),
                      children: [
                        ProfileEditIntroCard(
                          name: widget.arguments.user.displayName,
                        ),
                        SizedBox(height: 17.h),
                        ProfileEditImagePicker(
                          imageUrl: widget.arguments.user.profileImage,
                          onImageSelected: (image) {
                            _pickedImage = image;
                          },
                        ),
                        SizedBox(height: 14.h),
                        ProfileEditTextSection(
                          title: 'البيانات الشخصية',
                          icon: Icons.person_pin_circle_outlined,
                          inputs: _personalInputs,
                          controllers: _controllers,
                          accentColor: AppColors.primaryColor,
                        ),
                        SizedBox(height: 14.h),
                        ProfileEditDropdownCard(
                          label: 'المحافظة',
                          hint: 'اختر المحافظة',
                          value: _governorate,
                          items: {
                            for (final item in registrationGovernorates)
                              item: item,
                            '': 'بدون تحديد',
                          },
                          onChanged: (value) =>
                              setState(() => _governorate = value),
                        ),
                        SizedBox(height: 14.h),
                        ProfileEditDropdownCard(
                          label: 'النوع / الجنس',
                          hint: 'اختر النوع',
                          value: _gender.isEmpty ? null : _gender,
                          items: const {'MALE': 'ذكر', 'FEMALE': 'أنثى'},
                          onChanged: (value) =>
                              setState(() => _gender = value ?? ''),
                        ),
                        SizedBox(height: 14.h),
                        ProfileEditEmailField(
                          controller: _controllers['email']!,
                        ),
                        SizedBox(height: 14.h),
                        ProfileEditTextSection(
                          title: 'البيانات الدراسية',
                          icon: Icons.school_outlined,
                          inputs: _academicInputs,
                          controllers: _controllers,
                          accentColor: const Color(0xFF0D8B83),
                        ),
                      ],
                    ),
                  ),
                  ProfileEditActions(onSave: _saveChanges),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final changes = _collectChanges();
    if (changes.isEmpty && _pickedImage == null) {
      _showMessage('لم يتم إجراء أي تغييرات.');
      return;
    }

    final failure = await widget.arguments.cubit.updateProfile(
      changes,
      profileImage: _pickedImage,
    );
    if (!mounted) return;
    if (failure != null) {
      if (failure is ServerFailure &&
          failure.code == 'PROFILE_IMAGE_NOT_CONFIRMED') {
        context.pop();
        _showMessage(failure.message);
        return;
      }
      _showMessage(_failureMessage(failure));
      return;
    }

    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ التعديلات بنجاح'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Map<String, Object?> _collectChanges() {
    final changes = <String, Object?>{};
    for (final entry in _controllers.entries) {
      if (entry.key == 'email') continue;
      final currentValue = entry.value.text.trim();
      final initialValue = _initialTextFor(entry.key).trim();
      if (currentValue == initialValue) continue;

      if (entry.key == 'interests') {
        changes[entry.key] = currentValue
            .split(RegExp('[,،]'))
            .map((interest) => interest.trim())
            .where((interest) => interest.isNotEmpty)
            .join(', ');
      } else {
        changes[entry.key] = currentValue.isEmpty ? null : currentValue;
      }
    }

    if (_gender != _initialGender) {
      changes['gender'] = _gender.isEmpty ? null : _gender;
    }
    if (_governorate != _initialGovernorate) {
      changes['governorate'] = _governorate?.isEmpty ?? true
          ? null
          : _governorate;
    }
    return changes;
  }

  String _initialTextFor(String key) {
    final user = widget.arguments.user;
    return switch (key) {
      'fullName' => user.fullName ?? user.displayName,
      'phone' => user.phone ?? '',
      'housingStatus' => user.housingStatus ?? '',
      'bio' => user.bio ?? '',
      'university' => user.university ?? '',
      'faculty' => user.faculty ?? '',
      'major' => user.major ?? '',
      'academicYear' => user.academicYear ?? '',
      'interests' => user.interests?.join('، ') ?? '',
      _ => '',
    };
  }

  String _failureMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'تعذر الاتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.';
    }
    if (failure is AuthFailure) {
      return 'انتهت صلاحية جلسة الدخول. سجّل الدخول مرة أخرى.';
    }
    if (failure is ValidationFailure) {
      return failure.message;
    }
    if (failure is ServerFailure &&
        (failure.code == 'PROFILE_UPDATE_NOT_APPLIED' ||
            failure.code == 'PROFILE_IMAGE_NOT_CONFIRMED')) {
      return failure.message;
    }
    return 'تعذر حفظ التعديلات. تحقق من البيانات وحاول مرة أخرى.';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
