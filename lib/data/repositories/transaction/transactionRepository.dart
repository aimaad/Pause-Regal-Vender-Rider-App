import 'package:erestro_single_vender_rider/data/repositories/transaction/transactionRemoteDataSource.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageAndCodeException.dart';

class TransactionRepository {
  static final TransactionRepository _transactionRepository =
      TransactionRepository._internal();
  late TransactionRemoteDataSource _transactionRemoteDataSource;

  factory TransactionRepository() {
    _transactionRepository._transactionRemoteDataSource =
        TransactionRemoteDataSource();
    return _transactionRepository;
  }

  TransactionRepository._internal();

  Future<String> sendWalletRequest(
      String? userId, String? amount, String? paymentAddress) async {
    try {
      final result = await _transactionRemoteDataSource.sendWalletRequest(
          userId, amount, paymentAddress);
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
}
