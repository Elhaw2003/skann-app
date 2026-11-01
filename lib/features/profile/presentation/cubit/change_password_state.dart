import 'package:equatable/equatable.dart';

sealed class ChangePasswordState extends Equatable {
  const ChangePasswordState();
}

class ChangePasswordInitial extends ChangePasswordState {
  const ChangePasswordInitial();

  @override
  List<Object?> get props => [];
}

class ChangePasswordLoading extends ChangePasswordState {
  const ChangePasswordLoading();

  @override
  List<Object?> get props => [];
}

class ChangePasswordSuccess extends ChangePasswordState {
  const ChangePasswordSuccess();

  @override
  List<Object?> get props => [];
}

class ChangePasswordFailure extends ChangePasswordState {
  const ChangePasswordFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
