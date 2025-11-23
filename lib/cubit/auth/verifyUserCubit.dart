import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro_single_vender_rider/data/repositories/auth/authRepository.dart';


@immutable
abstract class VerifyUserState {}

class VerifyUserInitial extends VerifyUserState {}

class VerifyUserProgress extends VerifyUserState {
  VerifyUserProgress();
}

class VerifyUserSuccess extends VerifyUserState {
  VerifyUserSuccess();
}

class VerifyUserFailure extends VerifyUserState {
  final String errorMessage;
  VerifyUserFailure(this.errorMessage);
}

class VerifyUserCubit extends Cubit<VerifyUserState> {
  final AuthRepository _authRepository;
  VerifyUserCubit(this._authRepository) : super(VerifyUserInitial());

  //to verify user
  void verifyUser({String? mobile}) {
    //emitting verifyProgress state
    emit(VerifyUserProgress());
    //verify user with given provider and also add user detials in api
    _authRepository.verify(mobile: mobile).then((result) {
      
      emit(VerifyUserSuccess());
    }).catchError((e) {
      
      emit(VerifyUserFailure(e.toString()));
    });
  }
}
