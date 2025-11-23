import 'package:erestro_single_vender_rider/data/model/cashCollectionModel.dart';
import 'package:erestro_single_vender_rider/utils/api.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageAndCodeException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro_single_vender_rider/utils/apiBodyParameterLabels.dart';

@immutable
abstract class RiderCashCollectionState {}

class RiderCashCollectionInitial extends RiderCashCollectionState {}

class RiderCashCollectionProgress extends RiderCashCollectionState {}

class RiderCashCollectionSuccess extends RiderCashCollectionState {
  final List<CashCollectionModel> riderCashCollectionList;
  final int totalData;
  final bool hasMore;
  RiderCashCollectionSuccess(this.riderCashCollectionList, this.totalData, this.hasMore);
}

class RiderCashCollectionFailure extends RiderCashCollectionState {
  final String errorMessage, errorStatusCode;
  RiderCashCollectionFailure(this.errorMessage, this.errorStatusCode);
}

String? totalHasMore;

class RiderCashCollectionCubit extends Cubit<RiderCashCollectionState> {
  RiderCashCollectionCubit() : super(RiderCashCollectionInitial());
  Future<List<CashCollectionModel>> _fetchData({required String limit, String? offset, String? riderId, String? order, String? search}) async {
    try {
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
        riderIdKey: riderId ?? "",
        statusKey: riderCashCollectionKey,
        orderKey: order,
        searchKey: search
      };
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

  void fetchRiderCashCollection(String limit, String? riderId, String? order, String? search) {
    emit(RiderCashCollectionProgress());
    _fetchData(limit: limit, riderId: riderId, order: order, search: search).then((value) {
      final List<CashCollectionModel> usersDetails = value;
      final total = int.parse(totalHasMore!);
      emit(RiderCashCollectionSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(RiderCashCollectionFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  void fetchMoreRiderCashCollectionData(String limit, String? riderId, String? order, String? search) {
    _fetchData(
            limit: limit,
            offset: (state as RiderCashCollectionSuccess).riderCashCollectionList.length.toString(),
            riderId: riderId,
            order: order,
            search: search)
        .then((value) {
      final oldState = (state as RiderCashCollectionSuccess);
      final List<CashCollectionModel> usersDetails = value;
      final List<CashCollectionModel> updatedUserDetails = List.from(oldState.riderCashCollectionList);
      updatedUserDetails.addAll(usersDetails);
      emit(RiderCashCollectionSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(RiderCashCollectionFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  bool hasMoreData() {
    if (state is RiderCashCollectionSuccess) {
      return (state as RiderCashCollectionSuccess).hasMore;
    } else {
      return false;
    }
  }

  void addRiderCashCollection(CashCollectionModel RiderCashCollectionModel) {
    if (state is CashCollectionModel) {
      List<CashCollectionModel> currentRiderCashCollection = (state as RiderCashCollectionSuccess).riderCashCollectionList;
      int offset = (state as RiderCashCollectionSuccess).totalData;
      bool limit = (state as RiderCashCollectionSuccess).hasMore;
      currentRiderCashCollection.insert(0, RiderCashCollectionModel);
      emit(RiderCashCollectionSuccess(List<CashCollectionModel>.from(currentRiderCashCollection), offset, limit));
    }
  }

  riderCashCollectionAmount() {
    if (state is RiderCashCollectionSuccess) {
      return (state as RiderCashCollectionSuccess).riderCashCollectionList[0].cashReceived ?? 00;
    }
    return "0.0";
  }
}
