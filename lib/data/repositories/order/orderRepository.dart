import 'package:erestro_single_vender_rider/data/model/orderModel.dart';
import 'package:erestro_single_vender_rider/data/repositories/order/orderRemoteDataSource.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageAndCodeException.dart';

class OrderRepository {
  static final OrderRepository _orderRepository = OrderRepository._internal();
  late OrderRemoteDataSource _orderRemoteDataSource;

  factory OrderRepository() {
    _orderRepository._orderRemoteDataSource = OrderRemoteDataSource();
    return _orderRepository;
  }
  OrderRepository._internal();

  //to getOrder
  Future<OrderModel> getOrderData(
      String? status, String? orderId, String? reason) async {
    try {
      OrderModel result = await _orderRemoteDataSource.getOrder(
          status: status, orderId: orderId, reason: reason);
      return result;
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(),
          errorStatusCode:
              apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  //to updateOrderStatusData
  Future<Map<String, dynamic>> updateOrderStatusData(
      String? riderId, String? orderId, String? status, String? otp) async {
    try {
      final result = await _orderRemoteDataSource.updateOrderStatus(
          riderId: riderId, orderId: orderId, status: status, otp: otp);
      return Map.from(result);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(),
          errorStatusCode:
              apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  //to updateOrderRequestData
  Future<Map<String, dynamic>> updateOrderRequestData(
      String? riderId, String? orderId, String? acceptOrder) async {
    try {
      final result = await _orderRemoteDataSource.updateOrderRequest(
          riderId: riderId, orderId: orderId, acceptOrder: acceptOrder);
      return Map.from(result);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(),
          errorStatusCode:
              apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  //to manageLiveTracking
  Future<dynamic> manageLiveTrackingData(String? orderId, String? orderStatus,
      String? latitude, String? longitude) async {
    try {
      final result = await _orderRemoteDataSource.manageLiveTracking(
          orderId: orderId,
          orderStatus: orderStatus,
          latitude: latitude,
          longitude: longitude);
      return Map.from(result);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(),
          errorStatusCode:
              apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }

  //to deleteLiveTracking
  Future<dynamic> deleteLiveTrackingData(String? orderId) async {
    try {
      final result =
          await _orderRemoteDataSource.deleteLiveTracking(orderId: orderId);
      return Map.from(result);
    } on ApiMessageAndCodeException catch (e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      throw ApiMessageAndCodeException(
          errorMessage: apiMessageAndCodeException.errorMessage.toString(),
          errorStatusCode:
              apiMessageAndCodeException.errorStatusCode.toString());
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
