import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/services/secure_storage_helper.dart';
import 'package:skann_app/features/profile/data/repositories/profile_repository.dart';
import 'package:skann_app/features/profile/presentation/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required this.repository, required this.secureStorageHelper})
    : super(const ProfileInitial());

  final ProfileRepository repository;
  final SecureStorageHelper secureStorageHelper;
  int _requestGeneration = 0;

  Future<void> load() async {
    if (isClosed || state is ProfileLoading || state is ProfileLoaded) return;
    await _fetchProfile();
  }

  Future<void> refresh() async {
    if (isClosed || state is ProfileLoading) return;
    if (state is! ProfileLoaded) {
      await load();
      return;
    }

    final currentState = state as ProfileLoaded;
    if (currentState.isRefreshing) return;

    final generation = ++_requestGeneration;
    emit(currentState.copyWith(isRefreshing: true, clearRefreshError: true));
    final result = await repository.getMyProfile();
    if (isClosed || generation != _requestGeneration) return;

    result.fold((failure) {
      final latestState = state;
      if (latestState is ProfileLoaded) {
        emit(
          latestState.copyWith(
            isRefreshing: false,
            refreshError: _messageFor(failure),
          ),
        );
      }
    }, (user) => emit(ProfileLoaded(user: user)));
  }

  Future<void> logout() => secureStorageHelper.clearTokens();

  Future<void> _fetchProfile() async {
    final generation = ++_requestGeneration;
    emit(const ProfileLoading());
    final result = await repository.getMyProfile();
    if (isClosed || generation != _requestGeneration) return;

    result.fold(
      (failure) => emit(
        ProfileFailure(
          _messageFor(failure),
          requiresLogin: failure is AuthFailure,
        ),
      ),
      (user) => emit(ProfileLoaded(user: user)),
    );
  }

  String _messageFor(Failure failure) {
    if (failure is NetworkFailure) {
      return 'تعذر الاتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.';
    }
    if (failure is AuthFailure) {
      return 'انتهت صلاحية جلسة الدخول. سجّل الدخول مرة أخرى للمتابعة.';
    }
    if (failure is ServerFailure) {
      return 'حدث خطأ في الخادم. حاول مرة أخرى لاحقًا.';
    }
    return 'لم نتمكن من تحميل بيانات الملف الشخصي. حاول مرة أخرى.';
  }
}
