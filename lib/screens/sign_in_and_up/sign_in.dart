import 'package:es3fniforadmin/providers/auth.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:es3fniforadmin/core/ui_components/info_widget.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import '../../models/http_exception.dart';
import '../main_screen.dart';
import '../widgets.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String? email;
  String? password;
  String? errorMessage;
  final FocusNode _passwordNode = FocusNode();
  bool _showPassword = false;
  final GlobalKey<FormState> _formKey = GlobalKey();
 bool _isSignInSuccessful=false;
  void _showErrorDialog(String? message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message!),
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
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        setState(() {
          _isSignInSuccessful = true;
        });
        try {
          bool auth = await Provider.of<Auth>(context, listen: false).signInUsingEmail(
              email: email!.trim(), password: password!.trim());
          if (auth == true) {
            flutterToast(
                                      msg:
                translator.activeLanguageCode=='en'?"successfully Sign In":'نجح تسجيل الدخول', );
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HomeScreen()));
          }
        } on HttpException catch (error) {
          setState(() {
            _isSignInSuccessful = false;
          });
          switch (error.toString()) {
            case "ERROR_INVALID_EMAIL":
              errorMessage = "Your email address appears to be malformed.";
              break;
            case "ERROR_WRONG_PASSWORD":
              errorMessage = "Your password is wrong.";
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
            _isSignInSuccessful = false;
          });
          const errorMessage =
              'Could not authenticate you. Please try again later.';
          _showErrorDialog(errorMessage);
        }
      }

  }
  @override
  Widget build(BuildContext context) {
    return InfoWidget(
      builder: (context, infoWidget) {
        return SafeArea(
          child: Directionality(
            textDirection: translator.activeLanguageCode == "en" ?TextDirection.ltr:TextDirection.rtl,
            child: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: infoWidget.screenWidth! * 0.16,
                        ),
                        Container(
                            child: Center(
                                child: Hero(
                                    tag: 'splash',
                                    child: Image.asset('assets/logo.png',
                                        fit: BoxFit.fill,
                                        width: MediaQuery.of(context).orientation ==
                                                Orientation.landscape
                                            ? MediaQuery.of(context).size.width* 0.2
                                            : MediaQuery.of(context).size.width * 0.28)))),
                        const SizedBox(
                          height: 15.0,
                        ),
                        AnimatedTextKit(
                          animatedTexts: [
                            ColorizeAnimatedText(
                                translator.activeLanguageCode == "en" ? ' Es3fni ' : 'اسعفنى',
                                textStyle: TextStyle(
                                    fontSize: infoWidget.orientation==Orientation.portrait?infoWidget.screenWidth! * 0.05:infoWidget.screenWidth! * 0.032,
                                    fontWeight: FontWeight.bold),
                                colors: [
                                  Colors.red,
                                  Colors.indigo,
                                  Colors.red,
                                  Colors.indigo,
                                  Colors.red,
                                ],
                                textAlign: TextAlign.start,
                                textDirection: TextDirection.ltr),
                          ],
                          totalRepeatCount: 9,
                          pause: const Duration(milliseconds: 1000),
                          isRepeatingAnimation: true,
                        ),
                        SizedBox(
                          height: infoWidget.screenWidth! * 0.2,
                        ),
                         Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 8.0),
                           child: TextFormField(
                            autofocus: false,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            cursorColor: Colors.indigo,
                            decoration: InputDecoration(
                              labelText: translator.activeLanguageCode == "en" ?'Email':'البريد الالكترونى',
                              errorStyle: TextStyle(color: Colors.indigo),
                              focusedErrorBorder:OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.indigo),
                                  borderRadius: BorderRadius.all(Radius.circular(10))),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.indigo),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.indigo),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.indigo),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                              disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color:Colors.indigo),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                            ),
                            // ignore: missing_return
                            validator: (val) {
                              if (val!.isEmpty || !val.contains('@')) {
                                return translator.activeLanguageCode == "en" ?'InvalidEmail':'البريد الالكترونى غير صحيح';
                              }
                            },
                            onSaved: (val) {
                              email = val;
                            },
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_passwordNode);
                            },
                        ),
                         ),
                         SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextFormField(
                            focusNode: _passwordNode,
                            autofocus: false,
                            cursorColor: Colors.indigo,
                            obscureText: !_showPassword,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  icon: Icon(
                                    _showPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: _showPassword
                                        ? Colors.indigo
                                        : Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showPassword = !_showPassword;
                                    });
                                  }),
                              labelText: translator.activeLanguageCode == "en" ?'Password':'كلمه المرور',
                              errorStyle: TextStyle(color: Colors.indigo),
                              enabledBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color:Colors.indigo),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.indigo),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.indigo),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                              errorBorder: OutlineInputBorder(
                                  borderSide:
                                  BorderSide(color: Colors.indigo),
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                            ),
                            // ignore: missing_return
                            validator: (val) {
                              if (val!.trim().isEmpty) {
                                return translator.activeLanguageCode == "en" ?'Invalid password':'كلمه المرور غير صحيحه';
                              }
                              if ( val.trim().length < 4) {
                                return translator.activeLanguageCode == "en" ?'Short password':'كلمه المرور ضعيفه';
                              }
                            },
                            onSaved: (val) {
                              password = val;
                            },
                          ),
                        ),
                        SizedBox(height: 15,),
                        _isSignInSuccessful?Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                           const CircularProgressIndicator(color:  Colors.indigo,)
                          ],
                        ):
                        RaisedButton(
                          onPressed:
                            _submitForm,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 50),
                            child: Text(
                              translator.activeLanguageCode == "en" ?'Login':'تسجيل الدخول',
                              style: infoWidget.titleButton!
                                  .copyWith(color: Colors.indigo),
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),side: BorderSide(color: Colors.indigoAccent)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
