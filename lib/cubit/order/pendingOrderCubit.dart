import 'package:erestro_single_vender_rider/data/model/orderModel.dart';
import 'package:erestro_single_vender_rider/utils/api.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageAndCodeException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro_single_vender_rider/utils/apiBodyParameterLabels.dart';

@immutable
abstract class PendingOrderState {}

class PendingOrderInitial extends PendingOrderState {}

class PendingOrderProgress extends PendingOrderState {}

class PendingOrderSuccess extends PendingOrderState {
  final List<OrderModel> pendingOrderList;
  final int totalData;
  final bool hasMore;
  final total;
  PendingOrderSuccess(this.pendingOrderList, this.totalData, this.hasMore, this.total);
}

class PendingOrderFailure extends PendingOrderState {
  final String errorMessage, errorStatusCode;
  PendingOrderFailure(this.errorMessage, this.errorStatusCode);
}

String? totalHasMore;

class PendingOrderCubit extends Cubit<PendingOrderState> {
  PendingOrderCubit() : super(PendingOrderInitial());
  Future<List<OrderModel>> _fetchData({required String limit, String? offset, required String? userId, String? id}) async {
    try {
      //body of post request
      final body = {limitKey: limit, offsetKey: offset ?? "", userIdKey: userId, idKey: id ?? ""};

      if (offset == null) {
        body.remove(offset);
      }
      final result = await Api.post(body: body, url: Api.getPendingOrdersUrl, token: true, errorCode: true);
      totalHasMore = result[totalKey].toString();
      return (result[dataKey] as List).map((e) => OrderModel.fromJson(e)).toList();
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage, errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  void fetchPendingOrder(String limit, String userId, String? id) {
    emit(PendingOrderProgress());
    _fetchData(limit: limit, userId: userId, id: id).then((value) {
      final List<OrderModel> usersDetails = value;
      final total = int.parse(totalHasMore!);
      emit(PendingOrderSuccess(usersDetails, total, total > usersDetails.length, total));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(PendingOrderFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  void fetchMorePendingOrderData(String limit, String? userId, String? id) {
    _fetchData(limit: limit, offset: (state as PendingOrderSuccess).pendingOrderList.length.toString(), userId: userId, id: id).then((value) {
      final oldState = (state as PendingOrderSuccess);
      final List<OrderModel> usersDetails = value;
      final List<OrderModel> updatedUserDetails = List.from(oldState.pendingOrderList);
      updatedUserDetails.addAll(usersDetails);
      emit(PendingOrderSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length, int.parse(totalHasMore!)));
    }).catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(PendingOrderFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }

  bool hasMoreData() {
    if (state is PendingOrderSuccess) {
      return (state as PendingOrderSuccess).hasMore;
    } else {
      return false;
    }
  }

  void updateOrderRequest(OrderModel orderModel) {
    if (state is PendingOrderSuccess) {
      final oldState = (state as PendingOrderSuccess);
      List<OrderModel> pendingOrderList = (state as PendingOrderSuccess).pendingOrderList;
      bool hasMore = (state as PendingOrderSuccess).hasMore;
      pendingOrderList.removeWhere((element) => element.id == orderModel.id);
      emit(PendingOrderSuccess(pendingOrderList, oldState.totalData, hasMore, int.parse(totalHasMore!)));
    }
  }
}
