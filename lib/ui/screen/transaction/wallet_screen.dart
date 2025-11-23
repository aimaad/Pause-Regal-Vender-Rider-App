import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro_single_vender_rider/cubit/auth/authCubit.dart';
import 'package:erestro_single_vender_rider/cubit/profileManagement/getRiderDetailCubit.dart';
import 'package:erestro_single_vender_rider/cubit/transaction/getFundTransfersCubit.dart';
import 'package:erestro_single_vender_rider/cubit/transaction/getWithdrawRequestCubit.dart';
import 'package:erestro_single_vender_rider/cubit/transaction/sendWithdrawRequestCubit.dart';
import 'package:erestro_single_vender_rider/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestro_single_vender_rider/data/repositories/transaction/transactionRepository.dart';
import 'package:erestro_single_vender_rider/ui/screen/settings/no_internet_screen.dart';
import 'package:erestro_single_vender_rider/ui/widgets/fundTransferContainer.dart';
import 'package:erestro_single_vender_rider/ui/widgets/simmer/myOrderSimmer.dart';
import 'package:erestro_single_vender_rider/ui/widgets/noDataContainer.dart';
import 'package:erestro_single_vender_rider/ui/widgets/smallButtomContainer.dart';
import 'package:erestro_single_vender_rider/utils/constants.dart';
import 'package:erestro_single_vender_rider/utils/labelKeys.dart';
import 'package:erestro_single_vender_rider/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro_single_vender_rider/ui/styles/color.dart';
import 'package:erestro_single_vender_rider/ui/styles/design.dart';
import 'package:erestro_single_vender_rider/utils/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:erestro_single_vender_rider/utils/internetConnectivity.dart';
import 'dart:ui' as ui;

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  WalletScreenState createState() => WalletScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(providers: [
              BlocProvider<GetFundTransfersCubit>(
                create: (_) => GetFundTransfersCubit(),
              ),
              BlocProvider<GetWithdrawRequestCubit>(
                create: (_) => GetWithdrawRequestCubit(),
              ),
              BlocProvider<SendWithdrawRequestCubit>(create: (_) => SendWithdrawRequestCubit(TransactionRepository())),
            ], child: const WalletScreen()));
  }
}

class WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  double? width, height;
  ScrollController getFundTransferController = ScrollController();
  ScrollController withdrawWalletController = ScrollController();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController? amountController, messageController, withdrawAmountController, paymentAddressController;
  StateSetter? dialogState;
  bool isProgress = false;
  int offset = 0;
  int total = 0;
  bool isLoading = true, payTesting = true;
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  String? walletAmount, filter = "0";
  bool enableList = false;
  int? _selectedIndex = 0;
  List<String> transactionType = [StringsRes.fundTransfer, StringsRes.walletWithdrawTransaction];
  TabController? tabController;

  @override
  void initState() {
    super.initState();
    walletAmount = context.read<AuthCubit>().getBalance();
    amountController = TextEditingController();
    messageController = TextEditingController();
    withdrawAmountController = TextEditingController();
    paymentAddressController = TextEditingController();
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        setState(() {
          _connectionStatus = results;
        });
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionStatus = value;
          });
        });
      }
    });
    getFundTransferController.addListener(scrollGetFundTransferListener);
    Future.delayed(Duration.zero, () {
      context.read<GetFundTransfersCubit>().fetchGetFundTransfers(perPage, context.read<AuthCubit>().getId());
    });
    withdrawWalletController.addListener(scrollGetWithdrawListener);
    Future.delayed(Duration.zero, () {
      context.read<GetWithdrawRequestCubit>().fetchGetWithdrawRequest(perPage, context.read<AuthCubit>().getId());
    });
    tabController = TabController(length: 2, vsync: this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.initState();
  }

  scrollGetFundTransferListener() {
    if (getFundTransferController.position.maxScrollExtent == getFundTransferController.offset) {
      if (context.read<GetFundTransfersCubit>().hasMoreData()) {
        context.read<GetFundTransfersCubit>().fetchMoreGetFundTransfersData(perPage, context.read<AuthCubit>().getId());
      }
    }
  }

  scrollGetWithdrawListener() {
    if (withdrawWalletController.position.maxScrollExtent == withdrawWalletController.offset) {
      if (context.read<GetWithdrawRequestCubit>().hasMoreData()) {
        context.read<GetWithdrawRequestCubit>().fetchMoreGetWithdrawRequestData(perPage, context.read<AuthCubit>().getId());
      }
    }
  }

  @override
  void dispose() {
    amountController!.dispose();
    messageController!.dispose();
    withdrawAmountController!.dispose();
    paymentAddressController!.dispose();
    getFundTransferController.dispose();
    withdrawWalletController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  onChanged(int position) {
    setState(() {
      _selectedIndex = position;
      enableList = !enableList;
    });
  }

  onTap() {
    setState(() {
      enableList = !enableList;
    });
  }

  Widget selectTransactionType() {
    return Container(
      decoration: DesignConfig.boxDecorationContainerBorder(textFieldBorder, textFieldBackground, 4.0),
      margin: EdgeInsetsDirectional.only(top: height! / 99.0, start: width! / 30.0, end: width! / 30.0),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              decoration: DesignConfig.boxDecorationContainer(textFieldBackground, 4.0),
              padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 80.0, top: height! / 80.0, bottom: height! / 99.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                      child: Text(
                    transactionType[_selectedIndex!],
                    style: TextStyle(fontSize: 16.0, color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76), fontWeight: FontWeight.w500),
                  )),
                  Icon(enableList ? Icons.expand_less : Icons.expand_more,
                      size: 24.0, color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76)),
                ],
              ),
            ),
          ),
          enableList
              ? ListView.builder(
                  padding: EdgeInsetsDirectional.only(top: height! / 99.9, bottom: height! / 99.0),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  itemCount: transactionType.length,
                  itemBuilder: (context, position) {
                    return InkWell(
                      onTap: () {
                        onChanged(position);
                        filter = transactionType[position];
                        if (position == 0) {
                          context.read<GetFundTransfersCubit>().fetchGetFundTransfers(perPage, context.read<AuthCubit>().getId());
                        } else {
                          context.read<GetWithdrawRequestCubit>().fetchGetWithdrawRequest(perPage, context.read<AuthCubit>().getId());
                        }
                      },
                      child: Container(
                          padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top: height! / 99.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transactionType[position],
                                style: TextStyle(fontSize: 12.0, color: Theme.of(context).colorScheme.onSecondary),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.only(top: height! / 99.0),
                                child: DesignConfig.dividerSolid(),
                              ),
                            ],
                          )),
                    );
                  })
              : Container(),
        ],
      ),
    );
  }

  walletStatusCartTitle(String status) {
    if (status.toString() == "0") {
      return StringsRes.pending;
    } else if (status.toString() == "1") {
      return StringsRes.approval;
    } else if (status.toString() == "2") {
      return StringsRes.rejected;
    } else {
      return "";
    }
  }

  Widget walletWithdraw() {
    return BlocConsumer<GetWithdrawRequestCubit, GetWithdrawRequestState>(
        bloc: context.read<GetWithdrawRequestCubit>(),
        listener: (context, state) {
        },
        builder: (context, state) {
          if (state is GetWithdrawRequestProgress || state is GetWithdrawRequestInitial) {
            return MyOrderSimmer(length: 5, width: width, height: height);
          }
          if (state is GetWithdrawRequestFailure) {
            return SizedBox(height: height! / 1.90, child: onData());
          }
          final withdrawRequestList = (state as GetWithdrawRequestSuccess).withdrawRequestList;
          final hasMore = state.hasMore;
          return withdrawRequestList.isEmpty
              ? SizedBox(height: height! / 1.90, child: onData())
              : ListView.builder(
                  shrinkWrap: true,
                  controller: withdrawWalletController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: withdrawRequestList.length,
                  itemBuilder: (BuildContext context, index) {
                    return hasMore && index == (withdrawRequestList.length - 1)
                        ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                        : Container(
                            padding:
                                EdgeInsetsDirectional.only(start: width! / 20.0, top: height! / 80.0, end: width! / 20.0, bottom: height! / 80.0),
                            width: width!,
                            margin: EdgeInsetsDirectional.only(top: index == 0 ? 0.0 : height! / 52.0),
                            decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 0.0),
                            child: Padding(
                              padding: EdgeInsetsDirectional.only(start: width! / 60.0),
                              child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(UiUtils.getTranslatedLabel(context, idLabel).toUpperCase(),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w700, fontSize: 14.0)),
                                          Text(" #${withdrawRequestList[index].id!}",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w700, fontSize: 14.0)),
                                        ],
                                      ),
                                    ),
                                    withdrawRequestList[index].status == ""
                                        ? const SizedBox()
                                        : Align(
                                            alignment: Alignment.topRight,
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding: const EdgeInsetsDirectional.only(top: 5.0, bottom: 5.0, start: 5.0, end: 5.0),
                                              margin: const EdgeInsetsDirectional.only(start: 4.5),
                                              decoration: DesignConfig.boxDecorationContainerBorder(
                                                  DesignConfig.walletStatusCartColor(withdrawRequestList[index].status!),
                                                  DesignConfig.walletStatusCartColor(withdrawRequestList[index].status!).withValues(alpha: 0.10),
                                                  4.0),
                                              child: Text(
                                                walletStatusCartTitle(withdrawRequestList[index].status!.toString()),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.normal,
                                                  color: DesignConfig.walletStatusCartColor(withdrawRequestList[index].status!),
                                                ),
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.only(top: height! / 80.0, bottom: height! / 80.0),
                                  child: DesignConfig.divider(),
                                ),
                                Text("${UiUtils.getTranslatedLabel(context, dateLabel)} :",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w600, fontSize: 14.0)),
                                Text(formatter.format(DateTime.parse(withdrawRequestList[index].dateCreated!)),
                                    textAlign: TextAlign.start,
                                    style:
                                        TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.normal, fontSize: 14.0)),
                                SizedBox(height: height! / 60.0),
                                Text("${UiUtils.getTranslatedLabel(context, typeLabel)} : ",
                                    textAlign: TextAlign.start,
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.w600, fontSize: 14.0)),
                                Text(withdrawRequestList[index].paymentType!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontWeight: FontWeight.normal, fontSize: 14.0),
                                    maxLines: 2),
                                Padding(
                                  padding: EdgeInsetsDirectional.only(top: height! / 80.0, bottom: height! / 80.0),
                                  child: DesignConfig.divider(),
                                ),
                                Row(children: [
                                  SvgPicture.asset(DesignConfig.setSvgPath("amout_icon"),
                                      fit: BoxFit.scaleDown,
                                      colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn),
                                      width: 7.0,
                                      height: 12.3),
                                  SizedBox(width: width! / 80.0),
                                  Text("${UiUtils.getTranslatedLabel(context, amountLabel)}",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          color: Theme.of(context).colorScheme.onPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 14.0)),
                                  const Spacer(),
                                  Text(
                                      "${context.read<SystemConfigCubit>().getCurrency()}${double.parse(withdrawRequestList[index].amountRequested!).toStringAsFixed(2)}",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          color: Theme.of(context).colorScheme.secondary,
                                          fontWeight: FontWeight.w700,
                                          fontStyle: FontStyle.normal,
                                          fontSize: 14.0)),
                                ]),
                              ]),
                            ),
                          );
                  });
        });
  }

  Widget onData() {
    return NoDataContainer(
        image: "wallet",
        title: UiUtils.getTranslatedLabel(context, noWalletFoundLabel),
        subTitle: UiUtils.getTranslatedLabel(context, noWalletFoundSubTitleLabel),
        width: width!,
        height: height!);
  }

  Widget onFundTransferFoundData() {
    return NoDataContainer(
        image: "wallet",
        title: UiUtils.getTranslatedLabel(context, noFundTransferFoundLabel),
        subTitle: UiUtils.getTranslatedLabel(context, noFundTransferFoundSubTitle),
        width: width!,
        height: height!);
  }

  Widget getFundTransfers() {
    return BlocConsumer<GetFundTransfersCubit, GetFundTransfersState>(
        bloc: context.read<GetFundTransfersCubit>(),
        listener: (context, state) {
        },
        builder: (context, state) {
          if (state is GetFundTransfersProgress || state is GetFundTransfersInitial) {
            return MyOrderSimmer(length: 5, width: width, height: height);
          }
          if (state is GetFundTransfersFailure) {
            return SizedBox(height: height! / 1.90, child: onFundTransferFoundData());
          }
          final fundTransfersList = (state as GetFundTransfersSuccess).fundTransfersList;
          final hasMore = state.hasMore;
          return fundTransfersList.isEmpty
              ? SizedBox(height: height! / 1.90, child: onFundTransferFoundData())
              : ListView.builder(
                  shrinkWrap: true,
                  controller: getFundTransferController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: fundTransfersList.length,
                  itemBuilder: (BuildContext context, index) {
                    return hasMore && index == (fundTransfersList.length - 1)
                        ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                        : FundTransferContainer(fundTransferModel: fundTransfersList[index], height: height, width: width, index: index);
                  });
        });
  }

  withDrawMoneyBottomSheet() {
    showModalBottomSheet(
        isDismissible: true,
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        shape: DesignConfig.setRoundedBorderCard(0.0, 0.0, 16.0, 16.0),
        isScrollControlled: true,
        enableDrag: true,
        showDragHandle: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
            dialogState = setStater;
            return Container(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Form(
                        key: _formkey,
                        child: Flexible(
                          child: SingleChildScrollView(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: <Widget>[
                            Container(
                                margin: EdgeInsetsDirectional.only(start: width! / 20.0, top: height! / 60.0, end: width! / 20.0),
                                child: TextFormField(
                                  style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76), fontSize: 16.0, fontWeight: FontWeight.w500),
                                  keyboardType: TextInputType.number,
                                  validator: (val) => validateField(val!, UiUtils.getTranslatedLabel(context, requirdFieldLabel)),
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  textInputAction: TextInputAction.done,
                                  decoration: DesignConfig.inputDecorationextField(UiUtils.getTranslatedLabel(context, amountLabel),
                                      UiUtils.getTranslatedLabel(context, enterWithdrawAmountLabel), width!, context),
                                  cursorColor: lightFont,
                                  controller: withdrawAmountController,
                                )),
                            Container(
                                margin: EdgeInsetsDirectional.only(start: width! / 20.0, top: height! / 60.0, end: width! / 20.0),
                                child: TextFormField(
                                  maxLines: 7,
                                  style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76), fontSize: 16.0, fontWeight: FontWeight.w500),
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  decoration: DesignConfig.inputDecorationextField(UiUtils.getTranslatedLabel(context, bankDetailLabel),
                                      UiUtils.getTranslatedLabel(context, enterBankDetailLabel), width!, context),
                                  cursorColor: lightFont,
                                  controller: paymentAddressController,
                                )),
                          ])),
                        ),
                      ),
                      SizedBox(
                        height: height! / 40.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: SmallButtonContainer(
                              color: Theme.of(context).colorScheme.onSurface,
                              height: height,
                              width: width,
                              text: UiUtils.getTranslatedLabel(context, cancelLabel),
                              start: width! / 20.0,
                              end: width! / 40.0,
                              bottom: height! / 60.0,
                              top: height! / 99.0,
                              radius: 5.0,
                              status: false,
                              borderColor: Theme.of(context).colorScheme.onPrimary,
                              textColor: Theme.of(context).colorScheme.onPrimary,
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          Expanded(
                            child: BlocConsumer<SendWithdrawRequestCubit, SendWithdrawRequestState>(
                                bloc: context.read<SendWithdrawRequestCubit>(),
                                listener: (context, state) {
                                  if (state is SendWithdrawRequestFetchSuccess) {
                                    print(state.walletAmount);
                                    context.read<GetRiderDetailCubit>().setWallet(state.walletAmount);
                                    context.read<GetRiderDetailCubit>().setComplete(context.read<GetRiderDetailCubit>().getCompleteDelivery());
                                    context.read<GetRiderDetailCubit>().setPending(context.read<GetRiderDetailCubit>().getPendingDeivery());
                                    context.read<GetRiderDetailCubit>().setCancel(context.read<GetRiderDetailCubit>().getCancelDelivery());
                                    context.read<SystemConfigCubit>().getSystemConfig();
                                    context.read<GetWithdrawRequestCubit>().fetchGetWithdrawRequest(perPage, context.read<AuthCubit>().getId());
                                    Navigator.of(context, rootNavigator: true).pop(true);
                                    withdrawAmountController!.clear();
                                    paymentAddressController!.clear();
                                    withdrawAmountController = TextEditingController(text: "");
                                    paymentAddressController = TextEditingController(text: "");
                                  }
                                  if(state is SendWithdrawRequestFetchFailure){
                                    Navigator.of(context, rootNavigator: true).pop(true);
                                    UiUtils.setSnackBar(state.errorMessage, context, false, type: "2");
                                    withdrawAmountController!.clear();
                                    paymentAddressController!.clear();
                                    withdrawAmountController = TextEditingController(text: "");
                                    paymentAddressController = TextEditingController(text: "");
                                  }
                                },
                                builder: (context, state) {
                                  print(state.toString());
                                  if (state is SendWithdrawRequestFetchFailure) {
                                    print(state.errorMessage);
                                    return SmallButtonContainer(
                                      color: Theme.of(context).colorScheme.primary,
                                      height: height,
                                      width: width,
                                      text: UiUtils.getTranslatedLabel(context, sendLabel),
                                      start: 0,
                                      end: width! / 20.0,
                                      bottom: height! / 60.0,
                                      top: height! / 99.0,
                                      radius: 5.0,
                                      status: false,
                                      borderColor: Theme.of(context).colorScheme.primary,
                                      textColor: Theme.of(context).colorScheme.onPrimary,
                                      onTap: () {
                                        final form = _formkey.currentState!;
                                        if (form.validate() && withdrawAmountController!.text != '0') {
                                          form.save();
                                          context.read<SendWithdrawRequestCubit>().sendWithdrawRequest(
                                              context.read<AuthCubit>().getId(), withdrawAmountController!.text, paymentAddressController!.text);
                                        }
                                      },
                                    );
                                  } else {
                                    return SmallButtonContainer(
                                      color: Theme.of(context).colorScheme.primary,
                                      height: height,
                                      width: width,
                                      text: UiUtils.getTranslatedLabel(context, sendLabel),
                                      start: 0,
                                      end: width! / 20.0,
                                      bottom: height! / 60.0,
                                      top: height! / 99.0,
                                      radius: 5.0,
                                      status: false,
                                      borderColor: Theme.of(context).colorScheme.primary,
                                      textColor: Theme.of(context).colorScheme.onPrimary,
                                      onTap: () {
                                        final form = _formkey.currentState!;
                                        if (form.validate() && withdrawAmountController!.text != '0') {
                                          form.save();
                                          context.read<SendWithdrawRequestCubit>().sendWithdrawRequest(
                                              context.read<AuthCubit>().getId(), withdrawAmountController!.text, paymentAddressController!.text);
                                        }
                                      },
                                    );
                                  }
                                }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ));
          });
        });
  }

  Future<void> refreshList() async {
    context.read<GetFundTransfersCubit>().fetchGetFundTransfers(perPage, context.read<AuthCubit>().getId());
    context.read<GetWithdrawRequestCubit>().fetchGetWithdrawRequest(perPage, context.read<AuthCubit>().getId());
    context.read<SystemConfigCubit>().getSystemConfig();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
      ),
      child: _connectionStatus == connectivityCheck
          ? const NoInternetScreen()
          : DefaultTabController(
              length: 2,
              child: Scaffold(
                backgroundColor: Theme.of(context).colorScheme.surface,
                appBar: DesignConfig.appBarWihoutBackbutton(context, width!, UiUtils.getTranslatedLabel(context, walletLabel),
                    PreferredSize(preferredSize: Size(width!, height! / 12.0), child: SizedBox())),
                body: BlocListener<SystemConfigCubit, SystemConfigState>(
                  bloc: context.read<SystemConfigCubit>(),
                  listener: (context, state) {
                    print("state:${state.toString()}");
                    if (state is SystemConfigFetchSuccess) {}
                    if (state is SystemConfigFetchFailure) {
                      print(state.errorCode);
                    }
                  },
                  child: Container(
                    margin: EdgeInsetsDirectional.only(top: height! / 90.0),
                    width: width,
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsetsDirectional.only(start: 0, end: 0, top: height! / 80.0),
                            decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 4.0),
                            child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Stack(
                                children: [
                                  Container(
                                      decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.secondary, 10.0),
                                      margin: EdgeInsetsDirectional.only(start: width! / 20.0, end: width! / 20.0),
                                      padding: EdgeInsetsDirectional.only(
                                          top: height! / 40.0, bottom: height! / 40.0, start: width! / 20.0, end: width! / 20.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            " ${UiUtils.getTranslatedLabel(context, currentBalanceLabel)}",
                                            style: const TextStyle(
                                                color: Colors.white, fontWeight: FontWeight.w400, fontStyle: FontStyle.normal, fontSize: 14.0),
                                          ),
                                          const SizedBox(height: 5.0),
                                          BlocBuilder<GetRiderDetailCubit, GetRiderDetailState>(
                                              bloc: context.read<GetRiderDetailCubit>(),
                                              builder: (context, state) {
                                                if (state is GetRiderDetailFetchSuccess) {
                                                  return Text(
                                                    "${context.read<SystemConfigCubit>().getCurrency()}${double.parse(state.authModel.balance.toString()).toStringAsFixed(2)}",
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w600,
                                                        fontStyle: FontStyle.normal,
                                                        fontSize: 20.0),
                                                  );
                                                } else {
                                                  return Text(
                                                    "${context.read<SystemConfigCubit>().getCurrency()}${double.parse(walletAmount!).toStringAsFixed(2)}",
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w600,
                                                        fontStyle: FontStyle.normal,
                                                        fontSize: 20.0),
                                                  );
                                                }
                                              }),
                                          SizedBox(height: height! / 40.0),
                                          SizedBox(
                                            width: width,
                                            child: SmallButtonContainer(
                                              color: Theme.of(context).colorScheme.onSurface,
                                              height: height,
                                              width: width,
                                              text: UiUtils.getTranslatedLabel(context, withdrawMoneyLabel),
                                              start: width! / 40.0,
                                              end: width! / 99.0,
                                              bottom: 0,
                                              top: 0,
                                              status: false,
                                              radius: 5.0,
                                              borderColor: Theme.of(context).colorScheme.onSurface,
                                              textColor: Theme.of(context).colorScheme.onPrimary,
                                              onTap: () {
                                                withDrawMoneyBottomSheet();
                                              },
                                            ),
                                          )
                                        ],
                                      )),
                                  Positioned.directional(
                                    end: width! / 30.0,
                                    textDirection: Directionality.of(context),
                                    child: Container(
                                      alignment: Alignment.bottomLeft,
                                      width: width! / 5.4,
                                      height: height! / 12.0,
                                      decoration: Directionality.of(context) == ui.TextDirection.rtl
                                          ? DesignConfig.boxDecorationContainerRoundHalf(
                                              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.10), 0, 0, 10, 62)
                                          : DesignConfig.boxDecorationContainerRoundHalf(
                                              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.10), 0, 62, 10, 0),
                                    ),
                                  ),
                                  Positioned.directional(
                                    start: width! / 30.0,
                                    textDirection: Directionality.of(context),
                                    bottom: 0.0,
                                    child: Container(
                                      width: width! / 5.4,
                                      height: height! / 12.0,
                                      decoration: Directionality.of(context) == ui.TextDirection.rtl
                                          ? DesignConfig.boxDecorationContainerRoundHalf(
                                              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.10), 62, 10, 0, 0)
                                          : DesignConfig.boxDecorationContainerRoundHalf(
                                              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.10), 0, 0, 62, 0),
                                    ),
                                  ),
                                ],
                              ),
                              PreferredSize(
                                  preferredSize: Size.fromHeight(height! / 8.0),
                                  child: TabBar(
                                    labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.secondary, fontFamily: 'Quicksand'),
                                    controller: tabController,
                                    padding: EdgeInsetsDirectional.only(top: height! / 80.0),
                                    unselectedLabelStyle:
                                        TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.secondary, fontFamily: 'Quicksand'),
                                    tabs: [
                                      Tab(text: UiUtils.getTranslatedLabel(context, fundTransferLabel)),
                                      Tab(text: UiUtils.getTranslatedLabel(context, walletWithdrawLabel)),
                                    ],
                                    unselectedLabelColor: Theme.of(context).colorScheme.onPrimary,
                                    labelColor: Theme.of(context).colorScheme.secondary,
                                  ))
                            ]),
                          ),
                          Container(
                            height: height! / 1.65,
                            margin: EdgeInsetsDirectional.only(top: height! / 60.0),
                            child: TabBarView(
                              controller: tabController,
                              children: [
                                RefreshIndicator(onRefresh: refreshList, color: Theme.of(context).colorScheme.primary, child: getFundTransfers()),
                                RefreshIndicator(onRefresh: refreshList, color: Theme.of(context).colorScheme.primary, child: walletWithdraw())
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

String? validateField(String value, String? msg) {
  if (value.isEmpty) {
    return msg;
  } else {
    return null;
  }
}
