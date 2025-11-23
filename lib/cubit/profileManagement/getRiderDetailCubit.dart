
import 'package:erestro_single_vender_rider/data/model/authModel.dart';
import 'package:erestro_single_vender_rider/data/repositories/profileManagement/profileManagementRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class GetRiderDetailState {}

class GetRiderDetailInitial extends GetRiderDetailState {}

class GetRiderDetailFetchInProgress extends GetRiderDetailState {}

class GetRiderDetailFetchSuccess extends GetRiderDetailState {
  final AuthModel authModel;

  GetRiderDetailFetchSuccess({required this.authModel});
}

class GetRiderDetailFetchFailure extends GetRiderDetailState {
  final String errorCode;

  GetRiderDetailFetchFailure(this.errorCode);
}

class GetRiderDetailCubit extends Cubit<GetRiderDetailState> {
  final ProfileManagementRepository _profileManagementRepository;
  GetRiderDetailCubit(this._profileManagementRepository) : super(GetRiderDetailInitial());

  //to getRiderDetail
  getRiderDetail(String? riderId) {
    //emitting GetRiderDetailFetchInProgress state
    emit(GetRiderDetailFetchInProgress());
    //getRiderDetail details in api
    _profileManagementRepository.getRiderDetail(riderId).then((value) => emit(GetRiderDetailFetchSuccess(authModel: value))).catchError((e) {
      emit(GetRiderDetailFetchFailure(e.toString()));
    });
  }

  setWallet(String? walletAmount) {
    final riderDetails = (state as GetRiderDetailFetchSuccess).authModel;
    emit((GetRiderDetailFetchSuccess(authModel: riderDetails.copyWith(balance: walletAmount))));
  }

  setComplete(String? completeTotal) {
    final riderDetails = (state as GetRiderDetailFetchSuccess).authModel;
    emit((GetRiderDetailFetchSuccess(authModel: riderDetails.copyWith(completeDelivery: completeTotal))));
  }

  setCancel(String? cancelDeliveryTotal) {
    final riderDetails = (state as GetRiderDetailFetchSuccess).authModel;
    emit((GetRiderDetailFetchSuccess(authModel: riderDetails.copyWith(cancelDelivery: cancelDeliveryTotal))));
  }

  setPending(String? pendingDeiveryTotal) {
    final riderDetails = (state as GetRiderDetailFetchSuccess).authModel;
    emit((GetRiderDetailFetchSuccess(authModel: riderDetails.copyWith(pendingDeivery: pendingDeiveryTotal))));
  }

  void statusUpdateAuth(AuthModel authModels) {
    emit(GetRiderDetailFetchSuccess(authModel: authModels));
  }

  String getReciveCash() {
    if (state is GetRiderDetailFetchSuccess) {
      return (state as GetRiderDetailFetchSuccess).authModel.cashReceived.toString();
    }
    return "0.0";
  }

  String getCompleteDelivery() {
    if (state is GetRiderDetailFetchSuccess) {
      return (state as GetRiderDetailFetchSuccess).authModel.completeDelivery!;
    }
    return "";
  }

  String getCancelDelivery() {
    if (state is GetRiderDetailFetchSuccess) {
      return (state as GetRiderDetailFetchSuccess).authModel.cancelDelivery!;
    }
    return "";
  }

  String getPendingDeivery() {
    if (state is GetRiderDetailFetchSuccess) {
      return (state as GetRiderDetailFetchSuccess).authModel.pendingDeivery!;
    }
    return "";
  }
}
