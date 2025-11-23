import 'dart:io';
import 'package:erestro_single_vender_rider/data/repositories/auth/authRepository.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageAndCodeException.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@immutable
abstract class RegistrationState {}

class RegistrationInitial extends RegistrationState {}

class RegistrationInProgress extends RegistrationState {}

class RegistrationSuccess extends RegistrationState {
  final String message;

  RegistrationSuccess(this.message);
}

class RegistrationFailure extends RegistrationState {
  final String errorMessage, errorStatusCode;
  RegistrationFailure(this.errorMessage, this.errorStatusCode);
}

class RegistrationCubit extends Cubit<RegistrationState> {
  final AuthRepository _authRepository;

  RegistrationCubit(this._authRepository) : super(RegistrationInitial());

  void registration(File? file, String? name, String? email, String? mobile, String? address, String? serviceableCity, String? password) async {
    emit(RegistrationInProgress());
    _authRepository.registration(file, name, email, mobile, address, serviceableCity, password).then((value) {
      
      emit(RegistrationSuccess(value['message']));
    }).catchError((e) {
      
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(RegistrationFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }
}
