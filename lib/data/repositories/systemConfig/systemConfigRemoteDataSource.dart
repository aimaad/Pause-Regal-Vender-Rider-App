import 'package:erestro_single_vender_rider/data/model/settingModel.dart';
import 'package:erestro_single_vender_rider/utils/api.dart';
import 'package:erestro_single_vender_rider/utils/apiBodyParameterLabels.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageException.dart';

class SystemConfigRemoteDataSource {
  Future<SettingModel> getSystemConfing() async {
    try {
      final body = {};
      final result = await Api.post(
          body: body, url: Api.getSettingsUrl, token: true, errorCode: false);
      return SettingModel.fromJson(result);
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }

  Future<String> getAppSettings(String type) async {
    try {
      final body = {typeKey: type};
      final result = await Api.post(
          body: body, url: Api.getSettingsUrl, token: true, errorCode: false);
      return result[dataKey][type].toString();
    } catch (e) {
      throw ApiMessageException(errorMessage: e.toString());
    }
  }
}
