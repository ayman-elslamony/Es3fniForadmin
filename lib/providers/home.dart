import 'package:admin/models/coupon.dart';
import 'package:admin/models/http_exception.dart';
import 'package:admin/models/service.dart';
import 'package:admin/models/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home with ChangeNotifier {
  var firebaseAuth = FirebaseAuth.instance;
  final databaseReference = Firestore.instance;
  final String authToken;

  Home(
    this.authToken,
  );

  List<Service> allService = [];
  List<UserData> allNurses = [];
  List<Coupon> allCoupons = [];

  Future<bool> createAccountForParamedics(
      {String email, String password}) async {
    AuthResult auth;
    try {
      auth = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (auth.user != null) {
        var users = databaseReference.collection("nurses");
        DocumentSnapshot doc = await users.document(auth.user.uid).get();
        var x = email.split('@');
        if (!doc.exists) {
          await users.document(auth.user.uid).setData({
            'password': password,
            'email': email,
            'name': x[0] ?? 'Admin',
            'points': '0'
          });
        }
        await getAllParamedics();
      }
      print(auth.user);
      return true;
    } catch (e) {
      print(e);
      throw HttpException(e.code);
    }
  }

  Future getAllParamedics() async {
    var nurses = databaseReference.collection("nurses");
    var docs = await nurses.getDocuments();
    if (docs.documents.length != 0) {
      allNurses.clear();
      for (int i = 0; i < docs.documents.length; i++) {
        allNurses.add(UserData(
            docId: docs.documents[i].documentID,
            points: docs.documents[i].data['points'] ?? '',
            name: docs.documents[i].data['name'] ?? '',
            phoneNumber: docs.documents[i].data['phoneNumber'] ?? '',
            imgUrl: docs.documents[i].data['imgUrl'] ?? '',
            address: docs.documents[i].data['address'] ?? '',
            birthDate: docs.documents[i].data['birthDate'] ?? '',
            gender: docs.documents[i].data['gender'] ?? '',
            nationalId: docs.documents[i].data['nationalId'] ?? ''));
      }
    }
    notifyListeners();
  }

  Future<bool> deleteParamedic({UserData userData}) async {
    String userId;
    if (userData.email != null && userData.password != null) {
      try {
        AuthResult auth = await firebaseAuth.signInWithEmailAndPassword(
          email: userData.email,
          password: userData.password,
        );
        if (auth != null) {
          userId = auth.user.uid;
          await auth.user.delete();
          var nurses = databaseReference.collection("nurses");
          await nurses.document(userId).delete();
          allNurses.removeWhere((x) => x.docId == userData.docId);
          notifyListeners();
          return true;
        } else {
          return false;
        }
      } catch (e) {
        print(e);
        return false;
      }
    } else {
      return false;
    }
  }

  Future<String> addServices({String serviceName, String price}) async {
    var services = databaseReference.collection("services");
    String isvalid = 'yes';
//    var docs = await services.getDocuments();
//
//    if (docs.documents.length != 0) {
//      for (int i = 0; i < docs.documents.length; i++) {
//        if (docs.documents[i].data['serviceName'] == serviceName) {
//          isvalid = 'not valid';
//        }
//      }
//    }

    if (isvalid == 'yes') {
      await services.document().setData({
        'serviceName': serviceName,
        'price': price,
      }, merge: true);
      await getAllServices();
      isvalid = 'scuess';
    }
    return isvalid;
  }

  Future getAllServices() async {
    var services = databaseReference.collection("services");
    var docs = await services.getDocuments();
    if (docs.documents.length != 0) {
      allService.clear();
      for (int i = 0; i < docs.documents.length; i++) {
        allService.add(Service(
          id: docs.documents[i].documentID,
          price: docs.documents[i].data['price'],
          serviceName: docs.documents[i].data['serviceName'],
        ));
      }
    }
    notifyListeners();
  }

  Future<bool> deleteService({String serviceId}) async {
    var services = databaseReference.collection("services");
    await services.document(serviceId).delete();
    allService.removeWhere((x) => x.id == serviceId);
    notifyListeners();
    return true;
  }

  Future<String> addCoupon(
      {String couponName,
      String discountPercentage,
      String numberOfUses,
      String expiryDate}) async {
    var services = databaseReference.collection("coupons");
    String isvalid = 'yes';
//    var docs = await services.getDocuments();
//
//    if (docs.documents.length != 0) {
//      for (int i = 0; i < docs.documents.length; i++) {
//        if (docs.documents[i].data['serviceName'] == serviceName) {
//          isvalid = 'not valid';
//        }
//      }
//    }

    if (isvalid == 'yes') {
      await services.document().setData({
        'couponName': couponName,
        'discountPercentage': discountPercentage,
        'numberOfUses': numberOfUses,
        'expiryDate': expiryDate
      }, merge: true);
      await getAllCoupons();
      isvalid = 'scuess';
    }
    return isvalid;
  }

  Future<bool> deleteCoupon({String couponId}) async {
    var coupons = databaseReference.collection("coupons");
    await coupons.document(couponId).delete();
    allCoupons.removeWhere((x) => x.docId == couponId);
    notifyListeners();
    return true;
  }

  Future getAllCoupons() async {
    var coupons = databaseReference.collection("coupons");
    var docs = await coupons.getDocuments();
    if (docs.documents.length != 0) {
      allCoupons.clear();
      for (int i = 0; i < docs.documents.length; i++) {
        allCoupons.add(Coupon(
          docId: docs.documents[i].documentID,
          couponName: docs.documents[i].data['couponName'],
          discountPercentage: docs.documents[i].data['discountPercentage'],
          expiryDate: docs.documents[i].data['expiryDate'],
          numberOfUses: docs.documents[i].data['numberOfUses'],
        ));
      }
    }
    notifyListeners();
  }
}
