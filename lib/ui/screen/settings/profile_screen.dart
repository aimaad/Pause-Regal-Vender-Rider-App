import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro_single_vender_rider/cubit/auth/authCubit.dart';
import 'package:erestro_single_vender_rider/cubit/profileManagement/getRiderDetailCubit.dart';
import 'package:erestro_single_vender_rider/cubit/profileManagement/updateUserDetailsCubit.dart';
import 'package:erestro_single_vender_rider/cubit/profileManagement/uploadProfileCubit.dart';
import 'package:erestro_single_vender_rider/data/repositories/profileManagement/profileManagementRepository.dart';
import 'package:erestro_single_vender_rider/ui/screen/settings/no_internet_screen.dart';
import 'package:erestro_single_vender_rider/ui/widgets/buttomContainer.dart';
import 'package:erestro_single_vender_rider/utils/constants.dart';
import 'package:erestro_single_vender_rider/utils/labelKeys.dart';
import 'package:erestro_single_vender_rider/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro_single_vender_rider/ui/styles/color.dart';
import 'package:erestro_single_vender_rider/ui/styles/design.dart';
import 'package:erestro_single_vender_rider/utils/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:erestro_single_vender_rider/utils/internetConnectivity.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ProfileScreenState createState() => ProfileScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (context) => MultiBlocProvider(providers: [
        BlocProvider<UploadProfileCubit>(
            create: (context) => UploadProfileCubit(
                  ProfileManagementRepository(),
                )),
        BlocProvider<UpdateUserDetailCubit>(
            create: (_) =>
                UpdateUserDetailCubit(ProfileManagementRepository())),
      ], child: const ProfileScreen()),
    );
  }
}

class ProfileScreenState extends State<ProfileScreen> {
  double? width, height;
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController phoneNumberController = TextEditingController(text: "");
  TextEditingController addressController = TextEditingController(text: "");
  String? countryCode = defaulCountryCode;
  bool status = false;
  final formKey = GlobalKey<FormState>();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  File? image;
  // get image File camera
  _getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    final croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedFile!.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        //   sourcePath: pickedFile!.path,
        //   aspectRatioPresets: [
        //   CropAspectRatioPreset.square,
        //   CropAspectRatioPreset.ratio3x2,
        //   CropAspectRatioPreset.original,
        //   CropAspectRatioPreset.ratio4x3,
        //   CropAspectRatioPreset.ratio16x9
        // ],
        uiSettings: [
          AndroidUiSettings(
              statusBarColor: Colors.black,
              toolbarWidgetColor: Colors.black,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(),
        ]);
    File rotatedImage =
        await FlutterExifRotation.rotateAndSaveImage(path: croppedImage!.path);
    image = rotatedImage;
    final userId = context.read<AuthCubit>().getId();
    context.read<UploadProfileCubit>().uploadProfilePicture(image, userId);
  }

//get image file from library
  _getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    final croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedFile!.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        //   sourcePath: pickedFile!.path,
        //   aspectRatioPresets: [
        //   CropAspectRatioPreset.square,
        //   CropAspectRatioPreset.ratio3x2,
        //   CropAspectRatioPreset.original,
        //   CropAspectRatioPreset.ratio4x3,
        //   CropAspectRatioPreset.ratio16x9
        // ],
        uiSettings: [
          AndroidUiSettings(
              statusBarColor: Colors.black,
              toolbarWidgetColor: Colors.black,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(),
        ]);
    File rotatedImage =
        await FlutterExifRotation.rotateAndSaveImage(path: croppedImage!.path);
    image = rotatedImage;
    final userId = context.read<AuthCubit>().getId();
    context.read<UploadProfileCubit>().uploadProfilePicture(image, userId);
  }

  Future chooseProfile(BuildContext context) {
    return showModalBottomSheet(
      isDismissible: true,
      backgroundColor: Theme.of(context).colorScheme.onSurface,
      shape: DesignConfig.setRoundedBorderCard(0.0, 0.0, 16.0, 16.0),
      isScrollControlled: true,
      enableDrag: true,
      showDragHandle: true,
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(
                  top: height! / 80.0,
                  bottom: height! / 80.0,
                  end: width! / 20.0,
                  start: width! / 20.0),
              child: Text(
                UiUtils.getTranslatedLabel(context, profilePictureLabel),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      _getFromGallery();
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                          top: height! / 80.0,
                          bottom: height! / 35.0,
                          end: width! / 20.0,
                          start: width! / 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                              height: 50,
                              width: 50,
                              decoration:
                                  DesignConfig.boxDecorationContainerBorder(
                                      commentBoxBorderColor,
                                      Theme.of(context).colorScheme.onSurface,
                                      100.0),
                              child: Icon(
                                Icons.photo_library,
                                color: Theme.of(context).colorScheme.onPrimary,
                              )),
                          SizedBox(height: height! / 80.0),
                          Text(
                            UiUtils.getTranslatedLabel(context, galleryLabel),
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _getFromCamera();
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                          top: height! / 80.0,
                          bottom: height! / 35.0,
                          end: width! / 20.0,
                          start: width! / 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              height: 50,
                              width: 50,
                              decoration:
                                  DesignConfig.boxDecorationContainerBorder(
                                      commentBoxBorderColor,
                                      Theme.of(context).colorScheme.onSurface,
                                      100.0),
                              child: Icon(
                                Icons.photo_camera,
                                color: Theme.of(context).colorScheme.onPrimary,
                              )),
                          SizedBox(height: height! / 80.0),
                          Text(
                            UiUtils.getTranslatedLabel(context, cameraLabel),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  )
                ]),
          ],
        );
      },
    );
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
    nameController =
        TextEditingController(text: context.read<AuthCubit>().getName());
    emailController =
        TextEditingController(text: context.read<AuthCubit>().getEmail());
    phoneNumberController =
        TextEditingController(text: context.read<AuthCubit>().getMobile());
    addressController =
        TextEditingController(text: context.read<AuthCubit>().getAddress());
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Widget nameField() {
    return Container(
        padding: EdgeInsetsDirectional.only(bottom: height! / 30.0),
        margin: EdgeInsets.zero,
        child: TextFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return UiUtils.getTranslatedLabel(context, enterNameLabel);
            }
            return null;
          },
          controller: nameController,
          cursorColor: lightFont,
          decoration: DesignConfig.inputDecorationextField(
              UiUtils.getTranslatedLabel(context, nameLabel),
              UiUtils.getTranslatedLabel(context, enterNameLabel),
              width!,
              context),
          keyboardType: TextInputType.text,
          style: TextStyle(
            color:
                Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  Widget addressField() {
    return Container(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        child: TextFormField(
            controller: addressController,
            decoration: DesignConfig.inputDecorationextField(
                UiUtils.getTranslatedLabel(context, addressLabel),
                UiUtils.getTranslatedLabel(context, enterAddressLabel),
                width!,
                context),
            keyboardType: TextInputType.text,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary
                  .withValues(alpha: 0.76),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            )));
  }

  Widget phoneNumberField() {
    return Container(
        padding: EdgeInsetsDirectional.only(bottom: height! / 30.0),
        margin: EdgeInsets.zero,
        child: TextFormField(
            validator: (value) {
              if (value!.isEmpty) {
                return UiUtils.getTranslatedLabel(
                    context, enterPhoneNumberLabel);
              }
              return null;
            },
            controller: phoneNumberController,
            enabled: (context.read<AuthCubit>().getType() == "google") ||
                    (context.read<AuthCubit>().getType() == "facebook")
                ? true
                : false,
            decoration: DesignConfig.inputDecorationextField(
                UiUtils.getTranslatedLabel(context, phoneNumberLabel),
                UiUtils.getTranslatedLabel(context, enterPhoneNumberLabel),
                width!,
                context),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary
                  .withValues(alpha: 0.76),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            )));
  }

  Widget emailField() {
    return Container(
        padding: EdgeInsetsDirectional.only(bottom: height! / 30.0),
        margin: EdgeInsets.zero,
        child: TextFormField(
          validator: (value) {
            return UiUtils.validateEmail(value!, StringsRes.enterEmail,
                UiUtils.getTranslatedLabel(context, enterValidEmailLabel));
          },
          controller: emailController,
          cursorColor: lightFont,
          decoration: DesignConfig.inputDecorationextField(
              UiUtils.getTranslatedLabel(context, emailIdLabel),
              StringsRes.enterEmail,
              width!,
              context),
          keyboardType: TextInputType.text,
          style: TextStyle(
            color:
                Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ));
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
                  UiUtils.getTranslatedLabel(context, profileLabel),
                  const PreferredSize(
                      preferredSize: Size.zero, child: SizedBox())),
              body: Form(
                key: formKey,
                child: BlocConsumer<UploadProfileCubit, UploadProfileState>(
                    listener: (context, state) {
                  if (state is UploadProfileFailure) {
                    UiUtils.setSnackBar(state.errorMessage, context, false,
                        type: "2");
                  } else if (state is UploadProfileSuccess) {
                    context.read<AuthCubit>().statusUpdateAuth(state.authModel);
                    context
                        .read<GetRiderDetailCubit>()
                        .statusUpdateAuth(state.authModel);
                  }
                }, builder: (context, state) {
                  return Container(
                      height: height,
                      margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                      decoration: DesignConfig.boxDecorationContainerHalf(
                          Theme.of(context).colorScheme.onSurface),
                      width: width,
                      child: Container(
                        margin: EdgeInsetsDirectional.only(
                            start: width! / 20.0,
                            end: width! / 20.0,
                            top: height! / 20.0),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.only(
                                    start: width! / 10.0,
                                    end: width! / 10.0,
                                    bottom: height! / 25.0),
                                child: Center(
                                  child: SizedBox(
                                    width: width! *
                                        0.35, // Responsive width for the avatar card
                                    height: width! * 0.35, // Keep it square
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: width! *
                                              0.15, // Responsive radius
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.5),
                                          child: Container(
                                            alignment: Alignment.center,
                                            child: ClipOval(
                                              child: DesignConfig.imageWidgets(
                                                context
                                                    .read<AuthCubit>()
                                                    .getProfile(),
                                                width! * 0.30, // pass as double
                                                width! * 0.30, // pass as double
                                                "1",
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              chooseProfile(context);
                                            },
                                            child: CircleAvatar(
                                              radius: width! *
                                                  0.055, // Responsive radius for edit button
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                              child: CircleAvatar(
                                                radius: width! * 0.045,
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                child: Icon(Icons.edit_outlined,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                                    size: width! * 0.045),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              nameField(),
                              emailField(),
                              phoneNumberField(),
                              addressField(),
                              BlocConsumer<UpdateUserDetailCubit,
                                      UpdateUserDetailState>(
                                  bloc: context.read<UpdateUserDetailCubit>(),
                                  listener: (context, state) {
                                    if (state is UpdateUserDetailFailure) {
                                      status = false;
                                    }
                                    if (state is UpdateUserDetailSuccess) {
                                      context
                                          .read<AuthCubit>()
                                          .updateUserName(nameController.text);
                                      context.read<AuthCubit>().updateUserEmail(
                                          emailController.text);
                                      context
                                          .read<AuthCubit>()
                                          .updateUserMobile(
                                              phoneNumberController.text);
                                      context
                                          .read<AuthCubit>()
                                          .updateUserAddress(
                                              addressController.text);
                                      UiUtils.setSnackBar(
                                          StringsRes.updateSuccessFully,
                                          context,
                                          false,
                                          type: "1");
                                      status = false;
                                    } else if (state
                                        is UpdateUserDetailFailure) {
                                      UiUtils.setSnackBar(
                                          state.errorMessage, context, false,
                                          type: "2");
                                      status = false;
                                    }
                                  },
                                  builder: (context, state) {
                                    return SizedBox(
                                      width: width,
                                      child: ButtonContainer(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        height: height,
                                        width: width,
                                        text: UiUtils.getTranslatedLabel(
                                            context, saveProfileLabel),
                                        start: 0,
                                        end: 0,
                                        bottom: height! / 55.0,
                                        top: height! / 30.0,
                                        status: status,
                                        borderColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        textColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        onPressed: () {
                                          setState(() {
                                            status = true;
                                          });
                                          if (formKey.currentState!
                                              .validate()) {
                                            context
                                                .read<UpdateUserDetailCubit>()
                                                .updateProfile(
                                                    userId: context
                                                        .read<AuthCubit>()
                                                        .getId(),
                                                    name: nameController.text,
                                                    email: emailController.text,
                                                    mobile:
                                                        phoneNumberController
                                                            .text,
                                                    address:
                                                        addressController.text);
                                          } else {
                                            setState(() {
                                              status = false;
                                            });
                                          }
                                        },
                                      ),
                                    );
                                  })
                            ],
                          ),
                        ),
                      ));
                }),
              ),
            ),
    );
  }
}
