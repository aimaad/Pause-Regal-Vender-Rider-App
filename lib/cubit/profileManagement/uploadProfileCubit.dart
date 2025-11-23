import 'dart:io';
import 'package:erestro_single_vender_rider/data/model/authModel.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageAndCodeException.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro_single_vender_rider/data/repositories/profileManagement/profileManagementRepository.dart';

@immutable
abstract class UploadProfileState {}

class UploadProfileInitial extends UploadProfileState {}

class UploadProfileInProgress extends UploadProfileState {}

class UploadProfileSuccess extends UploadProfileState {
  final AuthModel authModel;

  UploadProfileSuccess(this.authModel);
}

class UploadProfileFailure extends UploadProfileState {
  final String errorMessage, errorStatusCode;
  UploadProfileFailure(this.errorMessage, this.errorStatusCode);
}

class UploadProfileCubit extends Cubit<UploadProfileState> {
  final ProfileManagementRepository _profileManagementRepository;

  UploadProfileCubit(this._profileManagementRepository) : super(UploadProfileInitial());

  void uploadProfilePicture(File? file, String? userId) async {
    emit(UploadProfileInProgress());
    _profileManagementRepository.uploadProfilePicture(file, userId).then((value) {
      
      emit(UploadProfileSuccess(AuthModel.fromJson(value)));
    }).catchError((e) {
      
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(UploadProfileFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }
}
