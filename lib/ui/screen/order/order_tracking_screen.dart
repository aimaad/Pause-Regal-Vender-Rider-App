import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro_single_vender_rider/cubit/auth/authCubit.dart';
import 'package:erestro_single_vender_rider/cubit/order/orderCubit.dart';
import 'package:erestro_single_vender_rider/cubit/order/manageLiveTrackingCubit.dart';
import 'package:erestro_single_vender_rider/cubit/settings/settingsCubit.dart';
import 'package:erestro_single_vender_rider/ui/styles/color.dart';
import 'package:erestro_single_vender_rider/ui/styles/dashLine.dart';
import 'package:erestro_single_vender_rider/ui/styles/design.dart';
import 'package:erestro_single_vender_rider/ui/widgets/noDataContainer.dart';
import 'package:erestro_single_vender_rider/utils/labelKeys.dart';
import 'package:erestro_single_vender_rider/ui/screen/settings/no_internet_screen.dart';
import 'package:erestro_single_vender_rider/utils/apiBodyParameterLabels.dart';
import 'package:erestro_single_vender_rider/utils/constants.dart';
import 'package:erestro_single_vender_rider/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:erestro_single_vender_rider/utils/internetConnectivity.dart';
import 'dart:ui' as ui;

class OrderTrackingScreen extends StatefulWidget {
  final String? id,
      customerAddress,
      restaurantAddress,
      customerName,
      customerMobile,
      customerImage;
  final double? customerLatitude,
      customerLongitude,
      restaurantLatitude,
      restaurantLongitude;
  final bool? isTracking;
  const OrderTrackingScreen(
      {Key? key,
      this.id,
      this.customerLatitude,
      this.customerLongitude,
      this.customerAddress,
      this.restaurantAddress,
      this.restaurantLatitude,
      this.restaurantLongitude,
      this.customerName,
      this.customerMobile,
      this.customerImage,
      this.isTracking})
      : super(key: key);

  @override
  _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<OrderCubit>(
              create: (_) => OrderCubit(),
              child: OrderTrackingScreen(
                  id: arguments['id'] as String,
                  customerLatitude: arguments['customerLatitude'] as double,
                  restaurantLongitude:
                      arguments['restaurantLongitude'] as double,
                  restaurantLatitude: arguments['restaurantLatitude'] as double,
                  customerLongitude: arguments['customerLongitude'] as double,
                  customerAddress: arguments['customerAddress'] as String,
                  restaurantAddress: arguments['restaurantAddress'] as String,
                  customerName: arguments['customerName'] as String,
                  customerMobile: arguments['customerMobile'] as String,
                  customerImage: arguments['customerImage'] as String,
                  isTracking: arguments['isTracking'] as bool),
            ));
  }
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with SingleTickerProviderStateMixin {
  LatLng? latlong;
  double? width, height;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  GoogleMapController? mapController;

  double? _originLatitude, _originLongitude;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  late PolylineId polylineId;
  Timer? timer;
  BitmapDescriptor? driverIcon, restaurantsIcon, destinationIcon;
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<BitmapDescriptor> bitmapDescriptorFromSvgAsset(
      BuildContext context, String assetName) async {
    // Read SVG file as String
    String svgString =
        await DefaultAssetBundle.of(context).loadString(assetName);
    // Create DrawableRoot from SVG String
    final PictureInfo pictureInfo =
        await vg.loadPicture(SvgStringLoader(svgString), null);

    // toPicture() and toImage() don't seem to be pixel ratio aware, so we calculate the actual sizes here
    MediaQueryData queryData = MediaQuery.of(context);
    double devicePixelRatio = queryData.devicePixelRatio;

    double width = 15 * devicePixelRatio;
    double height = 15 * devicePixelRatio;

    // Convert to ui.Picture
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);

    canvas.scale(
        width / pictureInfo.size.width, height / pictureInfo.size.height);
    canvas.drawPicture(pictureInfo.picture);
    final ui.Picture scaledPicture = recorder.endRecording();

    final image = await scaledPicture.toImage(width.toInt(), height.toInt());

    // Convert to ui.Image. toImage() takes width and height as parameters
    // you need to find the best size to suit your needs and take into account the
    // screen DPI

    ByteData? bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

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

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionStatus = value;
          });
        });
      }
    });
    Future.delayed(Duration.zero, () {
      context.read<OrderCubit>().fetchOrder(
          perPage, context.read<AuthCubit>().getId(), widget.id!, "");
    });
    _launchMap();
  }

  Widget noTrackingData() {
    return Container(
      height: height,
      margin: EdgeInsetsDirectional.only(top: height! / 80.0),
      width: width,
      child: NoDataContainer(
          image: "delivery_boy_tracking",
          title: UiUtils.getTranslatedLabel(context, orderTrackingLabel),
          subTitle: UiUtils.getTranslatedLabel(context, notStartYetRideLabel),
          width: width!,
          height: height!),
    );
  }

  @override
  void dispose() {
    timer!.cancel();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  _launchMap() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
    );
    Position position =
        await Geolocator.getCurrentPosition(locationSettings: locationSettings);

    _originLatitude = position.latitude;
    _originLongitude = position.longitude;

    /// origin marker
    _addMarker(LatLng(position.latitude, position.longitude), "origin");

    /// destination marker
    if (widget.isTracking!) {
      _addMarker(LatLng(widget.customerLatitude!, widget.customerLongitude!),
          "destination");
    } else {
      _addMarker(
          LatLng(widget.restaurantLatitude!, widget.restaurantLongitude!),
          "destination");
    }
    timer = Timer.periodic(const Duration(seconds: 2), (Timer t) async {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings);
      _originLatitude = position.latitude;
      _originLongitude = position.longitude;
      if (widget.isTracking!) {
        context.read<ManageLiveTrackingCubit>().manageLiveTracking(
            orderId: widget.id,
            orderStatus: outForDeliveryKey,
            latitude: _originLatitude.toString(),
            longitude: _originLongitude.toString());
      }
      updateMarker(
        LatLng(_originLatitude!, _originLongitude!),
        "origin",
      );
      _getPolyline();
    });

    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    buttonSqueezeanimation = Tween(
      begin: width! * 0.7,
      end: 50.0,
    ).animate(CurvedAnimation(
      parent: buttonController!,
      curve: const Interval(
        0.0,
        0.150,
      ),
    ));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return _connectionStatus == connectivityCheck
        ? const NoInternetScreen()
        : PopScope(
            canPop: true,
            onPopInvokedWithResult: (value, dynamic) async {
              context
                  .read<SettingsCubit>()
                  .setLatitude(_originLatitude.toString());
              context
                  .read<SettingsCubit>()
                  .setLongitude(_originLongitude.toString());
              //return true;
            },
            child: Scaffold(
                appBar: DesignConfig.appBar(
                  context,
                  width!,
                  UiUtils.getTranslatedLabel(context, orderTrackingLabel),
                  const PreferredSize(
                      preferredSize: Size.zero, child: SizedBox()),
                  from: "map",
                  latitude: context
                      .read<SettingsCubit>()
                      .setLatitude(_originLatitude.toString()),
                  longitude: context
                      .read<SettingsCubit>()
                      .setLongitude(_originLongitude.toString()),
                ),
                body: BlocListener<ManageLiveTrackingCubit,
                        ManageLiveTrackingState>(
                    bloc: context.read<ManageLiveTrackingCubit>(),
                    listener: (context, state) {},
                    child: BlocConsumer<OrderCubit, OrderState>(
                        bloc: context.read<OrderCubit>(),
                        listener: (context, state) {},
                        builder: (context, state) {
                          if (state is OrderProgress || state is OrderInitial) {
                            return Center(
                              child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.primary),
                            );
                          }
                          if (state is OrderFailure) {
                            return NoDataContainer(
                                image: "delivery_boy_tracking",
                                title: UiUtils.getTranslatedLabel(
                                    context, orderTrackingLabel),
                                subTitle: UiUtils.getTranslatedLabel(
                                    context, notStartYetRideLabel),
                                width: width!,
                                height: height!);
                          }
                          final orderList = (state as OrderSuccess).orderList;
                          return Stack(
                            children: [
                              Container(
                                height: height!,
                                padding: EdgeInsetsDirectional.only(
                                    top: MediaQuery.of(context).padding.top),
                                child: _originLatitude != null &&
                                        _originLongitude != null
                                    ? GoogleMap(
                                        initialCameraPosition: CameraPosition(
                                            target: LatLng(_originLatitude!,
                                                _originLongitude!),
                                            zoom: 14.0),
                                        myLocationEnabled: true,
                                        tiltGesturesEnabled: true,
                                        compassEnabled: true,
                                        scrollGesturesEnabled: true,
                                        zoomGesturesEnabled: true,
                                        onMapCreated: _onMapCreated,
                                        mapType: MapType.normal,
                                        markers: Set<Marker>.of(markers.values),
                                        polylines:
                                            Set<Polyline>.of(polylines.values),
                                      )
                                    : Container(),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Stack(
                                  children: [
                                    Container(
                                      margin: EdgeInsetsDirectional.only(
                                          top: height! / 1.4),
                                      padding: EdgeInsetsDirectional.only(
                                          bottom: height! / 60.0,
                                          start: width! / 20.0,
                                          end: width! / 20.0),
                                      alignment: Alignment.bottomCenter,
                                      decoration:
                                          DesignConfig.boxDecorationContainer(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .secondary,
                                              0.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 20,
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsetsDirectional
                                                          .all(2.0),
                                                  child: ClipOval(
                                                      child: DesignConfig
                                                          .imageWidgets(
                                                              orderList[0]
                                                                  .profile,
                                                              85,
                                                              85,
                                                              "2")),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsetsDirectional.only(
                                                        end: width! / 60.0,
                                                        start: width! / 60.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        orderList[0].username ??
                                                            "",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurface,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                                    const SizedBox(height: 5.0),
                                                    Text(
                                                        "${orderList[0].mobile!}",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .onSurface,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          GestureDetector(
                                            onTap: () async {
                                              final Uri launchUri = Uri(
                                                scheme: 'tel',
                                                path: orderList[0].mobile!,
                                              );
                                              await launchUrl(launchUri);
                                            },
                                            child: Container(
                                              alignment: Alignment.center,
                                              height: 30.0,
                                              width: 30.0,
                                              padding:
                                                  const EdgeInsets.all(3.1),
                                              decoration: DesignConfig
                                                  .boxDecorationContainer(
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .onSurface
                                                          .withValues(
                                                              alpha: 0.30),
                                                      4.0),
                                              child: Icon(Icons.call,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsetsDirectional.only(
                                          start: width! / 25.0,
                                          top: height! / 99.0,
                                          end: width! / 25.0),
                                      margin: EdgeInsetsDirectional.only(
                                          top: height! / 1.8),
                                      decoration: DesignConfig
                                          .boxDecorationContainerCardShadow(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                              shadowCard,
                                              10.0,
                                              0,
                                              3,
                                              6,
                                              0),
                                      width: width,
                                      height: height! / 4.0,
                                      child: SingleChildScrollView(
                                        child: Stack(
                                          children: [
                                            Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .only(
                                                                top: height! /
                                                                    40.0,
                                                                start: width! /
                                                                    40.00,
                                                                end: width! /
                                                                    40.0),
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                            margin:
                                                                EdgeInsetsDirectional.only(
                                                                    end: width! /
                                                                        50.0),
                                                            alignment: Alignment
                                                                .center,
                                                            height: 36.0,
                                                            width: 36,
                                                            decoration: DesignConfig.boxDecorationContainerBorder(
                                                                Theme.of(context)
                                                                    .colorScheme
                                                                    .secondary,
                                                                Theme.of(context)
                                                                    .colorScheme
                                                                    .secondary
                                                                    .withValues(
                                                                        alpha:
                                                                            0.10),
                                                                5.0),
                                                            child: SvgPicture.asset(
                                                                DesignConfig.setSvgPath(
                                                                    "order_pickup"),
                                                                width: 24,
                                                                height: 24,
                                                                colorFilter: ColorFilter.mode(
                                                                    Theme.of(context)
                                                                        .colorScheme
                                                                        .secondary,
                                                                    BlendMode.srcIn))),
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                UiUtils.getTranslatedLabel(
                                                                    context,
                                                                    deliveryFromLabel),
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onPrimary,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .normal)),
                                                            const SizedBox(
                                                                height: 2.0),
                                                            SizedBox(
                                                                width: width! /
                                                                    1.6,
                                                                child: Text(
                                                                    widget
                                                                        .restaurantAddress!,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                    style: TextStyle(
                                                                        color: Theme.of(context)
                                                                            .colorScheme
                                                                            .onPrimary
                                                                            .withValues(
                                                                                alpha:
                                                                                    0.76),
                                                                        fontSize:
                                                                            10,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        fontStyle:
                                                                            FontStyle.normal))),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    height: height! / 16.0,
                                                    margin:
                                                        EdgeInsetsDirectional
                                                            .only(
                                                                start: width! /
                                                                    15.0),
                                                    child: DashLineView(
                                                        direction:
                                                            Axis.vertical,
                                                        dashColor:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .secondary,
                                                        fillRate: 0.8),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .only(
                                                                start: width! /
                                                                    40.00,
                                                                end: width! /
                                                                    40.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                            margin:
                                                                EdgeInsetsDirectional.only(
                                                                    end: width! /
                                                                        50.0),
                                                            alignment: Alignment
                                                                .center,
                                                            height: 36.0,
                                                            width: 36,
                                                            decoration: DesignConfig.boxDecorationContainerBorder(
                                                                Theme.of(context)
                                                                    .colorScheme
                                                                    .secondary,
                                                                Theme.of(context)
                                                                    .colorScheme
                                                                    .secondary
                                                                    .withValues(
                                                                        alpha:
                                                                            0.10),
                                                                5.0),
                                                            child: SvgPicture.asset(
                                                                DesignConfig.setSvgPath(
                                                                    "order_pickup"),
                                                                width: 24,
                                                                height: 24,
                                                                colorFilter: ColorFilter.mode(
                                                                    Theme.of(context)
                                                                        .colorScheme
                                                                        .secondary,
                                                                    BlendMode.srcIn))),
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                                UiUtils.getTranslatedLabel(
                                                                    context,
                                                                    deliveryLocationLabel),
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onPrimary,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .normal)),
                                                            const SizedBox(
                                                                height: 2.0),
                                                            SizedBox(
                                                                width: width! /
                                                                    1.6,
                                                                child: Text(
                                                                  widget
                                                                      .customerAddress!,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style: TextStyle(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .onPrimary
                                                                          .withValues(
                                                                              alpha:
                                                                                  0.76),
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .normal),
                                                                  maxLines: 2,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                )),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ]),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }))),
          );
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    _addPolyLine();
  }

  _addMarker(LatLng position, String id) async {
    MarkerId markerId = MarkerId(id);

    BitmapDescriptor? icon, defaultIcon;
    if (id == "origin") {
      driverIcon = await bitmapDescriptorFromSvgAsset(
          context, DesignConfig.setSvgPath("delivery_boy"));
      defaultIcon =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      icon = driverIcon;
    }
    if (widget.isTracking!) {
      if (id == "destination") {
        restaurantsIcon = await bitmapDescriptorFromSvgAsset(
            context, DesignConfig.setSvgPath("address_icons"));
        defaultIcon =
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
        icon = restaurantsIcon;
      }
    } else {
      if (id == "destination") {
        destinationIcon = await bitmapDescriptorFromSvgAsset(
            context, DesignConfig.setSvgPath("map_pin"));
        defaultIcon =
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
        icon = destinationIcon;
      }
    }

    Marker marker = Marker(
      markerId: markerId,
      icon: icon ?? defaultIcon!,
      position: position,
    );
    markers[markerId] = marker;
  }

  updateMarker(LatLng latLng, String id) async {
    BitmapDescriptor? icon, defaultIcon;
    MarkerId markerId = MarkerId(id);
    driverIcon = await bitmapDescriptorFromSvgAsset(
        context, DesignConfig.setSvgPath("delivery_boy"));
    defaultIcon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    icon = driverIcon;
    Marker marker = Marker(
      markerId: markerId,
      position: latLng,
      icon: icon ?? defaultIcon,
    );
    if (mounted) {
      setState(() {
        markers[markerId] = marker;
      });
    }
  }

  _addPolyLine() {
    PolylineId id = PolylineId(widget.id!);
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates,
        width: 5);
    polylines[id] = polyline;
    setState(() {});
  }

  List<LatLng> decodeEncodedPolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());

      poly.add(p);
    }
    return poly;
  }

  Future<List<LatLng>> getRouteBetweenCoordinates(
    LatLng origin,
    LatLng destination,
  ) async {
    List<LatLng> latlnglist = [];
    var params = {
      "origin": "${origin.latitude},${origin.longitude}",
      "destination": "${destination.latitude},${destination.longitude}",
      "mode": 'driving',
      "key": Platform.isIOS ? googleAPiKeyIos : googleAPiKeyAndroid
    };

    Uri uri =
        Uri.https("maps.googleapis.com", "maps/api/directions/json", params);

    var response = await http.get(uri);
    if (response.statusCode == 200) {
      var parsedJson = json.decode(response.body);

      if (parsedJson["status"]?.toLowerCase() == 'ok' &&
          parsedJson["routes"] != null &&
          parsedJson["routes"].isNotEmpty) {
        latlnglist = decodeEncodedPolyline(
            parsedJson["routes"][0]["overview_polyline"]["points"]);
      }
    }
    return latlnglist;
  }

  _getPolyline() async {
    List<LatLng> mainroute = [];
    if (widget.isTracking!) {
      mainroute = await getRouteBetweenCoordinates(
          LatLng(_originLatitude!, _originLongitude!),
          LatLng(widget.customerLatitude!, widget.customerLongitude!));
    } else {
      mainroute = await getRouteBetweenCoordinates(
          LatLng(_originLatitude!, _originLongitude!),
          LatLng(widget.restaurantLatitude!, widget.restaurantLongitude!));
    }

    if (mainroute.isEmpty) {
      mainroute = [];
      mainroute.add(LatLng(_originLatitude!, _originLongitude!));
      if (widget.isTracking!) {
        mainroute
            .add(LatLng(widget.customerLatitude!, widget.customerLongitude!));
      } else {
        mainroute.add(
            LatLng(widget.restaurantLatitude!, widget.restaurantLongitude!));
      }
    }

    polylineId = PolylineId(widget.id!);
    Polyline polyline = Polyline(
        polylineId: polylineId,
        visible: true,
        points: mainroute,
        color: Theme.of(context).colorScheme.secondary,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
        width: 5);
    polylines[polylineId] = polyline;

    if (mounted) {
      setState(() {});
    }
  }
}
