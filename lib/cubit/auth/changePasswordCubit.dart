import 'package:erestro_single_vender_rider/data/repositories/auth/authRepository.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageAndCodeException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


@immutable
abstract class ChangePasswordState {}

class ChangePasswordInitial extends ChangePasswordState {}

class ChangePassword extends ChangePasswordState {
  ChangePassword();
}

class ChangePasswordProgress extends ChangePasswordState {
  ChangePasswordProgress();
}

class ChangePasswordSuccess extends ChangePasswordState {
  final String? userId, oldPassword, newPassword;
  ChangePasswordSuccess(this.userId, this.oldPassword, this.newPassword);
}

class ChangePasswordFailure extends ChangePasswordState {
  final String errorMessage, errorCode;
  ChangePasswordFailure(this.errorMessage, this.errorCode);
}

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final AuthRepository _authRepository;
  ChangePasswordCubit(this._authRepository) : super(ChangePasswordInitial());

  //to changePassword user
  void changePassword({
    String? userId,
    String? oldPassword,
    String? newPassword,
  }) {
    //emitting changePasswordProgress state
    emit(ChangePasswordProgress());
    //changePassword user with given provider and also change password user in api
    _authRepository
        .changePassword(
      userId: userId,
      oldPassword: oldPassword,
      newPassword: newPassword,
    )
        .then((result) {
      
      emit(ChangePasswordSuccess(userId, oldPassword, newPassword));
    }).catchError((e) {
      
      ApiMessageAndCodeException authException = e;
      emit(ChangePasswordFailure(authException.errorMessage.toString(), authException.errorStatusCode.toString()));
    });
  }
}
