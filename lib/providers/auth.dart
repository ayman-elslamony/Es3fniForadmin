import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:admin/core/models/device_info.dart';
import 'package:admin/models/http_exception.dart';
import 'package:admin/models/user_data.dart';
import 'package:admin/screens/main_screen.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class Auth with ChangeNotifier {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final databaseReference = Firestore.instance;
   String _token;
   static String _userId = '';
  String signInType = '';
  static UserData _userData;

   double lat= 30.033333;
   double lng=31.233334;
  String address='Cairo';
String get userId =>_userId;
  UserData get userData => _userData;
  bool get isAuth {
      return _token != null;
  }

  String getToken() {
    print(_token);
    return _token;
  }

  Future<String> get getUserId async {
    var user = await firebaseAuth.currentUser();
    if (user.uid != null) {
      return user.uid;
    } else {
      return null;
    }
  }

  Future<bool> tryToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('signInUsingEmail')) {
      final dataToSignIn =
      await json.decode(prefs.getString('signInUsingEmail')) as Map<String, Object>;
       await signInUsingEmail(email: dataToSignIn['email'], password: dataToSignIn['password']).then((_){
        signInType='signInUsingEmail';
      });
    }
   if(signInType =='signInUsingEmail'){
      return true;
    }else{
      return false;
    }
  }

  Future<void> setAndGetAdminData({String email}) async {
    var users = databaseReference.collection("admins");
    DocumentSnapshot doc = await users.document(_userId).get();
    var x=email.split('@');
    if (doc.exists == false) {
      await users.document(_userId).setData({
        'name': x[0]??'Admin',
        'points': '0'
      });
      _userData= UserData(name: x[0]??'Admin',points: '0');
    }else{
      _userData= UserData(name: doc.data['name']??'Admin',points: doc.data['points']??'0');
    }
    print('fdndfnmedf');
  }

  Future<bool> signInUsingEmail({String email,String password})async{
    AuthResult auth;
    try{
      auth= await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if(auth != null) {
        _userId = auth.user.uid;
         IdTokenResult x =await  auth.user.getIdToken();
         _token= x.token;
        await setAndGetAdminData(email: email);
        final prefs = await SharedPreferences.getInstance();
        if (!prefs.containsKey('signInUsingEmail')) {
          final _signInUsingEmail = json.encode({
            'email': email,
            'password': password,
          });
          prefs.setString('signInUsingEmail', _signInUsingEmail);
        }
        return true;
      }else{
        return false;
      }
    }catch (e) {
      throw HttpException(e.code);
    }
  }


  Future<bool> logout() async {
    try {
      firebaseAuth.signOut();
      _token = null;
      _userId = null;
      _userData =null;
      final prefs = await SharedPreferences.getInstance();
      prefs.clear();
      return true;
    } catch (e) {
      notifyListeners();
      return false;
    }
  }
}
