import 'package:erestro_single_vender_rider/data/model/fundTransferModel.dart';
import 'package:erestro_single_vender_rider/utils/api.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageAndCodeException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro_single_vender_rider/utils/apiBodyParameterLabels.dart';

@immutable
abstract class GetFundTransfersState {}

class GetFundTransfersInitial extends GetFundTransfersState {}

class GetFundTransfersProgress extends GetFundTransfersState {}

class GetFundTransfersSuccess extends GetFundTransfersState {
  final List<FundTransferModel> fundTransfersList;
  final int totalData;
  final bool hasMore;
  GetFundTransfersSuccess(this.fundTransfersList, this.totalData, this.hasMore);
}

class GetFundTransfersFailure extends GetFundTransfersState {
  final String errorMessage, errorStatusCode;
  GetFundTransfersFailure(this.errorMessage, this.errorStatusCode);
}

String? totalHasMore;

class GetFundTransfersCubit extends Cubit<GetFundTransfersState> {
  GetFundTransfersCubit() : super(GetFundTransfersInitial());
  Future<List<FundTransferModel>> _fetchData({required String limit, String? offset, String? userId}) async {
    try {
      //body of post request
      final body = {limitKey: limit, offsetKey: offset ?? "", userIdKey: userId ?? ""};
      if (offset == null) {
        body.remove(offset);
      }
      final result = await Api.post(body: body, url: Api.getFundTransfersUrl, token: true, errorCode: true);
      totalHasMore = result[totalKey].toString();
      return (result[dataKey] as List).map((e) => FundTransferModel.fromJson(e)).toList();
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  void fetchGetFundTransfers(String limit, String? userId) {
    emit(GetFundTransfersProgress());
    _fetchData(limit: limit, userId: userId).then((value) {
      final List<FundTransferModel> usersDetails = value;
      final total = int.parse(totalHasMore!);
      emit(GetFundTransfersSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(GetFundTransfersFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  void fetchMoreGetFundTransfersData(String limit, String? userId) {
    _fetchData(limit: limit, offset: (state as GetFundTransfersSuccess).fundTransfersList.length.toString(), userId: userId).then((value) {
      final oldState = (state as GetFundTransfersSuccess);
      final List<FundTransferModel> usersDetails = value;
      final List<FundTransferModel> updatedUserDetails = List.from(oldState.fundTransfersList);
      updatedUserDetails.addAll(usersDetails);
      emit(GetFundTransfersSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(GetFundTransfersFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  bool hasMoreData() {
    if (state is GetFundTransfersSuccess) {
      return (state as GetFundTransfersSuccess).hasMore;
    } else {
      return false;
    }
  }

  void addGetFundTransfers(FundTransferModel transactionModel) {
    if (state is GetFundTransfersSuccess) {
      List<FundTransferModel> currentGetFundTransfers = (state as GetFundTransfersSuccess).fundTransfersList;
      int offset = (state as GetFundTransfersSuccess).totalData;
      bool limit = (state as GetFundTransfersSuccess).hasMore;
      currentGetFundTransfers.insert(0, transactionModel);
      emit(GetFundTransfersSuccess(List<FundTransferModel>.from(currentGetFundTransfers), offset, limit));
    }
  }
}
