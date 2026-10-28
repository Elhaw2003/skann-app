import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skann_app/core/errors/failure.dart';
import 'package:skann_app/core/services/secure_storage_helper.dart';
import 'package:skann_app/features/auth/data/models/registration_response_model.dart';
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
    if (currentState.isRefreshing || currentState.isUpdating) return;

    final generation = ++_requestGeneration;
    emit(currentState.copyWith(isRefreshing: true, clearRefreshError: true));
    final result = await repository.getMyProfile();
    if (isClosed || generation != _requestGeneration) return;

    result.fold(
      (failure) {
        final latestState = state;
        if (latestState is ProfileLoaded) {
          emit(
            latestState.copyWith(
              isRefreshing: false,
              refreshError: _messageFor(failure),
            ),
          );
        }
      },
      (user) {
        emit(ProfileLoaded(user: user));
      },
    );
  }

  Future<Failure?> updateProfile(
    Map<String, Object?> changes, {
    XFile? profileImage,
  }) async {
    if (isClosed) {
      return const UnexpectedFailure(
        'تعذر حفظ التعديلات. حاول فتح الصفحة مرة أخرى.',
      );
    }
    if (changes.isEmpty && profileImage == null) {
      return const ValidationFailure('لم يتم إجراء أي تغييرات على البيانات.');
    }
    if (state is! ProfileLoaded) {
      return const UnexpectedFailure('تعذر تحميل بيانات الملف الشخصي.');
    }

    final currentState = state as ProfileLoaded;
    if (currentState.isUpdating || currentState.isRefreshing) {
      return const ValidationFailure('هناك عملية أخرى قيد التنفيذ.');
    }

    emit(currentState.copyWith(isUpdating: true, clearRefreshError: true));
    final result = await repository.updateProfile(
      changes,
      profileImage: profileImage,
    );
    if (isClosed) {
      return const UnexpectedFailure(
        'تعذر إكمال حفظ التعديلات. حاول مرة أخرى.',
      );
    }

    if (result.isLeft()) {
      final failure = result.swap().getOrElse(
        () => const UnexpectedFailure('تعذر حفظ تعديلات الملف الشخصي.'),
      );
      final latestState = state;
      if (latestState is ProfileLoaded) {
        emit(latestState.copyWith(isUpdating: false));
      }
      return failure;
    }

    final updatedUser = result.getOrElse(() => currentState.user);
    if (profileImage == null) {
      emit(ProfileLoaded(user: updatedUser));
      return null;
    }

    final refreshedProfile = await repository.getMyProfile();
    if (isClosed) return null;

    return refreshedProfile.fold(
      (failure) {
        emit(
          ProfileLoaded(user: updatedUser, refreshError: _messageFor(failure)),
        );
        return const ServerFailure(
          'تعذر تأكيد حفظ الصورة من الخادم. لن تظهر الصورة في الملف الشخصي حتى يعيد الخادم رابطها.',
          code: 'PROFILE_IMAGE_NOT_CONFIRMED',
        );
      },
      (user) {
        emit(ProfileLoaded(user: user));
        if (_hasRemoteProfileImage(user)) return null;

        return const ServerFailure(
          'لم يُرجع الخادم رابط الصورة بعد رفعها. لن تظهر الصورة في الملف الشخصي حتى يعيد الخادم رابطها.',
          code: 'PROFILE_IMAGE_NOT_CONFIRMED',
        );
      },
    );
  }

  bool _hasRemoteProfileImage(UserModel user) =>
      user.profileImage?.trim().isNotEmpty ?? false;

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
