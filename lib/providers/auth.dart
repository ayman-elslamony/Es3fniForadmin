import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
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
   String userId = '';
  String signInType = '';
   UserData _userData;

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
    DocumentSnapshot doc = await users.document(userId).get();
    var x=email.split('@');
    if (!doc.exists) {
      await users.document(userId).setData({

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
        userId = auth.user.uid;
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
      }
      notifyListeners();
      return true;
    }catch (e) {
      throw HttpException(e.code);
    }
  }

  Future<bool> editProfile({String type,String address,String phone,File image,String job,String social,String bio})async{
//    FormData formData;
//    var data;
//    try{
//      if(type =='bio'){
//        formData = FormData.fromMap({
//          'bio': bio,
//        });
//        data = await _netWork
//            .updateData(url: 'doctor/$_userId', formData: formData, headers: {
//          'Authorization': 'Bearer $_token',
//        });
//        print('data $data');
//      }
//      if(type == 'image'){
//        String fileName = image.path
//            .split('/')
//            .last;
//        if(_userType == 'doctor'){
//          formData = FormData.fromMap({
//            'doctorImage': await MultipartFile.fromFile(image.path,
//                filename: fileName)
//          });
//        }else{
//          formData = FormData.fromMap({
//            'patientImage': await MultipartFile.fromFile(image.path,
//                filename: fileName)
//          });
//        }
//        data = await _netWork
//            .updateData(url: _userType=='doctor'?'doctor/$_userId':'patient/$_userId', formData: formData, headers: {
//          'Authorization': 'Bearer $_token',
//        });
//        print(data);
//      }
//      if(type == 'job'){
//        formData = FormData.fromMap({
//          'job': job,
//        });
//        data = await _netWork
//            .updateData(url: _userType=='doctor'?'doctor/$_userId':'patient/$_userId', formData: formData, headers: {
//          'Authorization': 'Bearer $_token',
//        });
//        print('data $data');
//      }
//      if(type == 'address'){
//        String government = '';
//        for (int i = 0; i < governorateList.length; i++) {
//          if (address.contains(governorateList[i])) {
//            government = governorateList[i];
//          }
//        }
//        formData = FormData.fromMap({
//          'address': address,
//          'government': government,
//        });
//        data = await _netWork
//            .updateData(url: _userType=='doctor'?'doctor/$_userId':'patient/$_userId', formData: formData, headers: {
//          'Authorization': 'Bearer $_token',
//        });
//        print('data $data');
//      }
//      if(type == 'phone'){
//        if(_userType == 'doctor') {
//          formData = FormData.fromMap({
//            'number': '0$phone',
//          });
//        }else{
//          formData = FormData.fromMap({
//            'phone': '0$phone',
//          });
//        }
//        data = await _netWork
//            .updateData(url: _userType=='doctor'?'doctor/$_userId':'patient/$_userId', formData: formData, headers: {
//          'Authorization': 'Bearer $_token',
//        });
//        print('data $data');
//      }
//      if(type == 'social'){
//        formData = FormData.fromMap({
//          'status': social,
//        });
//        data = await _netWork
//            .updateData(url: _userType=='doctor'?'doctor/$_userId':'patient/$_userId', formData: formData, headers: {
//          'Authorization': 'Bearer $_token',
//        });
//        print('data $data');
//      }
//      if (data != null) {
//        if(_userType =='doctor'){
//          rgisterData = RegisterData.fromJson(data['doctor'], 'doctor');
//        }else{
//          rgisterData = RegisterData.fromJson(data['patient'], 'patient');
//        }
//        print('svfdsb');
//        notifyListeners();
//        return true;
//      }else{
//        return false;
//      }
//    }catch (e){
//      print(e);
//      return false;
//    }
    return true;
  }
  Future<bool> logout() async {
    try {
      firebaseAuth.signOut();
      _token = null;
      userId = null;
      final prefs = await SharedPreferences.getInstance();
      prefs.clear();
      return true;
    } catch (e) {
      notifyListeners();
      return false;
    }
  }
}
