import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/features/profile/data/repositories/profile_repository.dart';
import 'package:skann_app/features/profile/presentation/cubit/change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit({required this.repository})
    : super(const ChangePasswordInitial());

  final ProfileRepository repository;

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (isClosed || state is ChangePasswordLoading) return;

    emit(const ChangePasswordLoading());
    final result = await repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(ChangePasswordFailure(_messageFor(failure))),
      (_) => emit(const ChangePasswordSuccess()),
    );
  }

  String _messageFor(Failure failure) {
    if (failure is NetworkFailure) {
      return 'تعذر الاتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.';
    }
    if (failure is AuthFailure) {
      return 'انتهت صلاحية جلسة الدخول. سجّل الدخول مرة أخرى للمتابعة.';
    }
    if (failure is ServerFailure ||
        failure is ValidationFailure ||
        failure is PermissionFailure) {
      final message = failure.message.trim();
      if (message.isNotEmpty) return message;
    }
    return 'لم نتمكن من تغيير كلمة المرور. حاول مرة أخرى.';
  }
}
