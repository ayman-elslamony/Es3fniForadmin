import 'dart:io';
import 'package:admin/core/ui_components/info_widget.dart';
import 'package:admin/providers/auth.dart';
import 'package:admin/providers/home.dart';
import 'package:admin/screens/shared_widget/map.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import '../main_screen.dart';

class AddPatientRequest extends StatefulWidget {
  @override
  _AddPatientRequestState createState() => _AddPatientRequestState();
}

class _AddPatientRequestState extends State<AddPatientRequest> {
  GlobalKey<FormState> _newAccountKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _key = GlobalKey();
  bool _isLoading = false;
  int currentStep = 0;
  bool complete = false;
  bool _isEditLocationEnable = true;
  bool _selectUserLocationFromMap = false;
  bool _isGenderSelected = false;
  bool _isServiceSelected = false;
  bool _isAnalysisSelected = false;
  bool _isNurseTypeSelected = true;
  bool _isAgeSelected = false;
  bool _isNumOfUsersSelected = true;
  bool isSwitched = false;
  bool enableCoupon = false;
  bool enableScheduleTheService = false;
  bool enablePicture = false;
  bool _showWorkingDays = false;
  String _dateTime = '';
  List<String> _selectedWorkingDays = List<String>();
  List<bool> _clicked = List<bool>.generate(7, (i) => false);
  List<String> _sortedWorkingDays = List<String>.generate(7, (i) => '');
  List<bool> values = List.filled(7, false);
  FocusNode focusNode = FocusNode();
  FocusNode couponFocusNode = FocusNode();
  FocusNode locationFocusNode = FocusNode();
  FocusNode nameFocusNode = FocusNode();
  bool isLoadingCoupon = false;
  TextEditingController _locationTextEditingController =
      TextEditingController();
  File _imageFile;
  List<String> _genderList = ['Male', 'Female'];
  List<String> _ageList = List.generate(100, (index) {
    return '${1 + index}';
  });
  List<String> _numUsersList = List.generate(30, (index) {
    return '${1 + index}';
  });
  static DateTime _dateTimeNow =DateTime.now();
  final TextEditingController controller = TextEditingController();
  String initialCountry = 'EG';
  PhoneNumber number = PhoneNumber(isoCode: 'EG');
  Map<String, dynamic> _paramedicsData = {
    'Patient name': '',
    'Phone number': '',
    'gender': '',
    'age': '',
    'Location': '',
    'coupon': '',
    'accessories': '',
    'notes': '',
    'nurse type': 'Male',
    'service type': '',
    'analysis type': '',
    'numberOfUsersUseService': '1',
    'lat': '',
    'long': '',
    'startDate': '${_dateTimeNow.day}-${_dateTimeNow.month}-${_dateTimeNow.year}',
    'endDate': '',
  };
  List<String> workingDays = translator.currentLanguage == "en"
      ?[
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ]:['السبت','الاحد','الاثنين','الثلاثاء','الاربعاء','الخميس','الجمعه',];
  List<String> visitTime = [];
  final FocusNode _phoneNumberNode = FocusNode();
  final ImagePicker _picker = ImagePicker();

  //List<Step> steps = [];
  Home _home;
  bool isAnalysisSelected = false;

  getAllServicesAndAnalysis() async {
    await _home.getAllServices();
    await _home.getAllAnalysis();
  }

  @override
  void initState() {
    super.initState();
    _home = Provider.of<Home>(context, listen: false);
    getAllServicesAndAnalysis();
    if (translator.currentLanguage != "en") {
      _genderList = ['ذكر', 'انثى'];
    }
  }

  cancel() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
    }
  }

  goTo(int step) {
    setState(() => currentStep = step);
  }

  getDays(int index) {
    setState(() {
      _clicked[index] = !_clicked[index];
    });
    if (_clicked[index] == true) {
      _selectedWorkingDays.add(workingDays[index]);
    } else {
      _selectedWorkingDays.remove(workingDays[index]);
    }
  }
  Future<String> _getLocation() async {
    Position position =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final coordinates = new Coordinates(position.latitude, position.longitude);

    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    _paramedicsData['lat'] = position.latitude.toString();
    _paramedicsData['long'] = position.longitude.toString();
    return addresses.first.addressLine;
  }

  void _getUserLocation() async {
    _paramedicsData['Location'] = await _getLocation();
    setState(() {
      _locationTextEditingController.text = _paramedicsData['Location'];
      _isEditLocationEnable = true;
      _selectUserLocationFromMap = !_selectUserLocationFromMap;
    });
    Navigator.of(context).pop();
  }

  void selectLocationFromTheMap(String address, double lat, double long) {
    setState(() {
      _locationTextEditingController.text = address;
    });
    _paramedicsData['Location'] = address;
    _paramedicsData['lat'] = lat.toString();
    _paramedicsData['long'] = long.toString();
  }

  void selectUserLocationType() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0))),
        contentPadding: EdgeInsets.only(top: 10.0),
        title: Text(
          translator.currentLanguage == "en" ? 'Location' : 'الموقع',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize:
                  MediaQuery.of(context).orientation == Orientation.portrait
                      ? MediaQuery.of(context).size.width * 0.038
                      : MediaQuery.of(context).size.width * 0.024,
              color: Colors.indigo,
              fontWeight: FontWeight.bold),
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                RaisedButton(
                    onPressed: _getUserLocation,
                    color: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        translator.currentLanguage == "en"
                            ? 'Get current Location'
                            : 'الموقع الحالى',
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).orientation ==
                                    Orientation.portrait
                                ? MediaQuery.of(context).size.width * 0.035
                                : MediaQuery.of(context).size.width * 0.024,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                RaisedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (ctx) => GetUserLocation(
                                getAddress: selectLocationFromTheMap,
                              )));
                      setState(() {
                        _isEditLocationEnable = true;
                        _selectUserLocationFromMap =
                            !_selectUserLocationFromMap;
                      });
                    },
                    color: Colors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        translator.currentLanguage == "en"
                            ? 'Select Location from Map'
                            : 'اختر موقع من الخريطه',
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).orientation ==
                                    Orientation.portrait
                                ? MediaQuery.of(context).size.width * 0.035
                                : MediaQuery.of(context).size.width * 0.024,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child:
                Text(translator.currentLanguage == "en" ? 'Cancel' : 'الغاء'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    await _picker
        .getImage(source: source, maxWidth: 400.0)
        .then((PickedFile image) {
      if (image != null) {
        File x = File(image.path);
        _paramedicsData['UrlImg'] = x;
        setState(() {
          _imageFile = x;
          enablePicture = true;
        });
      }
      Navigator.pop(context);
    });
  }

  void _openImagePicker() {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10), topLeft: Radius.circular(10))),
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).orientation == Orientation.portrait
                ? MediaQuery.of(context).size.height * 0.16
                : MediaQuery.of(context).size.height * 0.28,
            padding: EdgeInsets.all(10.0),
            child: Column(children: [
              Text(
                  translator.currentLanguage == "en"
                      ? 'Pick an Image'
                      : 'التقط صوره',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? MediaQuery.of(context).size.width * 0.04
                          : MediaQuery.of(context).size.width * 0.03,
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold)),
              SizedBox(
                height: 10.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FlatButton.icon(
                    icon: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? MediaQuery.of(context).size.width * 0.065
                          : MediaQuery.of(context).size.width * 0.049,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: Colors.indigo,
                    textColor: Theme.of(context).primaryColor,
                    label: Text(
                      translator.currentLanguage == "en"
                          ? 'Use Camera'
                          : 'استخدم الكاميرا',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? MediaQuery.of(context).size.width * 0.035
                              : MediaQuery.of(context).size.width * 0.024,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      _getImage(ImageSource.camera);
                      // Navigator.of(context).pop();
                    },
                  ),
                  FlatButton.icon(
                    icon: Icon(
                      Icons.camera,
                      color: Colors.white,
                      size: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? MediaQuery.of(context).size.width * 0.065
                          : MediaQuery.of(context).size.width * 0.049,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: Colors.indigo,
                    textColor: Theme.of(context).primaryColor,
                    label: Text(
                      translator.currentLanguage == "en"
                          ? 'Use Gallery'
                          : 'استخدم المعرض',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? MediaQuery.of(context).size.width * 0.035
                              : MediaQuery.of(context).size.width * 0.024,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      _getImage(ImageSource.gallery);
                      // Navigator.of(context).pop();
                    },
                  ),
                ],
              )
            ]),
          );
        });
  }

  verifyUserData() async {
    if (_paramedicsData['Patient name'] == '' ||
            _paramedicsData['Phone number'] == ''
        //||
//        _paramedicsData['gender'] == '' ||
//        _paramedicsData['age'] == '' ||
//        _paramedicsData['Location'] == ''
        ) {
      Toast.show(
          translator.currentLanguage == "en"
              ? "Please complete patient info"
              : 'من فضلك ادخل معلومات المريض',
          context,
          duration: Toast.LENGTH_SHORT,
          gravity: Toast.BOTTOM);
    } else {
      setState(() {
        _isLoading = true;
      });
      try {
        print('A');
        bool isSccuess = await _home.addPatientRequest(
          analysisType: _paramedicsData['analysis type'],
          notes: _paramedicsData['notes'],
          discountCoupon: _paramedicsData['coupon'],
          endVisitDate: _paramedicsData['endDate'],
          numOfPatients: _paramedicsData['numberOfUsersUseService'],
          nurseGender: _paramedicsData['nurse type'],
          patientAge: _paramedicsData['age'],
          patientGender: _paramedicsData['gender'],
          patientLocation: _paramedicsData['Location'],
          patientName: _paramedicsData['Patient name'],
          patientPhone: _paramedicsData['Phone number'],
          picture: _imageFile,
          serviceType: _paramedicsData['service type'],
          startVisitDate: _paramedicsData['startDate'],
          suppliesFromPharmacy: _paramedicsData['accessories'],
          visitDays: _selectedWorkingDays.toString(),
          visitTime: visitTime.toString(),
        );
        print('isScuessisScuess$isSccuess');
        if (isSccuess) {
          setState(() {
            _isLoading = false;
          });

          if (isSccuess) {
            Toast.show(
                translator.currentLanguage == "en"
                    ? 'Sccfully added'
                    : "نجحت الاضافه",
                context,
                duration: Toast.LENGTH_SHORT,
                gravity: Toast.BOTTOM);
            _home.resetPrice();
            Navigator.of(context).pop();
//          showDialog(
//            context: context,
//            builder: (ctx) => AlertDialog(
//              shape: RoundedRectangleBorder(
//                  borderRadius: BorderRadius.all(Radius.circular(25.0))),
//              contentPadding: EdgeInsets.only(top: 10.0),
//              title: Text("Profile Created"),
//              content: Row(
//                crossAxisAlignment: CrossAxisAlignment.center,
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: <Widget>[
//                  Text(
//                    "Welcome ${_paramedicsData['First name']}",
//                  ),
//                ],
//              ),
//              actions: <Widget>[
//                FlatButton(
//                  child: Text("Ok"),
//                  onPressed: () {
//                    Navigator.of(context).pushReplacement(
//                        MaterialPageRoute(builder: (context) => HomeScreen()));
//                  },
//                ),
//                FlatButton(
//                  child: Text("Cancel"),
//                  onPressed: () {
//                    Navigator.of(context).pop();
//                    setState(() => complete = true);
//                  },
//                ),
//              ],
//            ),
//          );
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          Toast.show(
              translator.currentLanguage == "en"
                  ? "Please try again"
                  : 'من فضلك حاول مره اخرى',
              context,
              duration: Toast.LENGTH_SHORT,
              gravity: Toast.BOTTOM);
        }
      } catch (e) {
        print(e);
        setState(() {
          _isLoading = false;
        });
        Toast.show(
            translator.currentLanguage == "en"
                ? "Please try again"
                : 'من فضلك حاول مره اخرى',
            context,
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.BOTTOM);
      }
    }
  }

  _incrementStep() {
    currentStep + 1 == 2
        ? setState(() => complete = true)
        : goTo(currentStep + 1);
  }

  nextStep() async {
    print(currentStep);

    if (currentStep == 0) {
      _newAccountKey.currentState.validate();
      print(_paramedicsData);
      if (_paramedicsData['Patient name'] == '' ||
          _paramedicsData['Phone number'] == '' ||
          _paramedicsData['Location'] == '' ||
          _paramedicsData['gender'] == '' ||
          _paramedicsData['age'] == '' ||
          _locationTextEditingController.text == '') {
        Toast.show(
            translator.currentLanguage == "en"
                ? "Please add patient data"
                : ' من فضلك ادخل معلومات المريض ',
            context,
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.BOTTOM);
      }
      if (_newAccountKey.currentState.validate()) {
        _newAccountKey.currentState.save();
        _phoneNumberNode.unfocus();
        _incrementStep();
      }
      return;
    }
    if (currentStep == 1) {
      if (_paramedicsData['service type'] == '') {
        Toast.show(
            translator.currentLanguage == "en"
                ? "Please Complete data"
                : 'من فضلك اكمل البيانات',
            context,
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.BOTTOM);
      } else {
        if(_paramedicsData['service type'] == 'تحاليل' ||
            _paramedicsData['service type'] == 'Analysis'){
          if(_paramedicsData['analysis type']=='') {
            Toast.show(
                translator.currentLanguage == "en"
                    ? "Please enter analysis type"
                    : 'من فضلك ادخل نوع التحليل',
                context,
                duration: Toast.LENGTH_SHORT,
                gravity: Toast.BOTTOM);
          }else{
            verifyUserData();
          }
        }else {
          verifyUserData();
        }
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    return InfoWidget(
      builder: (context, infoWidget) => Directionality(
        textDirection: translator.currentLanguage == "en"
            ? TextDirection.ltr
            : TextDirection.rtl,
        child: Scaffold(
          key: _key,
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              translator.currentLanguage == "en"
                  ? 'New Patient request'
                  : 'طلب مسعف جديد',
              style: infoWidget.titleButton,
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 18, left: 8, right: 8),
                child: Consumer<Home>(
                  builder: (context, data, _) => Text(
                    translator.currentLanguage == "en"
                        ? '${data.price.servicePrice * double.parse(_paramedicsData['numberOfUsersUseService'])} EGP'
                        : '${data.price.servicePrice * double.parse(_paramedicsData['numberOfUsersUseService'])} جنيه ',
                    style: infoWidget.titleButton,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.indigo,
                          ),
                        )
                      : Stepper(
                          steps: [
                            Step(
                              title: Text(translator.currentLanguage == "en"
                                  ? 'Patient Info'
                                  : 'معلومات المريض'),
                              isActive: true,
                              state: StepState.indexed,
                              content: Form(
                                key: _newAccountKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 7.0),
                                      height: 80,
                                      child: TextFormField(
                                        autofocus: false,
                                        decoration: InputDecoration(
                                            labelText:
                                                translator.currentLanguage ==
                                                        "en"
                                                    ? 'Patient name'
                                                    : 'اسم المريض',
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0)),
                                              borderSide: BorderSide(
                                                color: Colors.indigo,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0)),
                                              borderSide: BorderSide(
                                                color: Colors.indigo,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0)),
                                              borderSide: BorderSide(
                                                color: Colors.indigo,
                                              ),
                                            ),
                                            disabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0)),
                                              borderSide: BorderSide(
                                                color: Colors.indigo,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10.0)),
                                              borderSide: BorderSide(
                                                  color: Colors.indigo),
                                            ),
                                            errorStyle: TextStyle(
                                                color: Colors.indigo)),
                                        // ignore: missing_return
                                        validator: (String val) {
                                          if (val.trim().isEmpty ||
                                              val.trim().length < 2) {
                                            return translator.currentLanguage ==
                                                    "en"
                                                ? 'Please enter patient name'
                                                : 'من فضلك ادخل اسم المريض';
                                          }
                                          if (val.trim().length < 2) {
                                            return translator.currentLanguage ==
                                                    "en"
                                                ? 'Invalid Name'
                                                : 'الاسم خطا';
                                          }
                                        },

                                        onChanged: (value) {
                                          _paramedicsData['Patient name'] =
                                              value.trim();
                                        },
                                      ),
                                    ),
                                    InternationalPhoneNumberInput(
                                      onInputChanged: (PhoneNumber number) {
                                        _paramedicsData['Phone number'] =
                                            number.phoneNumber;
                                      },
                                      ignoreBlank: true,
                                      autoValidate: false,
                                      selectorTextStyle:
                                          TextStyle(color: Colors.black),
                                      initialValue: number,
                                      textFieldController: controller,
                                      inputBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide:
                                            BorderSide(color: Colors.indigo),
                                      ),
                                      autoFocus: false,
                                      inputDecoration: InputDecoration(
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                            borderSide: BorderSide(
                                              color: Colors.indigo,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                            borderSide: BorderSide(
                                              color: Colors.indigo,
                                            ),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                            borderSide: BorderSide(
                                              color: Colors.indigo,
                                            ),
                                          ),
                                          disabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                            borderSide: BorderSide(
                                              color: Colors.indigo,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                            borderSide: BorderSide(
                                                color: Colors.indigo),
                                          ),
                                          errorStyle:
                                              TextStyle(color: Colors.indigo)),
                                      errorMessage:
                                          translator.currentLanguage == "en"
                                              ? 'Invalid phone number'
                                              : 'الرقم غير صحيح',
                                      hintText:
                                          translator.currentLanguage == "en"
                                              ? 'phone number'
                                              : 'رقم الهاتف',
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 7.0),
                                      height: 80,
                                      child: TextFormField(
                                        autofocus: false,
                                        style: TextStyle(fontSize: 15),
                                        controller:
                                            _locationTextEditingController,
                                        enabled: _isEditLocationEnable,
                                        decoration: InputDecoration(
                                          suffixIcon: InkWell(
                                            onTap: selectUserLocationType,
                                            child: Icon(
                                              Icons.my_location,
                                              size: 20,
                                              color: Colors.indigo,
                                            ),
                                          ),
                                          labelText:
                                              translator.currentLanguage == "en"
                                                  ? 'Location'
                                                  : 'الموقع',
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                            borderSide: BorderSide(
                                              color: Colors.indigo,
                                            ),
                                          ),
                                          disabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                            borderSide: BorderSide(
                                              color: Colors.indigo,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                            borderSide: BorderSide(
                                                color: Colors.indigo),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                            borderSide: BorderSide(
                                                color: Colors.indigo),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                            borderSide: BorderSide(
                                                color: Colors.indigo),
                                          ),
                                        ),
                                        keyboardType: TextInputType.text,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 8.0, top: 17),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 7),
                                            child: Text(
                                              translator.currentLanguage == "en"
                                                  ? 'number of users use service:'
                                                  : 'عدد مستخدمى الخدمه: ',
                                              style: infoWidget.titleButton
                                                  .copyWith(
                                                      color: Color(0xff484848)),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20.0),
                                            child: Material(
                                              shadowColor: Colors.blueAccent,
                                              elevation: 2.0,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                              type: MaterialType.card,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0,
                                                            right: 8.0),
                                                    child: Text(
                                                        _isNumOfUsersSelected ==
                                                                false
                                                            ? translator.currentLanguage ==
                                                                    "en"
                                                                ? 'number'
                                                                : 'العدد'
                                                            : _paramedicsData[
                                                                'numberOfUsersUseService'],
                                                        style: infoWidget
                                                            .titleButton
                                                            .copyWith(
                                                                color: Color(
                                                                    0xff484848))),
                                                  ),
                                                  Container(
                                                    height: 40,
                                                    width: 35,
                                                    child: PopupMenuButton(
                                                      initialValue: translator
                                                                  .currentLanguage ==
                                                              "en"
                                                          ? 'number'
                                                          : 'العدد',
                                                      tooltip: 'Select num',
                                                      itemBuilder: (ctx) =>
                                                          _numUsersList
                                                              .map((String
                                                                      val) =>
                                                                  PopupMenuItem<
                                                                      String>(
                                                                    value: val,
                                                                    child: Text(
                                                                        val.toString()),
                                                                  ))
                                                              .toList(),
                                                      onSelected: (val) {
                                                        setState(() {
                                                          _paramedicsData[
                                                                  'numberOfUsersUseService'] =
                                                              val.trim();
                                                          _isNumOfUsersSelected =
                                                              true;
                                                        });
                                                      },
                                                      icon: Icon(
                                                        Icons
                                                            .keyboard_arrow_down,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 8.0, top: 17),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 7),
                                            child: Text(
                                              translator.currentLanguage == "en"
                                                  ? 'Age:'
                                                  : 'السن',
                                              style: infoWidget.titleButton
                                                  .copyWith(
                                                      color: Color(0xff484848)),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20.0),
                                            child: Material(
                                              shadowColor: Colors.blueAccent,
                                              elevation: 2.0,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                              type: MaterialType.card,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0,
                                                            right: 8.0),
                                                    child: Text(
                                                        _isAgeSelected == false
                                                            ? translator.currentLanguage ==
                                                                    "en"
                                                                ? 'Age'
                                                                : 'السن'
                                                            : _paramedicsData[
                                                                'age'],
                                                        style: infoWidget
                                                            .titleButton
                                                            .copyWith(
                                                                color: Color(
                                                                    0xff484848))),
                                                  ),
                                                  Container(
                                                    height: 40,
                                                    width: 35,
                                                    child: PopupMenuButton(
                                                      initialValue: translator
                                                                  .currentLanguage ==
                                                              "en"
                                                          ? 'Age'
                                                          : 'السن',
                                                      tooltip: 'Select Age',
                                                      itemBuilder: (ctx) =>
                                                          _ageList
                                                              .map((String
                                                                      val) =>
                                                                  PopupMenuItem<
                                                                      String>(
                                                                    value: val,
                                                                    child: Text(
                                                                        val.toString()),
                                                                  ))
                                                              .toList(),
                                                      onSelected: (val) {
                                                        setState(() {
                                                          _paramedicsData[
                                                                  'age'] =
                                                              val.trim();
                                                          _isAgeSelected = true;
                                                        });
                                                      },
                                                      icon: Icon(
                                                        Icons
                                                            .keyboard_arrow_down,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 8.0, top: 17),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 7),
                                            child: Text(
                                              translator.currentLanguage == "en"
                                                  ? 'Gender:'
                                                  : 'النوع:',
                                              style: infoWidget.titleButton
                                                  .copyWith(
                                                      color: Color(0xff484848)),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20.0),
                                            child: Material(
                                              shadowColor: Colors.blueAccent,
                                              elevation: 2.0,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                              type: MaterialType.card,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0,
                                                            right: 8.0),
                                                    child: Text(
                                                        _isGenderSelected ==
                                                                false
                                                            ? translator.currentLanguage ==
                                                                    "en"
                                                                ? 'gender'
                                                                : 'النوع'
                                                            : _paramedicsData[
                                                                'gender'],
                                                        style: infoWidget
                                                            .titleButton
                                                            .copyWith(
                                                                color: Color(
                                                                    0xff484848))),
                                                  ),
                                                  Container(
                                                    height: 40,
                                                    width: 35,
                                                    child: PopupMenuButton(
                                                      initialValue: translator
                                                                  .currentLanguage ==
                                                              "en"
                                                          ? 'Male'
                                                          : 'ذكر',
                                                      tooltip: 'Select Gender',
                                                      itemBuilder: (ctx) =>
                                                          _genderList
                                                              .map((String
                                                                      val) =>
                                                                  PopupMenuItem<
                                                                      String>(
                                                                    value: val,
                                                                    child: Text(
                                                                        val.toString()),
                                                                  ))
                                                              .toList(),
                                                      onSelected: (val) {
                                                        setState(() {
                                                          _paramedicsData[
                                                                  'gender'] =
                                                              val.trim();
                                                          _isGenderSelected =
                                                              true;
                                                        });
                                                      },
                                                      icon: Icon(
                                                        Icons
                                                            .keyboard_arrow_down,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Step(
                              isActive: true,
                              state: StepState.indexed,
                              title: Text(translator.currentLanguage == "en"
                                  ? 'Service info'
                                  : 'معلومات الخدمه'),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8.0, top: 17),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 7),
                                          child: Text(
                                            translator.currentLanguage == "en"
                                                ? 'Service type:'
                                                : 'نوع الخدمه:',
                                            style: infoWidget.titleButton
                                                .copyWith(
                                                    color: Color(0xff484848)),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0),
                                          child: Material(
                                            shadowColor: Colors.blueAccent,
                                            elevation: 2.0,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                            type: MaterialType.card,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0,
                                                          right: 8.0),
                                                  child: Text(
                                                      _isServiceSelected ==
                                                              false
                                                          ? translator.currentLanguage ==
                                                                  "en"
                                                              ? 'type'
                                                              : 'النوع'
                                                          : _paramedicsData[
                                                              'service type'],
                                                      style: infoWidget
                                                          .titleButton
                                                          .copyWith(
                                                              color: Color(
                                                                  0xff484848))),
                                                ),
                                                Container(
                                                  height: 40,
                                                  width: 35,
                                                  child: Consumer<Home>(
                                                    builder:
                                                        (context, data, _) =>
                                                            PopupMenuButton(
                                                      initialValue: translator
                                                                  .currentLanguage ==
                                                              "en"
                                                          ? 'Injection'
                                                          : 'حقنه',
                                                      tooltip: 'Select Service',
                                                      itemBuilder: (ctx) => data
                                                          .allServicesType
                                                          .map(
                                                              (String val) =>
                                                                  PopupMenuItem<
                                                                      String>(
                                                                    value: val,
                                                                    child: Text(
                                                                        val.toString()),
                                                                  ))
                                                          .toList(),
                                                      onSelected: (val) {
                                                        if (val == 'تحاليل' ||
                                                            val == 'Analysis') {
                                                          setState(() {
                                                            _home.resetPrice();
                                                            isAnalysisSelected =
                                                                true;
                                                            _paramedicsData[
                                                                'analysis type'] = '';
                                                            _paramedicsData[
                                                                    'service type'] =
                                                                val.trim();
                                                            _isServiceSelected =
                                                                true;
                                                          });
                                                        } else {
                                                          _home.resetPrice();
                                                          _home.addToPrice(
                                                              type: '',
                                                              serviceType: val);
                                                          setState(() {
                                                            isAnalysisSelected =
                                                                false;
                                                            _paramedicsData[
                                                                'analysis type'] = '';
                                                            _paramedicsData[
                                                                    'service type'] =
                                                                val.trim();
                                                            _isServiceSelected =
                                                                true;
                                                          });
                                                        }
                                                      },
                                                      icon: Icon(
                                                        Icons
                                                            .keyboard_arrow_down,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  isAnalysisSelected
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0, top: 17),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 7),
                                                child: Text(
                                                  translator.currentLanguage ==
                                                          "en"
                                                      ? 'Analysis type:'
                                                      : 'نوع التحليل:',
                                                  style: infoWidget.titleButton
                                                      .copyWith(
                                                          color: Color(
                                                              0xff484848)),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20.0),
                                                child: Material(
                                                  shadowColor:
                                                      Colors.blueAccent,
                                                  elevation: 2.0,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10)),
                                                  type: MaterialType.card,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 8.0,
                                                                right: 8.0),
                                                        child: Text(
                                                            _isAnalysisSelected ==
                                                                    false
                                                                ? translator.currentLanguage ==
                                                                        "en"
                                                                    ? 'type'
                                                                    : 'النوع'
                                                                : _paramedicsData[
                                                                    'analysis type'],
                                                            style: infoWidget
                                                                .titleButton
                                                                .copyWith(
                                                                    color: Color(
                                                                        0xff484848))),
                                                      ),
                                                      Container(
                                                        height: 40,
                                                        width: 35,
                                                        child: Consumer<Home>(
                                                          builder: (context,
                                                                  data, _) =>
                                                              PopupMenuButton(
                                                            initialValue:
                                                                translator.currentLanguage ==
                                                                        "en"
                                                                    ? 'Injection'
                                                                    : 'حقنه',
                                                            tooltip:
                                                                'Select Service',
                                                            itemBuilder: (ctx) => data
                                                                .allAnalysisType
                                                                .map((String
                                                                        val) =>
                                                                    PopupMenuItem<
                                                                        String>(
                                                                      value:
                                                                          val,
                                                                      child: Text(
                                                                          val.toString()),
                                                                    ))
                                                                .toList(),
                                                            onSelected: (val) {
                                                              _home
                                                                  .resetPrice();
                                                              _home.addToPrice(
                                                                  type:
                                                                      'analysis',
                                                                  serviceType:
                                                                      val.trim());
                                                              setState(() {
                                                                _paramedicsData[
                                                                        'analysis type'] =
                                                                    val.trim();
                                                                _isAnalysisSelected =
                                                                    true;
                                                              });
                                                            },
                                                            icon: Icon(
                                                              Icons
                                                                  .keyboard_arrow_down,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      : SizedBox(),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8.0, top: 17),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 7),
                                          child: Text(
                                            translator.currentLanguage == "en"
                                                ? 'Nurse Type:'
                                                : 'نوع الممرض:',
                                            style: infoWidget.titleButton
                                                .copyWith(
                                                    color: Color(0xff484848)),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20.0),
                                          child: Material(
                                            shadowColor: Colors.blueAccent,
                                            elevation: 2.0,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10)),
                                            type: MaterialType.card,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0,
                                                          right: 8.0),
                                                  child: Text(
                                                      _isNurseTypeSelected ==
                                                              false
                                                          ? translator.currentLanguage ==
                                                                  "en"
                                                              ? 'gender'
                                                              : 'النوع'
                                                          : _paramedicsData[
                                                              'nurse type'],
                                                      style: infoWidget
                                                          .titleButton
                                                          .copyWith(
                                                              color: Color(
                                                                  0xff484848))),
                                                ),
                                                Container(
                                                  height: 40,
                                                  width: 35,
                                                  child: PopupMenuButton(
                                                    initialValue: translator
                                                                .currentLanguage ==
                                                            "en"
                                                        ? 'Male'
                                                        : 'ذكر',
                                                    tooltip: 'Select Gender',
                                                    itemBuilder: (ctx) =>
                                                        _genderList
                                                            .map((String val) =>
                                                                PopupMenuItem<
                                                                    String>(
                                                                  value: val,
                                                                  child: Text(val
                                                                      .toString()),
                                                                ))
                                                            .toList(),
                                                    onSelected: (val) {
                                                      setState(() {
                                                        _paramedicsData[
                                                                'nurse type'] =
                                                            val.trim();
                                                        _isNurseTypeSelected =
                                                            true;
                                                      });
                                                    },
                                                    icon: Icon(
                                                      Icons.keyboard_arrow_down,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8.0, top: 17),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 7),
                                            child: Text(
                                              translator.currentLanguage == "en"
                                                  ? 'You need supplies from the pharmacy:'
                                                  : 'تحتاج لمستلزمات من الصيدليه:',
                                              style: infoWidget.titleButton
                                                  .copyWith(
                                                      color: Color(0xff484848)),
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Switch(
                                              value: isSwitched,
                                              onChanged: (value) {
                                                setState(() {
                                                  isSwitched = value;
                                                  print(isSwitched);
                                                });
                                              },
                                              activeTrackColor:
                                                  Colors.indigoAccent,
                                              activeColor: Colors.indigo,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  isSwitched
                                      ? Container(
                                          height: 90,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 7.0),
                                          child: TextFormField(
                                            autofocus: false,
                                            textInputAction:
                                                TextInputAction.newline,
                                            decoration: InputDecoration(
                                              labelText:
                                                  translator.currentLanguage ==
                                                          "en"
                                                      ? "Accessories"
                                                      : 'مستلزمات',
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10.0)),
                                                borderSide: BorderSide(
                                                  color: Colors.indigo,
                                                ),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10.0)),
                                                borderSide: BorderSide(
                                                  color: Colors.indigo,
                                                ),
                                              ),
                                              focusedErrorBorder:
                                                  OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10.0)),
                                                borderSide: BorderSide(
                                                  color: Colors.indigo,
                                                ),
                                              ),
                                              disabledBorder:
                                                  OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10.0)),
                                                borderSide: BorderSide(
                                                  color: Colors.indigo,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10.0)),
                                                borderSide: BorderSide(
                                                    color: Colors.indigo),
                                              ),
                                            ),
                                            keyboardType: TextInputType.text,
                                            onChanged: (value) {
                                              _paramedicsData['accessories'] =
                                                  value.trim();
                                            },
                                            maxLines: 5,
                                            minLines: 2,
                                          ),
                                        )
                                      : SizedBox(),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8.0, top: 17),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 7),
                                            child: Text(
                                              translator.currentLanguage == "en"
                                                  ? 'Add a picture with Roshta or the name of the analysis:'
                                                  : 'اضافه صوره بالروشته او اسم التحليل:',
                                              style: infoWidget.titleButton
                                                  .copyWith(
                                                      color: Color(0xff484848)),
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                        enablePicture
                                            ? SizedBox()
                                            : Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 8.0),
                                                    child: InkWell(
                                                      onTap: () {
                                                        _openImagePicker();
                                                      },
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        decoration: BoxDecoration(
                                                            color:
                                                                Colors.indigo,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        child: Center(
                                                          child: Text(
                                                            translator.currentLanguage ==
                                                                    "en"
                                                                ? " Select Image "
                                                                : ' اختر صوره ',
                                                            style: infoWidget
                                                                .titleButton,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                      ],
                                    ),
                                  ),
                                  enablePicture
                                      ? Container(
                                          width: double.infinity,
                                          height: 200,
                                          child: Stack(
                                            children: <Widget>[
                                              ClipRRect(
                                                //backgroundColor: Colors.white,
                                                //backgroundImage:
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.file(
                                                  _imageFile,
                                                  fit: BoxFit.fill,
                                                  width: double.infinity,
                                                  height: 200,
                                                ),
                                              ),
                                              Positioned(
                                                  top: 3.0,
                                                  right: 3.0,
                                                  child: IconButton(
                                                      icon: Icon(
                                                        Icons.clear,
                                                        color: Colors.indigo,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          _imageFile = null;
                                                          enablePicture = false;
                                                        });
                                                      }))
                                            ],
                                          ),
                                        )
                                      : SizedBox(),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8.0, top: 17),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 7),
                                            child: Text(
                                              translator.currentLanguage == "en"
                                                  ? 'Discount coupon: ${_paramedicsData['coupon']}'
                                                  : ' كوبون خصم: ${_paramedicsData['coupon']}',
                                              style: infoWidget.titleButton
                                                  .copyWith(
                                                      color: Color(0xff484848)),
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Switch(
                                              value: enableCoupon,
                                              onChanged: (value) async {
                                                if (enableCoupon == false) {
                                                  await showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder:
                                                          (ctx) =>
                                                              Directionality(
                                                                textDirection:
                                                                    translator.currentLanguage ==
                                                                            "en"
                                                                        ? TextDirection
                                                                            .ltr
                                                                        : TextDirection
                                                                            .rtl,
                                                                child:
                                                                    StatefulBuilder(
                                                                  builder: (context,
                                                                          setState) =>
                                                                      AlertDialog(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(25.0))),
                                                                    contentPadding:
                                                                        EdgeInsets.only(
                                                                            top:
                                                                                10.0),
                                                                    title: Text(
                                                                      translator.currentLanguage ==
                                                                              "en"
                                                                          ? 'Discount coupon'
                                                                          : 'كوبون خصم',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: infoWidget
                                                                          .titleButton
                                                                          .copyWith(
                                                                              color: Colors.indigo),
                                                                    ),
                                                                    content:
                                                                        Container(
                                                                      height:
                                                                          60,
                                                                      child: Center(
                                                                          child: Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Container(
                                                                                height: 60,
                                                                                width: MediaQuery.of(context).size.width / 0.85,
                                                                                child: TextFormField(
                                                                                  focusNode: couponFocusNode,
                                                                                  decoration: InputDecoration(
                                                                                    labelText: translator.currentLanguage == "en" ? 'cpupon' : 'كوبون',
                                                                                    labelStyle: TextStyle(color: Colors.indigo),
                                                                                    focusedBorder: OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                                                      borderSide: BorderSide(
                                                                                        color: Colors.indigo,
                                                                                      ),
                                                                                    ),
                                                                                    disabledBorder: OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                                                      borderSide: BorderSide(
                                                                                        color: Colors.indigo,
                                                                                      ),
                                                                                    ),
                                                                                    enabledBorder: OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                                                      borderSide: BorderSide(color: Colors.indigo),
                                                                                    ),
                                                                                  ),
                                                                                  keyboardType: TextInputType.text,
                                                                                  onChanged: (val) {
                                                                                    _paramedicsData['coupon'] = val.trim();
                                                                                  },
                                                                                ),
                                                                              ))),
                                                                    ),
                                                                    actions: <
                                                                        Widget>[
                                                                      FlatButton(
                                                                        child:
                                                                            Text(
                                                                          translator.currentLanguage == "en"
                                                                              ? 'Cancel'
                                                                              : 'الغاء',
                                                                          style: TextStyle(
                                                                              fontSize: 16,
                                                                              color: Colors.indigo),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          _paramedicsData['coupon'] =
                                                                              '';
                                                                          Navigator.of(ctx)
                                                                              .pop();
                                                                        },
                                                                      ),
                                                                      isLoadingCoupon
                                                                          ? CircularProgressIndicator(
                                                                              backgroundColor: Colors.indigo,
                                                                            )
                                                                          : FlatButton(
                                                                              child: Text(
                                                                                translator.currentLanguage == "en" ? 'ok' : 'موافق',
                                                                                style: TextStyle(fontSize: 16, color: Colors.indigo),
                                                                              ),
                                                                              onPressed: () async {
                                                                                setState(() {
                                                                                  isLoadingCoupon = true;
                                                                                });
                                                                                String x = await _home.verifyCoupon(couponName: _paramedicsData['coupon']);
                                                                                couponFocusNode.unfocus();
                                                                                if (x == 'true') {
                                                                                  Toast.show(translator.currentLanguage == "en" ? "Scuessfully Discount" : 'نجح الخصم', context, duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);

                                                                                  Navigator.of(ctx).pop();
                                                                                } else if (x == 'add service before discount') {
                                                                                  Toast.show(translator.currentLanguage == "en" ? 'add service before discount' : 'اضف الخدمه قبل الخصم', context, duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                                                                                } else if (x == 'Coupon not Avilable') {
                                                                                  Toast.show(translator.currentLanguage == "en" ? 'Coupon not Avilable' : 'الكود غير متاح', context, duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                                                                                } else if (x == 'false') {
                                                                                  Toast.show(translator.currentLanguage == "en" ? "Invalid Coupon" : 'الكوبون غير متاح', context, duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                                                                                } else {
                                                                                  Toast.show(translator.currentLanguage == "en" ? "Already Discount" : 'تم الخصم بالفعل', context, duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                                                                                }
                                                                                setState(() {
                                                                                  isLoadingCoupon = false;
                                                                                });
                                                                                print(value);
                                                                                print(enableCoupon);
                                                                                print('56145313');
                                                                              },
                                                                            )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ));
                                                  setState(() {
                                                    enableCoupon = value;
                                                  });
                                                  if (_paramedicsData[
                                                          'coupon'] ==
                                                      '') {
                                                    print('oooo');
                                                    setState(() {
                                                      enableCoupon = false;
                                                    });
                                                  }
                                                  print(value);
                                                  print(enableCoupon);
                                                } else {
                                                  setState(() {
                                                    enableCoupon = value;
                                                    _paramedicsData['coupon'] =
                                                        '';
                                                  });
                                                  await _home.unVerifyCoupon();
                                                }
                                              },
                                              activeTrackColor:
                                                  Colors.indigoAccent,
                                              activeColor: Colors.indigo,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8.0, top: 17),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 7),
                                            child: Text(
                                              translator.currentLanguage == "en"
                                                  ? 'Schedule the service:'
                                                  : 'جدوله الخدمه:',
                                              style: infoWidget.titleButton
                                                  .copyWith(
                                                      color: Color(0xff484848)),
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Switch(
                                              value: enableScheduleTheService,
                                              onChanged: (value) {
                                                if (enableScheduleTheService ==
                                                    false) {
                                                  setState(() {
                                                    enableScheduleTheService =
                                                        value;
                                                  });
                                                } else {
                                                  setState(() {
                                                    enableScheduleTheService =
                                                        value;
                                                    _paramedicsData['coupon'] =
                                                        '';
                                                  });
                                                }
                                              },
                                              activeTrackColor:
                                                  Colors.indigoAccent,
                                              activeColor: Colors.indigo,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  enableScheduleTheService
                                      ? Column(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8.0, top: 17),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 7),
                                                      child: Text(
                                                        translator.currentLanguage ==
                                                                "en"
                                                            ? 'The visit period:'
                                                            : 'فتره الزياره:',
                                                        style: infoWidget
                                                            .titleButton
                                                            .copyWith(
                                                                color: Color(
                                                                    0xff484848)),
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              children: <Widget>[
                                                RaisedButton(
                                                  onPressed: () {
                                                    DatePicker.showDatePicker(
                                                        context,
                                                        showTitleActions: true,
                                                        theme: DatePickerTheme(
                                                          itemStyle: TextStyle(
                                                              color: Colors
                                                                  .indigo),
                                                          backgroundColor:
                                                              Colors.white,
                                                          headerColor:
                                                              Colors.white,
                                                          doneStyle: TextStyle(
                                                              color: Colors
                                                                  .indigoAccent),
                                                          cancelStyle:
                                                              TextStyle(
                                                                  color: Colors
                                                                      .black87),
                                                        ),
                                                        minTime: DateTime.now(),
                                                        maxTime: DateTime(
                                                            2080, 6, 7),
                                                        onChanged: (_) {},
                                                        onConfirm: (date) {
                                                      print('confirm $date');
                                                      setState(() {
                                                        _paramedicsData[
                                                                'startDate'] =
                                                            '${date.day}-${date.month}-${date.year}';
                                                      });
                                                    },
                                                        currentTime:
                                                            DateTime.now(),
                                                        locale: translator
                                                                    .currentLanguage ==
                                                                "en"
                                                            ? LocaleType.en
                                                            : LocaleType.ar);
                                                  },
                                                  color: Colors.indigo,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Text(
                                                      translator.currentLanguage ==
                                                              "en"
                                                          ? 'Start Date ${_paramedicsData['startDate']}'
                                                          : ' تاريخ البدايه ${_paramedicsData['startDate']}',
                                                      style: infoWidget
                                                          .titleButton),
                                                ),
                                                RaisedButton(
                                                  onPressed: () {
                                                    DatePicker.showDatePicker(
                                                        context,
                                                        showTitleActions: true,
                                                        theme: DatePickerTheme(
                                                          itemStyle: TextStyle(
                                                              color: Colors
                                                                  .indigo),
                                                          backgroundColor:
                                                              Colors.white,
                                                          headerColor:
                                                              Colors.white,
                                                          doneStyle: TextStyle(
                                                              color: Colors
                                                                  .indigoAccent),
                                                          cancelStyle:
                                                              TextStyle(
                                                                  color: Colors
                                                                      .black87),
                                                        ),
                                                        minTime: DateTime.now(),
                                                        maxTime: DateTime(
                                                            2080, 6, 7),
                                                        onChanged: (_) {},
                                                        onConfirm: (date) {
                                                      print('confirm $date');
                                                      setState(() {
                                                        _paramedicsData[
                                                                'endDate'] =
                                                            '${date.day}-${date.month}-${date.year}';
                                                      });
                                                    },
                                                        currentTime:
                                                            DateTime.now(),
                                                        locale: translator
                                                                    .currentLanguage ==
                                                                "en"
                                                            ? LocaleType.en
                                                            : LocaleType.ar);
                                                  },
                                                  color: Colors.indigo,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Text(
                                                      translator.currentLanguage ==
                                                              "en"
                                                          ? 'End Date ${_paramedicsData['endDate']}'
                                                          : ' تاريخ النهايه ${_paramedicsData['endDate']} ',
                                                      style: infoWidget
                                                          .titleButton),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8.0, top: 17),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 7),
                                                      child: Text(
                                                        translator.currentLanguage ==
                                                                "en"
                                                            ? 'Days of the visit:'
                                                            : 'ايام الزياره:',
                                                        style: infoWidget
                                                            .titleButton
                                                            .copyWith(
                                                                color: Color(
                                                                    0xff484848)),
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Switch(
                                                        value: _showWorkingDays,
                                                        onChanged: (value) {
                                                          if (_showWorkingDays) {
                                                            setState(() {
                                                              _showWorkingDays =
                                                                  value;
                                                              _clicked = List<
                                                                      bool>.generate(
                                                                  7,
                                                                  (i) => false);
                                                              _selectedWorkingDays
                                                                  .clear();
                                                            });
                                                          } else {
                                                            setState(() {
                                                              _showWorkingDays =
                                                                  value;
                                                            });
                                                          }
                                                        },
                                                        activeTrackColor:
                                                            Colors.indigoAccent,
                                                        activeColor:
                                                            Colors.indigo,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            _showWorkingDays
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 8.0,
                                                            left: 15,
                                                            right: 15,
                                                            top: 6.0),
                                                    child: GridView.builder(
                                                        shrinkWrap: true,
                                                        physics:
                                                            NeverScrollableScrollPhysics(),
                                                        itemCount:
                                                            workingDays.length,
                                                        gridDelegate:
                                                            SliverGridDelegateWithFixedCrossAxisCount(
                                                                crossAxisCount:
                                                                    2,
                                                                childAspectRatio:
                                                                    3,
                                                                crossAxisSpacing:
                                                                    10,
                                                                mainAxisSpacing:
                                                                    10),
                                                        itemBuilder:
                                                            (ctx, index) =>
                                                                InkWell(
                                                                  onTap: () {
                                                                    getDays(
                                                                        index);
                                                                    print(
                                                                        _selectedWorkingDays);
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    decoration: BoxDecoration(
                                                                        color: _clicked[index]
                                                                            ? Colors
                                                                                .grey
                                                                            : Colors
                                                                                .indigo,
                                                                        borderRadius:
                                                                            BorderRadius.circular(10)),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        workingDays[
                                                                            index],
                                                                        style: _clicked[index] ==
                                                                                false
                                                                            ? infoWidget.subTitle.copyWith(color: Colors.white)
                                                                            : infoWidget.subTitle.copyWith(color: Color(0xff484848)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )))
                                                : SizedBox(),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8.0, top: 17),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 7),
                                                      child: Text(
                                                        translator.currentLanguage ==
                                                                "en"
                                                            ? 'Visit Time:'
                                                            : 'وقت الزياره:',
                                                        style: infoWidget
                                                            .titleButton
                                                            .copyWith(
                                                                color: Color(
                                                                    0xff484848)),
                                                        maxLines: 2,
                                                      ),
                                                    ),
                                                  ),
                                                  RaisedButton(
                                                    onPressed: () {
                                                      showDialog(
                                                          context: context,
                                                          barrierDismissible:
                                                              false,
                                                          builder: (ctx) =>
                                                              Directionality(
                                                                textDirection:
                                                                    translator.currentLanguage ==
                                                                            "en"
                                                                        ? TextDirection
                                                                            .ltr
                                                                        : TextDirection
                                                                            .rtl,
                                                                child:
                                                                    AlertDialog(
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(25.0))),
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .only(
                                                                              top: 10.0),
                                                                  title: Text(
                                                                    translator.currentLanguage ==
                                                                            "en"
                                                                        ? 'Add time'
                                                                        : 'اضافه وقت',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: infoWidget
                                                                        .titleButton
                                                                        .copyWith(
                                                                            color:
                                                                                Colors.indigo),
                                                                  ),
                                                                  content:
                                                                      TimePickerSpinner(
                                                                    is24HourMode:
                                                                        true,
                                                                    normalTextStyle: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        color: Colors
                                                                            .indigo[200]),
                                                                    highlightedTextStyle: TextStyle(
                                                                        fontSize:
                                                                            18,
                                                                        color: Colors
                                                                            .indigo),
                                                                    spacing: 30,
                                                                    itemHeight:
                                                                        40,
                                                                    isForce2Digits:
                                                                        true,
                                                                    onTimeChange:
                                                                        (time) {
                                                                      // _clinicData['startTime']=time.toIso8601String();
                                                                      _dateTime =
                                                                          '${time.hour}:${time.minute}';
                                                                    },
                                                                  ),
                                                                  actions: <
                                                                      Widget>[
                                                                    FlatButton(
                                                                      child:
                                                                          Text(
                                                                        translator.currentLanguage ==
                                                                                "en"
                                                                            ? 'Cancel'
                                                                            : 'الغاء',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                Colors.indigo),
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        _dateTime =
                                                                            '';
                                                                        Navigator.of(ctx)
                                                                            .pop();
                                                                      },
                                                                    ),
                                                                    FlatButton(
                                                                      child:
                                                                          Text(
                                                                        translator.currentLanguage ==
                                                                                "en"
                                                                            ? 'ok'
                                                                            : 'موافق',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                Colors.indigo),
                                                                      ),
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          visitTime
                                                                              .add(_dateTime);
                                                                        });
                                                                        Navigator.of(ctx)
                                                                            .pop();
                                                                      },
                                                                    )
                                                                  ],
                                                                ),
                                                              ));
                                                    },
                                                    color: Colors.indigo,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                    child: Text(
                                                      translator.currentLanguage ==
                                                              "en"
                                                          ? 'Add Time'
                                                          : 'اضافه وقت',
                                                      style: infoWidget
                                                          .titleButton,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0,
                                                    left: 15,
                                                    right: 15,
                                                    top: 6.0),
                                                child: GridView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemCount: visitTime.length,
                                                    gridDelegate:
                                                        SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: 3,
                                                            childAspectRatio: 3,
                                                            crossAxisSpacing:
                                                                10,
                                                            mainAxisSpacing:
                                                                10),
                                                    itemBuilder:
                                                        (ctx, index) => InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  String
                                                                      deletedItem =
                                                                      visitTime
                                                                          .removeAt(
                                                                              index);
                                                                  setState(() {
                                                                    _key.currentState
                                                                      ..removeCurrentSnackBar()
                                                                      ..showSnackBar(
                                                                        SnackBar(
                                                                          content: Text(translator.currentLanguage == "en"
                                                                              ? "Removed $deletedItem"
                                                                              : 'حذف $deletedItem'),
                                                                          action: SnackBarAction(
                                                                              label: translator.currentLanguage == "en" ? "UNDO" : 'تراجع',
                                                                              onPressed: () => setState(
                                                                                    () => visitTime.insert(index, deletedItem),
                                                                                  ) // this is what you needed
                                                                              ),
                                                                        ),
                                                                      );
                                                                  });
                                                                });
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: _clicked[
                                                                            index]
                                                                        ? Colors
                                                                            .grey
                                                                        : Colors
                                                                            .indigo,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                                child: Center(
                                                                  child: Text(
                                                                    visitTime[
                                                                        index],
                                                                    style: infoWidget
                                                                        .titleButton
                                                                        .copyWith(
                                                                            color:
                                                                                Color(0xff484848)),
                                                                  ),
                                                                ),
                                                              ),
                                                            )))
                                          ],
                                        )
                                      : SizedBox(),
                                  Text(
                                    translator.currentLanguage == "en"
                                        ? 'Notes:'
                                        : 'ملاحظات:',
                                    style: infoWidget.titleButton
                                        .copyWith(color: Color(0xff484848)),
                                  ),
                                  Container(
                                    height: 90,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 7.0),
                                    child: TextFormField(
                                      autofocus: false,
                                      textInputAction: TextInputAction.newline,
                                      decoration: InputDecoration(
                                        labelText:
                                            translator.currentLanguage == "en"
                                                ? "notes"
                                                : 'ملاحظات',
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                          borderSide: BorderSide(
                                            color: Colors.indigo,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                          borderSide: BorderSide(
                                            color: Colors.indigo,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                          borderSide: BorderSide(
                                            color: Colors.indigo,
                                          ),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                          borderSide: BorderSide(
                                            color: Colors.indigo,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                          borderSide:
                                              BorderSide(color: Colors.indigo),
                                        ),
                                      ),
                                      keyboardType: TextInputType.text,
                                      onChanged: (value) {
                                        _paramedicsData['notes'] = value.trim();
                                      },
                                      maxLines: 5,
                                      minLines: 2,
                                    ),
                                  )

//            Padding(
//              padding: const EdgeInsets.only(bottom: 8.0, top: 17),
//              child: Row(
//                crossAxisAlignment: CrossAxisAlignment.start,
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: <Widget>[
//                  Expanded(
//                    child: Padding(
//                      padding: const EdgeInsets.symmetric(vertical: 7),
//                      child: Text(
//                        translator.currentLanguage == "en"?'You need supplies from the pharmacy:':'تحتاج لمستلزمات من الصيدليه:',
//                        style: TextStyle(fontSize: 18),
//                        maxLines: 2,
//                      ),
//                    ),
//                  ),
//                ],
//              ),
//            ),
                                ],
                              ),
                            ),
                          ],
                          currentStep: currentStep,
                          onStepContinue: nextStep,
                          onStepTapped: (step) => goTo(step),
                          onStepCancel: cancel,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
