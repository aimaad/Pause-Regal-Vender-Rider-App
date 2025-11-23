import 'package:erestro_single_vender_rider/data/repositories/order/orderRepository.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageAndCodeException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


@immutable
abstract class UpdateOrderRequestState {}

class UpdateOrderRequestInitial extends UpdateOrderRequestState {}

class UpdateOrderRequest extends UpdateOrderRequestState {
  UpdateOrderRequest();
}

class UpdateOrderRequestProgress extends UpdateOrderRequestState {
  UpdateOrderRequestProgress();
}

class UpdateOrderRequestSuccess extends UpdateOrderRequestState {
  final String? orderId;
  UpdateOrderRequestSuccess(this.orderId);
}

class UpdateOrderRequestFailure extends UpdateOrderRequestState {
  final String errorMessage, errorCode;
  UpdateOrderRequestFailure(this.errorMessage, this.errorCode);
}

class UpdateOrderRequestCubit extends Cubit<UpdateOrderRequestState> {
  final OrderRepository _orderRepository;
  UpdateOrderRequestCubit(this._orderRepository) : super(UpdateOrderRequestInitial());

  //to updateOrderRequest user
  void updateOrderRequest({String? riderId, String? orderId, String? acceptOrder}) {
    //emitting updateOrderRequestProgress state
    emit(UpdateOrderRequestProgress());
    //updateOrderRequest user with given provider and also reset password user in api
    _orderRepository.updateOrderRequestData(riderId, orderId, acceptOrder).then((result) {
      
      emit(UpdateOrderRequestSuccess(orderId));
    }).catchError((e) {
      
      ApiMessageAndCodeException authException = e;
      emit(UpdateOrderRequestFailure(authException.errorMessage.toString(), authException.errorStatusCode.toString()));
    });
  }
}
