import 'package:erestro_single_vender_rider/data/repositories/order/orderRepository.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageAndCodeException.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


@immutable
abstract class UpdateOrderStatusState {}

class UpdateOrderStatusInitial extends UpdateOrderStatusState {}

class UpdateOrderStatus extends UpdateOrderStatusState {
  UpdateOrderStatus();
}

class UpdateOrderStatusProgress extends UpdateOrderStatusState {
  UpdateOrderStatusProgress();
}

class UpdateOrderStatusSuccess extends UpdateOrderStatusState {
  final String? orderId;
  UpdateOrderStatusSuccess(this.orderId);
}

class UpdateOrderStatusFailure extends UpdateOrderStatusState {
  final String errorMessage, errorCode;
  UpdateOrderStatusFailure(this.errorMessage, this.errorCode);
}

class UpdateOrderStatusCubit extends Cubit<UpdateOrderStatusState> {
  final OrderRepository _orderRepository;
  UpdateOrderStatusCubit(this._orderRepository) : super(UpdateOrderStatusInitial());

  //to updateOrderStatus user
  void updateOrderStatus({String? riderId, String? orderId, String? status, String? otp}) {
    //emitting updateOrderStatusProgress state
    emit(UpdateOrderStatusProgress());
    //updateOrderStatus user with given provider and also reset password user in api
    _orderRepository.updateOrderStatusData(riderId, orderId, status, otp).then((result) {
      
      emit(UpdateOrderStatusSuccess(orderId));
    }).catchError((e) {
      
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(UpdateOrderStatusFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }
}
