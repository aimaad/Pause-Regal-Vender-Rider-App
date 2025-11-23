import 'package:erestro_single_vender_rider/data/model/cityModel.dart';
import 'package:erestro_single_vender_rider/utils/api.dart';
import 'package:erestro_single_vender_rider/utils/apiBodyParameterLabels.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageAndCodeException.dart';

class CityRemoteDataSource {
  Future<List<CityModel>> getCity(String? search) async {
    try {
      final body = {searchKey: search};
      final result = await Api.post(body: body, url: Api.getCitiesUrl, token: true, errorCode: true);
      return (result[dataKey] as List).map((e) => CityModel.fromJson(Map.from(e))).toList();
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }
}
