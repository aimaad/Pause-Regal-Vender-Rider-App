import 'dart:convert';
import 'dart:io';
import 'package:erestro_single_vender_rider/data/model/authModel.dart';
import 'package:erestro_single_vender_rider/utils/api.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageAndCodeException.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageException.dart';
import 'package:erestro_single_vender_rider/utils/string.dart';
import 'package:erestro_single_vender_rider/utils/apiBodyParameterLabels.dart';

class ProfileManagementRemoteDataSource {
  Future<dynamic> addProfileImage(File? images, String? userId) async {
    try {
      Map<String, String?> body = {userIdKey: userId};
      Map<String, File?> fileList = {
        profileKey: images,
      };
      var response = await Api.postApiFileProfilePic(
          Uri.parse(Api.updateUserUrl), fileList, body, userId);
      final res = json.decode(response);
      if (res[errorKey] == true) {
        throw ApiMessageAndCodeException(
            errorMessage: res[messageKey],
            errorStatusCode: res[statusCodeKey].toString());
      }
      return res[dataKey];
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

  Future<dynamic> updateProfile(
      {String? userId,
      String? email,
      String? name,
      String? mobile,
      String? address,
      String? status}) async {
    try {
      //body of post request
      Map<String, String> body = {
        userIdKey: userId.toString(),
        emailKey: email.toString(),
        userNameKey: name.toString(),
        mobileKey: mobile.toString(),
        addressKey: address.toString()
      };
      if(status!=null){
        body[acceptOrdersKey] = status;
      }
      final result = await Api.post(
          body: body, url: Api.updateUserUrl, token: true, errorCode: true);
      if (result[errorKey] == true) {
        throw ApiMessageAndCodeException(
            errorMessage: result[messageKey],
            errorStatusCode: result[statusCodeKey].toString());
      }
      return result[dataKey];
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  Future<AuthModel> getRiderDetail(String? id) async {
    try {
      final body = {idKey: id};
      final result = await Api.post(
          body: body, url: Api.getRiderDetailsUrl, token: true, errorCode: false);
      return AuthModel.fromJson(result[dataKey]);
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }
}
