import 'package:erestro_single_vender_rider/data/model/cityModel.dart';
import 'package:erestro_single_vender_rider/data/repositories/city/cityRepository.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageAndCodeException.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CityState {}

class CityInitial extends CityState {}

class CityProgress extends CityState {}

class CitySuccess extends CityState {
  final List<CityModel> cityList;

  CitySuccess(this.cityList);
}

class CityFailure extends CityState {
  final String errorStatusCode, errorMessage;
  CityFailure(this.errorMessage, this.errorStatusCode);
}

class CityCubit extends Cubit<CityState> {
  final CityRepository _cityRepository;

  CityCubit(this._cityRepository) : super(CityInitial());

  fetchCity(String? search) {
    emit(CityProgress());
    _cityRepository.getCity(search).then((value) {
      emit(CitySuccess(value));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(CityFailure(apiMessageAndCodeException.errorMessage, apiMessageAndCodeException.errorStatusCode!));
    });
  }

  List<CityModel> getCityList() {
    if (state is CitySuccess) {
      final citysList = (state as CitySuccess).cityList;
      return citysList;
    }
    return [];
  }
}
