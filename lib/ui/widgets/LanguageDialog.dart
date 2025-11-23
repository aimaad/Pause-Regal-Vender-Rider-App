import 'package:erestro_single_vender_rider/cubit/localization/appLocalizationCubit.dart';
import 'package:erestro_single_vender_rider/data/model/appLanguage.dart';
import 'package:erestro_single_vender_rider/ui/styles/design.dart';
import 'package:erestro_single_vender_rider/utils/appLanguages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageChangeDialog extends StatefulWidget {
  final String title, subtitle, from;
  final double? width, height;
  const LanguageChangeDialog({Key? key, required this.width, required this.height, required this.title, required this.subtitle, required this.from})
      : super(key: key);

  @override
  _LanguageChangeDialogState createState() => _LanguageChangeDialogState();
}

class _LanguageChangeDialogState extends State<LanguageChangeDialog> {
  @override
  Widget build(BuildContext context) {
    return contentBox(context);
  }

  Widget _buildAppLanguageTile({required AppLanguage appLanguage, required BuildContext context, required String currentSelectedLanguageCode}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          context.read<AppLocalizationCubit>().changeLanguage(appLanguage.languageCode);
          Navigator.of(context, rootNavigator: true).pop(true);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              appLanguage.languageName,
              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76), fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: appLanguage.languageCode == currentSelectedLanguageCode
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSecondary,
                    width: 1.75),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: appLanguage.languageCode == currentSelectedLanguageCode
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  contentBox(BuildContext context) {
    return Container(
      decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          BlocBuilder<AppLocalizationCubit, AppLocalizationState>(
            builder: (context, state) {
              return Padding(
                padding: EdgeInsetsDirectional.only(
                    
                    bottom: widget.height! / 80.0,
                    top: widget.height! / 80.0),
                child: Column(
                  children: appLanguages
                      .map((appLanguage) =>
                          _buildAppLanguageTile(appLanguage: appLanguage, context: context, currentSelectedLanguageCode: state.language.languageCode))
                      .toList(),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
