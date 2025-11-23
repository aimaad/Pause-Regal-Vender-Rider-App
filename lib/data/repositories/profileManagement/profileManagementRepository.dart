import 'package:erestro_single_vender_rider/data/localDataStore/profileManagementLocalDataSource.dart';
import 'package:erestro_single_vender_rider/data/model/authModel.dart';
import 'package:erestro_single_vender_rider/data/repositories/profileManagement/profileManagementRemoteDataSource.dart';
import 'dart:io';

import 'package:erestro_single_vender_rider/utils/apiMessageAndCodeException.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageException.dart';


class ProfileManagementRepository {
  static final ProfileManagementRepository _profileManagementRepository =
      ProfileManagementRepository._internal();
  late ProfileManagementLocalDataSource _profileManagementLocalDataSource;
  late ProfileManagementRemoteDataSource _profileManagementRemoteDataSource;

  factory ProfileManagementRepository() {
    _profileManagementRepository._profileManagementLocalDataSource =
        ProfileManagementLocalDataSource();
    _profileManagementRepository._profileManagementRemoteDataSource =
        ProfileManagementRemoteDataSource();

    return _profileManagementRepository;
  }

  ProfileManagementRepository._internal();

  ProfileManagementLocalDataSource get profileManagementLocalDataSource =>
      _profileManagementLocalDataSource;

  Future<Map<String, dynamic>> uploadProfilePicture(
      File? file, String? userId) async {
    try {
      final result = await _profileManagementRemoteDataSource.addProfileImage(
          file, userId);
      return Map.from(result);
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

  //update profile method in remote data source
  Future<Map<String, dynamic>> updateProfile(
      {String? userId,
      String? email,
      String? name,
      String? mobile,
      String? address,
      String? status="1"}) async {
    try {
      final result = await _profileManagementRemoteDataSource.updateProfile(
          userId: userId,
          email: email,
          name: name,
          mobile: mobile,
          address: address,
          status: status);
          return Map.from(result);
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

  Future<AuthModel> getRiderDetail(String? id) async {
    try {
      AuthModel result =
          await _profileManagementRemoteDataSource.getRiderDetail(id);
      print(result);
      return result;
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }
}
