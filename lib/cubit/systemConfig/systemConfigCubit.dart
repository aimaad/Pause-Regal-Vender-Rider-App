import 'dart:io';

import 'package:erestro_single_vender_rider/data/model/settingModel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro_single_vender_rider/data/repositories/systemConfig/systemConfigRepository.dart';

abstract class SystemConfigState {}

class SystemConfigIntial extends SystemConfigState {}

class SystemConfigFetchInProgress extends SystemConfigState {}

class SystemConfigFetchSuccess extends SystemConfigState {
  final SettingModel systemConfigModel;

  SystemConfigFetchSuccess({required this.systemConfigModel});
}

class SystemConfigFetchFailure extends SystemConfigState {
  final String errorCode;

  SystemConfigFetchFailure(this.errorCode);
}

class SystemConfigCubit extends Cubit<SystemConfigState> {
  final SystemConfigRepository _systemConfigRepository;
  SystemConfigCubit(this._systemConfigRepository) : super(SystemConfigIntial());

  //to getSettings
  getSystemConfig() {
    //emitting SystemConfigFetchInProgress state
    emit(SystemConfigFetchInProgress());
    //getSettings details in api
    _systemConfigRepository
        .getSystemConfig()
        .then(
            (value) => emit(SystemConfigFetchSuccess(systemConfigModel: value)))
        .catchError((e) {
      emit(SystemConfigFetchFailure(e.toString()));
    });
  }

  String getCurrency() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .systemSettings!
          .currency!;
    }
    return "";
  }

  String getIsReferEarnOn() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .systemSettings!
          .isReferEarnOn!;
    }
    return "";
  }

  String getCurrentVersionAndroid() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .systemSettings!
          .currentVersion!;
    }
    return "";
  }

  String getCurrentVersionIos() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .systemSettings!
          .currentVersionIos!;
    }
    return "";
  }

  String getReferEarnOn() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .systemSettings!
          .isReferEarnOn!;
    }
    return "";
  }

  String isForceUpdateEnable() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .systemSettings!
          .isVersionSystemOn!;
    }
    return "";
  }

  String isAppMaintenance() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .systemSettings!
          .isRiderAppMaintenanceModeOn!;
    }
    return "";
  }

  String getIsRiderOtpSettingOn() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .systemSettings!
          .isRiderOtpSettingOn!;
    }
    return "";
  }

  String getDemoMode() {
    if (state is SystemConfigFetchSuccess) {
      print(
          "getDemoMode:${(state as SystemConfigFetchSuccess).systemConfigModel.allowModification!.toString()}");
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .allowModification!
          .toString();
    }
    return "";
  }

  String getAuthenticationMethod() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess)
          .systemConfigModel
          .data!
          .authenticationMode
          .toString();
    }
    return "0";
  }

  String getAppLink() {
    if (state is SystemConfigFetchSuccess) {
      return Platform.isIOS
          ? (state as SystemConfigFetchSuccess)
              .systemConfigModel
              .data!
              .systemSettings!
              .riderAppIosLink!
          : (state as SystemConfigFetchSuccess)
              .systemConfigModel
              .data!
              .systemSettings!
              .riderAppAndroidLink!;
    }
    return "";
  }
}
