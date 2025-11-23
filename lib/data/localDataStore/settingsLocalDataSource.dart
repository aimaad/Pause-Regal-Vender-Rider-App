import 'package:erestro_single_vender_rider/utils/apiBodyParameterLabels.dart';
import 'package:erestro_single_vender_rider/utils/constants.dart';
import 'package:erestro_single_vender_rider/utils/hiveBoxKey.dart';
import 'package:hive/hive.dart';

class SettingsLocalDataSource {
  String? showLatitude() {
    return Hive.box(settingsBox).get(latitudeKey, defaultValue: "");
  }

  String? showLongitude() {
    return Hive.box(settingsBox).get(longitudeKey, defaultValue: "");
  }

  bool? showSkip() {
    return Hive.box(settingsBox).get(skipKey, defaultValue: true);
  }

  String getCurrentLanguageCode() {
    return Hive.box(settingsBox).get(currentLanguageCodeKey) ?? defaultLanguageCode;
  }

  Future<void> setCurrentLanguageCode(String value) async {
    Hive.box(settingsBox).put(currentLanguageCodeKey, value);
  }

  Future<void> setSkip(bool value) async {
    Hive.box(settingsBox).put(skipKey, value);
  }

  Future<void> setLatitude(String latitude) async {
    Hive.box(settingsBox).put(latitudeKey, latitude);
  }

  Future<void> setLongitude(String longitude) async {
    Hive.box(settingsBox).put(longitudeKey, longitude);
  }
}
