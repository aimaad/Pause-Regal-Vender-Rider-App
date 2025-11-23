import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro_single_vender_rider/cubit/auth/authCubit.dart';
import 'package:erestro_single_vender_rider/cubit/profileManagement/getRiderDetailCubit.dart';
import 'package:erestro_single_vender_rider/cubit/transaction/riderCashCollectionCubit.dart';
import 'package:erestro_single_vender_rider/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestro_single_vender_rider/cubit/transaction/riderCashCubit.dart';
import 'package:erestro_single_vender_rider/ui/screen/settings/no_internet_screen.dart';
import 'package:erestro_single_vender_rider/ui/widgets/riderCashAndCashCollectionContainer.dart';
import 'package:erestro_single_vender_rider/ui/widgets/simmer/myOrderSimmer.dart';
import 'package:erestro_single_vender_rider/ui/widgets/noDataContainer.dart';
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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:erestro_single_vender_rider/utils/internetConnectivity.dart';
import 'dart:ui' as ui;

class CashCollectionScreen extends StatefulWidget {
  const CashCollectionScreen({Key? key}) : super(key: key);

  @override
  CashCollectionScreenState createState() => CashCollectionScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(providers: [
              BlocProvider<RiderCashCollectionCubit>(
                create: (_) => RiderCashCollectionCubit(),
              ),
              BlocProvider<RiderCashCubit>(
                create: (_) => RiderCashCubit(),
              ),
            ], child: const CashCollectionScreen()));
  }
}

class CashCollectionScreenState extends State<CashCollectionScreen> with SingleTickerProviderStateMixin {
  double? width, height;
  ScrollController riderCashCollectionController = ScrollController();
  ScrollController riderCashController = ScrollController();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  TextEditingController? searchController = TextEditingController();
  StateSetter? dialogState;
  bool isProgress = false;
  int offset = 0;
  int total = 0;
  bool isLoading = true, payTesting = true;
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  String? walletAmount, filter = "0";
  bool enableList = false;
  int? filterIndex = 0, sortIndex = 0;
  StateSetter? filterBottomState;
  List<String> transactionType = [StringsRes.riderCash, StringsRes.riderCashCollection];
  String? sort = "DESC";
  String searchText = '';
  TabController? tabController;
  Icon actionIcon = new Icon(Icons.search);
  Widget appBarTitle = new Text(riderCashCollectionKey);

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
    riderCashCollectionController.addListener(scrollRiderCashCollectionListener);
    riderCashController.addListener(scrollRiderCashListener);
    Future.delayed(Duration.zero, () {
      riderCashApi();
      riderCashCollectionApi();
      setState(() {
        actionIcon = Icon(
          Icons.search,
          color: Theme.of(context).colorScheme.onPrimary,
        );
        appBarTitle = Text(UiUtils.getTranslatedLabel(context, cashCollectionLabel),
            textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 18, fontWeight: FontWeight.w500));
      });
    });
    tabController = TabController(length: 2, vsync: this);
    searchController!.addListener(() {
      String sText = searchController!.text;

      if (searchText != sText) {
        searchText = sText;

        Future.delayed(Duration.zero, () {
          riderCashApi();
          riderCashCollectionApi();
        });
      }
    });

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.initState();
  }

  scrollRiderCashCollectionListener() {
    if (riderCashCollectionController.position.maxScrollExtent == riderCashCollectionController.offset) {
      if (context.read<RiderCashCollectionCubit>().hasMoreData()) {
        context
            .read<RiderCashCollectionCubit>()
            .fetchMoreRiderCashCollectionData(perPage, context.read<AuthCubit>().getId(), sort, searchController!.text.trim());
      }
    }
  }

  scrollRiderCashListener() {
    if (riderCashController.position.maxScrollExtent == riderCashController.offset) {
      if (context.read<RiderCashCubit>().hasMoreData()) {
        context.read<RiderCashCubit>().fetchMoreRiderCashData(perPage, context.read<AuthCubit>().getId(), sort, searchController!.text.trim());
      }
    }
  }

  @override
  void dispose() {
    riderCashCollectionController.dispose();
    riderCashController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  onChanged(int position) {
    setState(() {
      filterIndex = position;
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
                    transactionType[filterIndex!],
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
                          riderCashApi();
                        } else {
                          riderCashCollectionApi();
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

  Widget riderCash() {
    return BlocConsumer<RiderCashCubit, RiderCashState>(
        bloc: context.read<RiderCashCubit>(),
        listener: (context, state) {
          
        },
        builder: (context, state) {
          if (state is RiderCashProgress || state is RiderCashInitial) {
            return MyOrderSimmer(length: 5, width: width, height: height);
          }
          if (state is RiderCashFailure) {
            return SizedBox(height: height! / 1.90, child: onCashFoundData());
          }
          final riderCashList = (state as RiderCashSuccess).riderCashList;
          final hasMore = state.hasMore;
          return riderCashList.isEmpty
              ? SizedBox(height: height! / 1.90, child: onCashFoundData())
              : ListView.builder(
                  shrinkWrap: true,
                  controller: riderCashController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: riderCashList.length,
                  itemBuilder: (BuildContext context, index) {
                    return hasMore && index == (riderCashList.length - 1)
                        ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                        : RiderCashAndCashCollectionContainer(cashCollectionModel: riderCashList[index], height: height, width: width, index: index);
                  });
        });
  }

  Widget onCashFoundData() {
    return NoDataContainer(
        image: "wallet",
        title: UiUtils.getTranslatedLabel(context, noCashFoundLabel),
        subTitle: UiUtils.getTranslatedLabel(context, noCashFoundSubTitleLabel),
        width: width!,
        height: height!);
  }

  Widget onCashCollectionFoundData() {
    return NoDataContainer(
        image: "wallet",
        title: UiUtils.getTranslatedLabel(context, noCashCollectionFoundLabel),
        subTitle: UiUtils.getTranslatedLabel(context, noCashCollectionFoundSubTitleLabel),
        width: width!,
        height: height!);
  }

  Widget riderCashCollection() {
    return BlocConsumer<RiderCashCollectionCubit, RiderCashCollectionState>(
        bloc: context.read<RiderCashCollectionCubit>(),
        listener: (context, state) {
        },
        builder: (context, state) {
          if (state is RiderCashCollectionProgress || state is RiderCashCollectionInitial) {
            return MyOrderSimmer(length: 5, width: width, height: height);
          }
          if (state is RiderCashCollectionFailure) {
            return SizedBox(height: height! / 1.90, child: onCashCollectionFoundData());
          }
          final riderCashCollectionList = (state as RiderCashCollectionSuccess).riderCashCollectionList;
          final hasMore = state.hasMore;
          return riderCashCollectionList.isEmpty
              ? SizedBox(height: height! / 1.90, child: onCashCollectionFoundData())
              : ListView.builder(
                  shrinkWrap: true,
                  controller: riderCashCollectionController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: riderCashCollectionList.length,
                  itemBuilder: (BuildContext context, index) {
                    return hasMore && index == (riderCashCollectionList.length - 1)
                        ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
                        : RiderCashAndCashCollectionContainer(
                            cashCollectionModel: riderCashCollectionList[index], height: height, width: width, index: index);
                  });
        });
  }

  Widget searchBar() {
    return TextField(
      controller: searchController,
      cursorColor: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: UiUtils.getTranslatedLabel(context, findOrderLabel),
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
        ),
      ),
      keyboardType: TextInputType.text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  sortBottomSheet() {
    showModalBottomSheet(
        useSafeArea: true,
        isDismissible: true,
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        shape: DesignConfig.setRoundedBorderCard(0.0, 0.0, 16.0, 16.0),
        isScrollControlled: true,
        enableDrag: true,
        showDragHandle: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState1) {
            filterBottomState = setState1;
            return Container(
              padding: EdgeInsetsDirectional.only(bottom: MediaQuery.of(context).viewInsets.bottom, start: width! / 20.0, end: width! / 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                            unselectedWidgetColor: Theme.of(context).colorScheme.secondary, disabledColor: Theme.of(context).colorScheme.secondary),
                        child: RadioListTile(
                          controlAffinity: ListTileControlAffinity.trailing,
                          activeColor: Theme.of(context).colorScheme.primary,
                          title: Text(
                            UiUtils.getTranslatedLabel(context, ascendingLabel),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal),
                          ),
                          value: 0,
                          groupValue: sortIndex,
                          contentPadding: EdgeInsets.all(5.0),
                          dense: true,
                          visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                          onChanged: (value) {
                            setState(() {
                              filterBottomState!(() {
                                sort = "ASC";
                              });
                            });
                          },
                        ),
                      ),
                      Theme(
                        data: Theme.of(context).copyWith(
                          unselectedWidgetColor: Theme.of(context).colorScheme.secondary,
                          disabledColor: Theme.of(context).colorScheme.secondary,
                        ),
                        child: RadioListTile(
                          controlAffinity: ListTileControlAffinity.trailing,
                          activeColor: Theme.of(context).colorScheme.primary,
                          title: Text(
                            UiUtils.getTranslatedLabel(context, decendingLabel),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal),
                          ),
                          value: 1,
                          groupValue: sortIndex,
                          contentPadding: EdgeInsets.all(5.0),
                          dense: true,
                          visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                          onChanged: (value) {
                            setState(() {
                              filterBottomState!(() {
                                sort = "DESC";
                              });
                            });
                          },
                        ),
                      ),
                      SizedBox(height: height! / 40.0),
                    ]),
                  ),
                ],
              ),
            );
          });
        });
  }

  filterBottomSheet() {
    showModalBottomSheet(
        useSafeArea: true,
        isDismissible: true,
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        shape: DesignConfig.setRoundedBorderCard(0.0, 0.0, 16.0, 16.0),
        isScrollControlled: true,
        enableDrag: true,
        showDragHandle: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState1) {
            filterBottomState = setState1;
            return Container(
              padding: EdgeInsetsDirectional.only(bottom: MediaQuery.of(context).viewInsets.bottom, start: width! / 20.0, end: width! / 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                            unselectedWidgetColor: Theme.of(context).colorScheme.secondary, disabledColor: Theme.of(context).colorScheme.secondary),
                        child: RadioListTile(
                          controlAffinity: ListTileControlAffinity.trailing,
                          activeColor: Theme.of(context).colorScheme.primary,
                          title: Text(
                            UiUtils.getTranslatedLabel(context, riderCashLabel),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal),
                          ),
                          value: 0,
                          groupValue: filterIndex,
                          contentPadding: EdgeInsets.all(5.0),
                          dense: true,
                          visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                          onChanged: (value) {
                            setState(() {
                              filterBottomState!(() {
                                filter = "0";
                                filterIndex = 0;
                              });
                            });
                            riderCashApi();
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Theme(
                        data: Theme.of(context).copyWith(
                          unselectedWidgetColor: Theme.of(context).colorScheme.secondary,
                          disabledColor: Theme.of(context).colorScheme.secondary,
                        ),
                        child: RadioListTile(
                          controlAffinity: ListTileControlAffinity.trailing,
                          activeColor: Theme.of(context).colorScheme.primary,
                          title: Text(
                            UiUtils.getTranslatedLabel(context, riderCashCollectionLabel),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.normal),
                          ),
                          value: 1,
                          groupValue: filterIndex,
                          contentPadding: EdgeInsets.all(5.0),
                          dense: true,
                          visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                          onChanged: (value) {
                            setState(() {
                              filterBottomState!(() {
                                filter = "1";
                                filterIndex = 1;
                              });
                            });
                            riderCashCollectionApi();
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      SizedBox(height: height! / 40.0),
                    ]),
                  ),
                ],
              ),
            );
          });
        });
  }

  Future<void> refreshList() async {
    riderCashApi();
    riderCashCollectionApi();
    context.read<SystemConfigCubit>().getSystemConfig();
  }

  riderCashApi() {
    context.read<RiderCashCubit>().fetchRiderCash(perPage, context.read<AuthCubit>().getId(), sort, searchText);
  }

  riderCashCollectionApi() {
    context.read<RiderCashCollectionCubit>().fetchRiderCashCollection(perPage, context.read<AuthCubit>().getId(), sort, searchText);
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
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(kToolbarHeight),
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
                          title: this.actionIcon.icon == Icons.search
                              ? Text(UiUtils.getTranslatedLabel(context, cashCollectionLabel),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 18, fontWeight: FontWeight.w500))
                              : appBarTitle,
                          actions: [
                            new IconButton(
                              icon: actionIcon,
                              onPressed: () {
                                setState(() {
                                  if (this.actionIcon.icon == Icons.search) {
                                    this.actionIcon = new Icon(
                                      Icons.close,
                                      color: Theme.of(context).colorScheme.onPrimary,
                                    );
                                    this.appBarTitle = searchBar();
                                  } else {
                                    this.actionIcon = new Icon(
                                      Icons.search,
                                      color: Theme.of(context).colorScheme.onPrimary,
                                    );
                                    this.appBarTitle = Text(UiUtils.getTranslatedLabel(context, cashCollectionLabel),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 18, fontWeight: FontWeight.w500));
                                  }
                                  if (this.actionIcon.icon == Icons.close) {
                                    searchController!.clear();
                                    searchText = searchController!.text;
                                    if (filterIndex == 0) {
                                      riderCashApi();
                                    } else {
                                      riderCashCollectionApi();
                                    }
                                  }
                                });
                              },
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (sortIndex == 0) {
                                    sortIndex = 1;
                                    sort = "ASC";
                                  } else {
                                    sortIndex = 0;
                                    sort = "DESC";
                                  }
                                });
                                if (filterIndex == 0) {
                                  riderCashApi();
                                } else {
                                  riderCashCollectionApi();
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsetsDirectional.only(start: 20, end: 20),
                                child: SvgPicture.asset(DesignConfig.setSvgPath(sortIndex == 0 ? "sort_asc" : "sort_desc"),
                                    colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn), fit: BoxFit.scaleDown),
                              ),
                            ),
                          ]),
                    ),
                  ),
                  body: Container(
                    margin: EdgeInsetsDirectional.only(top: height! / 90.0),
                    width: width,
                    child: BlocListener<SystemConfigCubit, SystemConfigState>(
                      bloc: context.read<SystemConfigCubit>(),
                      listener: (context, state) {
                        if (state is SystemConfigFetchSuccess) {}
                        if (state is SystemConfigFetchFailure) {
                          print(state.errorCode);
                        }
                      },
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsetsDirectional.only(start: 0, end: 0, top: height! / 80.0, bottom: 0),
                              decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 4.0),
                              child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Stack(
                                  children: [
                                    Container(
                                        width: width,
                                        decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.secondary, 10.0),
                                        margin: EdgeInsetsDirectional.only(start: width! / 20.0, end: width! / 20.0),
                                        padding: EdgeInsetsDirectional.only(
                                            top: height! / 40.0, bottom: height! / 40.0, start: width! / 20.0, end: width! / 20.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              " ${UiUtils.getTranslatedLabel(context, totalAmountLabel)}",
                                              style: const TextStyle(
                                                  color: Colors.white, fontWeight: FontWeight.w400, fontStyle: FontStyle.normal, fontSize: 14.0),
                                            ),
                                            const SizedBox(height: 5.0),
                                            BlocBuilder<GetRiderDetailCubit, GetRiderDetailState>(
                                                bloc: context.read<GetRiderDetailCubit>(),
                                                builder: (context, state) {
                                                  if (state is GetRiderDetailFetchSuccess) {
                                                    return Text(
                                                      "${context.read<SystemConfigCubit>().getCurrency()}${double.parse(state.authModel.cashReceived.toString()).toStringAsFixed(2)}", 
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w600,
                                                          fontStyle: FontStyle.normal,
                                                          fontSize: 20.0),
                                                    );
                                                  } else {
                                                    return Text(
                                                      "${context.read<SystemConfigCubit>().getCurrency()}${double.parse(context.read<GetRiderDetailCubit>().getReciveCash()).toStringAsFixed(2)}",
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w600,
                                                          fontStyle: FontStyle.normal,
                                                          fontSize: 20.0),
                                                    );
                                                  }
                                                }),
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
                                      labelStyle:
                                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.secondary, fontFamily: 'Quicksand'),
                                      controller: tabController,
                                      padding: EdgeInsetsDirectional.only(top: height! / 80.0),
                                      unselectedLabelStyle:
                                          TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.secondary, fontFamily: 'Quicksand'),
                                      onTap: (value) {
                                        setState(() {
                                          filter = value == 0 ? "0" : "1";
                                          filterIndex = value;
                                        });
                                      },
                                      tabs: [
                                        Tab(text: UiUtils.getTranslatedLabel(context, riderCashLabel)),
                                        Tab(text: UiUtils.getTranslatedLabel(context, riderCashCollectionLabel)),
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
                                    RefreshIndicator(onRefresh: refreshList, color: Theme.of(context).colorScheme.primary, child: riderCash()),
                                    RefreshIndicator(
                                        onRefresh: refreshList, color: Theme.of(context).colorScheme.primary, child: riderCashCollection())
                                  ],
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ));
  }
}

String? validateField(String value, String? msg) {
  if (value.isEmpty) {
    return msg;
  } else {
    return null;
  }
}
