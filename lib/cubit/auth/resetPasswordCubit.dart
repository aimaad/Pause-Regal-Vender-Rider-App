import 'package:erestro_single_vender_rider/data/repositories/auth/authRepository.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageAndCodeException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


@immutable
abstract class ResetPasswordState {}

class ResetPasswordInitial extends ResetPasswordState {}

class ResetPassword extends ResetPasswordState {
  ResetPassword();
}

class ResetPasswordProgress extends ResetPasswordState {
  ResetPasswordProgress();
}

class ResetPasswordSuccess extends ResetPasswordState {
  final String? mobile, password;
  ResetPasswordSuccess(this.mobile, this.password);
}

class ResetPasswordFailure extends ResetPasswordState {
  final String errorMessage, errorCode;
  ResetPasswordFailure(this.errorMessage, this.errorCode);
}

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final AuthRepository _authRepository;
  ResetPasswordCubit(this._authRepository) : super(ResetPasswordInitial());

  //to resetPassword user
  void resetPassword({
    String? mobile,
    String? password,
  }) {
    //emitting resetPasswordProgress state
    emit(ResetPasswordProgress());
    //resetPassword user with given provider and also reset password user in api
    _authRepository
        .resetPassword(
      mobile: mobile,
      password: password,
    )
        .then((result) {
      
      emit(ResetPasswordSuccess(mobile, password));
    }).catchError((e) {
      
      ApiMessageAndCodeException authException = e;
      emit(ResetPasswordFailure(authException.errorMessage.toString(), authException.errorStatusCode.toString()));
    });
  }
}
