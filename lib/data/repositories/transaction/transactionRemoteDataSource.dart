import 'package:erestro_single_vender_rider/utils/api.dart';
import 'package:erestro_single_vender_rider/utils/apiBodyParameterLabels.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageAndCodeException.dart';

class TransactionRemoteDataSource {
  Future<dynamic> sendWalletRequest(
      String? userId, String? amount, String? paymentAddress) async {
    try {
      final body = {
        userIdKey: userId,
        amountKey: amount,
        paymentAddressKey: paymentAddress
      };
      final result = await Api.post(
          body: body,
          url: Api.sendWithdrawRequestUrl,
          token: true,
          errorCode: true);
      return result[dataKey];
    } catch (e) {
      throw ApiMessageAndCodeException(errorMessage: e.toString());
    }
  }
}
