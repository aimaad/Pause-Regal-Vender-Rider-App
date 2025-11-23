import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro_single_vender_rider/cubit/order/orderCubit.dart';
import 'package:erestro_single_vender_rider/ui/screen/main/main_screen.dart';
import 'package:erestro_single_vender_rider/ui/screen/order/my_order_view_screen.dart';
import 'package:erestro_single_vender_rider/ui/screen/settings/no_internet_screen.dart';
import 'package:erestro_single_vender_rider/utils/constants.dart';
import 'package:erestro_single_vender_rider/utils/labelKeys.dart';
import 'package:erestro_single_vender_rider/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro_single_vender_rider/ui/styles/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:erestro_single_vender_rider/utils/internetConnectivity.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({Key? key}) : super(key: key);

  @override
  MyOrderScreenState createState() => MyOrderScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<OrderCubit>(
              create: (_) => OrderCubit(),
              child: const MyOrderScreen(),
            ));
  }
}

class MyOrderScreenState extends State<MyOrderScreen> with TickerProviderStateMixin {
  double? width, height;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  int? _selectedIndex = 0;
  TabController? tabController;
  String? orderStatus = "";
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

    if (globalKey == null) {
      globalKey = List.generate(orderTypeList.length, (index) => GlobalObjectKey(index));
    }
    tabController = TabController(length: orderTypeList.length, vsync: this, initialIndex: _selectedIndex!);
    tabController!.addListener(() {
      setState(() {
        _selectedIndex = tabController!.index;
        orderStatus = orderTypeList[_selectedIndex!].type;
      });
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
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
              length: orderTypeList.length,
              child: Scaffold(
                backgroundColor: Theme.of(context).colorScheme.surface,
                appBar: DesignConfig.appBarWihoutBackbutton(
                    context,
                    width!,
                    UiUtils.getTranslatedLabel(context, myDeliveryLabel),
                    PreferredSize(
                        preferredSize: Size.fromHeight(kToolbarHeight),
                        child: TabBar(
                          indicatorWeight: 2.0,
                          onTap: (int val) {
                            setState(() {
                              _selectedIndex = val;
                              orderStatus = orderTypeList[_selectedIndex!].type;
                            });
                          },
                          physics: const AlwaysScrollableScrollPhysics(),
                          isScrollable: true,
                          labelColor: Theme.of(context).colorScheme.onPrimary,
                          unselectedLabelColor: Theme.of(context).colorScheme.onPrimary,
                          indicatorColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          indicatorSize: TabBarIndicatorSize.label,
                          controller: tabController,
                          indicatorPadding: EdgeInsetsDirectional.zero,
                          labelPadding: EdgeInsetsDirectional.zero,
                          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                          tabs: orderTypeList
                              .map((t) => Container(
                                    height: 35,
                                    alignment: Alignment.center,
                                    margin: EdgeInsetsDirectional.only(
                                        start: width! / 40.0, end: width! / 40.0, top: height! / 80.0, bottom: height! / 80.0),
                                    padding: const EdgeInsetsDirectional.only(
                                      start: 20,
                                      end: 20,
                                    ),
                                    decoration: orderStatus == t.type
                                        ? DesignConfig.boxDecorationContainerBorder(
                                            Theme.of(context).colorScheme.onPrimary, Theme.of(context).colorScheme.primary, 100.0)
                                        : DesignConfig.boxDecorationContainerBorder(
                                            Theme.of(context).colorScheme.onPrimary, Theme.of(context).colorScheme.onSurface, 100.0),
                                    child: Tab(
                                      text: UiUtils.getTranslatedLabel(context, t.name!),
                                    ),
                                  ))
                              .toList(),
                        )),
                    preferSize: height! / 8.0),
                body: TabBarView(
                  controller: tabController,
                  children: List<Widget>.generate(orderTypeList.length, (int index) {
                    return BlocProvider(
                      create: (context) => OrderCubit(),
                      child: MyOrderViewScreen(orderStatus: orderTypeList[index].type!, key: globalKey![index]),
                    );
                  }),
                ),
              ),
            ),
    );
  }
}
