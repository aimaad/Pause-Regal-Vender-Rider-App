import 'package:erestro_single_vender_rider/data/repositories/order/orderRepository.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageAndCodeException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


@immutable
abstract class ManageLiveTrackingState {}

class ManageLiveTrackingInitial extends ManageLiveTrackingState {}

class ManageLiveTracking extends ManageLiveTrackingState {
  ManageLiveTracking();
}

class ManageLiveTrackingProgress extends ManageLiveTrackingState {
  ManageLiveTrackingProgress();
}

class ManageLiveTrackingSuccess extends ManageLiveTrackingState {
  final dynamic orderLiveTracking;
  final String orderId;
  ManageLiveTrackingSuccess(this.orderLiveTracking, this.orderId);
}

class ManageLiveTrackingFailure extends ManageLiveTrackingState {
  final String errorMessage, errorStatusCode;
  ManageLiveTrackingFailure(this.errorMessage, this.errorStatusCode);
}

class ManageLiveTrackingCubit extends Cubit<ManageLiveTrackingState> {
  final OrderRepository _orderRepository;
  ManageLiveTrackingCubit(this._orderRepository) : super(ManageLiveTrackingInitial());

  //to manageLiveTracking
  void manageLiveTracking({String? orderId, String? orderStatus, String? latitude, String? longitude}) {
    if (state is! ManageLiveTrackingSuccess) {
      //emitting ManageLiveTrackingProgress state
      emit(ManageLiveTrackingProgress());
    }
    //manageLiveTracking details in api
    _orderRepository
        .manageLiveTrackingData(orderId, orderStatus, latitude, longitude)
        .then((value) => emit(ManageLiveTrackingSuccess(value, orderId!)))
        .catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(ManageLiveTrackingFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }
}
