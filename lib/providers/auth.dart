import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:es3fniforadmin/models/http_exception.dart';
import 'package:es3fniforadmin/models/user_data.dart';

import 'package:shared_preferences/shared_preferences.dart';


class Auth with ChangeNotifier {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final databaseReference = FirebaseFirestore.instance;
   String? _token;
   static String? _userId = '';
  String signInType = '';
  static UserData? _userData;
  String? points = '0';
   double lat= 30.033333;
   double lng=31.233334;
  String? address='Cairo';
String? get userId =>_userId;
  UserData? get userData => _userData;
  bool get isAuth {
      return _token != null;
  }

  String? getToken() {
    print(_token);
    return _token;
  }

  Future<String?> get getUserId async {
    User user = firebaseAuth.currentUser!;
    if (user.uid.isNotEmpty) {
      return user.uid;
    } else {
      return null;
    }
  }

  Future<bool> tryToLogin() async {
    print('dfsgrsfrrrrrrrrrrrrrrrrrrff');
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('signInUsingEmail')) {
      print('dfsgffvdfhrtet5t');
      final dataToSignIn =
      await json.decode(prefs.getString('signInUsingEmail')!);
       await signInUsingEmail(email: dataToSignIn['email'] , password: dataToSignIn['password'] ).then((_){
        signInType='signInUsingEmail';
      });
    }
    print('dfsgff');
   if(signInType =='signInUsingEmail'){
      return true;
    }else{
      return false;
    }
  }
Future<void> getAdminPoints()async{
  var users = databaseReference.collection("admins");
  users.doc(_userId).snapshots().listen((doc){
    points = doc.data()!['points'];
    notifyListeners();
  });
}
  Future<void> setAndGetAdminData({required String email}) async {
    var users = databaseReference.collection("admins");
    DocumentSnapshot doc = await users.doc(_userId).get();
    var x=email.split('@');
    if (doc.exists == false) {
      await users. doc(_userId). set({
        'name': x[0],
        'points': '0'
      }, SetOptions(merge: true));
      _userData= UserData(name: x[0],points: '0');
    }else{
      _userData= UserData(name: doc.get('name')??'Admin',points: doc.get('points')??'0');
    }
    print('fdndfnmedf');
  }

  Future<bool> signInUsingEmail({required String email,required String password})async{
    UserCredential auth;
    print('dsgfdgfds');
    try{
       auth= await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if(auth.user!=null) {
        _userId = auth.user!.uid;
         String x =await  auth.user!.getIdToken();
         _token= x;
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
      throw HttpException(e.toString());
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
