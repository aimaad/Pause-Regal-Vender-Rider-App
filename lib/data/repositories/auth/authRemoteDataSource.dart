import 'dart:convert';
import 'dart:io';
import 'package:erestro_single_vender_rider/data/localDataStore/authLocalDataSource.dart';
import 'package:erestro_single_vender_rider/utils/api.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageAndCodeException.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageException.dart';
import 'package:erestro_single_vender_rider/utils/constants.dart';
import 'package:erestro_single_vender_rider/utils/string.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'package:erestro_single_vender_rider/utils/apiBodyParameterLabels.dart';

class AuthRemoteDataSource {
  //to loginUser
  Future<dynamic> signInUser({String? mobile, String? password}) async {
    try {
      String fcmToken = await getFCMToken();
      //body of post request
      final body = {
        mobileKey: mobile,
        passwordKey: password,
        fcmIdKey: fcmToken,
        deviceTypeKey: Platform.isAndroid ? "android" : "ios",
      };
      final result = await Api.post(
          body: body, url: Api.loginUrl, token: false, errorCode: false);
      AuthLocalDataSource.setJwtTocken(result['token']);

      return result[dataKey];
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  //to check user's exist
  Future<bool> isUserExist(String mobile) async {
    try {
      final body = {
        mobileKey: mobile,
        isForgotPasswordKey: "0",
      };
      final result = await Api.post(
          body: body, url: Api.verifyUserUrl, token: false, errorCode: false);
      if (result[errorKey] == true) {
        //if user does not exist means
        if (result[messageKey] == tockenExpireCode) {
          return false;
        }
        throw ApiMessageException(errorMessage: result[messageKey]);
      }
      return true;
    } on SocketException catch (_) {
      throw ApiMessageException(errorMessage: StringsRes.noInternet);
    } on ApiMessageException catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  //to verify otp user's exist
  Future<bool> isVerifyOtp(String mobile, String otp) async {
    try {
      final body = {mobileKey: mobile, otpKey: otp};
      final result = await Api.post(
          body: body, url: Api.verifyOtpUrl, token: true, errorCode: false);
      if (result['error']) {
        //if user does not exist means
        if (result['message'] == "102") {
          return false;
        }
        throw ApiMessageException(errorMessage: result['message']);
      }
      return true;
    } on SocketException catch (_) {
      throw ApiMessageException(errorMessage: StringsRes.noInternet);
    } on ApiMessageException catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  //to check user's exist
  Future<bool> isResendOtp(String mobile) async {
    try {
      final body = {mobileKey: mobile};
      final result = await Api.post(
          body: body, url: Api.resendOtpUrl, token: true, errorCode: false);
      if (result['error']) {
        //if user does not exist means
        if (result['message'] == "102") {
          return false;
        }
        throw ApiMessageException(errorMessage: result['message']);
      }
      return true;
    } on SocketException catch (_) {
      throw ApiMessageException(errorMessage: StringsRes.noInternet);
    } on ApiMessageException catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  //to reset password of user's
  Future<dynamic> resetPassword({String? mobile, String? password}) async {
    try {
      //body of post request
      final body = {mobileNoKey: mobile, newKey: password};
      print("call here" + body.toString());
      final response = await Api.post(
          body: body, url: Api.resetPasswordUrl, token: true, errorCode: true);
      print(response);

      if (response[errorKey] == true) {
        throw ApiMessageAndCodeException(
            errorMessage: response["message"],
            errorStatusCode: response[statusCodeKey].toString());
      }

      return response;
    } catch (e) {
      print("call here" + e.toString());
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  //to change password of user's
  Future<dynamic> changePassword(
      {String? userId, String? oldPassword, String? newPassword}) async {
    try {
      //body of post request
      final body = {
        userIdKey: userId,
        oldKey: oldPassword,
        newKey: newPassword
      };
      final response = await Api.post(
          body: body, url: Api.updateUserUrl, token: true, errorCode: true);

      if (response[errorKey] == true) {
        throw ApiMessageAndCodeException(
            errorMessage: response[messageKey],
            errorStatusCode: response[statusCodeKey].toString());
      }
      return response;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  //to delete my account
  Future<bool> deleteMyAccount(String riderId) async {
    try {
      final body = {
        riderIdKey: riderId,
      };
      final result = await Api.post(
          body: body,
          url: Api.deleteMyAccountUrl,
          token: true,
          errorCode: true);
      if (result[errorKey]) {
        //if user does not exist means
        if (result[messageKey] == tockenExpireCode) {
          return false;
        }
        throw ApiMessageAndCodeException(
            errorMessage: result[messageKey],
            errorStatusCode: result[statusCodeKey].toString());
      }
      return true;
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  //to update fcmId of user's
  Future<dynamic> updateFcmId({
    String? userId,
    String? fcmId,
  }) async {
    try {
      //body of post request
      final body = {
        userIdKey: userId,
        fcmIdKey: fcmId,
        deviceTypeKey: Platform.isAndroid ? "android" : "ios",
      };
      final result = await Api.post(
          body: body, url: Api.updateFcmUrl, token: true, errorCode: false);
      return result[dataKey];
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  Future<String> getFCMToken() async {
    try {
      return await fcm.FirebaseMessaging.instance.getToken() ?? "";
    } catch (e) {
      return "";
    }
  }

  Future<dynamic> registration(
      File? images,
      String? name,
      String? email,
      String? mobile,
      String? address,
      String? serviceableCity,
      String? password) async {
    try {
      Map<String, String?> body = {
        nameKey: name,
        emailKey: email,
        mobileKey: mobile,
        addressKey: address,
        serviceableCitysKey: serviceableCity,
        passwordKey: password,
        deviceTypeKey: Platform.isAndroid ? "android" : "ios",
      };
      Map<String, File?> fileList = {
        profileKey: images,
      };
      var response = await Api.postApiRegistration(
          Uri.parse(Api.registerRiderUrl),
          fileList,
          body,
          name,
          email,
          mobile,
          address,
          serviceableCity,
          password);
      final res = json.decode(response);
      if (res[errorKey] == true) {
        throw ApiMessageAndCodeException(
            errorMessage: res[messageKey],
            errorStatusCode: res[statusCodeKey].toString());
      }
      return res;
    } on SocketException catch (_) {
      throw ApiMessageAndCodeException(errorMessage: StringsRes.noInternet);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(),
          errorStatusCode:
              apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
