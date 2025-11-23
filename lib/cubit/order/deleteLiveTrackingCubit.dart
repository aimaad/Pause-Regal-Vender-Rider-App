import 'package:erestro_single_vender_rider/data/repositories/order/orderRepository.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageAndCodeException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


@immutable
abstract class DeleteLiveTrackingState {}

class DeleteLiveTrackingInitial extends DeleteLiveTrackingState {}

class DeleteLiveTracking extends DeleteLiveTrackingState {
  DeleteLiveTracking();
}

class DeleteLiveTrackingProgress extends DeleteLiveTrackingState {
  DeleteLiveTrackingProgress();
}

class DeleteLiveTrackingSuccess extends DeleteLiveTrackingState {
  final String? orderId;
  DeleteLiveTrackingSuccess(this.orderId);
}

class DeleteLiveTrackingFailure extends DeleteLiveTrackingState {
  final String errorMessage, errorCode;
  DeleteLiveTrackingFailure(this.errorMessage, this.errorCode);
}

class DeleteLiveTrackingCubit extends Cubit<DeleteLiveTrackingState> {
  final OrderRepository _orderRepository;
  DeleteLiveTrackingCubit(this._orderRepository) : super(DeleteLiveTrackingInitial());

  //to deleteLiveTracking user
  void deleteLiveTracking({String? orderId}) {
    //emitting deleteLiveTrackingProgress state
    emit(DeleteLiveTrackingProgress());
    //deleteLiveTracking user with given provider and also reset password user in api
    _orderRepository.deleteLiveTrackingData(orderId).then((result) {
      
      emit(DeleteLiveTrackingSuccess(orderId));
    }).catchError((e) {
      
      ApiMessageAndCodeException authException = e;
      emit(DeleteLiveTrackingFailure(authException.errorMessage.toString(), authException.errorStatusCode.toString()));
    });
  }
}
