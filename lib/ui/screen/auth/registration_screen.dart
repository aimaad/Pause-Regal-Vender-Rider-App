import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro_single_vender_rider/cubit/auth/authCubit.dart';
import 'package:erestro_single_vender_rider/cubit/auth/registrationCubit.dart';
import 'package:erestro_single_vender_rider/cubit/city/addressCubit.dart';
import 'package:erestro_single_vender_rider/data/model/cityModel.dart';
import 'package:erestro_single_vender_rider/data/repositories/auth/authRepository.dart';
import 'package:erestro_single_vender_rider/data/repositories/city/cityRepository.dart';
import 'package:erestro_single_vender_rider/ui/screen/settings/no_internet_screen.dart';
import 'package:erestro_single_vender_rider/ui/widgets/buttomContainer.dart';
import 'package:erestro_single_vender_rider/ui/widgets/keyboardOverlay.dart';
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
import 'package:intl_phone_field/intl_phone_field.dart';
import 'dart:ui' as ui;

import 'package:intl_phone_field/phone_number.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<RegistrationCubit>(
                  create: (_) => RegistrationCubit(
                    AuthRepository(),
                  ),
                ),
                BlocProvider(
                  create: (context) => CityCubit(CityRepository()),
                ),
              ],
              child: const RegistrationScreen(),
            ));
  }
}

class RegistrationScreenState extends State<RegistrationScreen> {
  double? width, height;
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController phoneNumberController = TextEditingController(text: "");
  TextEditingController addressController = TextEditingController(text: "");
  TextEditingController passwordController = TextEditingController(text: "");
  TextEditingController confirmPasswordController =
      TextEditingController(text: "");
  TextEditingController serviceableCityController =
      TextEditingController(text: "");
  Timer? _debounce;
  String? countryCode = defaulCountryCode;
  bool status = false, obscure = true, confirmObscure = true;
  final formKey = GlobalKey<FormState>();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  File? image;
  List<CityModel> serviceableCityList = [];
  List<String> finalServiceableCityList = [];
  final ValueNotifier<double?> optionsViewWidthNotifier = ValueNotifier(null);
  String searchText = '';
  FocusNode numberFocusNode = FocusNode();
  FocusNode numberFocusNodeAndroid = FocusNode();
  bool _submitted = false;
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
        // sourcePath: pickedFile!.path,
        // aspectRatioPresets: [
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
    setState(() {
      image = rotatedImage;
    });
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
        // sourcePath: pickedFile!.path,
        // aspectRatioPresets: [
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
    setState(() {
      image = rotatedImage;
    });
  }

  Widget passwordField() {
    return Container(
        padding: EdgeInsetsDirectional.only(bottom: height! / 30.0),
        margin: EdgeInsets.zero,
        child: TextFormField(
          obscureText: obscure,
          validator: (value) {
            setState(() {
              status = false;
            });
            return UiUtils.validatePassword(value!, context);
          },
          controller: passwordController,
          onChanged: (value) {
            setState(() {
              passwordController.text;
            });
          },
          cursorColor:
              Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
          decoration: DesignConfig.inputDecorationextField(
              UiUtils.getTranslatedLabel(context, passwordLabel),
              UiUtils.getTranslatedLabel(context, enterPasswordLabel),
              width!,
              context,
              passwordWidget: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (obscure == true) {
                        obscure = false;
                      } else {
                        obscure = true;
                      }
                    });
                  },
                  child: Icon(
                      obscure == true ? Icons.visibility_off : Icons.visibility,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withValues(alpha: 0.76)))),
          keyboardType: TextInputType.text,
          style: TextStyle(
            color:
                Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  Widget confirmPasswordField() {
    return Container(
        padding: EdgeInsetsDirectional.only(bottom: height! / 30.0),
        margin: EdgeInsets.zero,
        child: TextFormField(
          obscureText: confirmObscure,
          validator: (value) {
            if (passwordController.text.trim() !=
                confirmPasswordController.text.trim()) {
              return UiUtils.getTranslatedLabel(
                  context, conformPasswordMathLabel);
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
          cursorColor:
              Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
          decoration: DesignConfig.inputDecorationextField(
              UiUtils.getTranslatedLabel(context, confirmPasswordLabel),
              UiUtils.getTranslatedLabel(context, enterConfirmPasswordLabel),
              width!,
              context,
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
                  child: Icon(
                      confirmObscure == true
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withValues(alpha: 0.76)))),
          keyboardType: TextInputType.text,
          style: TextStyle(
            color:
                Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ));
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

    serviceableCityController = TextEditingController();
    _debounce = Timer(const Duration(milliseconds: 0), () {});

    numberFocusNode.addListener(() {
      bool hasFocus = numberFocusNode.hasFocus;
      if (hasFocus) {
        KeyboardOverlay.showOverlay(context);
      } else {
        KeyboardOverlay.removeOverlay();
      }
    });
    numberFocusNodeAndroid.addListener(() {
      bool hasFocus = numberFocusNodeAndroid.hasFocus;
      if (hasFocus) {
        KeyboardOverlay.showOverlay(context);
      } else {
        KeyboardOverlay.removeOverlay();
      }
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  void _onSearchChanged(String query) {
    if (_debounce!.isActive) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (query.isNotEmpty) {
        context.read<CityCubit>().fetchCity(
            query.trim()); // Ensure fetchCity is implemented to handle API call
      }
    });
  }

  @override
  void dispose() {
    _debounce!.cancel();

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
        padding: EdgeInsetsDirectional.only(bottom: height! / 30.0),
        margin: EdgeInsets.zero,
        child: TextFormField(
            controller: addressController,
            decoration: DesignConfig.inputDecorationextField(
                UiUtils.getTranslatedLabel(context, addressLabel),
                UiUtils.getTranslatedLabel(context, enterAddressLabel),
                width!,
                context),
            validator: (value) {
              if (value!.isEmpty) {
                return UiUtils.getTranslatedLabel(context, enterAddressLabel);
              }
              return null;
            },
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
        padding: EdgeInsetsDirectional.only(bottom: height! / 40.0),
        margin: EdgeInsets.zero,
        child: IntlPhoneField(
          autovalidateMode: _submitted == false
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.always,
          validator: (PhoneNumber? value) {
            print('in widget validator');
            if (value == null || value.number.isEmpty) {
              print('Please Enter Your Phone No');
              return UiUtils.getTranslatedLabel(context, enterPhoneNumberLabel);
            }
            return null;
          },
          controller: phoneNumberController,
          textInputAction: TextInputAction.done,
          dropdownIcon: Icon(Icons.keyboard_arrow_down_rounded,
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary
                  .withValues(alpha: 0.76)),
          decoration: InputDecoration(
            filled: true,
            fillColor: textFieldBackground,
            contentPadding: EdgeInsetsDirectional.zero,
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(width: 1.0, color: textFieldBorder),
            ),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(width: 1.0, color: textFieldBorder)),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1.0, color: textFieldBorder),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1.0, color: textFieldBorder),
            ),
            disabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(width: 1.0, color: textFieldBorder),
            ),
            focusColor: white,
            counterStyle: const TextStyle(color: white, fontSize: 0),
            border: InputBorder.none,
            hintText:
                UiUtils.getTranslatedLabel(context, enterPhoneNumberLabel),
            labelStyle: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary
                  .withValues(alpha: 0.76),
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
            floatingLabelStyle: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary
                  .withValues(alpha: 0.76),
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary
                  .withValues(alpha: 0.76),
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          flagsButtonMargin: EdgeInsets.all(width! / 80.0),
          textAlignVertical: TextAlignVertical.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          focusNode: Platform.isIOS ? numberFocusNode : numberFocusNodeAndroid,
          dropdownIconPosition: IconPosition.trailing,
          initialCountryCode: defaulIsoCountryCode,
          style: TextStyle(
            color:
                Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.76),
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
          textAlign: Directionality.of(context) == ui.TextDirection.rtl
              ? TextAlign.right
              : TextAlign.left,
          onChanged: (phone) {
            setState(() {
              countryCode = phone.countryCode;
            });
          },
          onCountryChanged: ((value) {
            setState(() {
              print(value.dialCode);
              countryCode = value.dialCode;
              defaulIsoCountryCode = value.code;
            });
          }),
        ));
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

  void addUniqueServiceableCityValue(CityModel selection) {
    if (!finalServiceableCityList.contains(selection.id)) {
      serviceableCityList.add(selection);
      finalServiceableCityList.add(selection.id!);
      print('$selection added');
    } else {
      print('$selection is already in the list');
    }
  }

  Widget serviceableCityField() {
    return BlocBuilder<CityCubit, CityState>(
      builder: (context, state) {
        print("state--city:${state}");
        return Container(
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          child: Autocomplete<CityModel>(
            fieldViewBuilder: (BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted) {
              if (serviceableCityController != textEditingController) {
                serviceableCityController = textEditingController;
                // Add listener if not already added
                serviceableCityController.addListener(() {
                  _onSearchChanged(serviceableCityController.text);
                });
              }
              return TextFormField(
                decoration: DesignConfig.inputDecorationextField(
                    UiUtils.getTranslatedLabel(context, serviceableCityLabel),
                    UiUtils.getTranslatedLabel(context, searchCityLabel),
                    width!,
                    context),
                controller: serviceableCityController,
                focusNode: focusNode,
                onFieldSubmitted: (String value) {
                  onFieldSubmitted();
                },
              );
            },
            optionsViewBuilder: (BuildContext context,
                AutocompleteOnSelected<CityModel> onSelected,
                Iterable<CityModel> options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 200,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final CityModel option = options.elementAt(index);
                          return ListTile(
                            title: Text('${option.name}'),
                            onTap: () {
                              onSelected(option);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<CityModel>.empty();
              }
              if (state is CitySuccess) {
                return state.cityList.where((CityModel option) {
                  return option.name!
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
                });
              } else {
                return const Iterable<CityModel>.empty();
              }
            },
            onSelected: (CityModel selection) {
              addUniqueServiceableCityValue(selection);
              setState(() {});
              serviceableCityController.clear();
              debugPrint('Selected city: ${selection.name}');
            },
            displayStringForOption: (CityModel city) => city.name!,
          ),
        );
      },
    );
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
                  UiUtils.getTranslatedLabel(context, createYourAccountLabel),
                  const PreferredSize(
                      preferredSize: Size.zero, child: SizedBox())),
              body: Form(
                key: formKey,
                child: Container(
                    height: height,
                    margin: EdgeInsetsDirectional.only(top: height! / 80.0),
                    decoration: DesignConfig.boxDecorationContainerHalf(
                        Theme.of(context).colorScheme.onSurface),
                    width: width,
                    child: Container(
                      margin: EdgeInsetsDirectional.only(
                          start: width! / 20.0, end: width! / 20.0),
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
                                child: Stack(
                                  alignment: Alignment.topCenter,
                                  clipBehavior: Clip.none,
                                  children: [
                                    Center(
                                      child: CircleAvatar(
                                        radius: 45,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.50),
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: ClipOval(
                                              child: image != null
                                                  ? Image.file(
                                                      image!,
                                                      height: 85,
                                                      width: 85,
                                                    )
                                                  : DesignConfig.imageWidgets(
                                                      context
                                                          .read<AuthCubit>()
                                                          .getProfile(),
                                                      85,
                                                      85,
                                                      "1")),
                                        ),
                                      ),
                                    ),
                                    Positioned.directional(
                                      textDirection: Directionality.of(context),
                                      top: height! / 16.0,
                                      start: width! / 2.5,
                                      child: GestureDetector(
                                        onTap: () {
                                          chooseProfile(context);
                                        },
                                        child: CircleAvatar(
                                          radius: 20,
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          child: CircleAvatar(
                                            radius: 18,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            child: Icon(Icons.edit_outlined,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              nameField(),
                              emailField(),
                              phoneNumberField(),
                              passwordField(),
                              confirmPasswordField(),
                              addressField(),
                              serviceableCityField(),
                              serviceableCityList.isNotEmpty
                                  ? Wrap(
                                      children: List.generate(
                                          serviceableCityList.length,
                                          (index) => Padding(
                                                padding:
                                                    EdgeInsetsDirectional.only(
                                                  end: 8.0,
                                                  top: height! / 80.0,
                                                ),
                                                child: Chip(
                                                    side: BorderSide(
                                                        color: textFieldBorder),
                                                    backgroundColor:
                                                        textFieldBackground,
                                                    deleteIconColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary
                                                            .withValues(
                                                                alpha: 0.75),
                                                    labelStyle: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary
                                                            .withValues(
                                                                alpha: 0.75)),
                                                    label: Text(
                                                        serviceableCityList[
                                                                index]
                                                            .name!),
                                                    onDeleted: () {
                                                      setState(() {
                                                        serviceableCityList
                                                            .removeAt(index);
                                                        finalServiceableCityList
                                                            .removeAt(index);
                                                      });
                                                    }),
                                              )))
                                  : Container(),
                              BlocConsumer<RegistrationCubit,
                                      RegistrationState>(
                                  bloc: context.read<RegistrationCubit>(),
                                  listener: (context, state) {
                                    if (state is RegistrationSuccess) {
                                      Navigator.pop(context);

                                      status = false;
                                    } else if (state is RegistrationFailure) {
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
                                            context, submitLabel),
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
                                            _submitted = true;
                                          });
                                          if (formKey.currentState!
                                              .validate()) {
                                            if (serviceableCityList.isEmpty) {
                                              UiUtils.setSnackBar(
                                                  UiUtils.getTranslatedLabel(
                                                      context,
                                                      pleassEnterServiceableCityLabel),
                                                  context,
                                                  false,
                                                  type: "2");
                                            } else {
                                              context
                                                  .read<RegistrationCubit>()
                                                  .registration(
                                                      image ?? File(''),
                                                      nameController.text,
                                                      emailController.text,
                                                      phoneNumberController
                                                          .text,
                                                      addressController.text,
                                                      finalServiceableCityList
                                                          .join(",")
                                                          .toString(),
                                                      confirmPasswordController
                                                          .text);
                                            }
                                          } else {
                                            setState(() {
                                              status = false;
                                            });
                                          }
                                        },
                                      ),
                                    );
                                  })
                            ]),
                      ),
                    )),
              ),
            ),
    );
  }
}
