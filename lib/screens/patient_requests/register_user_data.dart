import 'dart:io';
import 'package:es3fniforadmin/core/ui_components/info_widget.dart';
import 'package:es3fniforadmin/providers/auth.dart';
import 'package:es3fniforadmin/screens/shared_widget/map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../main_screen.dart';
import '../widgets.dart';

class RegisterUserData extends StatefulWidget {
  static const routeName = '/UserSignUp';
  @override
  _RegisterUserDataState createState() => _RegisterUserDataState();
}

class _RegisterUserDataState extends State<RegisterUserData> {
  GlobalKey<FormState> _newAccountKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int currentStep = 0;
  bool complete = false;
  bool _isEditLocationEnable = false;
  bool _selectUserLocationFromMap = false;
  bool _isMaterialStatus = false;
  bool _isDaySelected = false;
  bool _isMonthSelected = false;
  bool _isYearSelected = false;
  bool _isGenderSelected = false;
  bool _isSpecialtySelected = false;
  TextEditingController _locationTextEditingController =
      TextEditingController();
  File? _imageFile;
  List<int> _dayList = List.generate(31, (index) {
    return (1 + index);
  });
  List<int> _monthList = List.generate(12, (index) {
    return (1 + index);
  });
  List<int> _yearList = List.generate(80, (index) {
    return (index + 1970);
  });
  Map<String, dynamic> _accountData = {
    'First name': '',
    'Middle name': '',
    'Last name': '',
    'Phone number': '',
    'UrlImg': '',
    'Job': '',
    'gender': '',
    'day': '',
    'month': '',
    'year': '',
    'Location': '',
    'lat': '',
    'long': '',
    'materialStatus': '',
    'aboutYouOrBio': '',
    'speciatly': '',
  };

  List<String> materialStatus = [
    'Single',
    'Married',
    'Divorced',
    'Separated',
    'Widowed',
  ];
  final FocusNode _middleNameNode = FocusNode();
  final FocusNode _lastNameNode = FocusNode();
  final FocusNode _nationalIDNode = FocusNode();
  final FocusNode _phoneNumberNode = FocusNode();
  final FocusNode _jobNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  List<Step> steps=[];
  Auth? _auth;
  @override
  void initState() {
    super.initState();
    _auth = Provider.of<Auth>(context, listen: false);

  }
  cancel() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
    }
  }

  goTo(int step) {
    setState(() => currentStep = step);
  }

  Widget _createTextForm(
      {String? labelText,
      FocusNode? currentFocusNode,
      FocusNode? nextFocusNode,
      TextInputType textInputType = TextInputType.text,
      bool isSuffixIcon = false,
      Function? validator,
      IconData? suffixIcon,
      bool isStopped = false,
      bool isEnable = true,
      TextEditingController? controller}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 7.0),
      height: 80,
      child: TextFormField(
        controller: controller,
        autofocus: false,
        textInputAction:
            isStopped ? TextInputAction.done : TextInputAction.next,
        focusNode: currentFocusNode == null ? null : currentFocusNode,
        enabled: isEnable,
        decoration: InputDecoration(
          suffixIcon: Icon(
            suffixIcon,
            size: 20,
            color: Colors.blue,
          ),
          labelText: labelText,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(
              color: Colors.blue,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(
              color: Colors.blue,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(
              color: Colors.blue,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(
              color: Colors.blue,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
        keyboardType: textInputType,
// ignore: missing_return
        validator: validator as String? Function(String?)?,
        onSaved: (value) {
          _accountData['$labelText'] = value!.trim();
          if (currentFocusNode != null) {
            currentFocusNode.unfocus();
          }
          if (isStopped == false) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
        },
        onChanged: (value) {
          _accountData['$labelText'] = value.trim();
        },
        onFieldSubmitted: (_) {
          if (currentFocusNode != null) {
            currentFocusNode.unfocus();
          }
          if (isStopped == false) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
        },
      ),
    );
  }

  Future<String?> _getLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    var addresses =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    _accountData['lat'] = position.latitude.toString();
    _accountData['long'] = position.longitude.toString();
    return addresses.first.street;
  }

  void _getUserLocation() async {
    _accountData['Location'] = await _getLocation();
    setState(() {
      _locationTextEditingController.text = _accountData['Location'];
      _isEditLocationEnable = true;
      _selectUserLocationFromMap = !_selectUserLocationFromMap;
    });
    Navigator.of(context).pop();
  }

  void selectLocationFromTheMap(String address, double lat, double long) {
    setState(() {
      _locationTextEditingController.text = address;
    });
    _accountData['Location'] = address;
    _accountData['lat'] = lat.toString();
    _accountData['long'] = long.toString();
  }

  void selectUserLocationType() async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0))),
        contentPadding: EdgeInsets.only(top: 10.0),
        title: Text(
          'Location',
          textAlign: TextAlign.center,
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                InkWell(
                  onTap: _getUserLocation,
                  child: Material(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      type: MaterialType.card,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Get current Location',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      )),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (ctx) => GetUserLocation(
                              getAddress: selectLocationFromTheMap,
                            )));
                    setState(() {
                      _isEditLocationEnable = true;
                      _selectUserLocationFromMap = !_selectUserLocationFromMap;
                    });
                  },
                  child: Material(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      type: MaterialType.card,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Select Location from Map',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Cancel'),
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
        .then((PickedFile? image) {
      if (image != null) {
        File x = File(image.path);
        _accountData['UrlImg'] = x;
        setState(() {
          _imageFile = x;
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
            height: 100.0,
            padding: EdgeInsets.all(10.0),
            child: Column(children: [
              Text(
                  'Pick an Image',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).orientation==Orientation.portrait?MediaQuery.of(context).size.width * 0.04:MediaQuery.of(context).size.width * 0.03,
                      color: Colors.blue,
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
                      size: MediaQuery.of(context).orientation==Orientation.portrait?MediaQuery.of(context).size.width*0.065:MediaQuery.of(context).size.width*0.049,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: Colors.blue,
                    textColor: Theme.of(context).primaryColor,
                    label: Text(
                      'Use Camera',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).orientation==Orientation.portrait?MediaQuery.of(context).size.width * 0.035:MediaQuery.of(context).size.width * 0.024,
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
                      size: MediaQuery.of(context).orientation==Orientation.portrait?MediaQuery.of(context).size.width*0.065:MediaQuery.of(context).size.width*0.049,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: Colors.blue,
                    textColor: Theme.of(context).primaryColor,
                    label: Text(
                      'Use Gallery',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).orientation==Orientation.portrait?MediaQuery.of(context).size.width * 0.035:MediaQuery.of(context).size.width * 0.024,
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
  Widget _createBirthDate(
      {required String name, List<int>? list, Function? fun, int? initialValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Material(
        shadowColor: Colors.blueAccent,
        elevation: 2.0,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        type: MaterialType.card,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Text(name,
                  style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Container(
              height: 40,
              width: 35,
              child: PopupMenuButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.indigo)
                ),
                initialValue: initialValue,
                tooltip: 'Select Birth',
                itemBuilder: (ctx) => list!
                    .map((int val) => PopupMenuItem<int>(
                  value: val,
                  child: Text(val.toString()),
                ))
                    .toList(),
                onSelected: fun as void Function(int x),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  verifyUserData() async {
    if (_accountData['First name'] == '' ||
        _accountData['Middle name'] == '' ||
        _accountData['Last name'] == '' ||
        _accountData['Phone number'] == '' ||
        _accountData['UrlImg'] == '' ||
        _accountData['gender'] == '' ||
        _accountData['day'] == '' ||
        _accountData['month'] == '' ||
        _accountData['year'] == '' ||
        _accountData['Location'] == '' ||
        _accountData['materialStatus'] == '') {
      flutterToast(
                                      msg: "Please complete your profile",  );
    } else {
      setState(() {
        _isLoading = true;
      });
      try{
        String isSccuess = '';
//        await Provider.of<Auth>(context, listen: false)
//            .registerUserData(listOfData: _accountData);
        print('isScuessisScuess$isSccuess');
        if (isSccuess == 'success') {
          setState(() {
            _isLoading = false;
          });
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0))),
              contentPadding: EdgeInsets.only(top: 10.0),
              title: Text("Profile Created"),
              content: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Welcome ${_accountData['First name']}",
                  ),
                ],
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>HomeScreen()));
                  },
                ),
                FlatButton(
                  child: Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() => complete = true);
                  },
                ),
              ],
            ),
          );
        } else {
          setState(() {
            _isLoading = false;
          });
          flutterToast(
                                      msg: "Please try again",  );
        }
      }catch(e){
        print(e);
        setState(() {
          _isLoading = false;
        });
        flutterToast(
                                      msg: "Please try again",  );
      }

    }
  }

  _incrementStep() {
    currentStep + 1 == steps.length
        ? setState(() => complete = true)
        : goTo(currentStep + 1);
  }

  nextStep() async {
    print(steps.length);
    print(currentStep);

    if (currentStep == 0) {
      print(_accountData);
      if (_accountData['Location'] == '') {
        flutterToast(
                                      msg: "Please add your location",  );
      }
      if (_newAccountKey.currentState!.validate()) {
        _newAccountKey.currentState!.save();
        _middleNameNode.unfocus();
        _lastNameNode.unfocus();
        _nationalIDNode.unfocus();
        _phoneNumberNode.unfocus();
        _jobNode.unfocus();
        _incrementStep();
      }
      return;
    }
    if (currentStep == 1) {
      if (_accountData['day'] == '' ||
          _accountData['month'] == '' ||
          _accountData['year'] == '' ||
          _accountData['gender'] == '' ||
          _accountData['materialStatus'] == '') {
        flutterToast(
                                      msg: "Please Complete your data",  );
      } else {
        verifyUserData();
        return;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
//    SystemChannels.textInput.invokeMethod('TextInput.hide');
    steps = [
      Step(
        title: const Text('New Account'),
        isActive: true,
        state: StepState.indexed,
        content: Form(
          key: _newAccountKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _createTextForm(
                  labelText: 'First name',
                  nextFocusNode: _middleNameNode,
                  // ignore: missing_return
                  validator: (String val) {
                    if (val.trim().isEmpty || val.trim().length < 2) {
                      return 'Please enter first name';
                    }
                    if (val.trim().length < 2) {
                      return 'Invalid Name';
                    }
                  }),
              _createTextForm(
                  labelText: 'Middle name',
                  currentFocusNode: _middleNameNode,
                  nextFocusNode: _lastNameNode,
                  // ignore: missing_return
                  validator: (String val) {
                    if (val.trim().isEmpty || val.trim().length < 2) {
                      return 'Please enter middle name';
                    }
                    if (val.trim().length < 2) {
                      return 'Invalid Name';
                    }
                  }),
              _createTextForm(
                  labelText: 'Last name',
                  currentFocusNode: _lastNameNode,
                  nextFocusNode: _nationalIDNode,
                  // ignore: missing_return
                  validator: (String val) {
                    if (val.trim().isEmpty || val.trim().length < 2) {
                      return 'Please enter last name';
                    }
                    if (val.trim().length < 2) {
                      return 'Invalid Name';
                    }
                  }),
              Container(
                padding: EdgeInsets.symmetric(vertical: 7.0),
                height: 80,
                child: TextFormField(
                  autofocus: false,
                  textInputAction: TextInputAction.next,
                  focusNode: _phoneNumberNode,
                  decoration: InputDecoration(
                    prefix: Container(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        "+20",
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    labelText: "Phone number",
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
// ignore: missing_return
                  validator: (String? value) {
                    if (value!.trim().isEmpty ||
                        value.trim().length != 10) {
                      return "Please enter Phone number!";
                    }
                    if (value.trim().length != 10) {
                      return "Invalid Phone number!";
                    }
                  },
                  onChanged: (value) {
                    _accountData['Phone number'] = value.trim();
                  },
                  onSaved: (value) {
                    _accountData['Phone number'] = value!.trim();
                    _phoneNumberNode.unfocus();
                  },
                  onFieldSubmitted: (_) {
                    _phoneNumberNode.unfocus();
                    FocusScope.of(context).requestFocus(_jobNode);
                  },
                ),
              ),
              InkWell(
                  onTap: selectUserLocationType,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 7.0),
                    height: 80,
                    child: TextFormField(
                      autofocus: false,
                      style: TextStyle(fontSize: 15),
                      controller: _locationTextEditingController,
                      textInputAction: TextInputAction.done,
                      enabled: _isEditLocationEnable,
                      decoration: InputDecoration(
                        suffixIcon: InkWell(
                          onTap: selectUserLocationType,
                          child: Icon(
                            Icons.my_location,
                            size: 20,
                            color: Colors.blue,
                          ),
                        ),
                        labelText: 'Location',
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(
                            color: Colors.blue,
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(
                            color: Colors.blue,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      autovalidateMode: AutovalidateMode.always,
// ignore: missing_return
                      validator: (String? val) {
                        if (val!.trim().isEmpty) {
                          return 'Invalid Location';
                        }
                      },
                    ),
                  )),
              _createTextForm(
                  labelText: 'Job',
                  currentFocusNode: _jobNode,
                  // ignore: missing_return
                  validator: (_) {},
                  isStopped: true),
            ],
          ),
        ),
      ),
      Step(
        isActive: true,
        state: StepState.indexed,
        title: const Text('complete Your Data'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween
              ,children: <Widget>[InkWell(
                onTap: () {
                  _openImagePicker();
                },
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  height: 40,
                  width: 150,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        "Select Image",
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(color: Colors.white, fontSize: 17),
                      ),
                      Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              ),
                Container(
                  width: 100,
                  height: 100,
                  child: ClipRRect(
                    //backgroundColor: Colors.white,
                    //backgroundImage:
                    borderRadius: BorderRadius.circular(50),
                    child: _imageFile == null
                        ? Image.asset('assets/user.png',fit: BoxFit.fill,)
                        : Image.file(_imageFile!,fit: BoxFit.fill,),
                  ),
                ),],
            )
            ,Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Text(
                'Birth Date:',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _createBirthDate(
                  initialValue: 10,
                  name: _isDaySelected ? _accountData['day'] : 'Day',
                  list: _dayList,
                  fun: (int val) {
                    setState(() {
                      _accountData['day'] = val.toString();
                      _isDaySelected = true;
                    });
                  },
                ),
                _createBirthDate(
                    initialValue: 10,
                    name: _isMonthSelected
                        ? _accountData['month']
                        : 'Month',
                    list: _monthList,
                    fun: (int val) {
                      setState(() {
                        _accountData['month'] = val.toString();
                        _isMonthSelected = true;
                      });
                    }),
                _createBirthDate(
                    initialValue: 1990,
                    name: _isYearSelected ? _accountData['year'] : 'Year',
                    list: _yearList,
                    fun: (int val) {
                      setState(() {
                        _accountData['year'] = val.toString();
                        _isYearSelected = true;
                      });
                    }),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 17),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Text(
                      'Gender:',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Material(
                      shadowColor: Colors.blueAccent,
                      elevation: 2.0,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      type: MaterialType.card,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                                _isGenderSelected == false
                                    ? 'gender'
                                    : _accountData['gender'],
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            height: 40,
                            width: 35,
                            child: PopupMenuButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(color: Colors.indigo)
                              ),
                              initialValue: 'Male',
                              tooltip: 'Select Gender',
                              itemBuilder: (ctx) => ['Male', 'Female']
                                  .map((String val) =>
                                  PopupMenuItem<String>(
                                    value: val,
                                    child: Text(val.toString()),
                                  ))
                                  .toList(),
                              onSelected: (dynamic val) {
                                setState(() {
                                  _accountData['gender'] = val.trim();
                                  _isGenderSelected = true;
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
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Text(
                'Social status:',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Material(
                    shadowColor: Colors.blueAccent,
                    elevation: 2.0,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    type: MaterialType.card,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: FittedBox(
                            child: Text(
                                _isMaterialStatus == false
                                    ? 'Social status'
                                    : _accountData['materialStatus'],
                                style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 35,
                          child: PopupMenuButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.indigo)
                            ),
                            initialValue: 'Single',
                            tooltip: 'Select social status',
                            itemBuilder: (ctx) => materialStatus
                                .map(
                                    (String val) => PopupMenuItem<String>(
                                  value: val,
                                  child: Text(val.toString()),
                                ))
                                .toList(),
                            onSelected: (dynamic val) {
                              setState(() {
                                _accountData['materialStatus'] =
                                    val.trim();
                                _isMaterialStatus = true;
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
                ],
              ),
            ),
          ],
        ),
      ),
    ];
    return InfoWidget(
     builder: (context,infoWidget)=>Scaffold(
       backgroundColor: Colors.white,
       appBar: AppBar(centerTitle: true,title: Text('Please complete your profile',style: infoWidget.titleButton,),),
       body: SafeArea(
         child: Column(
           children: <Widget>[
             Expanded(
               child: _isLoading
                   ? Center(
                 child: const CircularProgressIndicator(color:  Colors.indigo,)
               )
                   : Stepper(
                 steps: steps,
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
    );
  }
}
