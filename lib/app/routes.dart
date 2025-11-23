import 'package:erestro_single_vender_rider/ui/screen/auth/registration_screen.dart';
import 'package:erestro_single_vender_rider/ui/screen/main/main_screen.dart';
import 'package:erestro_single_vender_rider/ui/screen/auth/change_password_screen.dart';
import 'package:erestro_single_vender_rider/ui/screen/auth/forgot_password_screen.dart';
import 'package:erestro_single_vender_rider/ui/screen/order/order_tracking_screen.dart';
import 'package:erestro_single_vender_rider/ui/screen/settings/account_screen.dart';
import 'package:erestro_single_vender_rider/ui/screen/order/my_order_screen.dart';
import 'package:erestro_single_vender_rider/ui/screen/order/order_detail_screen.dart';
import 'package:erestro_single_vender_rider/ui/screen/auth/login_screen.dart';
import 'package:erestro_single_vender_rider/ui/screen/settings/profile_screen.dart';
import 'package:erestro_single_vender_rider/ui/screen/settings/service_screen.dart';
import 'package:erestro_single_vender_rider/ui/screen/main/splash_screen.dart';
import 'package:erestro_single_vender_rider/ui/screen/transaction/wallet_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Routes {
  static const home = "/";
  static const login = "login";
  static const splash = 'splash';
  static const signUp = "/signUp";
  static const profile = "/profile";
  static const changePassword = "/changePassword";
  static const appSettings = "/appSettings";
  static const settings = "/settings";
  static const riderRatingDetail = "/riderRatingDetail";
  static const order = "/order";
  static const orderDetail = "/orderDetail";
  static const wallet = "/wallet";
  static const orderTracking = "/orderTracking";
  static const account = "/account";
  static const forgotPassword = "/forgotPassword";
  static const registration = "/registration";
  static String currentRoute = splash;

  static Route<dynamic> onGenerateRouted(RouteSettings routeSettings) {
    //to track current route
    //this will only track pushed route on top of previous route
    currentRoute = routeSettings.name ?? "";
    print("Current route is : $currentRoute");
    switch (routeSettings.name) {
      case splash:
        return CupertinoPageRoute(builder: (context) => const SplashScreen());
      case home:
        return MainScreen.route(routeSettings);
      case login:
        return LoginScreen.route(routeSettings);
      case appSettings:
        return ServiceScreen.route(routeSettings);
      case profile:
        return ProfileScreen.route(routeSettings);
      case changePassword:
        return ChangePasswordScreen.route(routeSettings);
      case order:
        return MyOrderScreen.route(routeSettings);
      case orderDetail:
        return OrderDetailScreen.route(routeSettings);
      case wallet:
        return WalletScreen.route(routeSettings);
      case orderTracking:
        return OrderTrackingScreen.route(routeSettings);
      case account:
        return CupertinoPageRoute(builder: (context) => const AccountScreen());
      case forgotPassword:
        return CupertinoPageRoute(builder: (context) => const ForgotPasswordScreen());
      case registration:
        return RegistrationScreen.route(routeSettings);
      default:
        return CupertinoPageRoute(builder: (context) => const Scaffold());
    }
  }
}
