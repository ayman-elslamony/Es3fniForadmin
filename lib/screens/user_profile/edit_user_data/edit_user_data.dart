import 'dart:io';
import 'package:admin/models/user_data.dart';
import 'package:admin/providers/home.dart';
import 'package:admin/screens/user_profile/edit_user_data/widgets/editImage.dart';
import 'package:flutter/material.dart';
import 'package:admin/core/models/device_info.dart';
import 'package:admin/core/ui_components/info_widget.dart';
import 'package:admin/providers/auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'widgets/edit_address.dart';
import 'widgets/edit_personal_info_card.dart';

class EditProfile extends StatefulWidget {
   final UserData userData;

   EditProfile({@required this.userData});

   @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  Home _home;
  File _imageFile;
  String address;
  TextEditingController name= TextEditingController();
  String lat;
  String lng;
  String socialStatus;
  String phone;
  bool _isEditLocationEnable = false;
  bool _selectUserLocationFromMap = false;
  List<String> addList = [];
  final GlobalKey<ScaffoldState> _userProfileState = GlobalKey<ScaffoldState>();
  TextEditingController _anotherInfoTextEditingController =
      TextEditingController();
  final TextEditingController controller = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formKeyForName = GlobalKey<FormState>();
  String initialCountry = 'EG';
  PhoneNumber number = PhoneNumber(isoCode: 'EG');
  String phoneNumber;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _home = Provider.of<Home>(context, listen: false);
    address = widget.userData.address;
    addList = translator.currentLanguage == "en"
          ? ['Add Name','Add Image', 'Add Phone', 'Add Address', 'Add Another Info']
          : ['اضافه اسم','اضافه صوره', 'اضافه هاتف', 'اضافه عنوان', 'اضافه معلومات اخرى'];
    
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  getImageFile(File file) {
    _imageFile = file;
  }

  getAddress(String add,String lat,String lng) {
    address = add;
    this.lat =lat;
    this.lng =lng;
  }

  editProfile(String type, BuildContext context,DeviceInfo deviceInfo) {
    if (type == 'image' || type == 'صوره') {
      showDialog(
          context: context,
          builder: (context) => Directionality(
                textDirection: translator.currentLanguage == "en"
                    ? TextDirection.ltr
                    : TextDirection.rtl,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0))),
                  contentPadding: EdgeInsets.only(top: 10.0),
                  content: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.18,
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: EditImage(
                          imgUrl: widget.userData.imgUrl,
                          getImageFile: getImageFile,
                        ),
                      )),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(
                          translator.currentLanguage == "en" ? 'Ok' : 'موافق'),
                      onPressed: () async {
                        if (_imageFile != null) {
                          print(_imageFile);
                          bool x = await _home.editProfile(
                            nurseId: widget.userData.docId,
                            userName: widget.userData.name,
                              type: 'image', picture: _imageFile);
                          if (x) {
                            Toast.show(
                                translator.currentLanguage == "en"
                                    ? "Scuessfully Editing"
                                    : 'نجح التعديل',
                                context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.BOTTOM);
                            Navigator.of(context).pop();
                          } else {
                            Toast.show(
                                translator.currentLanguage == "en"
                                    ? "Please try again later"
                                    : 'من فضلك حاول مره اخرى',
                                context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.BOTTOM);
                          }
                        } else {
                          Toast.show("Please enter your Image", context,
                              duration: Toast.LENGTH_SHORT,
                              gravity: Toast.BOTTOM);
                        }
                      },
                    ),
                    FlatButton(
                      child: Text(translator.currentLanguage == "en"
                          ? 'Cancel'
                          : 'الغاء'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ));
    }
    if (type == 'Phone Number' || type == 'رقم الهاتف') {
      if(widget.userData.phoneNumber.contains('+20')){
        String phoneNumber = widget.userData.phoneNumber.replaceAll('+20', '');
        String dialCode = '+20';
        number = PhoneNumber(isoCode: 'EG',dialCode: dialCode,phoneNumber: phoneNumber);
      }else{
        number =PhoneNumber(phoneNumber: widget.userData.phoneNumber);
      }
      showDialog(
          context: context,
          builder: (context) => Directionality(
                textDirection: translator.currentLanguage == "en"
                    ? TextDirection.ltr
                    : TextDirection.rtl,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0))),
                  contentPadding: EdgeInsets.only(top: 10.0),
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InternationalPhoneNumberInput(
                      onInputChanged: (PhoneNumber number) {
                        phoneNumber = number.phoneNumber;
                      },
                      focusNode: focusNode,
                      ignoreBlank: false,
                      autoValidate: false,
                      selectorTextStyle: TextStyle(color: Colors.black),
                      initialValue: number,
                      textFieldController: controller,
                      inputBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.indigo),
                      ),
                      hintText: translator.currentLanguage == "en"
                          ? 'phone number'
                          : 'رقم الهاتف',
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(
                          translator.currentLanguage == "en" ? 'Ok' : 'موافق'),
                      onPressed: () async {
                        focusNode.unfocus();
                        if (controller.text.trim().length == 12 && phoneNumber != widget.userData.phoneNumber ) {
                          bool x = await _home.editProfile(
                            type: 'Phone Number',nurseId: widget.userData.docId,
                            phone: phoneNumber.toString(),
                          );
                          if (x) {
                            Toast.show(
                                translator.currentLanguage == "en"
                                    ? "Scuessfully Editing"
                                    : 'نجح التعديل',
                                context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.BOTTOM);
                            Navigator.of(context).pop();
                          } else {
                            Toast.show(
                                translator.currentLanguage == "en"
                                    ? "Please try again later"
                                    : 'من فضلك حاول مره اخرى',
                                context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.BOTTOM);
                          }
                        } else if(phoneNumber == widget.userData.phoneNumber ){
                          Toast.show(
                              translator.currentLanguage == "en"
                                  ? 'Already exists'
                                  : 'الرقم موجود بالفعل',
                              context);
                        }else {
                          Toast.show(
                              translator.currentLanguage == "en"
                                  ? 'invalid phone number'
                                  : 'الرقم غير صحيح',
                              context);
                        }
                      },
                    ),
                    FlatButton(
                      child: Text(translator.currentLanguage == "en"
                          ? 'Cancel'
                          : 'الغاء'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ));
    }

    if (type == 'Name' || type == 'الاسم') {
      name.text = widget.userData.name;
      showDialog(
          context: context,
          builder: (context) => Directionality(
                textDirection: translator.currentLanguage == "en"
                    ? TextDirection.ltr
                    : TextDirection.rtl,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0))),
                  contentPadding: EdgeInsets.only(top: 10.0),
                  content: Form(
                    key: formKeyForName,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 7.0),
                      height: 80,
                      child: TextFormField(
                        autofocus: false,
                        textInputAction:
                        TextInputAction.done,
                        controller: name,
                        decoration: InputDecoration(
                          labelText: translator
                              .currentLanguage ==
                              "en"
                              ? "Nurse name"
                              : 'اسم المسعف',
                          focusedBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(
                                Radius.circular(
                                    10.0)),
                            borderSide: BorderSide(
                              color: Colors.indigo,
                            ),
                          ),
                          errorBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(
                                Radius.circular(
                                    10.0)),
                            borderSide: BorderSide(
                              color: Colors.indigo,
                            ),
                          ),
                          focusedErrorBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(
                                Radius.circular(
                                    10.0)),
                            borderSide: BorderSide(
                              color: Colors.indigo,
                            ),
                          ),
                          disabledBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(
                                Radius.circular(
                                    10.0)),
                            borderSide: BorderSide(
                              color: Colors.indigo,
                            ),
                          ),
                          enabledBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(
                                Radius.circular(
                                    10.0)),
                            borderSide: BorderSide(
                                color:
                                Colors.indigo),
                          ),
                          labelStyle: TextStyle(
                              color: Colors.indigo),
                        ),
                        keyboardType:
                        TextInputType.text,
// ignore: missing_return
                        validator: (String value) {
                          if (value
                              .trim()
                              .isEmpty) {
                            return translator
                                .currentLanguage ==
                                "en"
                                ? "Please enter nurse name!"
                                : 'من فضلك ادخل اسم المسعف';
                          }
                          if (value.trim().length <
                              3) {
                            return translator
                                .currentLanguage ==
                                "en"
                                ? "Invalid Name!"
                                : 'الاسم خطاء';
                          }
                        },
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(
                          translator.currentLanguage == "en" ? 'Ok' : 'موافق'),
                      onPressed: () async {
                        focusNode.unfocus();
                        if (name.text != widget.userData.name) {
                          bool x = await _home.editProfile(
                            type: 'Name',nurseId: widget.userData.docId,
                            userName:name.text
                          );
                          if (x) {
                            Toast.show(
                                translator.currentLanguage == "en"
                                    ? "Scuessfully Editing"
                                    : 'نجح التعديل',
                                context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.BOTTOM);
                            Navigator.of(context).pop();
                          } else {
                            Toast.show(
                                translator.currentLanguage == "en"
                                    ? "Please try again later"
                                    : 'من فضلك حاول مره اخرى',
                                context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.BOTTOM);
                          }
                        } else if (name.text != widget.userData.name) {
                          Toast.show(
                              translator.currentLanguage == "en"
                                  ? 'Already exists'
                                  : 'الاسم موجود بالفعل',
                              context);
                        }else {
                          Toast.show(
                              translator.currentLanguage == "en"
                                  ? 'invalid phone number'
                                  : 'الاسم غير صحيح',
                              context);
                        }
                      },
                    ),
                    FlatButton(
                      child: Text(translator.currentLanguage == "en"
                          ? 'Cancel'
                          : 'الغاء'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ));
    }
    if (type == 'Address' || type == 'العنوان') {
      showDialog(
          context: context,
          builder: (context) => Directionality(
                textDirection: translator.currentLanguage == "en"
                    ? TextDirection.ltr
                    : TextDirection.rtl,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0))),
                  contentPadding: EdgeInsets.only(top: 10.0),
                  content: SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: EditAddress(
                        getAddress: getAddress,
                        address: widget.userData.address,
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(
                          translator.currentLanguage == "en" ? 'Ok' : 'موافق'),
                      onPressed: () async {
                        if (address != null && address != widget.userData.address) {
                          print(address);
                          bool x = await _home.editProfile(
                            type: 'Address',nurseId: widget.userData.docId,
                            lat: lat,
                            lng: lng,
                            address: address,
                          );
                          if (x) {
                            Toast.show(
                                translator.currentLanguage == "en"
                                    ? "Scuessfully Editing"
                                    : 'نجح التعديل',
                                context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.BOTTOM);
                            Navigator.of(context).pop();
                          } else {
                            Toast.show(
                                translator.currentLanguage == "en"
                                    ? "Please try again later"
                                    : 'من فضلك حاول مره اخرى',
                                context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.BOTTOM);
                          }
                        } else if(address == widget.userData.address){
                          Toast.show(
                              translator.currentLanguage == "en"
                                  ? "Already exists"
                                  : 'العنوان موجود بالفعل',
                              context,
                              duration: Toast.LENGTH_SHORT,
                              gravity: Toast.BOTTOM);
                        }else {
                          Toast.show(
                              translator.currentLanguage == "en"
                                  ? "Please enter your address"
                                  : 'من فضلك ادخل العنوان',
                              context,
                              duration: Toast.LENGTH_SHORT,
                              gravity: Toast.BOTTOM);
                        }
                      },
                    ),
                    FlatButton(
                      child: Text(translator.currentLanguage == "en"
                          ? 'Cancel'
                          : 'الغاء'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ));
    }
    if (type == 'Another Info' || type == 'معلومات اخرى') {
      _anotherInfoTextEditingController.text = widget.userData.aboutYou;
      showDialog(
          context: context,
          builder: (context) => Directionality(
                textDirection: translator.currentLanguage == "en"
                    ? TextDirection.ltr
                    : TextDirection.rtl,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0))),
                  contentPadding: EdgeInsets.only(top: 10.0),
                  content: StatefulBuilder(
                    builder: (context, setState) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: formKey,
                        child: Container(
                          height: 90,
                          padding: EdgeInsets.symmetric(vertical: 7.0),
                          child: TextFormField(
                            controller: _anotherInfoTextEditingController,
                            autofocus: false,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              labelText: translator.currentLanguage == "en"
                                  ? "Another Info"
                                  : 'معلومات اخرى',
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(
                                  color: Colors.indigo,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(
                                  color: Colors.indigo,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(
                                  color: Colors.indigo,
                                ),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(
                                  color: Colors.indigo,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                borderSide: BorderSide(color: Colors.indigo),
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            maxLines: 5,
                            minLines: 2,
                            // ignore: missing_return
                            validator: (val) {
                              if (val.trim().length == 0) {
                                return translator.currentLanguage=='en'?'Please write some info':'من فضلك ادخل بعض البيانات';
                              }
                              if (val.trim() == widget.userData.aboutYou) {
                                return translator.currentLanguage=='en'?'Already exists':'موجود بالفعل';
                              }

                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(
                          translator.currentLanguage == "en" ? 'Ok' : 'موافق'),
                      onPressed: () async {
                        if (formKey.currentState.validate()) {
                          formKey.currentState.save();

                          bool x = await _home.editProfile(
                            type: 'Another Info',nurseId: widget.userData.docId,
                            aboutYou: _anotherInfoTextEditingController.text,
                          );
                          if (x) {
                            Toast.show(
                                translator.currentLanguage == "en"
                                    ? "Scuessfully Editing"
                                    : 'نجح التعديل',
                                context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.BOTTOM);
                            Navigator.of(context).pop();
                          } else {
                            Toast.show(
                                translator.currentLanguage == "en"
                                    ? "Please try again later"
                                    : 'من فضلك حاول مره اخرى',
                                context,
                                duration: Toast.LENGTH_SHORT,
                                gravity: Toast.BOTTOM);
                          }
                        }
                      },
                    ),
                    FlatButton(
                      child: Text(translator.currentLanguage == "en"
                          ? 'Cancel'
                          : 'الغاء'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ));
    }
  }

  personalInfo(
      {String title,
      String subtitle,
      DeviceInfo infoWidget,
      bool enableEdit = true,
      BuildContext context,
      IconData iconData}) {
    return ListTile(
      title: Text(
        title,
        style: infoWidget.titleButton.copyWith(color: Colors.indigo),
      ),
      leading: Icon(
        iconData,
        color: Colors.indigo,
      ),
      trailing: enableEdit
          ? IconButton(
              icon: Icon(
                Icons.edit,
                color: Colors.indigo,
              ),
              onPressed: () {
                editProfile(title, context,infoWidget);
              })
          : null,
      subtitle: Text(
        subtitle,
        style: infoWidget.subTitle.copyWith(color: Colors.grey[600]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: translator.currentLanguage == "en"
          ? TextDirection.ltr
          : TextDirection.rtl,
      child: InfoWidget(
        builder: (context, infoWidget) => Scaffold(
            key: _userProfileState,
            appBar: PreferredSize(
              preferredSize: Size(
                  infoWidget.screenWidth,
                  infoWidget.orientation == Orientation.portrait
                      ? infoWidget.screenHeight * 0.075
                      : infoWidget.screenHeight * 0.09),
              child: AppBar(
                shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40))),
                leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: infoWidget.orientation == Orientation.portrait
                          ? infoWidget.screenWidth * 0.05
                          : infoWidget.screenWidth * 0.035,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                actions: <Widget>[
                  PopupMenuButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.indigo)
                    ),
                    initialValue: '',
                    tooltip:
                        translator.currentLanguage == "en" ? 'Select' : 'اختار',
                    itemBuilder: (context) => addList
                        .map((String val) => PopupMenuItem<String>(
                              value: val,
                              child: Center(child: Text(val.toString())),
                            ))
                        .toList(),
                    onSelected: (val) {
                      if (val == 'Add Name' || val == 'اضافه اسم') {
                        editProfile('Name', context,infoWidget);
                      }
                      if (val == 'Add Image' || val == 'اضافه صوره') {
                        editProfile('image', context,infoWidget);
                      }
                      if (val == 'Add Phone' || val == 'اضافه هاتف') {
                        editProfile('Phone Number', context,infoWidget);
                      }
                      if (val == 'Add Address' || val == 'اضافه عنوان') {
                        editProfile('Address', context,infoWidget);
                      }
                      if (val == 'Add Another Info' ||
                          val == 'اضافه معلومات اخرى') {
                        editProfile('Another Info', context,infoWidget);
                      }
                    },
                    icon: Icon(
                      Icons.more_vert,
                    ),
                  ),
                ],
              ),
            ),
            body: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, left: 2.0, right: 2.0),
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        topLeft: Radius.circular(15),
                      ),
                      color: Colors.indigo,
                    ),
                    child: Center(
                      child: Stack(
                        children: <Widget>[
                          SizedBox(
                            width: 160,
                            height: 130,
                            child: Container(
                              decoration: BoxDecoration(
                                border:
                                Border.all(color: Colors.indigo),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ClipRRect(
                                //backgroundColor: Colors.white,
                                //backgroundImage:
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(15)),
                                  child: FadeInImage.assetNetwork(
                                      fit: BoxFit.fill,
                                      placeholder: 'assets/user.png',
                                      image: widget.userData.imgUrl)),
                            ),
                          ),
                          Positioned(
                              bottom: 0.0,
                              right: 0.0,
                              left: 0.0,
                              child: InkWell(
                                onTap: () {
                                  editProfile('image', context,infoWidget);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black45,
                                    borderRadius: BorderRadius.only(
                                        bottomRight:
                                        Radius.circular(15),
                                        bottomLeft:
                                        Radius.circular(15)),
                                  ),
                                  height: 35,
                                  child: Row(
                                    textDirection:
                                    translator.currentLanguage ==
                                        "en"
                                        ? TextDirection.ltr
                                        : TextDirection.rtl,
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                          translator.currentLanguage ==
                                              "en"
                                              ? 'Edit'
                                              : 'تعديل',
                                          style: infoWidget.subTitle
                                              .copyWith(
                                              color:
                                              Colors.indigo)),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        Icons.edit,
                                        color: Colors.indigo,
                                      ),
                                    ],
                                  ),
                                ),
                              ))
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: infoWidget.screenHeight * 0.02,
                ),
                widget.userData.name == ''
                    ? SizedBox()
                    : personalInfo(
                    context: context,
                    enableEdit: true,
                    title: translator.currentLanguage == "en"
                        ? 'Name'
                        : 'الاسم',
                    subtitle: translator.currentLanguage == "en"
                        ? widget.userData.name
                        : widget.userData.name,
                    iconData: Icons.person,
                    infoWidget: infoWidget),
                widget.userData.address == ''
                    ? SizedBox()
                    : personalInfo(
                    context: context,
                    title: translator.currentLanguage == "en"
                        ? 'Address'
                        : 'العنوان',
                    subtitle: translator.currentLanguage == "en"
                        ? widget.userData.address
                        : widget.userData.address,
                    iconData: Icons.my_location,
                    infoWidget: infoWidget),
                widget.userData.specialization== ''
                    ? SizedBox()
                    : personalInfo(
                    title: translator.currentLanguage == "en"
                        ? 'Specialization'
                        : 'التخصص',
                    subtitle:  widget.userData.specialization,
                    iconData: Icons.school,
                    enableEdit: false,
                    infoWidget: infoWidget),
                widget.userData.specializationBranch== ''
                    ? SizedBox()
                    : personalInfo(
                    title: translator.currentLanguage == "en"
                        ? 'Specialization type'
                        : 'نوع التخصص',
                    subtitle:  widget.userData.specializationBranch,
                    iconData: Icons.info,
                    enableEdit: false,
                    infoWidget: infoWidget),
                widget.userData.phoneNumber == ''
                    ? SizedBox()
                    : personalInfo(
                    context: context,
                    enableEdit: true,
                    title: translator.currentLanguage == "en"
                        ? 'Phone Number'
                        : 'رقم الهاتف',
                    subtitle: translator.currentLanguage == "en"
                        ? widget.userData.phoneNumber
                        : widget.userData.phoneNumber,
                    iconData: Icons.phone,
                    infoWidget: infoWidget)
                ,
                widget.userData.email == ''
                    ? SizedBox()
                    : personalInfo(
                    title: translator.currentLanguage == "en"
                        ? 'E-mail'
                        : 'البريد الالكترونى',
                    subtitle: translator.currentLanguage == "en"
                        ? widget.userData.email
                        : widget.userData.email,
                    iconData: Icons.email,
                    enableEdit: false,
                    context: context,
                    infoWidget: infoWidget),
                widget.userData.rating!='0.0'?ListTile(
                  title: Text(
                    translator.currentLanguage == "en" ? 'Rating' : 'التقيم',
                    style:
                    infoWidget.titleButton.copyWith(color: Colors.indigo),
                  ),
                  leading: Icon(
                    Icons.stars,
                    color: Colors.indigo,
                  ),
                  subtitle:   RatingBar(
                    onRatingUpdate: (_){},
                    ignoreGestures: true,
                    initialRating:double.parse(widget.userData.rating),
                    minRating: 1,
                    unratedColor: Colors.grey,
                    itemSize: infoWidget.screenWidth*0.067,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.stars,
                      color: Colors.indigo,
                    ),
                  ),
                ):SizedBox(),
                widget.userData.nationalId == ''
                    ? SizedBox()
                    : personalInfo(
                    context: context,
                    enableEdit: false,
                    title: translator.currentLanguage == "en"
                        ? 'National Id'
                        : 'الرقم القومى',
                    subtitle: translator.currentLanguage == "en"
                        ? widget.userData.nationalId
                        : widget.userData.nationalId,
                    iconData: Icons.fingerprint,
                    infoWidget: infoWidget),
                widget.userData.birthDate == ''
                    ? SizedBox()
                    : personalInfo(
                    context: context,
                    enableEdit: false,
                    title: translator.currentLanguage == "en"
                        ? 'Birth Date'
                        : 'تاريخ الميلاد',
                    subtitle: translator.currentLanguage == "en"
                        ? widget.userData.birthDate
                        : widget.userData.birthDate,
                    iconData: Icons.date_range,
                    infoWidget: infoWidget),
                widget.userData.gender == ''
                    ? SizedBox()
                    : personalInfo(
                    context: context,
                    enableEdit: false,
                    title: translator.currentLanguage == "en"
                        ? 'Gender'
                        : 'النوع',
                    subtitle: translator.currentLanguage == "en"
                        ? widget.userData.gender
                        : widget.userData.gender,
                    iconData: Icons.view_agenda,
                    infoWidget: infoWidget),
                widget.userData.aboutYou == ''
                    ? SizedBox()
                    : personalInfo(
                    title: translator.currentLanguage == "en"
                        ? 'Another Info'
                        : 'معلومات اخرى',
                    subtitle: translator.currentLanguage == "en"
                        ? widget.userData.aboutYou
                        : widget.userData.aboutYou,
                    iconData: Icons.info,context: context,
                    infoWidget: infoWidget),
                widget.userData.points == ''
                    ? SizedBox()
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                       Expanded(child:  personalInfo(
                         enableEdit: false,
                           title: translator.currentLanguage == "en"
                               ? 'Points'
                               : 'النقاط',
                           subtitle: widget.userData.points,
                           iconData: Icons.panorama_fish_eye,context: context,
                           infoWidget: infoWidget),)
                        ,widget.userData.loading
                            ? Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.indigo,
                            ))
                            : widget.userData.points!='0'?Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: RaisedButton(
                          onPressed:  widget.userData.points!='0'?() async {
                              setState(() {
                                widget.userData.loading = true;
                              });
                              bool x = await _home.nurseSupplying(
                                  nurseId: widget.userData.docId,points: widget.userData.points);
                              if (x) {
                                Toast.show(
                                    translator.currentLanguage == "en"
                                        ? "Successfully applying"
                                        : 'نجح التوريد',
                                    context,
                                    duration: Toast.LENGTH_SHORT,
                                    gravity: Toast.BOTTOM);
                              } else {
                                Toast.show(
                                    translator.currentLanguage == "en"
                                        ? "try again later"
                                        : 'حاول مره اخرى',
                                    context,
                                    duration: Toast.LENGTH_SHORT,
                                    gravity: Toast.BOTTOM);
                              }
                              setState(() {
                                widget.userData.loading = false;
                              });
                          }:null,
                          child: Text(
                              translator.currentLanguage == 'en'
                                  ? 'Supplying'
                                  : 'توريد',
                              style: infoWidget.titleButton,
                          ),
                          color: Colors.indigo,
                          shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                        ),
                            ):SizedBox()
                      ],
                    ),
              ],
            )),
      ),
    );
  }
}
