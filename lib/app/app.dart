import 'dart:io';
import 'package:erestro_single_vender_rider/app/appLocalization.dart';
import 'package:erestro_single_vender_rider/cubit/auth/deleteMyAccountCubit.dart';
import 'package:erestro_single_vender_rider/cubit/auth/resendOtpCubit.dart';
import 'package:erestro_single_vender_rider/cubit/auth/verifyOtpCubit.dart';
import 'package:erestro_single_vender_rider/cubit/auth/verifyUserCubit.dart';
import 'package:erestro_single_vender_rider/cubit/localization/appLocalizationCubit.dart';
import 'package:erestro_single_vender_rider/cubit/order/deleteLiveTrackingCubit.dart';
import 'package:erestro_single_vender_rider/cubit/order/pendingOrderCubit.dart';
import 'package:erestro_single_vender_rider/cubit/order/updateOrderRequestCubit.dart';
import 'package:erestro_single_vender_rider/cubit/order/updateOrderStatusCubit.dart';
import 'package:erestro_single_vender_rider/cubit/profileManagement/getRiderDetailCubit.dart';
import 'package:erestro_single_vender_rider/cubit/profileManagement/updateUserDetailsCubit.dart';
import 'package:erestro_single_vender_rider/cubit/transaction/getFundTransfersCubit.dart';
import 'package:erestro_single_vender_rider/cubit/transaction/riderCashCollectionCubit.dart';
import 'package:erestro_single_vender_rider/cubit/transaction/riderCashCubit.dart';
import 'package:erestro_single_vender_rider/cubit/auth/authCubit.dart';
import 'package:erestro_single_vender_rider/cubit/auth/signInCubit.dart';
import 'package:erestro_single_vender_rider/cubit/order/orderCubit.dart';
import 'package:erestro_single_vender_rider/cubit/order/orderDetailCubit.dart';
import 'package:erestro_single_vender_rider/cubit/order/manageLiveTrackingCubit.dart';
import 'package:erestro_single_vender_rider/cubit/transaction/sendWithdrawRequestCubit.dart';
import 'package:erestro_single_vender_rider/data/repositories/order/orderRepository.dart';
import 'package:erestro_single_vender_rider/cubit/transaction/getWithdrawRequestCubit.dart';
import 'package:erestro_single_vender_rider/cubit/settings/settingsCubit.dart';
import 'package:erestro_single_vender_rider/data/repositories/profileManagement/profileManagementRepository.dart';
import 'package:erestro_single_vender_rider/data/repositories/settings/settingsRepository.dart';
import 'package:erestro_single_vender_rider/cubit/systemConfig/systemConfigCubit.dart';
import 'package:erestro_single_vender_rider/data/repositories/systemConfig/systemConfigRepository.dart';
import 'package:erestro_single_vender_rider/data/repositories/transaction/transactionRepository.dart';
import 'package:erestro_single_vender_rider/firebase_options.dart';
import 'package:erestro_single_vender_rider/ui/styles/color.dart';
import 'package:erestro_single_vender_rider/utils/appLanguages.dart';
import 'package:erestro_single_vender_rider/utils/hiveBoxKey.dart';
import 'package:erestro_single_vender_rider/utils/uiUtils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro_single_vender_rider/app/routes.dart';
import 'package:erestro_single_vender_rider/data/repositories/auth/authRepository.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<Widget> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: SystemUiOverlay.values);
  HttpOverrides.global = MyHttpOverrides();
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark));
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (defaultTargetPlatform == TargetPlatform.android) {}
  }

  await Hive.initFlutter();
  await Hive.openBox(
      authBox); //auth box for storing all authentication related details
  await Hive.openBox(
      settingsBox); //settings box for storing all settings details
  await Hive.openBox(
      userdetailsBox); //userDetails box for storing all userDetails details
  await Hive.openBox(addressBox); //address box for storing all address details
  return const MyApp();
}

class GlobalScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      //providing global providers
      providers: [
        //Creating cubit/bloc that will be use in whole app or
        //will be use in multiple screens
        BlocProvider<AppLocalizationCubit>(
            create: (_) => AppLocalizationCubit(SettingsRepository())),
        BlocProvider<AuthCubit>(create: (_) => AuthCubit(AuthRepository())),
        BlocProvider<SignInCubit>(create: (_) => SignInCubit(AuthRepository())),
        BlocProvider<OrderCubit>(create: (_) => OrderCubit()),
        BlocProvider<SystemConfigCubit>(
            create: (_) => SystemConfigCubit(SystemConfigRepository())),
        BlocProvider<OrderDetailCubit>(
            create: (_) => OrderDetailCubit(OrderRepository())),
        BlocProvider<ManageLiveTrackingCubit>(
            create: (_) => ManageLiveTrackingCubit(OrderRepository())),
        BlocProvider<SettingsCubit>(
            create: (_) => SettingsCubit(SettingsRepository())),
        BlocProvider<GetWithdrawRequestCubit>(
            create: (_) => GetWithdrawRequestCubit()),
        BlocProvider<RiderCashCollectionCubit>(
            create: (_) => RiderCashCollectionCubit()),
        BlocProvider<RiderCashCubit>(create: (_) => RiderCashCubit()),
        BlocProvider<GetFundTransfersCubit>(
            create: (_) => GetFundTransfersCubit()),
        BlocProvider<SendWithdrawRequestCubit>(
            create: (_) => SendWithdrawRequestCubit(TransactionRepository())),
        BlocProvider<GetRiderDetailCubit>(
            create: (_) => GetRiderDetailCubit(ProfileManagementRepository())),
        BlocProvider<VerifyUserCubit>(
            create: (_) => VerifyUserCubit(AuthRepository())),
        BlocProvider<DeleteMyAccountCubit>(
            create: (_) => DeleteMyAccountCubit(AuthRepository())),
        BlocProvider<UpdateUserDetailCubit>(
            create: (_) =>
                UpdateUserDetailCubit(ProfileManagementRepository())),
        BlocProvider<PendingOrderCubit>(create: (_) => PendingOrderCubit()),
        BlocProvider<UpdateOrderRequestCubit>(
            create: (_) => UpdateOrderRequestCubit(OrderRepository())),
        BlocProvider<UpdateOrderStatusCubit>(
            create: (_) => UpdateOrderStatusCubit(OrderRepository())),
        BlocProvider<DeleteLiveTrackingCubit>(
            create: (_) => DeleteLiveTrackingCubit(OrderRepository())),
        BlocProvider<VerifyOtpCubit>(
            create: (_) => VerifyOtpCubit(AuthRepository())),
        BlocProvider<ResendOtpCubit>(
            create: (_) => ResendOtpCubit(AuthRepository())),
      ],
      child: Builder(
        builder: (context) {
          final currentLanguage =
              context.watch<AppLocalizationCubit>().state.language;
          return MaterialApp(
            builder: (context, widget) {
              return ScrollConfiguration(
                  behavior: GlobalScrollBehavior(), child: widget!);
            },
            navigatorKey: navigatorKey,
            theme: ThemeData(
                useMaterial3: false,
                scaffoldBackgroundColor: onBackgroundColor,
                fontFamily: 'Quicksand',
                iconTheme: const IconThemeData(
                  color: black,
                ),
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: primaryColor,
                      secondary: secondaryColor,
                      surface: backgroundColor,
                      error: errorColor,
                      onPrimary: onPrimaryColor,
                      onSecondary: onSecondaryColor,
                      onSurface: onBackgroundColor,
                    )),
            locale: currentLanguage,
            localizationsDelegates: const [
              AppLocalization.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: appLanguages.map((appLanguage) {
              return UiUtils.getLocaleFromLanguageCode(
                  appLanguage.languageCode);
            }).toList(),
            debugShowCheckedModeBanner: false,
            initialRoute: Routes.splash,
            onGenerateRoute: Routes.onGenerateRouted,
          );
        },
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
