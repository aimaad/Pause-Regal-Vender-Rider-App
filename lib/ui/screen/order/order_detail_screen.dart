import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro_single_vender_rider/data/model/addOnsDataModel.dart';
import 'package:erestro_single_vender_rider/cubit/order/orderCubit.dart';
import 'package:erestro_single_vender_rider/data/model/orderModel.dart';
import 'package:erestro_single_vender_rider/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestro_single_vender_rider/ui/screen/settings/no_internet_screen.dart';
import 'package:erestro_single_vender_rider/ui/styles/orderBillClipper.dart';
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
import 'package:url_launcher/url_launcher_string.dart';
import 'package:intl/intl.dart';
import 'package:erestro_single_vender_rider/utils/internetConnectivity.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel? orderModel;
  const OrderDetailScreen({Key? key, this.orderModel}) : super(key: key);

  @override
  OrderDetailScreenState createState() => OrderDetailScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<OrderCubit>(
              create: (_) => OrderCubit(),
              child: OrderDetailScreen(orderModel: arguments['orderModel'] as OrderModel),
            ));
  }
}

class OrderDetailScreenState extends State<OrderDetailScreen> {
  double? width, height;
  ScrollController orderController = ScrollController();
  String invoice = "", mobileNumber = "", activeStatusOrder = "";
  StateSetter? dialogState;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  Widget orderData() {
    return SizedBox(
        height: height! / 0.9,
        child: Container(
            margin: EdgeInsetsDirectional.only(start: width! / 20.0, end: width! / 20.0),
            width: width!,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (widget.orderModel!.reason!.isEmpty || widget.orderModel!.reason == "")
                      ? const SizedBox()
                      : Container(
                          decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 8.0),
                          margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                          padding: EdgeInsetsDirectional.only(top: height! / 40, start: width! / 20.0, end: width! / 20.0, bottom: height! / 40.0),
                          child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(
                              UiUtils.getTranslatedLabel(context, orderCancelDueToLabel),
                              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w600),
                            ),
                            (widget.orderModel!.reason!.isEmpty || widget.orderModel!.reason == "")
                                ? const SizedBox()
                                : Padding(
                                    padding: EdgeInsetsDirectional.only(
                                      top: height! / 99.0,
                                      bottom: height! / 80.0,
                                    ),
                                    child: DesignConfig.divider(),
                                  ),
                            (widget.orderModel!.reason!.isEmpty || widget.orderModel!.reason == "")
                                ? const SizedBox()
                                : Text("${widget.orderModel!.reason}",
                                    textAlign: TextAlign.start,
                                    maxLines: 2,
                                    style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76), fontSize: 14, fontWeight: FontWeight.w500)),
                          ])),
                  widget.orderModel!.isSelfPickUp == "0"
                      ? const SizedBox()
                      : widget.orderModel!.ownerNote!.isEmpty
                          ? const SizedBox()
                          : Container(
                              decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 8.0),
                              margin: EdgeInsetsDirectional.only(top: height! / 60.0),
                              padding: EdgeInsetsDirectional.only(top: height! / 80, start: width! / 20.0, end: width! / 20.0, bottom: height! / 80.0),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      UiUtils.getTranslatedLabel(context, additionalInstructionsLabel),
                                      style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w600),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.only(
                                        top: height! / 99.0,
                                        bottom: height! / 80.0,
                                      ),
                                      child: DesignConfig.divider(),
                                    ),
                                    Text(widget.orderModel!.ownerNote!,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.normal,
                                        )),
                                  ])),
                  Container(
                      margin: EdgeInsetsDirectional.only(top: height! / 60.0, bottom: height! / 40.0),
                      padding: EdgeInsetsDirectional.only(top: height! / 40, bottom: height! / 40.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              margin: EdgeInsetsDirectional.only(end: width! / 50.0),
                              alignment: Alignment.center,
                              height: 42.0,
                              width: 42,
                              decoration: DesignConfig.boxDecorationContainerBorder(
                                  Theme.of(context).colorScheme.secondary, Theme.of(context).colorScheme.secondary.withValues(alpha: 0.10), 5.0),
                              child: SvgPicture.asset(DesignConfig.setSvgPath("address"),
                                  width: 24, height: 24, colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.secondary, BlendMode.srcIn))),
                          const SizedBox(width: 5.0),
                          Expanded(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    UiUtils.getTranslatedLabel(context, deliveryLocationLabel),
                                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(widget.orderModel!.username!,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          color: Theme.of(context).colorScheme.secondary,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                          fontStyle: FontStyle.normal)),
                                  SizedBox(height: height! / 99.0),
                                  widget.orderModel!.address!.isEmpty
                                      ? const SizedBox()
                                      : Padding(
                                          padding: EdgeInsetsDirectional.only(bottom: height! / 99.0),
                                          child: Text(widget.orderModel!.address!,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.onPrimary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FontStyle.normal,
                                              )),
                                        ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.only(bottom: 2.0),
                                    child: Text(widget.orderModel!.mobile!,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                            color: Theme.of(context).colorScheme.secondary,
                                            fontSize: 12.0,
                                            decoration: TextDecoration.underline,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.normal)),
                                  ),
                                ]),
                          ),
                        ],
                      )),
                  ClipPath(
                    clipper: OrderBillClipper(),
                    child: Container(
                        decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 8.0),
                        margin: EdgeInsetsDirectional.only(top: 0.0),
                        padding: EdgeInsetsDirectional.only(top: height! / 40, start: width! / 20.0, end: width! / 20.0, bottom: height! / 40.0),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${UiUtils.getTranslatedLabel(context, orderDetailsLabel)}",
                                    textAlign: TextAlign.start,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.only(
                                  top: height! / 80.0,
                                  bottom: height! / 80.0,
                                ),
                                child: DesignConfig.divider(),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(widget.orderModel!.orderItems!.length, (i) {
                                  OrderItems data = widget.orderModel!.orderItems![i];
                                  return Container(
                                      width: width!,
                                      margin: EdgeInsetsDirectional.only(top: height! / 99.0),
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(children: [
                                              data.indicator == "1"
                                                  ? SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"), width: 15, height: 15)
                                                  : data.indicator == "2"
                                                      ? SvgPicture.asset(DesignConfig.setSvgPath("non_veg_icon"), width: 15, height: 15)
                                                      : const SizedBox(height: 15, width: 15.0),
                                              const SizedBox(width: 5.0),
                                              Text(
                                                "${data.quantity!} x ",
                                                textAlign: Directionality.of(context) == TextDirection.RTL ? TextAlign.end : TextAlign.start,
                                                style: TextStyle(
                                                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    overflow: TextOverflow.ellipsis),
                                                maxLines: 1,
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Text(
                                                  data.name!,
                                                  textAlign: Directionality.of(context) == TextDirection.RTL ? TextAlign.end : TextAlign.start,
                                                  style: TextStyle(
                                                      color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      overflow: TextOverflow.ellipsis),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text("${context.read<SystemConfigCubit>().getCurrency()}${data.price!}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      color: Theme.of(context).colorScheme.secondary, fontSize: 14, fontWeight: FontWeight.w700)),
                                            ]),
                                            widget.orderModel!.orderItems![i].attrName != ""
                                                ? Container(
                                                    margin: EdgeInsetsDirectional.only(start: width! / 16.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text("${widget.orderModel!.orderItems![i].attrName!} : ",
                                                            textAlign: TextAlign.left,
                                                            style: const TextStyle(color: lightFont, fontSize: 12, fontWeight: FontWeight.w500)),
                                                        Text(widget.orderModel!.orderItems![i].variantValues!,
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(
                                                                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
                                                                fontSize: 12,
                                                                overflow: TextOverflow.ellipsis),
                                                            maxLines: 1),
                                                      ],
                                                    ),
                                                  )
                                                : Container(),
                                            const SizedBox(height: 5.0),
                                            Wrap(
                                                spacing: 5.0,
                                                runSpacing: 2.0,
                                                direction: Axis.horizontal,
                                                children: List.generate(widget.orderModel!.orderItems![i].addOns!.length, (j) {
                                                  AddOnsDataModel addOnData = widget.orderModel!.orderItems![i].addOns![j];
                                                  return Container(
                                                    width: width!,
                                                    margin: EdgeInsetsDirectional.only(start: width! / 16.0),
                                                    child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text("${addOnData.qty!} x ",
                                                              textAlign: TextAlign.start,
                                                              style: TextStyle(
                                                                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
                                                                  fontSize: 10,
                                                                  overflow: TextOverflow.ellipsis),
                                                              maxLines: 2),
                                                          Text("${addOnData.title!}",
                                                              textAlign: TextAlign.start,
                                                              style: TextStyle(
                                                                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
                                                                  fontSize: 10,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  fontWeight: FontWeight.w600)),
                                                          Text("${context.read<SystemConfigCubit>().getCurrency()}${addOnData.price!}, ",
                                                              textAlign: TextAlign.start,
                                                              style: TextStyle(
                                                                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
                                                                  fontSize: 10,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  fontWeight: FontWeight.w600)),
                                                        ]),
                                                  );
                                                }))
                                          ]));
                                }),
                              ),
                              SizedBox(height: height! / 60.0),
                              Text(UiUtils.getTranslatedLabel(context, billDetailLabel),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                  )),
                              Padding(
                                padding: EdgeInsetsDirectional.only(top: height! / 99.0, bottom: height! / 99.0),
                                child: DesignConfig.divider(),
                              ),
                              Padding(
                                padding: EdgeInsetsDirectional.only(bottom: height! / 99.0),
                                child: Row(children: [
                                  Text(UiUtils.getTranslatedLabel(context, subTotalLabel),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          fontStyle: FontStyle.normal)),
                                  const Spacer(),
                                  Text(context.read<SystemConfigCubit>().getCurrency() + double.parse(widget.orderModel!.total!).toStringAsFixed(2),
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          color: Theme.of(context).colorScheme.secondary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          fontStyle: FontStyle.normal)),
                                ]),
                              ),
                              Row(children: [
                                Text(
                                    "${UiUtils.getTranslatedLabel(context, chargesAndTaxesLabel)} (${widget.orderModel!.totalTaxPercent!}${StringsRes.percentSymbol})",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.normal)),
                                const Spacer(),
                                Text(context.read<SystemConfigCubit>().getCurrency() + widget.orderModel!.totalTaxAmount!,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        color: Theme.of(context).colorScheme.secondary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FontStyle.normal)),
                              ]),
                              Padding(
                                padding: EdgeInsetsDirectional.only(top: height! / 99.0, bottom: height! / 99.0),
                                child: DesignConfig.divider(),
                              ),
                              Row(children: [
                                Text(UiUtils.getTranslatedLabel(context, totalLabel),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.normal)),
                                const Spacer(),
                                Text(
                                    "${context.read<SystemConfigCubit>().getCurrency()}${(double.parse(widget.orderModel!.total!) + double.parse(widget.orderModel!.totalTaxAmount!)).toStringAsFixed(2)}",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        color: Theme.of(context).colorScheme.secondary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.normal)),
                              ]),
                              Padding(
                                padding: EdgeInsetsDirectional.only(top: height! / 99.0, bottom: height! / 99.0),
                                child: DesignConfig.divider(),
                              ),
                              widget.orderModel!.promoDiscount != "0"
                                  ? Padding(
                                      padding: EdgeInsetsDirectional.only(bottom: widget.orderModel!.promoDiscount != "0" ? 0.0 : height! / 99.0),
                                      child: Row(children: [
                                        Text(StringsRes.coupons + widget.orderModel!.promoCode!,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FontStyle.normal)),
                                        const Spacer(),
                                        Text(" - ${context.read<SystemConfigCubit>().getCurrency()}${widget.orderModel!.promoDiscount!}",
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.secondary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FontStyle.normal)),
                                      ]),
                                    )
                                  : Container(),
                              widget.orderModel!.deliveryTip == "0"
                                  ? const SizedBox()
                                  : Padding(
                                      padding: EdgeInsetsDirectional.only(bottom: widget.orderModel!.deliveryTip == "0" ? 0.0 : height! / 99.0),
                                      child: Row(children: [
                                        Text(UiUtils.getTranslatedLabel(context, deliveryTipLabel),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FontStyle.normal)),
                                        const Spacer(),
                                        Text("${context.read<SystemConfigCubit>().getCurrency()}${widget.orderModel!.deliveryTip!}",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.secondary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FontStyle.normal)),
                                      ]),
                                    ),
                              widget.orderModel!.walletBalance == "0"
                                  ? const SizedBox()
                                  : Padding(
                                      padding: EdgeInsetsDirectional.only(
                                        bottom: widget.orderModel!.walletBalance == "0" ? 0.0 : height! / 99.0,
                                      ),
                                      child: Row(children: [
                                        Text(UiUtils.getTranslatedLabel(context, useWalletLabel),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FontStyle.normal)),
                                        const Spacer(),
                                        Text(
                                            " - ${context.read<SystemConfigCubit>().getCurrency()}${double.parse(widget.orderModel!.walletBalance!).toStringAsFixed(2)}",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.secondary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FontStyle.normal)),
                                      ]),
                                    ),
                              widget.orderModel!.isSelfPickUp == "1"
                                  ? const SizedBox()
                                  : Padding(
                                      padding: EdgeInsetsDirectional.only(bottom: height! / 99.0),
                                      child: Row(children: [
                                        Text(UiUtils.getTranslatedLabel(context, deliveryFeeLabel),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                fontStyle: FontStyle.normal)),
                                        const Spacer(),
                                        Text("${context.read<SystemConfigCubit>().getCurrency()}${widget.orderModel!.deliveryCharge!}",
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                color: Theme.of(context).colorScheme.secondary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                fontStyle: FontStyle.normal)),
                                      ]),
                                    ),
                              Padding(
                                padding: EdgeInsetsDirectional.only(top: height! / 99.0, bottom: height! / 99.0),
                                child: DesignConfig.divider(),
                              ),
                              Row(children: [
                                Text(UiUtils.getTranslatedLabel(context, totalPayLabel),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.normal)),
                                const Spacer(),
                                Text(
                                    "${context.read<SystemConfigCubit>().getCurrency()}${double.parse(widget.orderModel!.totalPayable!).toStringAsFixed(2)}",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        color: Theme.of(context).colorScheme.secondary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        fontStyle: FontStyle.normal)),
                              ]),
                            ])),
                  ),
                  SizedBox(height: height! / 40.0),
                ],
              ),
            )));
  }

  @override
  void dispose() {
    orderController.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  launchMap(lat, lng) async {
    var url = '';

    if (Platform.isAndroid) {
      url = "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving&dir_action=navigate";
    } else {
      url = "http://maps.apple.com/?saddr=&daddr=$lat,$lng&directionsmode=driving&dir_action=navigate";
    }
    await launchUrlString(url, mode: LaunchMode.externalApplication);
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
          : Scaffold(
              backgroundColor: Theme.of(context).colorScheme.surface,
              appBar: DesignConfig.appBar(context, width!, UiUtils.getTranslatedLabel(context, orderDetailsLabel),
                  const PreferredSize(preferredSize: Size.zero, child: SizedBox()),
                  status: false),
              body: Container(
                width: width,
                child: orderData(),
              )),
    );
  }
}


