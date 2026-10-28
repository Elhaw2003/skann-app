import 'package:equatable/equatable.dart';
import 'package:skann_app/features/auth/data/models/registration_response_model.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();

  @override
  List<Object?> get props => [];
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();

  @override
  List<Object?> get props => [];
}

class ProfileFailure extends ProfileState {
  const ProfileFailure(this.message, {this.requiresLogin = false});

  final String message;
  final bool requiresLogin;

  @override
  List<Object?> get props => [message, requiresLogin];
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded({
    required this.user,
    this.isRefreshing = false,
    this.refreshError,
    this.isUpdating = false,
  });

  final UserModel user;
  final bool isRefreshing;
  final String? refreshError;
  final bool isUpdating;

  ProfileLoaded copyWith({
    bool? isRefreshing,
    String? refreshError,
    bool clearRefreshError = false,
    bool? isUpdating,
    UserModel? user,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      refreshError: clearRefreshError
          ? null
          : refreshError ?? this.refreshError,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [user, isRefreshing, refreshError, isUpdating];
}
