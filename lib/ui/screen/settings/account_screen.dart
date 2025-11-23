import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro_single_vender_rider/app/routes.dart';
import 'package:erestro_single_vender_rider/cubit/auth/authCubit.dart';
import 'package:erestro_single_vender_rider/cubit/profileManagement/getRiderDetailCubit.dart';
import 'package:erestro_single_vender_rider/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestro_single_vender_rider/ui/screen/settings/no_internet_screen.dart';
import 'package:erestro_single_vender_rider/ui/styles/dashLine.dart';
import 'package:erestro_single_vender_rider/ui/widgets/LanguageDialog.dart';
import 'package:erestro_single_vender_rider/ui/widgets/customDialog.dart';
import 'package:erestro_single_vender_rider/utils/apiBodyParameterLabels.dart';
import 'package:erestro_single_vender_rider/utils/constants.dart';
import 'package:erestro_single_vender_rider/utils/labelKeys.dart';
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
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

class AccountScreen extends StatefulWidget {
  final Function? bottomStatus;
  const AccountScreen({Key? key, this.bottomStatus}) : super(key: key);

  @override
  AccountScreenState createState() => AccountScreenState();
}

class AccountScreenState extends State<AccountScreen>
    with TickerProviderStateMixin {
  double? width, height;
  var size;
  bool isScrollingDown = false;
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

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  bottomStatusUpdate() {
    setState(() {
      widget.bottomStatus!(0);
    });
  }

  profileData(Size size, String? image, state) {
    return Container(
      width: width,
      decoration: DesignConfig.boxDecorationContainer(
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.11), 8.0),
      height: height! / 11,
      margin: EdgeInsetsDirectional.only(
          top: height! / 50, start: width! / 20.0, end: width! / 20.0),
      padding:
          EdgeInsetsDirectional.only(start: width! / 40.0, end: width! / 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(end: width! / 40.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(4.0)),
              child: (state is AuthInitial || state is Unauthenticated)
                  ? DesignConfig.imageWidgets(
                      context.read<AuthCubit>().getProfile(), 57, 57, "1")
                  : DesignConfig.imageWidgets(
                      state.authModel.image, 57, 57, "1"),
            ),
          ),
          Expanded(
              child: (context.read<AuthCubit>().state is AuthInitial ||
                      context.read<AuthCubit>().state is Unauthenticated)
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text(
                              UiUtils.getTranslatedLabel(
                                  context, yourProfileLabel),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2.0),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "${UiUtils.getTranslatedLabel(context, loginLabel)} ",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.of(context)
                                          .pushNamed(Routes.login, arguments: {
                                        'from': 'profile'
                                      }).then((value) {});
                                    },
                                ),
                                TextSpan(
                                  text: UiUtils.getTranslatedLabel(context,
                                      loginOrSignUpToViewYourCompleteProfileLabel),
                                  style: const TextStyle(
                                      color: greayLightColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
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
                        Text(state.authModel.username!,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 5.0),
                        Text(state.authModel.email!,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: greayLightColor,
                                fontSize: 12,
                                fontWeight: FontWeight.normal)),
                      ],
                    )),
          Align(alignment: Alignment.topRight, child: editProfileButton()),
        ],
      ),
    );
  }

  Widget editProfileButton() {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      return (context.read<AuthCubit>().state is AuthInitial ||
              context.read<AuthCubit>().state is Unauthenticated)
          ? const SizedBox.shrink()
          : InkWell(
              onTap: () {
                Navigator.of(context)
                    .pushNamed(Routes.profile, arguments: false);
              },
              child: Container(
                  height: 24,
                  width: 24,
                  margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                  decoration: DesignConfig.boxDecorationContainer(
                      Theme.of(context).colorScheme.primary, 4),
                  child: SvgPicture.asset(DesignConfig.setSvgPath("pro_edit"),
                      width: 14.0,
                      height: 13.99,
                      colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onPrimary,
                          BlendMode.srcIn))),
            );
    });
  }

  Widget arrowTile({String? title, VoidCallback? onPressed, String? image}) {
    return InkWell(
      onTap: onPressed,
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
        leading: CircleAvatar(
            radius: 18.0,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: SvgPicture.asset(DesignConfig.setSvgPath(image!),
                width: 16.0,
                height: 16.0,
                colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn))),
        title: Text(title!,
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onPrimary
                    .withValues(alpha: 0.76),
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        trailing: IconButton(
            onPressed: onPressed,
            padding: EdgeInsetsDirectional.only(start: height! / 40.0),
            icon: Icon(Icons.arrow_forward_ios,
                size: 12, color: Theme.of(context).colorScheme.onSecondary)),
      ),
    );
  }

  Widget changePassword() {
    return arrowTile(
        image: "pro_password",
        title: UiUtils.getTranslatedLabel(context, changePasswordLabel),
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.changePassword, arguments: {
            "from": "change",
            "mobileNumber": context.read<AuthCubit>().getMobile()
          });
        });
  }

  Widget termAndCondition() {
    return arrowTile(
        image: "pro_tc",
        title: UiUtils.getTranslatedLabel(context, termAndConditionLabel),
        onPressed: () {
          Navigator.of(context)
              .pushNamed(Routes.appSettings, arguments: termsAndConditionsKey);
        });
  }

  Widget privacyPolicyData() {
    return arrowTile(
        image: "pro_pp",
        title: UiUtils.getTranslatedLabel(context, privacyPolicyLabel),
        onPressed: () {
          Navigator.of(context)
              .pushNamed(Routes.appSettings, arguments: privacyPolicyKey);
        });
  }

  Widget deleteYourAccount(AuthState state) {
    return arrowTile(
        image: "pro_delete",
        title: UiUtils.getTranslatedLabel(context, deleteYourAccountLabel),
        onPressed: () {
          if (context.read<AuthCubit>().state is AuthInitial ||
              context.read<AuthCubit>().state is Unauthenticated) {
            Navigator.of(context).pushNamed(Routes.login,
                arguments: {'from': 'deleteYourAccount'}).then((value) {});
            return;
          } else {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomDialog(
                      title: UiUtils.getTranslatedLabel(
                          context, deleteYourAccountLabel),
                      subtitle: UiUtils.getTranslatedLabel(
                          context, deleteYourAccountSubTitleLabel),
                      width: width!,
                      height: height!,
                      from: UiUtils.getTranslatedLabel(context, deleteLabel));
                });
          }
        });
  }

  // Widget rateUs() {
  //   return arrowTile(
  //       image: "pro_rateus",
  //       title: UiUtils.getTranslatedLabel(context, rateUsLabel),
  //       onPressed: () {
  //         LaunchReview.launch(
  //           androidAppId: packageName,
  //           iOSAppId: iosAppId,
  //         );
  //       });
  // }

  Widget rateUs(BuildContext context) {
    final inAppReview = InAppReview.instance;
    return arrowTile(
      image: "pro_rateus",
      title: UiUtils.getTranslatedLabel(context, rateUsLabel),
      onPressed: () async {
        // Try the in-app review prompt first (quota-limited)
        if (await inAppReview.isAvailable()) {
          await inAppReview.requestReview();
        }
        // Always also deep-link to the store listing:
        final appLink = context.read<SystemConfigCubit>().getAppLink();
        final iosId = extractAppId(appLink);
        await inAppReview.openStoreListing(
          appStoreId: iosId, // required on iOS/macOS
          // On Android, openStoreListing() uses your app’s packageName under the hood,
          // so you don’t need to pass androidAppId explicitly.
        );
      },
    );
  }

  Widget languageChange() {
    return arrowTile(
        image: "pro_translate",
        title: UiUtils.getTranslatedLabel(context, languageChangeLabel),
        onPressed: () {
          showModalBottomSheet(
              isDismissible: true,
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              shape: DesignConfig.setRoundedBorderCard(0.0, 0.0, 16.0, 16.0),
              isScrollControlled: true,
              enableDrag: true,
              showDragHandle: true,
              context: context,
              builder: (context) {
                return StatefulBuilder(builder: (BuildContext context,
                    void Function(void Function()) setStater) {
                  return Container(
                      padding: EdgeInsetsDirectional.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                          start: width! / 20.0,
                          end: width! / 20.0),
                      child: LanguageChangeDialog(
                          title: UiUtils.getTranslatedLabel(
                              context, languageChangeLabel),
                          subtitle: UiUtils.getTranslatedLabel(
                              context, areYouSureYouWantToLogoutLabel),
                          width: width!,
                          height: height!,
                          from: UiUtils.getTranslatedLabel(
                              context, logoutLabel)));
                });
              });
        });
  }

  Widget share() {
    return arrowTile(
        image: "pro_share",
        title: UiUtils.getTranslatedLabel(context, shareLabel),
        onPressed: () {
          // Use screen dimensions to position the share dialog at the bottom
          final Size screenSize = MediaQuery.of(context).size;
          try {
            Share.share(
                "$appName\n${context.read<SystemConfigCubit>().getAppLink()}",
                sharePositionOrigin: Rect.fromLTWH(
                  0, // x: Left edge of the screen
                  screenSize.height - 10, // y: Slightly above the screen height
                  screenSize.width, // Width of the entire screen
                  10, // Non-zero height (small positive value)
                ));
          } catch (e) {
            UiUtils.setSnackBar(e.toString(), context, false, type: "2");
          }
        });
  }

  Widget line() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
          top: height! / 60.0, bottom: height! / 60.0),
      child: DashLineView(
        fillRate: 0.5,
        direction: Axis.horizontal,
      ),
    );
  }

  Widget listHederTitle(String? title) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
          top: height! / 80.0, start: width! / 20.0, bottom: height! / 80.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              decoration: DesignConfig.boxDecorationContainer(
                  Theme.of(context).colorScheme.primary, 2),
              height: height! / 40.0,
              width: width! / 80.0),
          SizedBox(width: width! / 80.0),
          Expanded(
            child: Text(UiUtils.getTranslatedLabel(context, title!),
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget profile(AuthState state) {
    RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');
    return Container(
        width: width,
        child: SingleChildScrollView(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<AuthCubit, AuthState>(
                bloc: context.read<AuthCubit>(),
                builder: (context, state) {
                  if (state is Authenticated) {
                    return profileData(size, state.authModel.image!, state);
                  }
                  return profileData(size, "", state);
                }),
            SizedBox(height: height! / 80.0),
            listHederTitle(riderCommissionMethodLabel),
            BlocBuilder<GetRiderDetailCubit, GetRiderDetailState>(
              bloc: context.read<GetRiderDetailCubit>(),
              builder: (context, state) {
                if (state is GetRiderDetailFetchSuccess) {
                  return Container(
                      decoration: DesignConfig.boxDecorationContainer(
                          Theme.of(context).colorScheme.surface, 10.0),
                      padding: EdgeInsetsDirectional.only(
                          start: width! / 40.0,
                          end: width! / 40.0,
                          top: height! / 80.0,
                          bottom: height! / 80.0),
                      margin: EdgeInsetsDirectional.only(
                          top: height! / 80.0,
                          bottom: height! / 80.0,
                          start: width! / 20.0,
                          end: width! / 20.0),
                      child: Row(
                        children: [
                          Container(
                              margin: EdgeInsetsDirectional.only(
                                  end: width! / 40.0),
                              height: height! / 15.0,
                              width: width! / 6.0,
                              alignment: Alignment.center,
                              decoration: DesignConfig.boxDecorationContainer(
                                  Theme.of(context).colorScheme.primary, 8.0),
                              child: Text(
                                  "${double.parse(state.authModel.commission!).toStringAsFixed(2).replaceAll(regex, '')}${(state.authModel.commissionMethod.toString().toLowerCase().contains("percentage") ? StringsRes.percentSymbol : context.read<SystemConfigCubit>().getCurrency())}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.w700))),
                          Expanded(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      UiUtils.getTranslatedLabel(
                                          context, noteLabel),
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4.0),
                                  Text(
                                      UiUtils.capitalize(
                                              state.authModel.commissionMethod!)
                                          .toString()
                                          .replaceAll("_", " "),
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                              .withValues(alpha: 0.76),
                                          fontWeight: FontWeight.w500))
                                ]),
                          ),
                        ],
                      ));
                }
                return SizedBox.shrink();
              },
            ),
            SizedBox(height: height! / 80.0),
            listHederTitle(settingsLabel),
            Container(
                decoration: DesignConfig.boxDecorationContainer(
                    Theme.of(context).colorScheme.surface, 10.0),
                padding: const EdgeInsetsDirectional.all(16.0),
                margin: EdgeInsetsDirectional.only(
                    top: height! / 80.0,
                    bottom: height! / 80.0,
                    start: width! / 20.0,
                    end: width! / 20.0),
                child: Column(children: [
                  languageChange(),
                  line(),
                  (context.read<AuthCubit>().state is AuthInitial ||
                          context.read<AuthCubit>().state is Unauthenticated)
                      ? const SizedBox.shrink()
                      : changePassword(),
                  (context.read<AuthCubit>().state is AuthInitial ||
                          context.read<AuthCubit>().state is Unauthenticated)
                      ? const SizedBox.shrink()
                      : line(),
                  termAndCondition(),
                  line(),
                  privacyPolicyData(),
                  line(),
                  rateUs(context),
                  line(),
                  share(),
                  (context.read<AuthCubit>().state is AuthInitial ||
                              context.read<AuthCubit>().state
                                  is Unauthenticated) ||
                          (context.read<SystemConfigCubit>().getDemoMode() ==
                              "0") ||
                          context.read<AuthCubit>().getMobile() == "9987654321"
                      ? const SizedBox.shrink()
                      : line(),
                  (context.read<AuthCubit>().state is AuthInitial ||
                              context.read<AuthCubit>().state
                                  is Unauthenticated) ||
                          (context.read<SystemConfigCubit>().getDemoMode() ==
                              "0") ||
                          context.read<AuthCubit>().getMobile() == "9987654321"
                      ? const SizedBox.shrink()
                      : deleteYourAccount(state),
                ])),
            SizedBox(height: height! / 10.0),
          ],
        )));
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
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
              appBar: DesignConfig.appBarWihoutBackbutton(
                  context,
                  width,
                  UiUtils.getTranslatedLabel(context, myProfileLabel),
                  const PreferredSize(
                      preferredSize: Size.zero, child: SizedBox())),
              backgroundColor: Theme.of(context).colorScheme.onSurface,
              body: _connectionStatus == connectivityCheck
                  ? const NoInternetScreen()
                  : BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                      return profile(state);
                    }),
            ),
    );
  }
}
