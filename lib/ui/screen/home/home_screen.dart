import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro_single_vender_rider/app/routes.dart';
import 'package:erestro_single_vender_rider/cubit/auth/authCubit.dart';
import 'package:erestro_single_vender_rider/cubit/order/pendingOrderCubit.dart';
import 'package:erestro_single_vender_rider/cubit/order/updateOrderRequestCubit.dart';
import 'package:erestro_single_vender_rider/cubit/profileManagement/getRiderDetailCubit.dart';
import 'package:erestro_single_vender_rider/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestro_single_vender_rider/data/model/addOnsDataModel.dart';
import 'package:erestro_single_vender_rider/data/model/orderModel.dart';
import 'package:erestro_single_vender_rider/data/repositories/order/orderRepository.dart';
import 'package:erestro_single_vender_rider/ui/screen/settings/no_internet_screen.dart';
import 'package:erestro_single_vender_rider/ui/widgets/customDialog.dart';
import 'package:erestro_single_vender_rider/ui/widgets/simmer/homeSimmer.dart';
import 'package:erestro_single_vender_rider/ui/widgets/simmer/myOrderSimmer.dart';
import 'package:erestro_single_vender_rider/ui/widgets/smallButtomContainer.dart';
import 'package:erestro_single_vender_rider/utils/constants.dart';
import 'package:erestro_single_vender_rider/utils/labelKeys.dart';
import 'package:erestro_single_vender_rider/utils/notificationUtility.dart';
import 'package:erestro_single_vender_rider/utils/string.dart';
import 'package:erestro_single_vender_rider/utils/uiUtils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro_single_vender_rider/ui/styles/color.dart';
import 'package:erestro_single_vender_rider/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:erestro_single_vender_rider/utils/internetConnectivity.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  final Function? bottomStatus;
  const HomeScreen({Key? key, this.bottomStatus}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  double? width, height;
  var size;
  ScrollController orderController = ScrollController();
  bool isScrollingDown = false;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  bool riderStatusSwitch = true;
  Alignment switchControlAlignment = Alignment.centerLeft;
  var inputFormat = DateFormat('yyyy-MM-dd hh:mm:ss');
  var outputFormat = DateFormat('dd,MMMM yyyy hh:mm a');
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
    orderController.addListener(orderScrollListener);
    Future.delayed(Duration.zero, () {
      refreshList();
    });
    final pushNotificationService = NotificationUtility(context: context);
    pushNotificationService.initLocalNotification();
    pushNotificationService.setupInteractedMessage();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  Future<void> refreshList() async {
    context.read<PendingOrderCubit>().fetchPendingOrder(perPage, context.read<AuthCubit>().getId(), "");
    context.read<GetRiderDetailCubit>().getRiderDetail(context.read<AuthCubit>().getId());
  }

  orderScrollListener() {
    if (orderController.position.maxScrollExtent == orderController.offset) {
      if (context.read<PendingOrderCubit>().hasMoreData()) {
        context.read<PendingOrderCubit>().fetchMorePendingOrderData(perPage, context.read<AuthCubit>().getId(), "");
      }
    }
  }

  profileData(Size size, String? image, state) {
    return Container(
      margin: EdgeInsetsDirectional.only(top: height! / 50, end: width! / 20.0, bottom: height!/ 80.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(end: width! / 40.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              child: (state is AuthInitial || state is Unauthenticated)
                  ? DesignConfig.imageWidgets(context.read<AuthCubit>().getProfile(), 40, 40, "1")
                  : DesignConfig.imageWidgets(state.authModel.image, 40, 40, "1"),
            ),
          ),
          Expanded(
              child: (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text(UiUtils.getTranslatedLabel(context, yourProfileLabel),
                              textAlign: TextAlign.start,
                              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2.0),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "${UiUtils.getTranslatedLabel(context, loginLabel)} ",
                                  style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 16, fontWeight: FontWeight.bold),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context).pushNamed(Routes.login, arguments: {'from': 'profile'}).then((value) {});
                                    },
                                ),
                                TextSpan(
                                  text: UiUtils.getTranslatedLabel(context, loginOrSignUpToViewYourCompleteProfileLabel),
                                  style: const TextStyle(color: greayLightColor, fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )
                        ])
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${UiUtils.getTranslatedLabel(context, welcomeLabel)},",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76), fontSize: 14, fontWeight: FontWeight.w500)),
                        Text(state.authModel.username!,
                            textAlign: TextAlign.start,
                            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                      ],
                    )),
        ],
      ),
    );
  }

  Widget logInAndLogoutButton() {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return CustomDialog(
                  title: UiUtils.getTranslatedLabel(context, logoutLabel),
                  subtitle: UiUtils.getTranslatedLabel(context, areYouSureYouWantToLogoutLabel),
                  width: width!,
                  height: height!,
                  from: UiUtils.getTranslatedLabel(context, logoutLabel));
            });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(UiUtils.getTranslatedLabel(context, logoutLabel),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.error)),
          SizedBox(width: width! / 80.0),
          Icon(Icons.power_settings_new, color: Theme.of(context).colorScheme.error),
        ],
      ),
    );
  }

  Widget statasticCard(String? icon, String? title, String? total) {
    return Container(
        height: height!/6.7,
        width: width!,
        decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.primary.withValues(alpha: 0.11), 8.0),
        margin: EdgeInsetsDirectional.only(top: height! / 50, start: width! / 40.0, end: width! / 40.0),
        padding: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top: height! / 80.0, bottom: height! / 80.0),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  decoration: DesignConfig.boxDecorationContainerCardShadow(
                      Theme.of(context).colorScheme.secondary, Theme.of(context).colorScheme.secondary.withValues(alpha: 0.11), 4.0, 0, 2, 10, 0),
                  padding: EdgeInsetsDirectional.all(5.0),
                  child: SvgPicture.asset(DesignConfig.setSvgPath(icon!))),
              const SizedBox(height: 10.0),
              Text(title!,
                  style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76), fontWeight: FontWeight.w500)),
              const SizedBox(height: 4.0),
              Text(total!, style: TextStyle(fontSize: 22, color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w700)),
            ]));
  }

  Widget riderStatastic() {
    return BlocBuilder<GetRiderDetailCubit, GetRiderDetailState>(
      builder: (context, getRiderDetailState) {
        if (getRiderDetailState is GetRiderDetailFetchInProgress || getRiderDetailState is GetRiderDetailInitial) {
          return HomeSimmer(width: width!, height: height!);
        }
        if (getRiderDetailState is GetRiderDetailFetchSuccess) {
          return Container(
              margin: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0),
              width: width,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                controller: orderController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.secondary, 4.0),
                        padding: EdgeInsetsDirectional.all(16.0),
                        margin: EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0, top: height! / 80.0),
                        child: Row(
                          children: [
                            Text(UiUtils.getTranslatedLabel(context, acceptingPickUpsOffTitleLabel),
                                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
                            const Spacer(),
                            Row(
                              children: [
                                Text(
                                    getRiderDetailState.authModel.acceptOrders == "1"
                                        ? UiUtils.getTranslatedLabel(context, onLabel)
                                        : UiUtils.getTranslatedLabel(context, offLabel),
                                    style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
                                SizedBox(width: width! / 40.0),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.decelerate,
                                    width: 52,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16.0),
                                      color: getRiderDetailState.authModel.acceptOrders == "1"
                                          ? Theme.of(context).colorScheme.onSurface
                                          : Theme.of(context).colorScheme.onSurface,
                                    ),
                                    child: AnimatedAlign(
                                      duration: const Duration(milliseconds: 300),
                                      alignment: getRiderDetailState.authModel.acceptOrders == "1" ? Alignment.centerRight : Alignment.centerLeft,
                                      curve: Curves.decelerate,
                                      child: Padding(
                                        padding: EdgeInsets.all(getRiderDetailState.authModel.acceptOrders == "1" ? 2.0 : 5.0),
                                        child: getRiderDetailState.authModel.acceptOrders == "1"
                                            ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.secondary, size: 25)
                                            : Icon(Icons.cancel, color: Theme.of(context).colorScheme.onPrimary, size: 25),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialog(
                                              title: UiUtils.getTranslatedLabel(context, acceptingPickUpsOffTitleLabel),
                                              subtitle: getRiderDetailState.authModel.acceptOrders == "1"
                                                  ? UiUtils.getTranslatedLabel(context, acceptingPickUpsOffSubTitleLabel)
                                                  : UiUtils.getTranslatedLabel(context, acceptingPickUpsOffSubTitleOnLabel),
                                              width: width!,
                                              height: height!,
                                              from: UiUtils.getTranslatedLabel(context, acceptingPickUpsOffTitleLabel));
                                        });
                                  },
                                )
                              ],
                            ),
                          ],
                        )),
                    Row(children: [
                      Expanded(
                          child: statasticCard("total_earning", UiUtils.getTranslatedLabel(context, totalEarningLabel),
                              "${context.read<SystemConfigCubit>().getCurrency()}${double.parse(getRiderDetailState.authModel.balance!).toStringAsFixed(2)}")),
                      Expanded(
                          child: statasticCard("complete_delivery", UiUtils.getTranslatedLabel(context, completeDeliveryLabel),
                              "${getRiderDetailState.authModel.completeDelivery}")),
                    ]),
                    Row(children: [
                      Expanded(
                          child: statasticCard("cancel_delivery", UiUtils.getTranslatedLabel(context, cancelDeliveryLabel),
                              "${getRiderDetailState.authModel.cancelDelivery}")),
                      Expanded(
                          child: statasticCard("pending_delivery", UiUtils.getTranslatedLabel(context, pendingDeliveryLabel),
                              "${getRiderDetailState.authModel.pendingDeivery}")),
                    ]),
                    BlocBuilder<PendingOrderCubit, PendingOrderState>(
                      builder: (context, state) {
                        if (state is PendingOrderSuccess) {
                          return Padding(
                            padding: EdgeInsetsDirectional.only(top: height! / 40.0, start: width! / 40.0, end: width! / 40.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.primary, 2),
                                    height: height! / 40.0,
                                    width: width! / 80.0),
                                SizedBox(width: width! / 80.0),
                                Text("${state.total.toString()} ${UiUtils.getTranslatedLabel(context, deliveryFoundLabel)}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                    myOrder()
                  ],
                ),
              ));
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  PreferredSize appBarData() {
    return PreferredSize(
      preferredSize: Size.fromHeight(height! / 11.0),
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.1),
            offset: Offset(0, 2.0),
            blurRadius: 12.0,
          )
        ]),
        child: AppBar(
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.secondary,
          ),
          backgroundColor: Theme.of(context).colorScheme.onSurface,
          shadowColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: BlocBuilder<AuthCubit, AuthState>(
              bloc: context.read<AuthCubit>(),
              builder: (context, state) {
                if (state is Authenticated) {
                  return profileData(size, state.authModel.image!, state);
                }
                return profileData(size, "", state);
              }),
          actions: [
            Padding(
              padding: EdgeInsetsDirectional.only(top: height! / 50, end: width! / 20.0),
              child: logInAndLogoutButton(),
            )
          ],
        ),
      ),
    );
  }

  Widget myOrder() {
    return BlocConsumer<PendingOrderCubit, PendingOrderState>(
        bloc: context.read<PendingOrderCubit>(),
        listener: (context, state) {
        },
        builder: (context, state) {
          if (state is PendingOrderProgress || state is PendingOrderInitial) {
            return MyOrderSimmer(length: 5, width: width!, height: height!);
          }
          if (state is PendingOrderFailure) {
            return (state.errorMessage.toString() == "Order Does Not Exists" || state.errorStatusCode.toString() == tockenExpireCode)
                ? const SizedBox.shrink()
                : Center(
                    child: Text(
                    state.errorMessage.toString(),
                    textAlign: TextAlign.center,
                  ));
          }
          final orderList = (state as PendingOrderSuccess).pendingOrderList;
          final hasMore = state.hasMore;
          return orderList.isEmpty
              ? const SizedBox.shrink()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orderList.length,
                  itemBuilder: (BuildContext context, index) {
                    var inputDate = inputFormat.parse(orderList[index].dateAdded.toString());
                    var outputDate = outputFormat.format(inputDate);
                    return hasMore && index == (orderList.length - 1)
                        ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                        : Builder(builder: (context) {
                            return BlocProvider(
                                create: (context) => UpdateOrderRequestCubit(OrderRepository()),
                                child: Builder(builder: (context) {
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
                                          start: width! / 40.0,
                                          end: width! / 40.0,
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
                                                  Expanded(
                                                    child: Text(
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
                                            ),
                                            Padding(
                                              padding: EdgeInsetsDirectional.only(
                                                top: height! / 80.0,
                                                bottom: height! / 80.0,
                                              ),
                                              child: DesignConfig.divider(),
                                            ),
                                            Column(
                                                children: List.generate(
                                                    orderList[index].orderItems!.length > 2 ? 2 : orderList[index].orderItems!.length, (i) {
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
                                                              textAlign: Directionality.of(context) == ui.TextDirection.rtl
                                                                  ? TextAlign.right
                                                                  : TextAlign.left,
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
                                                                      style: const TextStyle(
                                                                          color: lightFont, fontSize: 10, fontWeight: FontWeight.w500)),
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
                                                                style: const TextStyle(
                                                                    color: lightFontColor, fontSize: 10, overflow: TextOverflow.ellipsis),
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
                                                      padding: EdgeInsetsDirectional.only(
                                                          start: width! / 13.0, bottom: height! / 80.0, top: height! / 99.0),
                                                      child: Text(
                                                          "${orderList[index].orderItems!.length - 2} ${StringsRes.pluseSymbol} ${UiUtils.getTranslatedLabel(context, moreLabel)}",
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w600,
                                                              color: Theme.of(context).colorScheme.secondary)),
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
                                                  child: Text(context.read<SystemConfigCubit>().getCurrency() + orderList[index].totalPayable!,
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
                                                      child: orderList[index].profile != ""
                                                          ? DesignConfig.imageWidgets(orderList[index].profile, 40, 40, "1")
                                                          : DesignConfig.imageWidgets('', 40, 40, "1"),
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
                                                              color: Theme.of(context).colorScheme.onPrimary,
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w600)),
                                                      Text(orderList[index].mobile!,
                                                          textAlign: TextAlign.start,
                                                          style: TextStyle(
                                                              color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w500)),
                                                    ],
                                                  )),
                                                  GestureDetector(
                                                      onTap: () async {
                                                        final Uri launchUri = Uri(
                                                          scheme: 'tel',
                                                          path: orderList[index].mobile,
                                                        );
                                                        await launchUrl(launchUri);
                                                      },
                                                      child: Container(
                                                          padding: EdgeInsetsDirectional.all(5.0),
                                                          decoration:
                                                              DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.secondary, 100),
                                                          child: Icon(Icons.phone, color: Theme.of(context).colorScheme.onSurface)))
                                                ],
                                              ),
                                            ),
                                            BlocConsumer<UpdateOrderRequestCubit, UpdateOrderRequestState>(
                                              listener: (context, updateOrderRequestState) {
                                                if (updateOrderRequestState is UpdateOrderRequestSuccess) {
                                                  context.read<PendingOrderCubit>().updateOrderRequest(orderList[index]);
                                                }
                                              },
                                              builder: (context, updateOrderRequestState) {
                                                return Row(children: [
                                                  Expanded(
                                                    child: SmallButtonContainer(
                                                      color: Theme.of(context).colorScheme.surface,
                                                      height: height,
                                                      width: width,
                                                      text: UiUtils.getTranslatedLabel(context, rejectOrderLabel),
                                                      start: width! / 40.0,
                                                      end: width! / 80.0,
                                                      bottom: 0,
                                                      top: height! / 80.0,
                                                      status: false,
                                                      borderColor: (updateOrderRequestState is UpdateOrderRequestProgress)
                                                          ? commentBoxBorderColor
                                                          : Theme.of(context).colorScheme.onPrimary,
                                                      textColor: (updateOrderRequestState is UpdateOrderRequestProgress)
                                                          ? commentBoxBorderColor
                                                          : Theme.of(context).colorScheme.onPrimary,
                                                      radius: 5.0,
                                                      onTap: () {
                                                        if (updateOrderRequestState is UpdateOrderRequestProgress) {
                                                        } else {
                                                          context.read<UpdateOrderRequestCubit>().updateOrderRequest(
                                                              riderId: context.read<AuthCubit>().getId(),
                                                              orderId: orderList[index].id,
                                                              acceptOrder: "0");
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: SmallButtonContainer(
                                                      color: (updateOrderRequestState is UpdateOrderRequestProgress)
                                                          ? Theme.of(context).colorScheme.surface
                                                          : Theme.of(context).colorScheme.primary,
                                                      height: height,
                                                      width: width,
                                                      text: UiUtils.getTranslatedLabel(context, acceptOrderLabel),
                                                      start: width! / 80.0,
                                                      end: width! / 40.0,
                                                      bottom: 0,
                                                      top: height! / 80.0,
                                                      status: false,
                                                      borderColor: (updateOrderRequestState is UpdateOrderRequestProgress)
                                                          ? commentBoxBorderColor
                                                          : Theme.of(context).colorScheme.primary,
                                                      textColor: (updateOrderRequestState is UpdateOrderRequestProgress)
                                                          ? commentBoxBorderColor
                                                          : Theme.of(context).colorScheme.onPrimary,
                                                      radius: 5.0,
                                                      onTap: () {
                                                        if (updateOrderRequestState is UpdateOrderRequestProgress) {
                                                        } else {
                                                          context.read<UpdateOrderRequestCubit>().updateOrderRequest(
                                                              riderId: context.read<AuthCubit>().getId(),
                                                              orderId: orderList[index].id,
                                                              acceptOrder: "1");
                                                        }
                                                      },
                                                    ),
                                                  )
                                                ]);
                                              },
                                            )
                                          ],
                                        )),
                                  );
                                }));
                          });
                  });
        });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
      child: _connectionStatus == connectivityCheck
          ? const NoInternetScreen()
          : Scaffold(
              appBar: appBarData(),
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              body: RefreshIndicator(
                onRefresh: refreshList,
                color: Theme.of(context).colorScheme.primary,
                child: riderStatastic(),
              ),
            ),
    );
  }
}
