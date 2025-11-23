import 'package:erestro_single_vender_rider/data/repositories/transaction/transactionRepository.dart';
import 'package:erestro_single_vender_rider/utils/apiMessageAndCodeException.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SendWithdrawRequestState {}

class SendWithdrawRequestIntial extends SendWithdrawRequestState {}

class SendWithdrawRequestFetchInProgress extends SendWithdrawRequestState {}

class SendWithdrawRequestFetchSuccess extends SendWithdrawRequestState {
  final String? userId, amount, paymentAddress, walletAmount;

  SendWithdrawRequestFetchSuccess({this.userId, this.amount, this.paymentAddress, this.walletAmount});
}

class SendWithdrawRequestFetchFailure extends SendWithdrawRequestState {
  final String errorMessage, errorStatusCode;
  SendWithdrawRequestFetchFailure(this.errorMessage, this.errorStatusCode);
}

class SendWithdrawRequestCubit extends Cubit<SendWithdrawRequestState> {
  final TransactionRepository _transactionRepository;
  SendWithdrawRequestCubit(this._transactionRepository) : super(SendWithdrawRequestIntial());

  //to sendWithdrawRequest user
  void sendWithdrawRequest(String? userId, String? amount, String? paymentAddress) {
    //emitting SendWithdrawRequestProgress state
    emit(SendWithdrawRequestFetchInProgress());
    //SendWithdrawRequest in api
    _transactionRepository
        .sendWalletRequest(userId, amount, paymentAddress)
        .then((value) => emit(SendWithdrawRequestFetchSuccess(userId: userId, amount: amount, paymentAddress: paymentAddress, walletAmount: value)))
        .catchError((e) {
      ApiMessageAndCodeException apiMessageAndCodeException = e;
      emit(
          SendWithdrawRequestFetchFailure(apiMessageAndCodeException.errorMessage.toString(), apiMessageAndCodeException.errorStatusCode.toString()));
    });
  }
}
