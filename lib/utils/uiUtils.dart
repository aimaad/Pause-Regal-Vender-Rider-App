import 'package:erestro_single_vender_rider/app/appLocalization.dart';
import 'package:erestro_single_vender_rider/ui/styles/color.dart';
import 'package:erestro_single_vender_rider/utils/labelKeys.dart';
import 'package:flutter/material.dart';

class UiUtils {
  static void setSnackBar(String msg, BuildContext context, bool showAction, {Function? onPressedAction, Duration? duration, required String type}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          textAlign: showAction ? TextAlign.start : TextAlign.start,
          maxLines: 2,
          style: const TextStyle(
            color: white,
            fontSize: 12.0,
            fontWeight: FontWeight.normal,
          )),
      behavior: SnackBarBehavior.floating,
      duration: duration ?? const Duration(seconds: 2),
      backgroundColor: type == "1" ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.error,
      action: showAction
          ? SnackBarAction(
              label: "Retry",
              onPressed: onPressedAction as void Function(),
              textColor: white,
            )
          : null,
      elevation: 2.0,
    ));
  }

  static Locale getLocaleFromLanguageCode(String languageCode) {
    List<String> result = languageCode.split("-");
    return result.length == 1 ? Locale(result.first) : Locale(result.first, result.last);
  }

  static String getTranslatedLabel(BuildContext context, String labelKey) {
    return (AppLocalization.of(context)!.getTranslatedValues(labelKey) ?? labelKey).trim();
  }

  static String? validatePass(String value, String? msg1, String? msg2) {
    if (value.isEmpty) {
      return msg1;
    } else {
      if (value.length <= 8) {
        return msg2;
      } else {
        return null;
      }
    }
  }

  static String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  static String? validatePassword(String value, BuildContext context) {
    RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~_.?=^`-]).{8,}$');
    if (value.isEmpty) {
      return UiUtils.getTranslatedLabel(context, enterPasswordLabel);
    } else {
      if (!regex.hasMatch(value)) {
        return UiUtils.getTranslatedLabel(context, passwordValidationMessageLabel);
      } else {
        return null;
      }
    }
  }

  static String? validateEmail(String value, String? msg1, String? msg2) {
                                                               
    if (value.isEmpty) {
      return msg1;
    } else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value)) {
      return msg2;
    } else {
      return null;
    }
  }
}
