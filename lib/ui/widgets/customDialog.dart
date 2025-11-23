import 'package:erestro_single_vender_rider/app/routes.dart';
import 'package:erestro_single_vender_rider/cubit/auth/authCubit.dart';
import 'package:erestro_single_vender_rider/cubit/auth/deleteMyAccountCubit.dart';
import 'package:erestro_single_vender_rider/cubit/profileManagement/getRiderDetailCubit.dart';
import 'package:erestro_single_vender_rider/cubit/profileManagement/updateUserDetailsCubit.dart';
import 'package:erestro_single_vender_rider/ui/styles/color.dart';
import 'package:erestro_single_vender_rider/ui/styles/design.dart';
import 'package:erestro_single_vender_rider/ui/widgets/smallButtomContainer.dart';
import 'package:erestro_single_vender_rider/utils/labelKeys.dart';
import 'package:erestro_single_vender_rider/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomDialog extends StatefulWidget {
  final String title, subtitle, from;
  final double? width, height;
  const CustomDialog({Key? key, required this.width, required this.height, required this.title, required this.subtitle, required this.from})
      : super(key: key);

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: DesignConfig.setRounded(16.0),
      
      child: contentBox(context),
    );
  }

  contentBox(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: widget.height! / 40.0),
      decoration: DesignConfig.boxDecorationContainer(Theme.of(context).colorScheme.onSurface, 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(widget.title,
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w700, fontStyle: FontStyle.normal, fontSize: 14.0),
              textAlign: TextAlign.left),
          Padding(
            padding: EdgeInsetsDirectional.only(start: widget.width! / 40.0, top: widget.height! / 80.0, end: widget.width! / 40.0),
            child: Text(widget.subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                )),
          ),
          SizedBox(
            height: widget.height! / 40.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SmallButtonContainer(
                  color: Theme.of(context).colorScheme.surface,
                  height: widget.height,
                  width: widget.width,
                  text: UiUtils.getTranslatedLabel(context, cancelLabel),
                  start: widget.width! / 20.0,
                  end: widget.width! / 40.0,
                  bottom: widget.height! / 60.0,
                  top: widget.height! / 99.0,
                  radius: 5.0,
                  status: false,
                  borderColor: Theme.of(context).colorScheme.onSurface,
                  textColor: Theme.of(context).colorScheme.onPrimary,
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop(true);
                  },
                ),
              ),
              widget.from == UiUtils.getTranslatedLabel(context, logoutLabel)
                  ? Expanded(
                      child: SmallButtonContainer(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                        height: widget.height,
                        width: widget.width,
                        text: UiUtils.getTranslatedLabel(context, logoutLabel),
                        start: widget.width! / 40.0,
                        end: widget.width! / 20.0,
                        bottom: widget.height! / 60.0,
                        top: widget.height! / 99.0,
                        radius: 5.0,
                        status: false,
                        borderColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                        textColor: Theme.of(context).colorScheme.primary,
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).pop(true);
                          context.read<AuthCubit>().signOut();
                          Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (Route<dynamic> route) => false, arguments: {'from': 'logout'});
                        },
                      ),
                    )
                  : widget.from == UiUtils.getTranslatedLabel(context, deleteLabel)
                      ? Expanded(
                          child: BlocConsumer<DeleteMyAccountCubit, DeleteMyAccountState>(
                              bloc: context.read<DeleteMyAccountCubit>(),
                              listener: (context, state) {
                                if (state is DeleteMyAccountFailure) {
                                  Center(
                                      child: SizedBox(
                                    width: widget.width! / 2,
                                    child: Text(state.errorMessage.toString(),
                                        textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(overflow: TextOverflow.ellipsis)),
                                  ));
                                }
                                if (state is DeleteMyAccountSuccess) {
                                  Navigator.of(context, rootNavigator: true).pop(true);
                                  context.read<AuthCubit>().signOut();
                                  Navigator.of(context)
                                      .pushNamedAndRemoveUntil(Routes.login, (Route<dynamic> route) => false, arguments: {'from': 'delete'});
                                }
                              },
                              builder: (context, state) {
                                return SmallButtonContainer(
                                    color: Theme.of(context).colorScheme.error,
                                    height: widget.height,
                                    width: widget.width,
                                    text: UiUtils.getTranslatedLabel(context, deleteLabel),
                                    start: widget.width! / 40.0,
                                    end: widget.width! / 20.0,
                                    bottom: widget.height! / 60.0,
                                    top: widget.height! / 99.0,
                                    radius: 5.0,
                                    status: false,
                                    borderColor: Theme.of(context).colorScheme.error,
                                    textColor: white,
                                    onTap: () {
                                      context.read<DeleteMyAccountCubit>().deleteMyAccount(riderId: context.read<AuthCubit>().getId());
                                    });
                              }),
                        )
                      : Expanded(
                          child: BlocConsumer<UpdateUserDetailCubit, UpdateUserDetailState>(
                              bloc: context.read<UpdateUserDetailCubit>(),
                              listener: (context, state) {
                                if (state is UpdateUserDetailFailure) {
                                   Navigator.of(context, rootNavigator: true).pop(true);
                                   UiUtils.setSnackBar(state.errorMessage, context, false, type: "2");
                                }
                                if (state is UpdateUserDetailSuccess) {
                                  context.read<GetRiderDetailCubit>().statusUpdateAuth(state.authModel);
                                  context.read<AuthCubit>().statusUpdateAuth(state.authModel);
                                  Navigator.of(context, rootNavigator: true).pop(true);
                                  
                                }
                              },
                              builder: (context, state) {
                                return SmallButtonContainer(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                                    height: widget.height,
                                    width: widget.width,
                                    text: context.read<AuthCubit>().getAcceptOrders() == "1"
                                        ? UiUtils.getTranslatedLabel(context, offLabel)
                                        : UiUtils.getTranslatedLabel(context, onLabel),
                                    start: widget.width! / 40.0,
                                    end: widget.width! / 20.0,
                                    bottom: widget.height! / 60.0,
                                    top: widget.height! / 99.0,
                                    radius: 5.0,
                                    status: false,
                                    borderColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                                    textColor: Theme.of(context).colorScheme.primary,
                                    onTap: () {
                                      print(
                                          "status:${context.read<AuthCubit>().getAcceptOrders()}--${context.read<AuthCubit>().getAcceptOrders() == "1" ? "0" : "1"}");
                                      context.read<UpdateUserDetailCubit>().updateProfile(
                                          userId: context.read<AuthCubit>().getId(),
                                          name: context.read<AuthCubit>().getName(),
                                          email: context.read<AuthCubit>().getEmail(),
                                          mobile: context.read<AuthCubit>().getMobile(),
                                          address: context.read<AuthCubit>().getAddress(),
                                          status: context.read<AuthCubit>().getAcceptOrders() == "1" ? "0" : "1");
                                    });
                              }),
                        )
            ],
          ),
        ],
      ),
    );
  }
}
