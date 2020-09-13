import 'package:admin/core/models/device_info.dart';
import 'package:admin/core/ui_components/info_widget.dart';
import 'package:admin/models/user_data.dart';
import 'package:admin/providers/home.dart';
import 'package:admin/screens/user_profile/show_profile.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toast/toast.dart';
import '../../models/http_exception.dart';

class Paramedics extends StatefulWidget {
  @override
  _ParamedicsState createState() => _ParamedicsState();
}

class _ParamedicsState extends State<Paramedics> {
  TextEditingController paramedicEmail = TextEditingController();
  TextEditingController password = TextEditingController();
  Home _home;
  bool loadingBody = true;
  final FocusNode _passwordNode = FocusNode();
  bool _showPassword = false;
  String errorMessage;
  final GlobalKey<FormState> _formKey = GlobalKey();

  Widget content({UserData userData, DeviceInfo infoWidget}) {
    return InkWell(
      onTap: () {
        if(userData.nationalId !='' && userData.gender != ''){
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => ShowUserProfile(userData: userData,)));
        }

      },
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Container(
          color: Colors.blue[100],
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text(
                      translator.currentLanguage == 'en'
                          ? 'Paramedic: ${userData.name}'
                          : 'مسعف: ${userData.name}',
                      style: infoWidget.title,
                    ),
                    Text(
                      translator.currentLanguage == 'en'
                          ? 'Number of points: ${userData.points}'
                          : 'عدد النقاط: ${userData.points} ',
                      style: infoWidget.subTitle,
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    userData.loading
                        ? Center(
                            child: CircularProgressIndicator(
                            backgroundColor: Colors.indigo,
                          ))
                        : RaisedButton(
                            onPressed: () async {
                              setState(() {
                                userData.loading = true;
                              });
                              print(userData.email);print(userData.password);
                              bool x = await _home.deleteParamedic(
                                  userData: userData);
                              if (x) {
                                Toast.show(
                                    translator.currentLanguage == "en"
                                        ? "successfully deleted"
                                        : 'نجح الحذف',
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
                                userData.loading = false;
                              });
                            },
                            child: Text(
                              translator.currentLanguage == 'en'
                                  ? 'delete'
                                  : 'حذف',
                              style: infoWidget.titleButton,
                            ),
                            color: Colors.indigo,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isLoading = false;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _isLoading = true;
      });
      try {
        bool auth = await Provider.of<Home>(context, listen: false)
            .createAccountForParamedics(
                email: paramedicEmail.text.trim(),
                password: password.text.trim());
        print('welcome');
        if (auth == true) {
          Toast.show(
              translator.currentLanguage == "en"
                  ? "successfully created"
                  : 'نجحت الاضافه',
              context,
              duration: Toast.LENGTH_SHORT,
              gravity: Toast.BOTTOM);
          Navigator.of(context).pop();
          setState(() {
            _isLoading = false;
          });
        }
      } on HttpException catch (error) {
        setState(() {
          _isLoading = false;
        });
        switch (error.toString()) {
          case "ERROR_INVALID_EMAIL":
            errorMessage = "Your email address appears to be malformed.";
            break;
          case "ERROR_EMAIL_ALREADY_IN_USE":
            errorMessage =
                "The email address is already in use by another account.";
            break;
          case "ERROR_USER_NOT_FOUND":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "ERROR_USER_DISABLED":
            errorMessage = "User with this email has been disabled.";
            break;
          case "ERROR_TOO_MANY_REQUESTS":
            errorMessage = "Too many requests. Try again later.";
            break;
          case "ERROR_OPERATION_NOT_ALLOWED":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }
        _showErrorDialog(errorMessage);
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        const errorMessage =
            'Could not authenticate you. Please try again later.';
        _showErrorDialog(errorMessage);
      }
    }
  }

  getAllParamedics() async {
    if (_home.allNurses.length == 0) {
      await _home.getAllParamedics();
    }
    setState(() {
      loadingBody = false;
    });
  }

  @override
  void initState() {
    _home = Provider.of<Home>(context, listen: false);
    getAllParamedics();
    super.initState();
  }

  @override
  void dispose() {
    _passwordNode.dispose();
    paramedicEmail.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InfoWidget(
      builder: (context, infoWidget) {
        return Directionality(
          textDirection: translator.currentLanguage == "en"
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: RefreshIndicator(
            color: Colors.indigo,
            backgroundColor: Colors.white,
            onRefresh: () async {
              await _home.getAllParamedics();
            },
            child: Scaffold(
              body: loadingBody
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ListView.builder(
                        itemBuilder: (context, _) => Shimmer.fromColors(
                          baseColor: Colors.black12.withOpacity(0.1),
                          highlightColor: Colors.black.withOpacity(0.2),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.blue[100],
                              ),
                              height: infoWidget.screenHeight * 0.15,
                            ),
                          ),
                        ),
                        itemCount: 5,
                      ),
                    )
                  : Consumer<Home>(
                      builder: (context, data, _) {
                        if (data.allNurses.length == 0) {
                          return Center(
                            child: Text(
                              translator.currentLanguage == "en"
                                  ? 'there is no any nursses'
                                  : 'لا يوجد مسعفين',
                              style: infoWidget.titleButton
                                  .copyWith(color: Colors.indigo),
                            ),
                          );
                        } else {
                          return ListView.builder(
                              itemCount: data.allNurses.length,
                              itemBuilder: (context, index) => content(
                                  infoWidget: infoWidget,
                                  userData: data.allNurses[index]));
                        }
                      },
                    ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (ctx) => Directionality(
                            textDirection: translator.currentLanguage == "en"
                                ? TextDirection.ltr
                                : TextDirection.rtl,
                            child: StatefulBuilder(
                              builder: (context, setState) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(25.0))),
                                contentPadding: EdgeInsets.only(top: 10.0),
                                title: Text(
                                  translator.currentLanguage == "en"
                                      ? 'add Paramedic'
                                      : 'اضافه مسعف',
                                  textAlign: TextAlign.center,
                                  style: infoWidget.title,
                                ),
                                content: Container(
                                  height: infoWidget.screenHeight * 0.25,
                                  child: Center(
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                height: 60,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    0.85,
                                                child: TextFormField(
                                                  controller: paramedicEmail,
                                                  autofocus: false,
                                                  decoration: InputDecoration(
                                                    labelText: translator
                                                                .currentLanguage ==
                                                            "en"
                                                        ? 'Paramedic Email'
                                                        : 'البريد الالكترونى للمسعف',
                                                    labelStyle: TextStyle(
                                                        color: Colors.indigo),
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
                                                          color: Colors.indigo),
                                                    ),
                                                  ),
                                                  // ignore: missing_return
                                                  validator: (val) {
                                                    if (val.isEmpty ||
                                                        !val.contains('@')) {
                                                      return translator
                                                                  .currentLanguage ==
                                                              "en"
                                                          ? 'InvalidEmail'
                                                          : 'البريد الالكترونى غير صحيح';
                                                    }
                                                  },
                                                  onFieldSubmitted: (_) {
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            _passwordNode);
                                                  },
                                                  keyboardType:
                                                      TextInputType.text,
                                                ),
                                              )),
                                          Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                height: 60,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    0.85,
                                                child: TextFormField(
                                                  controller: password,
                                                  autofocus: false,
                                                  focusNode: _passwordNode,
                                                  decoration: InputDecoration(
                                                    suffixIcon: IconButton(
                                                        icon: Icon(
                                                          _showPassword
                                                              ? Icons.visibility
                                                              : Icons
                                                                  .visibility_off,
                                                          color: _showPassword
                                                              ? Colors.indigo
                                                              : Colors.grey,
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            _showPassword =
                                                                !_showPassword;
                                                          });
                                                        }),
                                                    labelText: translator
                                                                .currentLanguage ==
                                                            "en"
                                                        ? 'Password'
                                                        : 'كلمه المرور',
                                                    labelStyle: TextStyle(
                                                        color: Colors.indigo),
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
                                                          color: Colors.indigo),
                                                    ),
                                                  ),
                                                  // ignore: missing_return
                                                  validator: (val) {
                                                    if (val.trim().isEmpty) {
                                                      return translator
                                                                  .currentLanguage ==
                                                              "en"
                                                          ? 'Invalid password'
                                                          : 'كلمه المرور غير صحيحه';
                                                    }
                                                    if (val.trim().length < 4) {
                                                      return translator
                                                                  .currentLanguage ==
                                                              "en"
                                                          ? 'Short password'
                                                          : 'كلمه المرور ضعيفه';
                                                    }
                                                  },
                                                  keyboardType:
                                                      TextInputType.text,
                                                ),
                                              ))
                                          //,Text('this is Your location',style: TextStyle(fontSize: 18,color: Colors.blue),),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text(
                                      translator.currentLanguage == "en"
                                          ? 'Cancel'
                                          : 'الغاء',
                                      style: infoWidget.subTitle
                                          .copyWith(color: Colors.indigo),
                                    ),
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                  _isLoading
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            CircularProgressIndicator(
                                              backgroundColor: Colors.indigo,
                                            )
                                          ],
                                        )
                                      : FlatButton(
                                          child: Text(
                                            translator.currentLanguage == "en"
                                                ? 'Add'
                                                : 'اضافه',
                                            style: infoWidget.subTitle
                                                .copyWith(color: Colors.indigo),
                                          ),
                                          onPressed: _submitForm,
                                        )
                                ],
                              ),
                            ),
                          ));
                },
                tooltip: translator.currentLanguage == "en" ? 'add' : 'اضافه',
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                backgroundColor: Colors.indigo,
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
            ),
          ),
        );
      },
    );
  }
}
