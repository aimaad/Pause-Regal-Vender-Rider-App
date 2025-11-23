import 'package:erestro_single_vender_rider/data/model/cityModel.dart';
import 'package:erestro_single_vender_rider/data/repositories/city/cityRemoteDataSource.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageAndCodeException.dart';

class CityRepository {
  static final CityRepository _cityRepository = CityRepository._internal();
  late CityRemoteDataSource _cityRemoteDataSource;

  factory CityRepository() {
    _cityRepository._cityRemoteDataSource = CityRemoteDataSource();
    return _cityRepository;
  }

  CityRepository._internal();

  Future<List<CityModel>> getCity(String? search) async {
    try {
      List<CityModel> result = await _cityRemoteDataSource.getCity(search);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(), errorStatusCode: apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
