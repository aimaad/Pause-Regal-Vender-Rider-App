import 'package:erestro_single_vender_rider/app/app.dart';
import 'package:erestro_single_vender_rider/data/localDataStore/authLocalDataSource.dart';
import 'package:erestro_single_vender_rider/utils/apiBodyParameterLabels.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageAndCodeException.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageException.dart';
import 'package:erestro_single_vender_rider/utils/constants.dart';
import 'package:erestro_single_vender_rider/utils/string.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class Api {
//api end points
  static String addTransactionUrl = "${databaseUrl}add_transaction";
  static String getLiveTrackingDetailsUrl =
      "${databaseUrl}get_live_tracking_details";
  static String loginUrl = "${databaseUrl}login";
  static String verifyUserUrl = "${databaseUrl}verify_user";
  static String getFundTransfersUrl = "${databaseUrl}get_fund_transfers";
  static String updateFcmUrl = "${databaseUrl}update_fcm";
  static String getRiderDetailsUrl = "${databaseUrl}get_rider_details";
  static String updateUserUrl = "${databaseUrl}update_user";
  static String getSettingsUrl = "${databaseUrl}get_settings";
  static String getOrdersUrl = "${databaseUrl}get_orders";
  static String resetPasswordUrl = "${databaseUrl}reset_password";
  static String updateOrderStatusUrl = "${databaseUrl}update_order_status";
  static String updateOrderRequestUrl = "${databaseUrl}update_order_request";
  static String deleteMyAccountUrl = "${databaseUrl}delete_rider";
  static String getPendingOrdersUrl = "${databaseUrl}get_pending_orders";
  static String sendWithdrawRequestUrl =
      "${databaseUrl}send_withdrawal_request";
  static String getWithdrawRequestUrl = "${databaseUrl}get_withdrawal_request";
  static String getRiderCashCollectionUrl =
      "${databaseUrl}get_rider_cash_collection";
  static String manageLiveTrackingUrl = "${databaseUrl}manage_live_tracking";
  static String deleteLiveTrackingUrl = "${databaseUrl}delete_live_tracking";
  static String getAllDetailsUrl = "${databaseUrl}get_all_details";
  static String verifyOtpUrl = "${databaseUrl}verify_otp";
  static String resendOtpUrl = "${databaseUrl}resend_otp";
  static String getCitiesUrl = "${databaseUrl}get_cities";
  static String registerRiderUrl = "${databaseUrl}register_rider";

  //jwt key tocken
  static Map<String, String> getHeaders() {
    String jwtToken = AuthLocalDataSource().getJwtTocken()!;
    return {"Authorization": 'Bearer $jwtToken'};
  }

  static Future<dynamic> post(
      {required Map<dynamic, dynamic> body,
      required String url,
      bool? token,
      bool? errorCode}) async {
    try {
      http.Response response;
      if (token!) {
        response = await http.post(Uri.parse(url),
            body: body, headers: Api.getHeaders());
      } else {
        response = await http.post(Uri.parse(url), body: body);
      }
      print(
          "url:$url\nparameter:$body\njwtToken:${Api.getHeaders()}\nresponse:${response.body}");
      if (response.statusCode == 503) {
        isMaintenance(navigatorKey.currentContext!);
      }
      final responseJson = convertJson(response);
      print(responseJson);
      if (responseJson['error']) {
        if (errorCode!) {
          throw ApiMessageAndCodeException(
              errorMessage: responseJson[messageKey],
              errorStatusCode: responseJson[statusCodeKey].toString());
        } else {
          throw ApiMessageException(errorMessage: responseJson[messageKey]);
        }
      }

      return responseJson;
    } on SocketException catch (_) {
      throw ApiMessageAndCodeException(errorMessage: StringsRes.noInternet);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      print(
          "error:${apiMessageAndCodeException.errorMessage.toString()} -- ${apiMessageAndCodeException.errorStatusCode.toString()}");
      if (apiMessageAndCodeException.errorStatusCode == tockenExpireCode) {
        reLogin(navigatorKey.currentContext!);
      }
      if (errorCode!) {
        print(
            "error:${apiMessageAndCodeException.errorMessage.toString()} -- ${apiMessageAndCodeException.errorStatusCode.toString()}");
        throw ApiMessageAndCodeException(
            errorMessage: apiMessageAndCodeException.errorMessage.toString(),
            errorStatusCode:
                apiMessageAndCodeException.errorStatusCode.toString());
      } else {
        throw ApiMessageAndCodeException(
            errorMessage: apiMessageAndCodeException.errorMessage.toString());
      }
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  static Future postApiFileProfilePic(Uri url, Map<String, File?> fileList,
      Map<String, String?> body, String? userId) async {
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(Api.getHeaders());
      body.forEach((key, value) {
        request.fields[key] = value!;
      });
      body[userIdKey] = userId;

      fileList.forEach((key, value) async {
        final mimeType = lookupMimeType(value!.path);

        var extension = mimeType!.split("/");
        var pic = await http.MultipartFile.fromPath(key, value.path,
            contentType: MediaType('image', extension[1]));
        request.files.add(pic);
      });
      var res = await request.send();
      var responseData = await res.stream.toBytes();
      var response = String.fromCharCodes(responseData);
      if (res.statusCode == 503) {
        isMaintenance(navigatorKey.currentContext!);
      }
      if (res.statusCode == 200) {
        return response;
      } else {
        return null;
      }
    } on SocketException catch (_) {
      throw ApiMessageAndCodeException(errorMessage: StringsRes.noInternet);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      if (apiMessageAndCodeException.errorStatusCode == tockenExpireCode) {
        reLogin(navigatorKey.currentContext!);
      }
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(),
          errorStatusCode:
              apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  static Future postApiRegistration(
      Uri url,
      Map<String, File?> fileList,
      Map<String, String?> body,
      String? name,
      String? email,
      String? mobile,
      String? address,
      String? serviceableCity,
      String? password) async {
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(Api.getHeaders());
      body.forEach((key, value) {
        request.fields[key] = value!;
      });
      body[nameKey] = name;
      body[emailKey] = email;
      body[mobileKey] = mobile;
      body[addressKey] = address;
      body[serviceableCitysKey] = serviceableCity;
      body[passwordKey] = password;

      fileList.forEach((key, value) async {
        final mimeType = lookupMimeType(value!.path);

        var extension = mimeType!.split("/");
        var pic = await http.MultipartFile.fromPath(key, value.path,
            contentType: MediaType('image', extension[1]));
        request.files.add(pic);
      });
      var res = await request.send();
      var responseData = await res.stream.toBytes();
      var response = String.fromCharCodes(responseData);
      if (res.statusCode == 503) {
        isMaintenance(navigatorKey.currentContext!);
      }
      if (res.statusCode == 200) {
        return response;
      } else {
        return null;
      }
    } on SocketException catch (_) {
      throw ApiMessageAndCodeException(errorMessage: StringsRes.noInternet);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      if (apiMessageAndCodeException.errorStatusCode == tockenExpireCode) {
        reLogin(navigatorKey.currentContext!);
      }
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(),
          errorStatusCode:
              apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  static convertJson(Response response) {
    return json.decode(response.body);
  }
}
