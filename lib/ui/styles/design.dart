import 'dart:io';

import 'package:erestro_single_vender_rider/cubit/settings/settingsCubit.dart';
import 'package:erestro_single_vender_rider/ui/styles/dashLine.dart';
import 'package:erestro_single_vender_rider/utils/apiBodyParameterLabels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'color.dart';

class DesignConfig {
  static RoundedRectangleBorder setRoundedBorderCard(
      double radius1, double radius2, double radius3, double radius4) {
    return RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(radius1),
            bottomRight: Radius.circular(radius2),
            topLeft: Radius.circular(radius3),
            topRight: Radius.circular(radius4)));
  }

  static RoundedRectangleBorder setRoundedBorder(
      Color borderColor, double radius, bool isSetSide) {
    return RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: isSetSide ? 1.0 : 0),
        borderRadius: BorderRadius.circular(radius));
  }

  static RoundedRectangleBorder setRounded(double radius) {
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
  }

  static RoundedRectangleBorder setHalfRoundedBorder(
      Color borderColor,
      double radius1,
      double radius2,
      double radius3,
      double radius4,
      bool isSetSide) {
    return RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: isSetSide ? 1.0 : 0),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radius1),
            bottomLeft: Radius.circular(radius2),
            topRight: Radius.circular(radius3),
            bottomRight: Radius.circular(radius4)));
  }

  static BoxDecoration boxDecorationContainerRoundHalf(Color color,
      double bradius1, double bradius2, double bradius3, double bradius4) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(bradius1),
          bottomLeft: Radius.circular(bradius2),
          topRight: Radius.circular(bradius3),
          bottomRight: Radius.circular(bradius4)),
    );
  }

  static BoxDecoration boxDecorationContainerShadow(
      Color color,
      double bradius1,
      double bradius2,
      double bradius3,
      double bradius4,
      BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.onSurface,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(bradius1),
          bottomLeft: Radius.circular(bradius2),
          topRight: Radius.circular(bradius3),
          bottomRight: Radius.circular(bradius4)),
      boxShadow: [
        BoxShadow(
            color: color,
            offset: const Offset(0.0, 2.0),
            blurRadius: 6.0,
            spreadRadius: 0)
      ],
    );
  }

  static BoxDecoration boxDecorationContainer(Color color, double radius) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static OutlineInputBorder outlineInputBorder(Color color, double radius) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: 1),
    );
  }

  static BoxDecoration boxDecorationContainerHalf(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(0.0),
          bottomLeft: Radius.circular(0.0),
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0)),
    );
  }

  static BoxDecoration boxDecorationContainerBorder(
      Color color, Color colorBackground, double radius,
      {bool status = false}) {
    return BoxDecoration(
      color: colorBackground,
      border: Border.all(color: color, width: status == false ? 1 : 0.5),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration boxDecorationContainerBorderCustom(
      Color color, Color colorBackground, double radius) {
    return BoxDecoration(
      color: colorBackground,
      border: Border.all(color: color, width: 0.5),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration boxDecorationCircle(
      Color color, Color colorBackground, double radius) {
    return BoxDecoration(
      color: colorBackground,
      border: Border.all(color: color, width: 2.0),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration circle(Color color) {
    return BoxDecoration(shape: BoxShape.circle, color: color);
  }

  static setSvgPath(String name) {
    return "assets/images/svg/$name.svg";
  }

  static setPngPath(String name) {
    return "assets/images/png/$name.png";
  }

  static setLottiePath(String name) {
    return "assets/images/json/$name.json";
  }

  static BoxDecoration boxCurveShadow(Color? color) {
    return BoxDecoration(
        color: color!,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
        boxShadow: const [
          BoxShadow(
            color: shadow,
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, -9),
          )
        ]);
  }

  static BoxDecoration boxDecorationContainerCardShadow(
      Color color,
      Color shadowColor,
      double radius,
      double x,
      double y,
      double b,
      double s) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
            color: shadowColor,
            offset: Offset(x, y),
            blurRadius: b,
            spreadRadius: s),
      ],
    );
  }

  static BoxDecoration boxDecorationContainerShadow1(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.onSurface,
      shape: BoxShape.circle,
      boxShadow: const [
        BoxShadow(
            color: Color(0x0f292929),
            offset: Offset(0.0, 6.0),
            blurRadius: 10.0,
            spreadRadius: 0)
      ],
    );
  }

  static InputDecoration inputDecorationextField(
      String lableText, String hintText, double width, BuildContext context,
      {bool? status = false,
      Widget passwordWidget = const SizedBox.shrink(),
      Widget prefixWidget = const SizedBox.shrink()}) {
    return InputDecoration(
      labelText: lableText,
      fillColor: textFieldBackground,
      filled: true,
      border: InputBorder.none,
      alignLabelWithHint: true,
      hintText: hintText,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
      ),
      errorMaxLines: 2,
      prefix: prefixWidget,
      suffixIcon: passwordWidget,
      hintStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
      ),
      contentPadding: EdgeInsetsDirectional.all(16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(width: 1.0, color: textFieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(width: 1.0, color: textFieldBorder),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(width: 1.0, color: textFieldBorder),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(width: 1.0, color: textFieldBorder),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(width: 1.0, color: textFieldBorder),
      ),
    );
  }

  static InputDecoration inputDecorationextIconField(
      String lableText, String hintText, double width, BuildContext context,
      {bool? status = false,
      Widget passwordWidget = const SizedBox.shrink(),
      Widget prefixWidget = const SizedBox.shrink()}) {
    return InputDecoration(
      labelText: lableText,
      fillColor: textFieldBackground,
      filled: true,
      border: InputBorder.none,
      alignLabelWithHint: true,
      hintText: hintText,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: prefixWidget,
      suffixIcon: passwordWidget,
      hintStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
      ),
      contentPadding: EdgeInsetsDirectional.all(16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(width: 1.0, color: textFieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(width: 1.0, color: textFieldBorder),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(width: 1.0, color: textFieldBorder),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(width: 1.0, color: textFieldBorder),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(width: 1.0, color: textFieldBorder),
      ),
    );
  }

  static imageWidgets(
      String? image, double? height, double? width, String? imageStatus) {
    return (image != "" && image!.isNotEmpty)
        ? FadeInImage(
            placeholder: imageStatus == "1"
                ? AssetImage(
                    DesignConfig.setPngPath('profile_pic'),
                  )
                : AssetImage(
                    DesignConfig.setPngPath('placeholder_square'),
                  ),
            image: NetworkImage(
              image,
            ),
            imageErrorBuilder: (context, error, stackTrace) {
              return imageStatus == "1"
                  ? Image.asset(
                      DesignConfig.setPngPath('profile_pic'),
                      height: height,
                      width: width,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      DesignConfig.setPngPath('placeholder_square'),
                      height: height,
                      width: width,
                      fit: BoxFit.cover,
                    );
            },
            placeholderErrorBuilder: (context, error, stackTrace) {
              return imageStatus == "1"
                  ? Image.asset(
                      DesignConfig.setPngPath('profile_pic'),
                      height: height,
                      width: width,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      DesignConfig.setPngPath('placeholder_square'),
                      height: height,
                      width: width,
                      fit: BoxFit.cover,
                    );
            },
            height: height!,
            width: width!,
            fit: BoxFit.cover,
          )
        : imageStatus == "1"
            ? Image.asset(
                DesignConfig.setPngPath('profile_pic'),
                height: height,
                width: width,
                fit: BoxFit.cover,
              )
            : Image.asset(
                DesignConfig.setPngPath('placeholder_square'),
                height: height!,
                width: width!,
                fit: BoxFit.cover,
              );
  }

  static appBar(BuildContext context, double? width, String? text, bottom,
      {bool? status = false,
      double? preferSize = kToolbarHeight,
      String? from = "",
      String? latitude = "",
      longitude = ""}) {
    return PreferredSize(
      preferredSize: Size.fromHeight(preferSize!),
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.1),
            offset: Offset(0, 2.0),
            blurRadius: 12.0,
          )
        ]),
        child: AppBar(
            leading: InkWell(
                onTap: () {
                  if (from == "map") {
                    context
                        .read<SettingsCubit>()
                        .setLatitude(latitude.toString());
                    context
                        .read<SettingsCubit>()
                        .setLongitude(longitude.toString());
                    Navigator.pop(context);
                  } else {
                    if (status == false) {
                      Navigator.pop(context);
                    } else {
                      Future.delayed(Duration.zero, () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      });
                    }
                  }
                },
                child: Padding(
                    padding: EdgeInsetsDirectional.only(start: width! / 20),
                    child: Icon(
                        Platform.isIOS
                            ? Icons.arrow_back_ios
                            : Icons.arrow_back,
                        color: Theme.of(context).colorScheme.onPrimary))),
            backgroundColor: Theme.of(context).colorScheme.onSurface,
            shadowColor: textFieldBackground,
            elevation: 0,
            centerTitle: false,
            title: Text(text!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w500)),
            bottom: bottom),
      ),
    );
  }

  static appBarWihoutBackbutton(
      BuildContext context, double? width, String? text, bottom,
      {preferSize = kToolbarHeight,
      Widget? actionBar = const SizedBox.shrink()}) {
    return PreferredSize(
      preferredSize: Size.fromHeight(preferSize),
      child: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.1),
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
            title: Text(text!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w500)),
            bottom: bottom,
            actions: [actionBar!]),
      ),
    );
  }

  static Widget divider() {
    return DashLineView(
      fillRate: 0.5,
      direction: Axis.horizontal,
    );
  }

  static Divider dividerSolid() {
    return Divider(
        color: lightFont.withValues(alpha: 0.85), height: 0.2, thickness: 0.2);
  }

  static TextButton bottomBarTextButton(
      BuildContext context,
      int selectedIndex,
      int index,
      void Function() onPressed,
      String? activeIcon,
      String? inactiveIcon,
      String? iconTitle) {
    return TextButton(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(selectedIndex == index
              ? DesignConfig.setSvgPath(activeIcon!)
              : DesignConfig.setSvgPath(inactiveIcon!)),
          selectedIndex == index ? SizedBox(height: 2) : const SizedBox(),
          selectedIndex == index
              ? Text(iconTitle!.toUpperCase(),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimary))
              : const SizedBox.shrink(),
        ],
      ),
      onPressed: () => onPressed(),
    );
  }

  static Color orderStatusCartColor(String status) {
    if (status == pendingKey) {
      return orderPendingColor;
    } else if (status == confirmedKey) {
      return orderConfirmedColor;
    } else if (status == preparingKey) {
      return orderPreparingColor;
    } else if (status == outForDeliveryKey) {
      return orderOutForDeliveryColor;
    } else if (status == deliveredKey) {
      return orderDeliveredColor;
    } else if (status == cancelledKey) {
      return orderCancelledColor;
    } else if (status == readyForPickupKey) {
      return orderReadyForPickUpColor;
    } else {
      return blueColor;
    }
  }

  static Color riderCashStatusCartColor(String status) {
    if (status.toLowerCase() == collectedTypeKey.toLowerCase()) {
      return successColor;
    } else {
      return errorColor;
    }
  }

  static Color walletStatusCartColor(String status) {
    if (status == "1") {
      return successColor;
    } else if (status == "0") {
      return orderPendingColor;
    } else {
      return errorColor;
    }
  }
}
