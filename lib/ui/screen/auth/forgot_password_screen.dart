import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro_single_vender_rider/cubit/auth/verifyUserCubit.dart';
import 'package:erestro_single_vender_rider/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestro_single_vender_rider/ui/screen/auth/otp_verify_screen.dart';
import 'package:erestro_single_vender_rider/ui/screen/settings/no_internet_screen.dart';
import 'package:erestro_single_vender_rider/ui/widgets/buttomContainer.dart';
import 'package:erestro_single_vender_rider/ui/widgets/keyboardOverlay.dart';
import 'package:erestro_single_vender_rider/utils/constants.dart';
import 'package:erestro_single_vender_rider/utils/labelKeys.dart';
import 'package:erestro_single_vender_rider/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:erestro_single_vender_rider/ui/styles/color.dart';
import 'package:erestro_single_vender_rider/ui/styles/design.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'package:erestro_single_vender_rider/utils/internetConnectivity.dart';
import 'dart:ui' as ui;

class ForgotPasswordScreen extends StatefulWidget {
  final String? from;
  const ForgotPasswordScreen({Key? key, this.from}) : super(key: key);

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
  static Route<ForgotPasswordScreen> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (_) => ForgotPasswordScreen(
        from: arguments['from'] as String,
      ),
    );
  }
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  GlobalKey<ScaffoldState>? scaffoldKey;
  late double width, height;
  TextEditingController phoneNumberController = TextEditingController(text: "");
  String? countryCode = defaulCountryCode;
  FocusNode numberFocusNode = FocusNode();
  FocusNode numberFocusNodeAndroid = FocusNode();
  bool status = false;
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
    numberFocusNode.addListener(() {
      bool hasFocus = numberFocusNode.hasFocus;
      if (hasFocus) {
        KeyboardOverlay.showOverlay(context);
      } else {
        KeyboardOverlay.removeOverlay();
      }
    });
    scaffoldKey = GlobalKey<ScaffoldState>();
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    numberFocusNode.dispose();
    numberFocusNodeAndroid.dispose();
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
          : Scaffold(
              key: scaffoldKey,
              body: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: <Widget>[
                          SvgPicture.asset(DesignConfig.setSvgPath("rider_pass_forgot")),
                          Container(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12), height: height / 2.5),
                        ],
                      ),
                      SizedBox(height: height / 40.0),
                      Padding(
                        padding: EdgeInsetsDirectional.only(start: width / 20.0, end: width / 20.0, bottom: height / 80.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(UiUtils.getTranslatedLabel(context, forgotPasswordTitleLabel),
                              style: TextStyle(fontSize: 32, color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.only(start: width / 20.0, end: width / 20.0, bottom: height / 40.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(UiUtils.getTranslatedLabel(context, weWillSendAVerificationCodeToThisNumberLabel),
                              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w500)),
                        ),
                      ),
                      Container(
                          padding: EdgeInsetsDirectional.only(start: width / 20.0, top: height / 99.0),
                          margin: EdgeInsetsDirectional.only(
                            bottom: height / 40.0,
                            end: width / 20.0,
                          ),
                          child: IntlPhoneField(
                            controller: phoneNumberController,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textInputAction: TextInputAction.done,
                            dropdownIcon: Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).colorScheme.onPrimary),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: textFieldBackground,
                              contentPadding: const EdgeInsets.only(top: 15, bottom: 15),
                              focusedBorder: DesignConfig.outlineInputBorder(textFieldBorder, 4.0),
                              focusedErrorBorder: DesignConfig.outlineInputBorder(textFieldBorder, 4.0),
                              errorBorder: DesignConfig.outlineInputBorder(textFieldBorder, 4.0),
                              enabledBorder: DesignConfig.outlineInputBorder(textFieldBorder, 4.0),
                              focusColor: white,
                              counterStyle: const TextStyle(color: white, fontSize: 0),
                              border: InputBorder.none,
                              hintText: UiUtils.getTranslatedLabel(context, enterPhoneNumberLabel),
                              labelStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontSize: 16.0,
                              ),
                              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 16.0, fontWeight: FontWeight.w500),
                              
                            ),
                            flagsButtonMargin: EdgeInsets.all(width / 40.0),
                            textAlignVertical: TextAlignVertical.center,
                            keyboardType: TextInputType.number,
                            focusNode: Platform.isIOS ? numberFocusNode : numberFocusNodeAndroid,
                            dropdownIconPosition: IconPosition.trailing,
                            dropdownTextStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 16.0, fontWeight: FontWeight.w500),
                            initialCountryCode: defaulIsoCountryCode,
                            showCountryFlag: false,
                            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 16.0, fontWeight: FontWeight.w500),
                            textAlign: Directionality.of(context) == ui.TextDirection.rtl ? TextAlign.right : TextAlign.left,
                            onChanged: (phone) {
                              setState(() {
                                
                                countryCode = phone.countryCode;
                              });
                            },
                            onCountryChanged: ((value) {
                              setState(() {
                                print(value.dialCode);
                                countryCode = value.dialCode;
                                defaulIsoCountryCode = value.code;
                              });
                            }),
                          )),
                      BlocConsumer<VerifyUserCubit, VerifyUserState>(
                        listener: (context, state) {
                          if (state is VerifyUserSuccess) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => OtpVerifyScreen(
                                  mobileNumber: phoneNumberController.text,
                                  countryCode: countryCode,
                                  from: widget.from,
                                  type: context.read<SystemConfigCubit>().getAuthenticationMethod() == "0" ? "firebase":"sms"
                                ),
                              ),
                            );
                          } else if (state is VerifyUserFailure) {
                            UiUtils.setSnackBar(state.errorMessage, context, false, type: "2");
                          }
                        },
                        builder: (context, state) {
                          return Container(
                            child: SizedBox(
                              width: width,
                              child: ButtonContainer(
                                color: Theme.of(context).colorScheme.primary,
                                height: height,
                                width: width,
                                text: UiUtils.getTranslatedLabel(context, verifyLabel),
                                bottom: height / 30.0,
                                start: width / 20.0,
                                end: width / 20.0,
                                top: height / 99.0,
                                status: status,
                                borderColor: Theme.of(context).colorScheme.primary,
                                textColor: Theme.of(context).colorScheme.onPrimary,
                                onPressed: () {
                                  if (phoneNumberController.text.isEmpty) {
                                    UiUtils.setSnackBar(UiUtils.getTranslatedLabel(context, enterPhoneNumberLabel), context, false, type: "2");
                                    status = false;
                                  } else {
                                    context.read<VerifyUserCubit>().verifyUser(mobile: phoneNumberController.text);
                                    status = false;
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ]),
                  ),
                ],
              )),
    );
  }
}
