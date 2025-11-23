import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro_single_vender_rider/cubit/auth/authCubit.dart';
import 'package:erestro_single_vender_rider/cubit/order/pendingOrderCubit.dart';
import 'package:erestro_single_vender_rider/cubit/profileManagement/getRiderDetailCubit.dart';
import 'package:erestro_single_vender_rider/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestro_single_vender_rider/data/model/orderTypeModel.dart';
import 'package:erestro_single_vender_rider/ui/screen/auth/login_screen.dart';
import 'package:erestro_single_vender_rider/ui/screen/home/home_screen.dart';
import 'package:erestro_single_vender_rider/ui/screen/order/my_order_screen.dart';
import 'package:erestro_single_vender_rider/ui/screen/order/my_order_view_screen.dart';
import 'package:erestro_single_vender_rider/ui/screen/settings/account_screen.dart';
import 'package:erestro_single_vender_rider/ui/screen/settings/maintenance_screen.dart';
import 'package:erestro_single_vender_rider/ui/screen/settings/no_internet_screen.dart';
import 'package:erestro_single_vender_rider/ui/screen/transaction/cash_collection_screen.dart';
import 'package:erestro_single_vender_rider/ui/screen/transaction/wallet_screen.dart';
import 'package:erestro_single_vender_rider/ui/styles/design.dart';
import 'package:erestro_single_vender_rider/ui/widgets/forceUpdateDialog.dart';
import 'package:erestro_single_vender_rider/utils/apiBodyParameterLabels.dart';
import 'package:erestro_single_vender_rider/utils/constants.dart';
import 'package:erestro_single_vender_rider/utils/internetConnectivity.dart';
import 'package:erestro_single_vender_rider/utils/labelKeys.dart';
import 'package:erestro_single_vender_rider/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
  static Route<MainScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MainScreen(),
    );
  }
}

StreamController? streamController;
List<OrderTypeModel> orderTypeList = [];

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int? selectedIndex = 0;
  late List<Widget> fragments;
  double? width, height;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  DateTime? currentBackPressTime;
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

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

    setBottomClass();
    setStreamConfig();
    isMaintenance();
    userStatus();
    //Check for Force Update
    _initPackageInfo().then((value) {
      Future.delayed(Duration.zero, () {
        forceUpdateDialog();
      });
    });
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  isMaintenance() {
    if (context.read<SystemConfigCubit>().isAppMaintenance() == "1") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const MaintenanceScreen(),
        ),
      );
    } else {}
  }

  userStatus() {
    if (context.read<AuthCubit>().getActive() == "0") {
      Future.delayed(Duration.zero, () {
        userActiveStatus(context);
      });
    } else {}
  }

  forceUpdateDialog() {
    if (context.read<SystemConfigCubit>().isForceUpdateEnable() == "1") {
      if (Platform.isIOS) {
        if (context.read<SystemConfigCubit>().getCurrentVersionIos() != _packageInfo.version) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return ForceUpdateDialog(width: width!, height: height!);
              });
        }
      } else {
        print("forceUpdate:${context.read<SystemConfigCubit>().getCurrentVersionAndroid()}--${_packageInfo.version}");
        if (context.read<SystemConfigCubit>().getCurrentVersionAndroid() != _packageInfo.version) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return ForceUpdateDialog(width: width!, height: height!);
              });
        }
      }
    } else {}
  }

  Future userActiveStatus(BuildContext context) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(UiUtils.getTranslatedLabel(context, userNotActiveLabel),
              textAlign: TextAlign.start,
              maxLines: 2,
              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
          actions: [
            TextButton(
              style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(Colors.transparent),
              ),
              child: Text(UiUtils.getTranslatedLabel(context, okLabel),
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w500)),
              onPressed: () {
                context.read<AuthCubit>().signOut();
                Navigator.of(context)
                    .pushAndRemoveUntil(CupertinoPageRoute(builder: (context) => const LoginScreen()), (Route<dynamic> route) => false);
              },
            )
          ],
        );
      },
    );
  }

  setBottomClass() {
    orderTypeList = [
      OrderTypeModel(name: allLabel, type: ""),
      OrderTypeModel(name: awaitingLbLabel, type: waitingKey),
      OrderTypeModel(name: confirmedLbLabel, type: confirmedKey),
      OrderTypeModel(name: preparingLbLabel, type: preparingKey),
      OrderTypeModel(name: readyForPickupLbLabel, type: readyForPickupKey),
      OrderTypeModel(name: outForDeliveryLbLabel, type: outForDeliveryKey),
      OrderTypeModel(name: deliveredLabel, type: deliveredKey),
      OrderTypeModel(name: cancelledsLabel, type: cancelledKey),
    ];
    fragments = [HomeScreen(), MyOrderScreen(), WalletScreen(), CashCollectionScreen(), AccountScreen()];
  }

  setStreamConfig() {
    streamController = StreamController<String>.broadcast();
    streamController!.stream.listen((data) {
      print("streamNotification recive::::::$data");
      if (data == "1") {
        globalKey?.clear();
        globalKey = List.generate(orderTypeList.length, (index) => GlobalObjectKey(index));
        List.generate(orderTypeList.length, (index) => globalKey?[index].currentState?.refreshList());
        context.read<PendingOrderCubit>().fetchPendingOrder(perPage, context.read<AuthCubit>().getId(), "");
        context.read<GetRiderDetailCubit>().getRiderDetail(context.read<AuthCubit>().getId());
      }
    });
  }

  void updateTabSelection(int index, String buttonText) {
    setState(() {
      selectedIndex = index;
    });
  }

  bottomState(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return _connectionStatus == connectivityCheck
        ? const NoInternetScreen()
        : PopScope(
            canPop: selectedIndex != 0 ? false : true,
            onPopInvokedWithResult: (value, dynamic) {
              
              if (selectedIndex != 0) {
                setState(() {
                  selectedIndex = 0;
                });
              }
            },
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarIconBrightness: Platform.isIOS ? Brightness.light : Brightness.dark,
              ),
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                extendBody: true,
                backgroundColor: Colors.transparent,
                body: IndexedStack(
                  index: selectedIndex!,
                  children: fragments,
                ),
                
                bottomNavigationBar: BottomAppBar(
                  
                  color: Theme.of(context).colorScheme.onSurface,
                  shape: CircularNotchedRectangle(), 
                  notchMargin: 10,
                  height: Directionality.of(context) == TextDirection.ltr
                      ? height! / 14
                      : height! / 13, 
                  child: Row(
                    
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      DesignConfig.bottomBarTextButton(context, selectedIndex!, 0, () {
                        bottomState(0);
                      }, "home_active", "home_inactive", UiUtils.getTranslatedLabel(context, homeLabel)),
                      DesignConfig.bottomBarTextButton(context, selectedIndex!, 1, () {
                        bottomState(1);
                      }, "mydelivery_active", "mydelivery_inactive", UiUtils.getTranslatedLabel(context, myDeliveryLabel)),
                      DesignConfig.bottomBarTextButton(context, selectedIndex!, 2, () {
                        bottomState(2);
                      }, "wallet_active", "wallet_inactive", UiUtils.getTranslatedLabel(context, walletLabel)),
                      DesignConfig.bottomBarTextButton(context, selectedIndex!, 3, () {
                        bottomState(3);
                      }, "cash_active", "cash_inactive", UiUtils.getTranslatedLabel(context, cashLabel)),
                      DesignConfig.bottomBarTextButton(context, selectedIndex!, 4, () {
                        bottomState(4);
                      }, "profile_active", "profile_inactive", UiUtils.getTranslatedLabel(context, profileLabel)),
                    ],
                  ),
                ),
              ),
            ));
  }
}
