import 'package:erestro_single_vender_rider/data/model/orderLiveTrackingModel.dart';
import 'package:erestro_single_vender_rider/data/model/orderModel.dart';
import 'package:erestro_single_vender_rider/utils/api.dart';
import 'package:erestro_single_vender_rider/utils/apiBodyParameterLabels.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageAndCodeException.dart';

class OrderRemoteDataSource {
  //to getUserOrder
  Future<OrderModel> getOrder(
      {String? status, String? orderId, String? reason}) async {
    try {
      //body of post request
      final body = {
        statusKey: status,
        orderIdKey: orderId,
        reasonKey: reason ?? ""
      };
      final result = await Api.post(
          body: body,
          url: Api.updateOrderStatusUrl,
          token: true,
          errorCode: true);
      return OrderModel.fromJson(result);
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException =
          e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage,
          errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  //to getUserOrder
  Future<dynamic> updateOrderStatus(
      {String? riderId, String? orderId, String? status, String? otp}) async {
    try {
      //body of post request
      final body = {
        riderIdKey: riderId,
        orderIdKey: orderId,
        statusKey: status
      };
      
      if (otp != null) {
        body[otpKey] = otp;
      }
      final result = await Api.post(
          body: body,
          url: Api.updateOrderStatusUrl,
          token: true,
          errorCode: true);
      return result;
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException =
          e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage,
          errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  //to updateOrderRequest
  Future<dynamic> updateOrderRequest(
      {String? riderId, String? orderId, String? acceptOrder}) async {
    try {
      //body of post request
      final body = {
        riderIdKey: riderId,
        orderIdKey: orderId,
        acceptOrderKey: acceptOrder
      };
      final result = await Api.post(
          body: body,
          url: Api.updateOrderRequestUrl,
          token: true,
          errorCode: true);
      return result;
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException =
          e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage,
          errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  //to getUserOrderLiveTracking
  Future<OrderLiveTrackingModel> getOrderLiveTracing({String? orderId}) async {
    try {
      //body of post request
      final body = {orderIdKey: orderId};
      final result = await Api.post(
          body: body,
          url: Api.getLiveTrackingDetailsUrl,
          token: true,
          errorCode: true);
      return OrderLiveTrackingModel.fromJson(result[dataKey][0]);
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException =
          e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage,
          errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  //to manageLiveTracking
  Future<Map<String, dynamic>> manageLiveTracking(
      {String? orderId,
      String? orderStatus,
      String? latitude,
      String? longitude}) async {
    try {
      //body of post request
      final body = {
        orderIdKey: orderId,
        orderStatusKey: orderStatus,
        latitudeKey: latitude,
        longitudeKey: longitude
      };
      final result = await Api.post(
          body: body,
          url: Api.manageLiveTrackingUrl,
          token: true,
          errorCode: true);
      return result;
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException =
          e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage,
          errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }

  //to deleteLiveTracking
  Future<Map<String, dynamic>> deleteLiveTracking({String? orderId}) async {
    try {
      //body of post request
      final body = {orderIdKey: orderId};
      final result = await Api.post(
          body: body,
          url: Api.deleteLiveTrackingUrl,
          token: true,
          errorCode: true);
      return result;
    } catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException =
          e as ApiMessageAndCodeException;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage,
          errorStatusCode: apiMessageAndCodeException.errorStatusCode);
    }
  }
}
