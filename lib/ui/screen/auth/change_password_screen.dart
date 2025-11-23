import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro_single_vender_rider/cubit/auth/authCubit.dart';
import 'package:erestro_single_vender_rider/cubit/auth/changePasswordCubit.dart';
import 'package:erestro_single_vender_rider/cubit/auth/resetPasswordCubit.dart';
import 'package:erestro_single_vender_rider/data/repositories/auth/authRepository.dart';
import 'package:erestro_single_vender_rider/ui/screen/settings/no_internet_screen.dart';
import 'package:erestro_single_vender_rider/ui/widgets/buttomContainer.dart';
import 'package:erestro_single_vender_rider/utils/constants.dart';
import 'package:erestro_single_vender_rider/utils/labelKeys.dart';
import 'package:erestro_single_vender_rider/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro_single_vender_rider/ui/styles/design.dart';
import 'package:erestro_single_vender_rider/utils/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:erestro_single_vender_rider/utils/internetConnectivity.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String? from, mobileNumber;
  ChangePasswordScreen({Key? key, this.from, this.mobileNumber}) : super(key: key);

  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
      builder: (context) => MultiBlocProvider(providers: [
        BlocProvider<ChangePasswordCubit>(create: (_) => ChangePasswordCubit(AuthRepository())),
        BlocProvider<ResetPasswordCubit>(create: (_) => ResetPasswordCubit(AuthRepository())),
      ], child: ChangePasswordScreen(from: arguments['from'] as String, mobileNumber: arguments['mobileNumber'] as String)),
    );
  }
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  double? width, height;
  TextEditingController currentPasswordController = TextEditingController(text: "");
  TextEditingController newPasswordController = TextEditingController(text: "");
  TextEditingController confirmPasswordController = TextEditingController(text: "");
  bool status = false, currentObscure = true, newObscure = true, confirmObscure = true;
  final formKey = GlobalKey<FormState>();
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

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Widget currentPasswordField() {
    return Container(
        padding: EdgeInsetsDirectional.only(top: height! / 30.0, start: width! / 20.0, end: width! / 20.0),
        margin: EdgeInsets.zero,
        child: TextFormField(
          obscureText: currentObscure,
          controller: currentPasswordController,
          cursorColor: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
          decoration: DesignConfig.inputDecorationextField(UiUtils.getTranslatedLabel(context, currentPasswordLabel),
              UiUtils.getTranslatedLabel(context, enterCurrentPasswordLabel), width!, context,
              passwordWidget: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (currentObscure == true) {
                        currentObscure = false;
                      } else {
                        currentObscure = true;
                      }
                    });
                  },
                  child: Icon(currentObscure == true ? Icons.visibility_off : Icons.visibility,
                      color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76)))),
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  Widget confirmPasswordField() {
    return Container(
        padding: EdgeInsetsDirectional.only(top: height! / 30.0, start: width! / 20.0, end: width! / 20.0),
        margin: EdgeInsets.zero,
        child: TextFormField(
          obscureText: confirmObscure,
          validator: (value) {
            if (newPasswordController.text.trim() != confirmPasswordController.text.trim()) {
              return UiUtils.getTranslatedLabel(context, conformPasswordMathLabel);
            }
            setState(() {
              status = false;
            });
            return UiUtils.validatePassword(value!, context);
          },
          controller: confirmPasswordController,
          onChanged: (value) {
            setState(() {
              confirmPasswordController.text;
            });
          },
          cursorColor: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
          decoration: DesignConfig.inputDecorationextField(UiUtils.getTranslatedLabel(context, confirmPasswordLabel),
              UiUtils.getTranslatedLabel(context, enterConfirmPasswordLabel), width!, context,
              passwordWidget: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (confirmObscure == true) {
                        confirmObscure = false;
                      } else {
                        confirmObscure = true;
                      }
                    });
                  },
                  child: Icon(confirmObscure == true ? Icons.visibility_off : Icons.visibility,
                      color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76)))),
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  Widget newPasswordField() {
    return Container(
        padding: EdgeInsetsDirectional.only(top: height! / 30.0, start: width! / 20.0, end: width! / 20.0),
        margin: EdgeInsets.zero,
        child: TextFormField(
          obscureText: newObscure,
          validator: (value) {
            setState(() {
              status = false;
            });
            return UiUtils.validatePassword(value!, context);
          },
          controller: newPasswordController,
          onChanged: (value) {
            setState(() {
              newPasswordController.text;
            });
          },
          cursorColor: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
          decoration: DesignConfig.inputDecorationextField(
              UiUtils.getTranslatedLabel(context, newPasswordLabel), UiUtils.getTranslatedLabel(context, enterNewPasswordLabel), width!, context,
              passwordWidget: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (newObscure == true) {
                        newObscure = false;
                      } else {
                        newObscure = true;
                      }
                    });
                  },
                  child: Icon(newObscure == true ? Icons.visibility_off : Icons.visibility,
                      color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76)))),
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  changePasswordButton() {
    return BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
        bloc: context.read<ChangePasswordCubit>(),
        listener: (context, state) {
          if (state is ChangePasswordFailure) {
            status = false;
          }
          if (state is ChangePasswordSuccess) {
            UiUtils.setSnackBar(StringsRes.updateSuccessFully, context, false, type: "1");
            status = false;
            
          } else if (state is ChangePasswordFailure) {
            UiUtils.setSnackBar(state.errorMessage, context, false, type: "2");
            status = false;
          }
        },
        builder: (context, state) {
          return SizedBox(
            width: width,
            child: ButtonContainer(
              color: Theme.of(context).colorScheme.primary,
              height: height,
              width: width,
              text: UiUtils.getTranslatedLabel(context, changePasswordLabel),
              start: width! / 20.0,
              end: width! / 20.0,
              bottom: height! / 55.0,
              top: height! / 30.0,
              status: status,
              borderColor: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.onPrimary,
              onPressed: () {
                setState(() {
                  status = true;
                });
                if (formKey.currentState!.validate()) {
                  context.read<ChangePasswordCubit>().changePassword(
                      userId: context.read<AuthCubit>().getId(),
                      oldPassword: currentPasswordController.text,
                      newPassword: newPasswordController.text);
                }
              },
            ),
          );
        });
  }

  resetPasswordButton() {
    return BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
        bloc: context.read<ResetPasswordCubit>(),
        listener: (context, state) {
          if (state is ResetPasswordFailure) {
            status = false;
          }
          if (state is ResetPasswordSuccess) {
            UiUtils.setSnackBar(StringsRes.updateSuccessFully, context, false, type: "1");
            status = false;
            
          } else if (state is ResetPasswordFailure) {
            UiUtils.setSnackBar(state.errorMessage, context, false, type: "2");
            status = false;
          }
        },
        builder: (context, state) {
          return SizedBox(
            width: width,
            child: ButtonContainer(
              color: Theme.of(context).colorScheme.primary,
              height: height,
              width: width,
              text: UiUtils.getTranslatedLabel(context, resetPasswordLabel),
              start: width! / 20.0,
              end: width! / 20.0,
              bottom: height! / 55.0,
              top: height! / 30.0,
              status: status,
              borderColor: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.onPrimary,
              onPressed: () {
                setState(() {
                  status = true;
                });
                if (formKey.currentState!.validate()) {
                  print("widget:${widget.mobileNumber}");
                  context.read<ResetPasswordCubit>().resetPassword(mobile: widget.mobileNumber, password: confirmPasswordController.text);
                }
              },
            ),
          );
        });
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
              appBar: DesignConfig.appBar(
                  context,
                  width,
                  status: widget.from == "forgot" ? true : false,
                  widget.from == "forgot"
                      ? UiUtils.getTranslatedLabel(context, resetPasswordLabel)
                      : UiUtils.getTranslatedLabel(context, changePasswordLabel),
                  const PreferredSize(preferredSize: Size.zero, child: SizedBox())),
              body: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        widget.from == "forgot" ? const SizedBox.shrink() : currentPasswordField(),
                        newPasswordField(),
                        confirmPasswordField(),
                        widget.from == "forgot" ? resetPasswordButton() : changePasswordButton()
                      ]),
                ),
              ),
            ),
    );
  }
}
