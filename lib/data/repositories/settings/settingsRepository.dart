import 'package:erestro_single_vender_rider/data/localDataStore/settingsLocalDataSource.dart';
import 'package:erestro_single_vender_rider/utils/constants.dart';
import 'package:erestro_single_vender_rider/utils/hiveBoxKey.dart';
import 'package:hive/hive.dart';

class SettingsRepository {
  static final SettingsRepository _settingsRepository =
      SettingsRepository._internal();
  late SettingsLocalDataSource _settingsLocalDataSource;

  factory SettingsRepository() {
    _settingsRepository._settingsLocalDataSource = SettingsLocalDataSource();
    return _settingsRepository;
  }

  SettingsRepository._internal();

  Map<String, dynamic> getCurrentSettings() {
    return {
      "latitude": _settingsLocalDataSource.showLatitude(),
      "longitude": _settingsLocalDataSource.showLongitude(),
      "skip": _settingsLocalDataSource.showSkip(),
    };
  }

  void changeSkip(bool value) => _settingsLocalDataSource.setSkip(value);
  void changeLatitude(String latitude) =>
      _settingsLocalDataSource.setLatitude(latitude);
  void changeLongitude(String longitude) =>
      _settingsLocalDataSource.setLongitude(longitude);
  String getCurrentLanguageCode() {
    return Hive.box(settingsBox).get(currentLanguageCodeKey) ??
        defaultLanguageCode;
  }

  Future<void> setCurrentLanguageCode(String value) async {
    Hive.box(settingsBox).put(currentLanguageCodeKey, value);
  }
}
