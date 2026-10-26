import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/features/auth/data/models/login_request_model.dart';
import 'package:skann_app/features/auth/data/models/owner_registration_request.dart';
import 'package:skann_app/features/auth/data/models/registration_response_model.dart';
import 'package:skann_app/features/auth/data/models/student_registration_request.dart';
import 'package:skann_app/features/auth/data/repositories/auth_repository.dart';
import 'package:skann_app/features/auth/presentation/cubit/auth_states.dart';

class AuthCubit extends Cubit<AuthStates> {
  AuthCubit({required this.authRepository}) : super(const AuthInitial());

  final AuthRepository authRepository;

  Future<void> registerOwner(OwnerRegistrationRequest request) {
    return _authenticate(
      () => authRepository.registerOwner(request),
      isRegistration: true,
    );
  }

  Future<void> registerStudent(StudentRegistrationRequest request) {
    return _authenticate(
      () => authRepository.registerStudent(request),
      isRegistration: true,
    );
  }

  Future<void> login(LoginRequestModel request) {
    return _authenticate(
      () => authRepository.login(request),
      isRegistration: false,
    );
  }

  Future<void> _authenticate(
    Future<Either<Failure, RegistrationResponseModel>> Function() operation, {
    required bool isRegistration,
  }) async {
    if (isClosed || state is AuthLoading) return;

    emit(const AuthLoading());
    final result = await operation();
    if (isClosed) return;

    result.fold(
      (failure) =>
          emit(AuthFailureState(_userMessageFor(failure, isRegistration))),
      (response) => emit(AuthSuccess(response)),
    );
  }

  void reset() {
    if (!isClosed && state is! AuthLoading) {
      emit(const AuthInitial());
    }
  }

  String _userMessageFor(Failure failure, bool isRegistration) {
    if (failure is NetworkFailure) {
      return 'تعذر الاتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.';
    }
    if (failure is ValidationFailure) {
      return isRegistration
          ? 'تعذر إنشاء الحساب. تحقق من البيانات المدخلة.'
          : 'يرجى مراجعة البريد الإلكتروني وكلمة المرور.';
    }
    if (failure is StorageFailure) {
      return isRegistration
          ? 'تم إنشاء الحساب لكن تعذر حفظ بيانات الدخول على هذا الجهاز.'
          : 'تعذر حفظ بيانات الدخول على هذا الجهاز. حاول مرة أخرى.';
    }
    if (failure is AuthFailure) {
      if (!isRegistration) {
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
      }
      if (failure.code?.contains('EMAIL') == true ||
          failure.code?.contains('PHONE') == true ||
          failure.code?.contains('EXISTS') == true) {
        return 'البريد الإلكتروني أو رقم الهاتف مستخدم بالفعل.';
      }
    }
    if (failure is ServerFailure) {
      return 'حدث خطأ في الخادم. حاول مرة أخرى لاحقًا.';
    }
    return isRegistration
        ? 'لم نتمكن من إتمام التسجيل. حاول مرة أخرى.'
        : 'لم نتمكن من تسجيل الدخول. حاول مرة أخرى.';
  }
}
