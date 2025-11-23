import 'package:erestro_single_vender_rider/data/model/cashCollectionModel.dart';
import 'package:erestro_single_vender_rider/utils/api.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageAndCodeException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro_single_vender_rider/utils/apiBodyParameterLabels.dart';

@immutable
abstract class RiderCashState {}

class RiderCashInitial extends RiderCashState {}

class RiderCashProgress extends RiderCashState {}

class RiderCashSuccess extends RiderCashState {
  final List<CashCollectionModel> riderCashList;
  final int totalData;
  final bool hasMore;
  RiderCashSuccess(this.riderCashList, this.totalData, this.hasMore);
}

class RiderCashFailure extends RiderCashState {
  final String errorMessage, errorStatusCode;
  RiderCashFailure(this.errorMessage, this.errorStatusCode);
}

String? totalHasMore;

class RiderCashCubit extends Cubit<RiderCashState> {
  RiderCashCubit() : super(RiderCashInitial());
  Future<List<CashCollectionModel>> _fetchData({required String limit, String? offset, String? riderId, String? order, String? search}) async {
    try {
      //body of post request
      final body = {limitKey: limit, offsetKey: offset ?? "", riderIdKey: riderId ?? "", statusKey: riderCashKey, orderKey: order, searchKey: search};
      if (offset == null) {
        body.remove(offset);
      }
      final result = await Api.post(body: body, url: Api.getRiderCashCollectionUrl, token: true, errorCode: true);
      totalHasMore = result[totalKey].toString();
      return (result[dataKey] as List).map((e) => CashCollectionModel.fromJson(e)).toList();
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  void fetchRiderCash(String limit, String? riderId, String? order, String? search) {
    emit(RiderCashProgress());
    _fetchData(limit: limit, riderId: riderId, order: order, search: search).then((value) {
      final List<CashCollectionModel> usersDetails = value;
      final total = int.parse(totalHasMore!);
      emit(RiderCashSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(RiderCashFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  void fetchMoreRiderCashData(String limit, String? riderId, String? order, String? search) {
    _fetchData(limit: limit, offset: (state as RiderCashSuccess).riderCashList.length.toString(), riderId: riderId, order: order, search: search)
        .then((value) {
      final oldState = (state as RiderCashSuccess);
      final List<CashCollectionModel> usersDetails = value;
      final List<CashCollectionModel> updatedUserDetails = List.from(oldState.riderCashList);
      updatedUserDetails.addAll(usersDetails);
      emit(RiderCashSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(RiderCashFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  bool hasMoreData() {
    if (state is RiderCashSuccess) {
      return (state as RiderCashSuccess).hasMore;
    } else {
      return false;
    }
  }

  void addRiderCash(CashCollectionModel RiderCashModel) {
    if (state is CashCollectionModel) {
      List<CashCollectionModel> currentRiderCash = (state as RiderCashSuccess).riderCashList;
      int offset = (state as RiderCashSuccess).totalData;
      bool limit = (state as RiderCashSuccess).hasMore;
      currentRiderCash.insert(0, RiderCashModel);
      emit(RiderCashSuccess(List<CashCollectionModel>.from(currentRiderCash), offset, limit));
    }
  }
}
