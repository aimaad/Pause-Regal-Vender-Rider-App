import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro_single_vender_rider/app/routes.dart';
import 'package:erestro_single_vender_rider/cubit/auth/authCubit.dart';
import 'package:erestro_single_vender_rider/cubit/auth/signInCubit.dart';
// import 'package:erestro_single_vender_rider/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestro_single_vender_rider/ui/screen/settings/no_internet_screen.dart';
import 'package:erestro_single_vender_rider/ui/widgets/buttomContainer.dart';
import 'package:erestro_single_vender_rider/ui/widgets/keyboardOverlay.dart';
import 'package:erestro_single_vender_rider/utils/apiBodyParameterLabels.dart';
import 'package:erestro_single_vender_rider/utils/constants.dart';
import 'package:erestro_single_vender_rider/utils/labelKeys.dart';
import 'package:erestro_single_vender_rider/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:erestro_single_vender_rider/ui/styles/design.dart';

import 'package:erestro_single_vender_rider/utils/internetConnectivity.dart';

class LoginScreen extends StatefulWidget {
  final String? from;
  const LoginScreen({Key? key, this.from}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
  static Route<LoginScreen> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (_) => LoginScreen(
        from: arguments['from'] as String,
      ),
    );
  }
}

class LoginScreenState extends State<LoginScreen> {
  GlobalKey<ScaffoldState>? scaffoldKey;
  late double width, height;
  TextEditingController phoneNumberController = TextEditingController(text: "");
  TextEditingController passwordController = TextEditingController(text: "");
  String? countryCode = defaulCountryCode;
  FocusNode numberFocusNode = FocusNode();
  FocusNode numberFocusNodeAndroid = FocusNode();
  bool obscure = true, status = false;
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
    phoneNumberController = TextEditingController(text: "9987654321");
    // (context.read<SystemConfigCubit>().getDemoMode() == "0")
    //     ? "9987654321"
    //     : "");
    passwordController = TextEditingController(text: "12345678");
    // (context.read<SystemConfigCubit>().getDemoMode() == "0")
    //     ? "12345678"
    //     : "");
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
    passwordController.dispose();
    numberFocusNode.dispose();
    numberFocusNodeAndroid.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
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
              bottomNavigationBar: Padding(
                padding: EdgeInsetsDirectional.only(
                    start: width / 20.0,
                    end: width / 20.0,
                    bottom: height / 40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                        UiUtils.getTranslatedLabel(
                            context, byContinuingYouAgreeToOurLabel),
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withValues(alpha: 0.76),
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal)),
                    SizedBox(height: height / 99.0),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  Routes.appSettings,
                                  arguments: termsAndConditionsKey);
                            },
                            child: Text(
                                "${UiUtils.getTranslatedLabel(context, termAndConditionLabel)} ",
                                style: TextStyle(
                                    decoration: TextDecoration.none,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600)),
                          ),
                          Text(
                              "${UiUtils.getTranslatedLabel(context, andLabel)} ",
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimary
                                      .withValues(alpha: 0.76),
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600)),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  Routes.appSettings,
                                  arguments: privacyPolicyKey);
                            },
                            child: Text(
                                UiUtils.getTranslatedLabel(
                                    context, privacyPolicyLabel),
                                style: TextStyle(
                                    decoration: TextDecoration.none,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ]),
                  ],
                ),
              ),
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
                          SvgPicture.asset(
                              DesignConfig.setSvgPath("rider_login")),
                          Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.12),
                              height: height / 2.5),
                        ],
                      ),
                      SizedBox(height: height / 40.0),
                      Container(
                          padding: EdgeInsetsDirectional.only(
                              start: width / 20.0, top: height / 99.0),
                          margin: EdgeInsetsDirectional.only(
                            bottom: height / 40.0,
                            end: width / 20.0,
                          ),
                          child: TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            controller: phoneNumberController,
                            cursorColor: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withValues(alpha: 0.76),
                            decoration:
                                DesignConfig.inputDecorationextIconField(
                                    UiUtils.getTranslatedLabel(
                                        context, phoneNumberLabel),
                                    UiUtils.getTranslatedLabel(
                                        context, enterPhoneNumberLabel),
                                    width,
                                    context,
                                    prefixWidget: Icon(Icons.call_outlined,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                            .withValues(alpha: 0.76))),
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withValues(alpha: 0.76),
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                      Container(
                          padding: EdgeInsetsDirectional.only(
                              start: width / 20.0, top: height / 99.0),
                          margin: EdgeInsetsDirectional.only(
                            bottom: height / 40.0,
                            end: width / 20.0,
                          ),
                          child: TextFormField(
                            controller: passwordController,
                            cursorColor: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withValues(alpha: 0.76),
                            obscureText: obscure,
                            decoration:
                                DesignConfig.inputDecorationextIconField(
                                    UiUtils.getTranslatedLabel(
                                        context, passwordLabel),
                                    UiUtils.getTranslatedLabel(
                                        context, enterPasswordLabel),
                                    width,
                                    context,
                                    status: true,
                                    passwordWidget: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (obscure == true) {
                                              obscure = false;
                                            } else {
                                              obscure = true;
                                            }
                                          });
                                        },
                                        child: Icon(
                                            obscure == true
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                                .withValues(alpha: 0.76))),
                                    prefixWidget: Icon(Icons.lock_outline,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                            .withValues(alpha: 0.76))),
                            keyboardType: TextInputType.text,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withValues(alpha: 0.76),
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(Routes.forgotPassword);
                        },
                        child: Padding(
                          padding:
                              EdgeInsetsDirectional.only(end: width / 20.0),
                          child: Align(
                            alignment:
                                Directionality.of(context) == TextDirection.rtl
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                            child: Text(
                                UiUtils.getTranslatedLabel(
                                    context, forgotPasswordLabel),
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                      BlocConsumer<SignInCubit, SignInState>(
                        listener: (context, state) {
                          if (state is SignInFailure) {
                            print(state.errorMessage.toString());
                            UiUtils.setSnackBar(
                                state.errorMessage, context, false,
                                type: "2");
                            status = false;
                          } else if (state is SignInSuccess) {
                            context
                                .read<AuthCubit>()
                                .updateDetails(authModel: state.authModel);
                            status = false;
                            Future.delayed(
                                Duration.zero,
                                () => Navigator.of(context)
                                    .pushNamedAndRemoveUntil(Routes.home,
                                        (Route<dynamic> route) => false));
                          }
                        },
                        builder: (context, state) {
                          return Container(
                            padding: EdgeInsetsDirectional.only(
                                start: width / 20.0,
                                top: height / 99.0,
                                end: width / 20.0),
                            child: SizedBox(
                              width: width,
                              child: ButtonContainer(
                                color: Theme.of(context).colorScheme.primary,
                                height: height,
                                width: width,
                                text: UiUtils.getTranslatedLabel(
                                    context, loginLabel),
                                bottom: height / 30.0,
                                start: 0,
                                end: 0,
                                top: height / 60.0,
                                status: status,
                                borderColor:
                                    Theme.of(context).colorScheme.primary,
                                textColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                onPressed: () {
                                  if (phoneNumberController.text.isEmpty) {
                                    UiUtils.setSnackBar(
                                        UiUtils.getTranslatedLabel(
                                            context, enterPhoneNumberLabel),
                                        context,
                                        false,
                                        type: "2");
                                    status = false;
                                  } else if (passwordController.text.isEmpty) {
                                    UiUtils.setSnackBar(
                                        UiUtils.getTranslatedLabel(
                                            context, enterPasswordLabel),
                                        context,
                                        false,
                                        type: "2");
                                    status = false;
                                  } else {
                                    context.read<SignInCubit>().signInUser(
                                        mobile: phoneNumberController.text,
                                        password: passwordController.text);
                                    status = true;
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      RichText(
                        text: TextSpan(
                          text:
                              "${UiUtils.getTranslatedLabel(context, letsGetYouOnBoardLabel)} ",
                          style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withValues(alpha: 0.76),
                              fontWeight: FontWeight.w500),
                          children: <TextSpan>[
                            TextSpan(
                              text: UiUtils.getTranslatedLabel(
                                  context, createYourAccountLabel),
                              style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.w700),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).pushNamed(
                                      Routes.registration,
                                      arguments: false);
                                },
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ],
              )),
    );
  }
}
