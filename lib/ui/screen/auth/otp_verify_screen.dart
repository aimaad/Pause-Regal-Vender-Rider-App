import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro_single_vender_rider/app/routes.dart';
import 'package:erestro_single_vender_rider/cubit/auth/resendOtpCubit.dart';
import 'package:erestro_single_vender_rider/cubit/auth/verifyOtpCubit.dart';
import 'package:erestro_single_vender_rider/ui/widgets/buttomContainer.dart';
import 'package:erestro_single_vender_rider/ui/styles/design.dart';
import 'package:erestro_single_vender_rider/ui/styles/color.dart';
import 'package:erestro_single_vender_rider/utils/constants.dart';
import 'package:erestro_single_vender_rider/utils/labelKeys.dart';
import 'package:erestro_single_vender_rider/utils/string.dart';
import 'package:erestro_single_vender_rider/ui/screen/auth/resendOtpTimerContainer.dart';
import 'package:erestro_single_vender_rider/ui/screen/settings/no_internet_screen.dart';
import 'package:erestro_single_vender_rider/utils/uiUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_autofill/sms_autofill.dart';

import 'package:erestro_single_vender_rider/utils/internetConnectivity.dart';

const int otpTimeOutSeconds = 60;

class OtpVerifyScreen extends StatefulWidget {
  final String? countryCode, mobileNumber, from, type;
  const OtpVerifyScreen({Key? key, this.countryCode, this.mobileNumber, this.from, this.type}) : super(key: key);

  @override
  _OtpVerifyScreenState createState() => _OtpVerifyScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => OtpVerifyScreen(
            mobileNumber: arguments['mobileNumber'] as String,
            countryCode: arguments['countryCode'] as String,
            from: arguments['from'] as String,
            type: arguments['type'] as String));
  }
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> with SingleTickerProviderStateMixin {
  double? width, height;
  String mobile = "", _verificationId = "", otp = "", signature = "";
  bool _isClickable = false, isCodeSent = false, isloading = false, isErrorOtp = false;
  late TextEditingController controller = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late AnimationController buttonController;

  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool enableResendOtpButton = false;
  bool codeSent = false;
  final GlobalKey<ResendOtpTimerContainerState> resendOtpTimerContainerKey = GlobalKey<ResendOtpTimerContainerState>();
  String? _message = '';

  void signInWithPhoneNumber() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      timeout: const Duration(seconds: otpTimeOutSeconds),
      phoneNumber: "+${widget.countryCode}${widget.mobileNumber}",
      verificationCompleted: (PhoneAuthCredential credential) {
        print("Phone number verified");
        _message = credential.smsCode ?? "";
        controller.text = _message!;
        otp = _message!;
        if (controller.text.isEmpty) {
          otpMobile(controller.text);
        } else {
          _onFormSubmitted();
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        //if otp code does not verify
        print("Firebase Auth error------------");
        print(e.message);
        print("---------------------");
        UiUtils.setSnackBar(e.toString(), context, false, type: "2");

        setState(() {
          isloading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        print("Code sent successfully");
        setState(() {
          codeSent = true;
          _verificationId = verificationId;
          isloading = false;
        });

        Future.delayed(const Duration(milliseconds: 75)).then((value) {
          resendOtpTimerContainerKey.currentState?.setResendOtpTimer();
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("verificationId:$verificationId");
      },
    );
  }

  Widget _buildResendText() {
    return BlocListener<ResendOtpCubit, ResendOtpState>(
      listener: (context, state) {
        if (state is ResendOtpFailure) {
          UiUtils.setSnackBar(state.errorMessage, context, false, type: '2');
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          enableResendOtpButton == false
              ? ResendOtpTimerContainer(
                  key: resendOtpTimerContainerKey,
                  enableResendOtpButton: () {
                    setState(() {
                      enableResendOtpButton = true;
                    });
                  })
              : const SizedBox.shrink(),
          enableResendOtpButton
              ? TextButton(
                  style: ButtonStyle(overlayColor: WidgetStateProperty.all(Colors.transparent)),
                  onPressed: enableResendOtpButton
                      ? () async {
                          print("Resend otp ");
                          setState(() {
                            isloading = false;
                            enableResendOtpButton = false;
                          });
                          resendOtpTimerContainerKey.currentState?.cancelOtpTimer();
                          if (widget.type == "firebase") {
                            signInWithPhoneNumber();
                          } else {
                            context.read<ResendOtpCubit>().resentOtp(mobile: widget.mobileNumber);

                            Future.delayed(const Duration(milliseconds: 75)).then((value) {
                              resendOtpTimerContainerKey.currentState?.setResendOtpTimer();
                            });
                          }
                        }
                      : null,
                  child: Text(
                    UiUtils.getTranslatedLabel(context, resendOtpLabel),
                    style: TextStyle(fontSize: 16.0, color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  bool otpMobile(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        isErrorOtp = true;
      });
      return false;
    }
    return false;
  }

  static Future<bool> checkNet() async {
    bool check = false;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      check = true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      check = true;
    }
    return check;
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

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionStatus = value;
          });
        });
      }
    });
    if (widget.mobileNumber == "1234567890") {
      controller = TextEditingController(text: "123456");
      otp = "123456";
    }
    print("widget${widget.mobileNumber}");
    if (widget.type == "firebase") {
      getSignature();
      signInWithPhoneNumber();
    } else {
      codeSent = true;

      Future.delayed(const Duration(milliseconds: 75)).then((value) {
        resendOtpTimerContainerKey.currentState?.setResendOtpTimer();
      });
    }
    Future.delayed(const Duration(seconds: 60)).then((_) {
      _isClickable = true;
    });
    buttonController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);
  }

  @override
  void dispose() {
    buttonController.dispose();
    controller.dispose();
    SmsAutoFill().unregisterListener();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> getSignature() async {
    SmsAutoFill().getAppSignature.then((sign) {
      setState(() {
        signature = sign;
      });
    });
    SmsAutoFill().listenForCode;
  }

  Future<void> checkNetworkOtpResend() async {
    bool checkInternet = await checkNet();
    if (checkInternet) {
      if (_isClickable) {
        signInWithPhoneNumber();
      } else {
        if (!mounted) return;
        UiUtils.setSnackBar(StringsRes.resendSnackBar, context, false, type: "2");
      }
    } else {
      setState(() {
        checkInternet = false;
      });
      Future.delayed(const Duration(seconds: 60)).then((_) async {
        bool checkInternet = await checkNet();
        if (checkInternet) {
          if (_isClickable) {
            signInWithPhoneNumber();
          } else {
            if (!mounted) return;
            UiUtils.setSnackBar(StringsRes.resendSnackBar, context, false, type: "2");
          }
        } else {
          await buttonController.reverse();
          if (!mounted) return;
          UiUtils.setSnackBar(StringsRes.noInterNetSnackBar, context, false, type: "2");
        }
      });
    }
  }

  void _onFormSubmitted() async {
    String code = otp.trim();
    if (code.length == 6) {
      setState(() {
        isloading = true;
      });
      AuthCredential authCredential = PhoneAuthProvider.credential(verificationId: _verificationId, smsCode: code);
      _firebaseAuth.signInWithCredential(authCredential).then((UserCredential value) async {
        login();
        isloading = false;
        if (value.user != null) {
          await buttonController.reverse();
        } else {
          await buttonController.reverse();
        }
      }).catchError((error) async {
        if (mounted) {
          UiUtils.setSnackBar(error.toString(), context, false, type: "2");
          isloading = false;
          await buttonController.reverse();
        }
      });
    } else {}
  }

  login() async {
    await Navigator.of(context).pushNamed(Routes.changePassword, arguments: {'from': 'forgot', 'mobileNumber': widget.mobileNumber});
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return _connectionStatus == connectivityCheck
        ? const NoInternetScreen()
        : Builder(
            builder: (context) => Scaffold(
              appBar: DesignConfig.appBar(context, width!, UiUtils.getTranslatedLabel(context, otpVerificationLabel),
                  const PreferredSize(preferredSize: Size.zero, child: SizedBox())),
              body: Container(
                  margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                  decoration: DesignConfig.boxDecorationContainerHalf(Theme.of(context).colorScheme.onSurface),
                  width: width,
                  child: Container(
                    height: height!,
                    margin: EdgeInsetsDirectional.only(start: width! / 20.0, end: width! / 20.0, top: height! / 60.0),
                    child: SingleChildScrollView(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: height! / 70.0),
                            Text(
                              UiUtils.getTranslatedLabel(context, enterVerificationCodeLabel),
                              style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onPrimary),
                              textAlign: TextAlign.start,
                            ),
                            SizedBox(height: height! / 80.0),
                            Text(
                              UiUtils.getTranslatedLabel(context, otpVerificationSubTitleLabel),
                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onPrimary),
                              textAlign: TextAlign.start,
                            ),
                            SizedBox(height: height! / 50.0),
                            Text(
                              "${widget.countryCode!} - ${widget.mobileNumber!}",
                              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onPrimary),
                              textAlign: TextAlign.center,
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.only(bottom: 10.0, top: height! / 8.0),
                              child: PinInputTextField(
                                pinLength: 6,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                controller: controller,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.phone,
                                textCapitalization: TextCapitalization.characters,
                                onSubmit: (pin) {
                                  debugPrint('submit pin:$pin');
                                  otp = pin;
                                },
                                onChanged: (pin) {
                                  debugPrint('onChanged execute. pin:$pin${pin.length}');
                                  isErrorOtp = controller.text.isEmpty;
                                  otp = pin;
                                  isloading = false;
                                },
                                decoration: BoxLooseDecoration(
                                    strokeColorBuilder: PinListenColorBuilder(Theme.of(context).colorScheme.secondary, textFieldBorder),
                                    textStyle: TextStyle(
                                        color: Theme.of(context).colorScheme.onSecondary,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Quicksand'),
                                    gapSpace: 8.0,
                                    bgColorBuilder: PinListenColorBuilder(textFieldBackground, textFieldBackground)),
                                enableInteractiveSelection: false,
                                cursor: Cursor(
                                  width: 0.5,
                                  color: Theme.of(context).colorScheme.onSecondary,
                                  radius: const Radius.circular(8),
                                  
                                ),
                              ),
                            ),
                            BlocListener<VerifyOtpCubit, VerifyOtpState>(
                                    listener: (context, state) {
                                      if (state is VerifyOtpSuccess) {
                                        login();
                                      }
                                      if (state is VerifyOtpFailure) {
                                        UiUtils.setSnackBar(state.errorMessage, context, false, type: '2');
                                      }
                                    },
                                    child: SizedBox(
                                      width: width!,
                                      child: ButtonContainer(
                                        color: (codeSent || (controller.text.length == 6))
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context).colorScheme.onSurface,
                                        height: height,
                                        width: width,
                                        text: UiUtils.getTranslatedLabel(context, enterOtpLabel),
                                        bottom: height! / 20.0,
                                        start: 0,
                                        end: 0,
                                        top: height! / 20.0,
                                        status: isloading,
                                        borderColor: (codeSent || (controller.text.length == 6)) ? Theme.of(context).colorScheme.primary : commentBoxBorderColor,
                                        textColor: (codeSent || (controller.text.length == 6)) ? Theme.of(context).colorScheme.onPrimary : commentBoxBorderColor,
                                        onPressed: () {
                                          if (controller.text.isEmpty) {
                                            otpMobile(controller.text);
                                          } else {
                                            if (widget.type == "firebase") {
                                            _onFormSubmitted();
                                            }else{
                                              context.read<VerifyOtpCubit>().verifyOtp(mobile: widget.mobileNumber, otp: controller.text);
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                            enableResendOtpButton
                                ? Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      UiUtils.getTranslatedLabel(context, didNotGetCodeYetLabel),
                                      style: TextStyle(fontSize: 14.0, color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : const SizedBox(),
                            codeSent ? _buildResendText() : Container(),
                          ]),
                    ),
                  )),
            ),
          );
  }
}
