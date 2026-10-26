import 'package:equatable/equatable.dart';
import 'package:skann_app/features/auth/data/models/registration_response_model.dart';

abstract class AuthStates extends Equatable {
  const AuthStates();
}

class AuthInitial extends AuthStates {
  const AuthInitial();

  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthStates {
  const AuthLoading();

  @override
  List<Object?> get props => [];
}

class AuthSuccess extends AuthStates {
  const AuthSuccess(this.response);

  final RegistrationResponseModel response;

  @override
  List<Object?> get props => [response];
}

class AuthFailureState extends AuthStates {
  const AuthFailureState(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
