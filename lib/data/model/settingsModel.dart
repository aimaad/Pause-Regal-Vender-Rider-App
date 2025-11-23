class SettingsModel {
  final bool skip;
  String latitude;
  String longitude;

  SettingsModel(
      {
      required this.latitude,
      required this.longitude,
      required this.skip,
      });

  static SettingsModel fromJson(var settingsJson) {
    //to see the json response go to getCurrentSettings() function in settingsRepository
    return SettingsModel(
        latitude: settingsJson['latitude'],
        longitude: settingsJson['longitude'],
        skip: settingsJson['skip'],
      );
  }

  SettingsModel copyWith(
      {
      bool? skip,
      String? latitude,
      String? longitude,
      }) {
    return SettingsModel(
        skip: skip ?? this.skip,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        );
  }
}
