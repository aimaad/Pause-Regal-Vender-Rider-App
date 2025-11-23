import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro_single_vender_rider/app/routes.dart';
import 'package:erestro_single_vender_rider/cubit/auth/authCubit.dart';
import 'package:erestro_single_vender_rider/cubit/order/deleteLiveTrackingCubit.dart';
import 'package:erestro_single_vender_rider/cubit/order/manageLiveTrackingCubit.dart';
import 'package:erestro_single_vender_rider/cubit/order/updateOrderStatusCubit.dart';
import 'package:erestro_single_vender_rider/cubit/settings/settingsCubit.dart';
import 'package:erestro_single_vender_rider/data/model/addOnsDataModel.dart';
import 'package:erestro_single_vender_rider/cubit/order/orderCubit.dart';
import 'package:erestro_single_vender_rider/data/model/orderModel.dart';
import 'package:erestro_single_vender_rider/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestro_single_vender_rider/ui/screen/main/main_screen.dart';
import 'package:erestro_single_vender_rider/ui/screen/settings/no_internet_screen.dart';
import 'package:erestro_single_vender_rider/ui/widgets/simmer/myOrderSimmer.dart';
import 'package:erestro_single_vender_rider/ui/widgets/noDataContainer.dart';
import 'package:erestro_single_vender_rider/ui/widgets/smallButtomContainer.dart';
import 'package:erestro_single_vender_rider/utils/apiBodyParameterLabels.dart';
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
import 'package:flutter_svg/svg.dart';
import 'dart:ui' as ui;

import 'package:erestro_single_vender_rider/utils/internetConnectivity.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

List<GlobalKey<MyOrderViewScreenState>>? globalKey;

// ignore: must_be_immutable
class MyOrderViewScreen extends StatefulWidget {
  String orderStatus;
  MyOrderViewScreen({Key? key, required this.orderStatus}) : super(key: key);

  @override
  MyOrderViewScreenState createState() => MyOrderViewScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<OrderCubit>(
              create: (_) => OrderCubit(),
              child: MyOrderViewScreen(orderStatus: arguments['orderStatus'] as String),
            ));
  }
}

class MyOrderViewScreenState extends State<MyOrderViewScreen> with AutomaticKeepAliveClientMixin {
  double? width, height;
  ScrollController orderController = ScrollController();
  TextEditingController otpController = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');
  var inputFormat = DateFormat('yyyy-MM-dd hh:mm:ss');
  var outputFormat = DateFormat('dd,MMMM yyyy hh:mm a');
  StateSetter? dialogState;

  @override
  void initState() {
    super.initState();
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
    orderController.addListener(orderScrollListener);
    refreshList();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  orderScrollListener() {
    if (orderController.position.maxScrollExtent == orderController.offset) {
      if (context.read<OrderCubit>().hasMoreData()) {
        context.read<OrderCubit>().fetchMoreOrderData(perPage, context.read<AuthCubit>().getId(), "", widget.orderStatus);
      }
    }
  }

  Widget noOrder() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsetsDirectional.zero,
      child: NoDataContainer(
          image: "empty_order",
          title: UiUtils.getTranslatedLabel(context, noOrderYetLabel),
          subTitle: UiUtils.getTranslatedLabel(context, noOrderYetSubTitleLabel),
          width: width!,
          height: height!),
    );
  }

  Widget myOrder() {
    return BlocConsumer<OrderCubit, OrderState>(
        bloc: context.read<OrderCubit>(),
        listener: (context, state) {
        },
        builder: (context, state) {
          if (state is OrderProgress || state is OrderInitial) {
            return MyOrderSimmer(length: 5, width: width!, height: height!);
          }
          if (state is OrderFailure) {
            return (state.errorMessage.toString() == "Order Does Not Exists" || state.errorStatusCode.toString() == tockenExpireCode)
                ? noOrder()
                : Center(
                    child: Text(
                    state.errorMessage.toString(),
                    textAlign: TextAlign.center,
                  ));
          }
          final orderList = (state as OrderSuccess).orderList;
          final hasMore = state.hasMore;
          return orderList.isEmpty
              ? noOrder()
              : ListView.builder(
                  shrinkWrap: true,
                  controller: orderController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: orderList.length,
                  itemBuilder: (BuildContext context, index) {
                    var status = "";
                    if (orderList[index].activeStatus == deliveredKey) {
                      status = UiUtils.getTranslatedLabel(context, deliveredLabel);
                    } else if (orderList[index].activeStatus == pendingKey) {
                      status = UiUtils.getTranslatedLabel(context, pendingLbLabel);
                    } else if (orderList[index].activeStatus == waitingKey) {
                      status = UiUtils.getTranslatedLabel(context, awaitingLbLabel);
                    } else if (orderList[index].activeStatus == outForDeliveryKey) {
                      status = UiUtils.getTranslatedLabel(context, outForDeliveryLbLabel);
                    } else if (orderList[index].activeStatus == confirmedKey) {
                      status = UiUtils.getTranslatedLabel(context, confirmedLbLabel);
                    } else if (orderList[index].activeStatus == cancelledKey) {
                      status = UiUtils.getTranslatedLabel(context, cancelledsLabel);
                    } else if (orderList[index].activeStatus == preparingKey) {
                      status = UiUtils.getTranslatedLabel(context, preparingLbLabel);
                    } else if (orderList[index].activeStatus == readyForPickupKey) {
                      status = UiUtils.getTranslatedLabel(context, readyForPickupLbLabel);
                    } else {
                      status = "";
                    }
                    var inputDate = inputFormat.parse(orderList[index].dateAdded.toString()); // <-- dd/MM 24H format
                    var outputDate = outputFormat.format(inputDate);
                    return hasMore && index == (orderList.length - 1)
                        ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                        : Builder(builder: (context) {
                            return GestureDetector(
                              onTap: () {
                                print(orderList[index].activeStatus);
                                Navigator.of(context).pushNamed(Routes.orderDetail, arguments: {'orderModel': orderList[index]});
                              },
                              child: Container(
                                  padding: EdgeInsetsDirectional.only(top: height! / 60.0, bottom: height! / 60.0),
                                  width: width!,
                                  margin: EdgeInsetsDirectional.only(
                                    top: index == 0 ? height! / 80.0 : height! / 70.0,
                                    start: width! / 20.0,
                                    end: width! / 20.0,
                                  ),
                                  decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.surface, 8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${UiUtils.getTranslatedLabel(context, orderIdLabel)}: #${orderList[index].id!}",
                                                  textAlign: TextAlign.start,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      color: Theme.of(context).colorScheme.onPrimary,
                                                      fontSize: 14,
                                                      overflow: TextOverflow.ellipsis,
                                                      fontWeight: FontWeight.w700),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Row(
                                                  children: [
                                                    SvgPicture.asset(DesignConfig.setSvgPath("pro_date"),
                                                        height: 14,
                                                        width: 14,
                                                        colorFilter: ColorFilter.mode(
                                                            Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76), BlendMode.srcIn)),
                                                    const SizedBox(
                                                      width: 5.0,
                                                    ),
                                                    Text(outputDate.toString(),
                                                        textAlign: TextAlign.start,
                                                        style: TextStyle(
                                                          color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w600,
                                                        )),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            orderList[index].activeStatus==readyForPickupKey||orderList[index].activeStatus==outForDeliveryKey?FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: Container(width: width!/5.0,
                                                alignment: Alignment.center,
                                                padding: const EdgeInsetsDirectional.only(top: 4.5, bottom: 4.5, start: 4.5, end: 4.5),
                                                decoration: DesignConfig.boxDecorationContainerBorder(
                                                    DesignConfig.orderStatusCartColor(orderList[index].activeStatus!),
                                                    DesignConfig.orderStatusCartColor(orderList[index].activeStatus!).withValues(alpha: 0.10),
                                                    4.0),
                                                child: Text(
                                                  status,textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: DesignConfig.orderStatusCartColor(orderList[index].activeStatus!), overflow: TextOverflow.ellipsis
                                                  ),maxLines: 2,
                                                ),
                                              ),
                                            ) : FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: Container(
                                                alignment: Alignment.center,
                                                padding: const EdgeInsetsDirectional.only(top: 4.5, bottom: 4.5, start: 4.5, end: 4.5),
                                                decoration: DesignConfig.boxDecorationContainerBorder(
                                                    DesignConfig.orderStatusCartColor(orderList[index].activeStatus!),
                                                    DesignConfig.orderStatusCartColor(orderList[index].activeStatus!).withValues(alpha: 0.10),
                                                    4.0),
                                                child: Text(
                                                  status,textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: DesignConfig.orderStatusCartColor(orderList[index].activeStatus!), overflow: TextOverflow.ellipsis
                                                  ),maxLines: 2,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(
                                          top: height! / 80.0,
                                          bottom: height! / 80.0,
                                        ),
                                        child: DesignConfig.divider(),
                                      ),
                                      Column(
                                          children:
                                              List.generate(orderList[index].orderItems!.length > 2 ? 2 : orderList[index].orderItems!.length, (i) {
                                        OrderItems data = orderList[index].orderItems![i];
                                        return Container(
                                          padding: EdgeInsetsDirectional.only(bottom: height! / 99.0),
                                          width: width!,
                                          margin: EdgeInsetsDirectional.only(top: height! / 99.0, start: width! / 40.0, end: width! / 60.0),
                                          child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    data.indicator == "1"
                                                        ? SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"), width: 15, height: 15)
                                                        : data.indicator == "2"
                                                            ? SvgPicture.asset(DesignConfig.setSvgPath("non_veg_icon"), width: 15, height: 15)
                                                            : const SizedBox(height: 15, width: 15.0),
                                                    const SizedBox(width: 5.0),
                                                    Text(
                                                      "${data.quantity!} x ",
                                                      textAlign:
                                                          Directionality.of(context) == ui.TextDirection.rtl ? TextAlign.right : TextAlign.left,
                                                      style: TextStyle(
                                                          color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                          overflow: TextOverflow.ellipsis),
                                                      maxLines: 1,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        data.name!,
                                                        textAlign:
                                                            Directionality.of(context) == ui.TextDirection.rtl ? TextAlign.right : TextAlign.left,
                                                        style: TextStyle(
                                                            color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.bold,
                                                            overflow: TextOverflow.ellipsis),
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                    i == 0
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              Navigator.of(context)
                                                                  .pushNamed(Routes.orderDetail, arguments: {'orderModel': orderList[index]});
                                                            },
                                                            child: Icon(Icons.arrow_circle_right_rounded,
                                                                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76)),
                                                          )
                                                        : const SizedBox.shrink()
                                                  ],
                                                ),
                                                orderList[index].orderItems![i].attrName != ""
                                                    ? Padding(
                                                        padding: EdgeInsetsDirectional.only(start: width! / 20.0),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text("${orderList[index].orderItems![i].attrName!} : ",
                                                                textAlign: TextAlign.left,
                                                                style: const TextStyle(color: lightFont, fontSize: 10, fontWeight: FontWeight.w500)),
                                                            Text(orderList[index].orderItems![i].variantValues!,
                                                                textAlign: TextAlign.left,
                                                                style: const TextStyle(
                                                                  color: lightFont,
                                                                  fontSize: 10,
                                                                )),
                                                          ],
                                                        ),
                                                      )
                                                    : Container(),
                                                Padding(
                                                  padding: EdgeInsetsDirectional.only(start: width! / 20.0, end: width! / 99.0),
                                                  child: Wrap(
                                                      spacing: 5.0,
                                                      runSpacing: 2.0,
                                                      direction: Axis.horizontal,
                                                      children: List.generate(orderList[index].orderItems![i].addOns!.length, (j) {
                                                        AddOnsDataModel addOnData = orderList[index].orderItems![i].addOns![j];
                                                        return Text(
                                                          "${addOnData.qty!} x ${addOnData.title!}, ",
                                                          textAlign: TextAlign.center,
                                                          style:
                                                              const TextStyle(color: lightFontColor, fontSize: 10, overflow: TextOverflow.ellipsis),
                                                          maxLines: 2,
                                                        );
                                                      })),
                                                ),
                                              ]),
                                        );
                                      })),
                                      orderList[index].orderItems!.length > 2
                                          ? Align(
                                              alignment: Alignment.topLeft,
                                              child: Padding(
                                                padding:
                                                    EdgeInsetsDirectional.only(start: width! / 13.0, bottom: height! / 80.0, top: height! / 99.0),
                                                child: Text(
                                                    "${orderList[index].orderItems!.length - 2} ${StringsRes.pluseSymbol} ${UiUtils.getTranslatedLabel(context, moreLabel)}",
                                                    style: TextStyle(
                                                        fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.secondary)),
                                              ))
                                          : SizedBox.shrink(),
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(
                                          top: height! / 99.0,
                                          bottom: height! / 80.0,
                                        ),
                                        child: DesignConfig.divider(),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0),
                                        child: Row(children: [
                                          Text(UiUtils.getTranslatedLabel(context, totalPayLabel),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Theme.of(context).colorScheme.onPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                                          const Spacer(),
                                          Container(
                                            margin: EdgeInsetsDirectional.only(end: width! / 40.0),
                                            decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 0.0),
                                            padding: EdgeInsetsDirectional.all(5.0),
                                            child: Text(orderList[index].paymentMethod!,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Theme.of(context).colorScheme.secondary,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.96)),
                                          ),
                                          Container(
                                            decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 0.0),
                                            padding: EdgeInsetsDirectional.all(5.0),
                                            child: Text(context.read<SystemConfigCubit>().getCurrency() + orderList[index].finalTotal!,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Theme.of(context).colorScheme.secondary,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.96)),
                                          ),
                                        ]),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.only(
                                          top: height! / 99.0,
                                          bottom: height! / 80.0,
                                        ),
                                        child: DesignConfig.divider(),
                                      ),
                                      Container(
                                        margin: EdgeInsetsDirectional.only(start: width! / 40, end: width! / 40.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsetsDirectional.only(end: width! / 40.0),
                                              child: ClipRRect(
                                                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                                                child: DesignConfig.imageWidgets(orderList[index].profile, 40, 40, "1")
                                              ),
                                            ),
                                            Expanded(
                                                child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(orderList[index].username!,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      
                                                        color: Theme.of(context).colorScheme.onPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                                                Text(orderList[index].mobile!,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w500)),
                                              ],
                                            )),
                                            (orderList[index].activeStatus == deliveredKey || orderList[index].activeStatus == cancelledKey)
                                                ? const SizedBox.shrink()
                                                : GestureDetector(
                                                    onTap: () async {
                                                      Navigator.of(context).pushNamed(Routes.orderTracking, arguments: {
                                                        'id': orderList[index].id!,
                                                        'customerLatitude': double.parse(orderList[index].latitude!),
                                                        'customerLongitude': double.parse(orderList[index].longitude!),
                                                        'restaurantLatitude': double.parse(orderList[index].branchDetails!.latitude!),
                                                        'restaurantLongitude': double.parse(orderList[index].branchDetails!.longitude!),
                                                        'customerAddress': orderList[index].address,
                                                        'restaurantAddress': orderList[index].branchDetails!.address,
                                                        'customerName': orderList[index].username,
                                                        'customerMobile': orderList[index].mobile,
                                                        'customerImage': orderList[index].profile,
                                                        'isTracking': orderList[index].activeStatus == outForDeliveryKey ? true : false
                                                      });
                                                    },
                                                    child: Container(
                                                        margin: EdgeInsetsDirectional.only(end: width! / 40.0),
                                                        padding: EdgeInsetsDirectional.all(5.0),
                                                        decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.secondary, 100),
                                                        child: Icon(Icons.location_on, color: Theme.of(context).colorScheme.onSurface))),
                                            GestureDetector(
                                                onTap: () async {
                                                  final Uri launchUri = Uri(
                                                    scheme: 'tel',
                                                    path: orderList[index].mobile,
                                                  );
                                                  if (await canLaunchUrl(launchUri)) {
                                                    await launchUrl(launchUri);
                                                  } else {
                                                    Clipboard.setData(ClipboardData(text: orderList[index].mobile!));
                                                    print('Calling not supported. Number copied to clipboard.${orderList[index].mobile!}');
                                                  }
                                                },
                                                child: Container(
                                                    padding: EdgeInsetsDirectional.all(5.0),
                                                    decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.secondary, 100),
                                                    child: Icon(Icons.phone, color: Theme.of(context).colorScheme.onSurface)))
                                          ],
                                        ),
                                      ),
                                      BlocListener<ManageLiveTrackingCubit, ManageLiveTrackingState>(
                                        listener: (context, state) {
                                          if (state is ManageLiveTrackingSuccess) {
                                            if (orderList[index].activeStatus == deliveredKey && state.orderId == orderList[index].id) {
                                              context.read<DeleteLiveTrackingCubit>().deleteLiveTracking(orderId: orderList[index].id);
                                            }
                                          }
                                        },
                                        child: BlocConsumer<UpdateOrderStatusCubit, UpdateOrderStatusState>(
                                          listener: (context, updateOrderStatusState) {
                                            if (updateOrderStatusState is UpdateOrderStatusSuccess) {
                                              if (status == deliveredKey) {
                                                context.read<ManageLiveTrackingCubit>().manageLiveTracking(
                                                    orderId: orderList[index].id,
                                                    orderStatus: deliveredKey,
                                                    latitude: context.read<SettingsCubit>().getSettings().latitude,
                                                    longitude: context.read<SettingsCubit>().getSettings().longitude);
                                              }
                                              otpController.clear();
                                              List.generate(orderTypeList.length, (index) => globalKey?[index].currentState?.refreshList());
                                            }
                                          },
                                          builder: (context, updateOrderStatusState) {
                                            return Row(children: [
                                              orderList[index].riderCancelOrder == "0"
                                                  ? const SizedBox.shrink()
                                                  : (orderList[index].activeStatus == deliveredKey || orderList[index].activeStatus == cancelledKey)
                                                      ? const SizedBox.shrink()
                                                      : Expanded(
                                                          child: SmallButtonContainer(
                                                            color: Theme.of(context).colorScheme.surface,
                                                            height: height,
                                                            width: width,
                                                            text: UiUtils.getTranslatedLabel(context, cancelLabel),
                                                            start: width! / 40.0,
                                                            end: width! / 80.0,
                                                            bottom: 0,
                                                            top: height! / 80.0,
                                                            status: (updateOrderStatusState is UpdateOrderStatusProgress) ? true : false,
                                                            borderColor: Theme.of(context).colorScheme.onPrimary,
                                                            textColor: Theme.of(context).colorScheme.onPrimary,
                                                            radius: 5.0,
                                                            onTap: () {
                                                              if (/* context.read<SystemConfigCubit>().getIsRiderOtpSettingOn() */ orderList[index]
                                                                      .isRiderOtpSettingOn ==
                                                                  "0") {
                                                                context.read<UpdateOrderStatusCubit>().updateOrderStatus(
                                                                    riderId: context.read<AuthCubit>().getId(),
                                                                    orderId: orderList[index].id,
                                                                    status: cancelledKey);
                                                              }else{
                                                              if (orderList[index].otp != "" &&
                                                                  orderList[index].otp!.isNotEmpty &&
                                                                  orderList[index].otp != "0") {
                                                                addOtpBottomSheet(orderList[index], cancelledKey);
                                                              } else {
                                                                context.read<UpdateOrderStatusCubit>().updateOrderStatus(
                                                                    riderId: context.read<AuthCubit>().getId(),
                                                                    orderId: orderList[index].id,
                                                                    status: cancelledKey);
                                                              }
                                                              }
                                                            },
                                                          ),
                                                        ),
                                              orderList[index].activeStatus == outForDeliveryKey || orderList[index].activeStatus == readyForPickupKey
                                                  ? Expanded(
                                                      child: SmallButtonContainer(
                                                        color: (updateOrderStatusState is UpdateOrderStatusProgress) ? Theme.of(context).colorScheme.surface:Theme.of(context).colorScheme.primary,
                                                        height: height,
                                                        width: width,
                                                        text: orderList[index].activeStatus == outForDeliveryKey
                                                            ? UiUtils.getTranslatedLabel(context, markAsDeliveryLabel)
                                                            : UiUtils.getTranslatedLabel(context, markAsPickupLabel),
                                                        start: width! / 80.0,
                                                        end: width! / 40.0,
                                                        bottom: 0,
                                                        top: height! / 80.0,
                                                        status: false,
                                                        borderColor: (updateOrderStatusState is UpdateOrderStatusProgress)
                                                            ? commentBoxBorderColor
                                                            : Theme.of(context).colorScheme.primary,
                                                        textColor: (updateOrderStatusState is UpdateOrderStatusProgress)
                                                            ? commentBoxBorderColor
                                                            : Theme.of(context).colorScheme.onPrimary,
                                                        radius: 5.0,
                                                        onTap: () {
                                                          if (updateOrderStatusState is UpdateOrderStatusProgress) {
                                                        } else {
                                                          if (/* context.read<SystemConfigCubit>().getIsRiderOtpSettingOn() */orderList[index].isRiderOtpSettingOn == "0") {
                                                            context.read<UpdateOrderStatusCubit>().updateOrderStatus(
                                                                riderId: context.read<AuthCubit>().getId(),
                                                                orderId: orderList[index].id,
                                                                status: orderList[index].activeStatus == outForDeliveryKey
                                                                    ? deliveredKey
                                                                    : outForDeliveryKey);
                                                            
                                                          } else {
                                                            if (orderList[index].otp != "" &&
                                                                orderList[index].otp!.isNotEmpty &&
                                                                orderList[index].otp != "0" &&
                                                                orderList[index].activeStatus == outForDeliveryKey) {
                                                              print(orderList[index].otp);
                                                              addOtpBottomSheet(orderList[index], deliveredKey);
                                                            } else {
                                                              context.read<UpdateOrderStatusCubit>().updateOrderStatus(
                                                                  riderId: context.read<AuthCubit>().getId(),
                                                                  orderId: orderList[index].id,
                                                                  status: orderList[index].activeStatus == outForDeliveryKey
                                                                      ? deliveredKey
                                                                      : outForDeliveryKey);
                                                            }
                                                          }
                                                        }
                                                        },
                                                      ),
                                                    )
                                                  : const SizedBox.shrink()
                                            ]);
                                          },
                                        ),
                                      ),
                                    ],
                                  )),
                            );
                          });
                  });
        });
  }

  addOtpBottomSheet(OrderModel? orderModel, String? status) {
    otpController.text = "";
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
                                  validator: (String? value) {
                                    if (value!.isEmpty) {
                                      return UiUtils.getTranslatedLabel(context, requirdFieldLabel);
                                    } else if (value.trim() != orderModel!.otp) {
                                      return UiUtils.getTranslatedLabel(context, OtpErrorLabel);
                                    } else {
                                      return null;
                                    }
                                  },
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  textInputAction: TextInputAction.done,
                                  decoration: DesignConfig.inputDecorationextField(UiUtils.getTranslatedLabel(context, otpLabel),
                                      UiUtils.getTranslatedLabel(context, enterOtpLabel), width!, context),
                                  cursorColor: lightFont,
                                  controller: otpController,
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
                            child: BlocConsumer<UpdateOrderStatusCubit, UpdateOrderStatusState>(
                                bloc: context.read<UpdateOrderStatusCubit>(),
                                listener: (context, state) {
                                  if (state is UpdateOrderStatusSuccess) {
                                    Navigator.of(context, rootNavigator: true).pop(true);
                                    
                                  }
                                  
                                },
                                builder: (context, state) {
                                  print(state.toString());
                                  if (state is UpdateOrderStatusFailure) {
                                    print(state.errorCode);
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
                                        if (form.validate() && otpController.text != '0') {
                                          form.save();
                                          context.read<UpdateOrderStatusCubit>().updateOrderStatus(
                                              riderId: context.read<AuthCubit>().getId(),
                                              orderId: orderModel!.id,
                                              status: status,
                                              otp: otpController.text);
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
                                        if (form.validate() && otpController.text != '0') {
                                          form.save();
                                          context.read<UpdateOrderStatusCubit>().updateOrderStatus(
                                              riderId: context.read<AuthCubit>().getId(),
                                              orderId: orderModel!.id,
                                              status: status,
                                              otp: otpController.text);
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
        }).then((value){
          
        });
  }

  Future<void> refreshList() async {
    context.read<OrderCubit>().fetchOrder(perPage, context.read<AuthCubit>().getId(), "", widget.orderStatus);
  }

  @override
  void dispose() {
    orderController.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
      ),
      child: _connectionStatus == connectivityCheck
          ? const NoInternetScreen()
          : Scaffold(
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              body: RefreshIndicator(onRefresh: refreshList, color: Theme.of(context).colorScheme.primary, child: myOrder())),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
