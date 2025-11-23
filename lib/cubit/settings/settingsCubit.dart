
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro_single_vender_rider/data/model/settingsModel.dart';
import 'package:erestro_single_vender_rider/data/repositories/settings/settingsRepository.dart';

class SettingsState {
  final SettingsModel? settingsModel;
  SettingsState({this.settingsModel});
}

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;
  SettingsCubit(this._settingsRepository) : super(SettingsState()) {
    _getCurrentSettings();
  }

  void _getCurrentSettings() {
    emit(SettingsState(settingsModel: SettingsModel.fromJson(_settingsRepository.getCurrentSettings())));
  }

  SettingsModel getSettings() {
    return state.settingsModel!;
  }

  void changeShowSkip() {
    _settingsRepository.changeSkip(false);
    emit(SettingsState(settingsModel: state.settingsModel!.copyWith(skip: false)));
  }

  setLatitude(String latitude) {
    _settingsRepository.changeLatitude(latitude);
    emit(SettingsState(settingsModel: state.settingsModel!.copyWith(latitude: latitude)));
  }

  setLongitude(String longitude) {
    _settingsRepository.changeLongitude(longitude);
    emit(SettingsState(settingsModel: state.settingsModel!.copyWith(longitude: longitude)));
  }
}
