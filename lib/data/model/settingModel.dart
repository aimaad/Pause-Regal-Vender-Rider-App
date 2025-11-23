class SettingModel {
  bool? error;
  int? allowModification;
  String? message;
  Data? data;

  SettingModel({this.error, this.allowModification, this.message, this.data});

  SettingModel.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    allowModification = json['allow_modification'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['error'] = this.error;
    data['allow_modification'] = this.allowModification;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  SystemSettings? systemSettings;
  String? riderTermsConditions;
  String? riderPrivacyPolicy;
  int? authenticationMode;

  Data(
      {this.systemSettings,
      this.riderTermsConditions,
      this.riderPrivacyPolicy,
      this.authenticationMode});

  Data.fromJson(Map<String, dynamic> json) {
    systemSettings = json['system_settings'] != null
        ? new SystemSettings.fromJson(json['system_settings'])
        : null;
    riderTermsConditions = json['rider_terms_conditions'];
    riderPrivacyPolicy = json['rider_privacy_policy'];
    authenticationMode = json['authentication_mode'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.systemSettings != null) {
      data['system_settings'] = this.systemSettings!.toJson();
    }
    data['rider_terms_conditions'] = this.riderTermsConditions;
    data['rider_privacy_policy'] = this.riderPrivacyPolicy;
    return data;
  }
}

class SystemSettings {
  String? systemConfigurations;
  String? systemTimezoneGmt;
  String? systemConfigurationsId;
  String? appName;
  String? supportNumber;
  String? supportEmail;
  String? currentVersion;
  String? currentVersionIos;
  String? isVersionSystemOn;
  String? otpLogin;
  String? googleLogin;
  String? facebookLogin;
  String? appleLogin;
  String? currency;
  String? systemTimezone;
  String? isReferEarnOn;
  String? tax;
  String? isEmailSettingOn;
  String? googleMapApiKey;
  String? googleMapJavascriptApiKey;
  String? minReferEarnOrderAmount;
  String? referEarnBonus;
  String? referEarnMethod;
  String? maxReferEarnAmount;
  String? referEarnBonusTimes;
  String? minimumCartAmt;
  String? lowStockLimit;
  String? maxItemsCart;
  String? isRiderOtpSettingOn;
  String? isAppMaintenanceModeOn;
  String? isRiderAppMaintenanceModeOn;
  String? isPartnerAppMaintenanceModeOn;
  String? isWebMaintenanceModeOn;
  String? supportedLocals;
  String? customerAppAndroidLink;
  String? riderAppAndroidLink;
  String? customerAppIosLink;
  String? riderAppIosLink;

  SystemSettings(
      {this.systemConfigurations,
      this.systemTimezoneGmt,
      this.systemConfigurationsId,
      this.appName,
      this.supportNumber,
      this.supportEmail,
      this.currentVersion,
      this.currentVersionIos,
      this.isVersionSystemOn,
      this.otpLogin,
      this.googleLogin,
      this.facebookLogin,
      this.appleLogin,
      this.currency,
      this.systemTimezone,
      this.isReferEarnOn,
      this.tax,
      this.isEmailSettingOn,
      this.googleMapApiKey,
      this.googleMapJavascriptApiKey,
      this.minReferEarnOrderAmount,
      this.referEarnBonus,
      this.referEarnMethod,
      this.maxReferEarnAmount,
      this.referEarnBonusTimes,
      this.minimumCartAmt,
      this.lowStockLimit,
      this.maxItemsCart,
      this.isRiderOtpSettingOn,
      this.isAppMaintenanceModeOn,
      this.isRiderAppMaintenanceModeOn,
      this.isPartnerAppMaintenanceModeOn,
      this.isWebMaintenanceModeOn,
      this.supportedLocals,
      this.customerAppAndroidLink,
      this.riderAppAndroidLink,
      this.customerAppIosLink,
      this.riderAppIosLink,});

  SystemSettings.fromJson(Map<String, dynamic> json) {
    systemConfigurations = json['system_configurations'];
    systemTimezoneGmt = json['system_timezone_gmt'];
    systemConfigurationsId = json['system_configurations_id'];
    appName = json['app_name'];
    supportNumber = json['support_number'];
    supportEmail = json['support_email'];
    currentVersion = json['current_version'];
    currentVersionIos = json['current_version_ios'];
    isVersionSystemOn = json['is_version_system_on'];
    otpLogin = json['otp_login'];
    googleLogin = json['google_login'];
    facebookLogin = json['facebook_login'];
    appleLogin = json['apple_login'];
    currency = json['currency'];
    systemTimezone = json['system_timezone'];
    isReferEarnOn = json['is_refer_earn_on'];
    tax = json['tax'];
    isEmailSettingOn = json['is_email_setting_on'];
    googleMapApiKey = json['google_map_api_key'];
    googleMapJavascriptApiKey = json['google_map_javascript_api_key'];
    minReferEarnOrderAmount = json['min_refer_earn_order_amount'];
    referEarnBonus = json['refer_earn_bonus'];
    referEarnMethod = json['refer_earn_method'];
    maxReferEarnAmount = json['max_refer_earn_amount'];
    referEarnBonusTimes = json['refer_earn_bonus_times'];
    minimumCartAmt = json['minimum_cart_amt'];
    lowStockLimit = json['low_stock_limit'];
    maxItemsCart = json['max_items_cart'];
    isRiderOtpSettingOn = json['is_rider_otp_setting_on'];
    isAppMaintenanceModeOn = json['is_app_maintenance_mode_on'];
    isRiderAppMaintenanceModeOn = json['is_rider_app_maintenance_mode_on'];
    isPartnerAppMaintenanceModeOn = json['is_partner_app_maintenance_mode_on'];
    isWebMaintenanceModeOn = json['is_web_maintenance_mode_on'];
    supportedLocals = json['supported_locals'];
    customerAppAndroidLink = json['customer_app_android_link'];
    riderAppAndroidLink = json['rider_app_android_link'];
    customerAppIosLink = json['customer_app_ios_link'];
    riderAppIosLink = json['rider_app_ios_link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['system_configurations'] = this.systemConfigurations;
    data['system_timezone_gmt'] = this.systemTimezoneGmt;
    data['system_configurations_id'] = this.systemConfigurationsId;
    data['app_name'] = this.appName;
    data['support_number'] = this.supportNumber;
    data['support_email'] = this.supportEmail;
    data['current_version'] = this.currentVersion;
    data['current_version_ios'] = this.currentVersionIos;
    data['is_version_system_on'] = this.isVersionSystemOn;
    data['otp_login'] = this.otpLogin;
    data['google_login'] = this.googleLogin;
    data['facebook_login'] = this.facebookLogin;
    data['apple_login'] = this.appleLogin;
    data['currency'] = this.currency;
    data['system_timezone'] = this.systemTimezone;
    data['is_refer_earn_on'] = this.isReferEarnOn;
    data['tax'] = this.tax;
    data['is_email_setting_on'] = this.isEmailSettingOn;
    data['google_map_api_key'] = this.googleMapApiKey;
    data['google_map_javascript_api_key'] = this.googleMapJavascriptApiKey;
    data['min_refer_earn_order_amount'] = this.minReferEarnOrderAmount;
    data['refer_earn_bonus'] = this.referEarnBonus;
    data['refer_earn_method'] = this.referEarnMethod;
    data['max_refer_earn_amount'] = this.maxReferEarnAmount;
    data['refer_earn_bonus_times'] = this.referEarnBonusTimes;
    data['minimum_cart_amt'] = this.minimumCartAmt;
    data['low_stock_limit'] = this.lowStockLimit;
    data['max_items_cart'] = this.maxItemsCart;
    data['is_rider_otp_setting_on'] = this.isRiderOtpSettingOn;
    data['is_app_maintenance_mode_on'] = this.isAppMaintenanceModeOn;
    data['is_rider_app_maintenance_mode_on'] = this.isRiderAppMaintenanceModeOn;
    data['is_partner_app_maintenance_mode_on'] =
        this.isPartnerAppMaintenanceModeOn;
    data['is_web_maintenance_mode_on'] = this.isWebMaintenanceModeOn;
    data['supported_locals'] = this.supportedLocals;
    return data;
  }
}
