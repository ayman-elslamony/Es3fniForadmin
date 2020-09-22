import 'dart:io';
import 'package:admin/models/analysis.dart';
import 'package:admin/models/price.dart';
import 'package:admin/models/requests.dart';
import 'package:admin/models/supplying.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:path/path.dart' as path;
import 'package:admin/models/coupon.dart';
import 'package:admin/models/http_exception.dart';
import 'package:admin/models/service.dart';
import 'package:admin/models/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Home with ChangeNotifier {
  var firebaseAuth = FirebaseAuth.instance;
  final databaseReference = Firestore.instance;
  final String authToken;

  Home(
    this.authToken,
  );

  List<Service> allService = [];
  List<Analysis> allAnalysis = [];
  List<String> allServicesType =
      translator.currentLanguage == "en" ? ['Analysis'] : ['تحاليل'];
  List<String> allAnalysisType = [];
  List<UserData> allNurses = [];
  List<UserData> allNursesSupplies = [];
  List<Supplying> allSpecificNurseSupplies = [];
  List<Coupon> allCoupons = [];
  List<Requests> allAnalysisRequests = [];
  List<Requests> allPatientsRequests = [];

  Price price = Price(allServiceType: [], servicePrice: 0.0);
  Coupon coupon =
      Coupon(docId: '',couponName: '', discountPercentage: '0.0', numberOfUses: '0');
  double discount = 0.0;
  double priceBeforeDiscount = 0.0;

  addToPrice({String type, String serviceType}) {
    if (type == 'analysis') {
      if (!price.allServiceType.contains(serviceType)) {
        int index =
            allAnalysis.indexWhere((x) => x.analysisName == serviceType);
        List<String> x = price.allServiceType;
        x.add(serviceType);
//       priceBeforeDiscount =price.servicePrice + double.parse(allAnalysis[index].price);
        price = Price(
            servicePrice:
                price.servicePrice + double.parse(allAnalysis[index].price),
            allServiceType: x);
      }
    } else {
      if (!price.allServiceType.contains(serviceType)) {
        int index = allService.indexWhere((x) => x.serviceName == serviceType);
        List<String> x = price.allServiceType;
        // priceBeforeDiscount =price.servicePrice + double.parse(allService[index].price);
        x.add(serviceType);
        price = Price(
            servicePrice:
                price.servicePrice + double.parse(allService[index].price),
            allServiceType: x);
      }
    }
    notifyListeners();
  }

  resetPrice() {
    price = Price(allServiceType: [], servicePrice: 0.0);
  }

  removeFromPrice({String type, String serviceType}) {
    if (type == 'analysis') {
      if (!price.allServiceType.contains(serviceType)) {
        int index =
            allAnalysis.indexWhere((x) => x.analysisName == serviceType);
        List<String> x = price.allServiceType;
        x.add(serviceType);
        price = Price(
            servicePrice:
                price.servicePrice + double.parse(allAnalysis[index].price),
            allServiceType: x);
      }
    } else {
      if (!price.allServiceType.contains(serviceType)) {
        int index = allService.indexWhere((x) => x.serviceName == serviceType);
        List<String> x = price.allServiceType;
        x.add(serviceType);
        price = Price(
            servicePrice:
                price.servicePrice + double.parse(allService[index].price),
            allServiceType: x);
      }
    }
    notifyListeners();
  }

  Future<bool> createAccountForNurse(
      {String name,String email, String password, String nationalId}) async {
    AuthResult auth;
    try {
      auth = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (auth.user != null) {
        var users = databaseReference.collection("nurses");
        DocumentSnapshot doc = await users.document(auth.user.uid).get();
        if (!doc.exists) {
          await users.document(auth.user.uid).setData({
            'nationalId': nationalId,
            'password': password,
            'email': email,
            'name': name,
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
            email: docs.documents[i].data['email'] ?? '',
            password: docs.documents[i].data['password'] ?? '',
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
  Future getAllNursesSupplies() async {
    var nurses = databaseReference.collection("nurses");
    var docs = await nurses.getDocuments();
    if (docs.documents.length != 0) {
      allNursesSupplies.clear();
      for (int i = 0; i < docs.documents.length; i++) {
        allNursesSupplies.add(UserData(
            docId: docs.documents[i].documentID,
            email: docs.documents[i].data['email'] ?? '',
            password: docs.documents[i].data['password'] ?? '',
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
  Future getSpecificNurseSupplies() async {
    var nurses = databaseReference.collection("nurses");
    var docs = await nurses.getDocuments();
    if (docs.documents.length != 0) {
      allSpecificNurseSupplies.clear();
      for (int i = 0; i < docs.documents.length; i++) {
        allSpecificNurseSupplies.add(Supplying(
        points: docs.documents[i].data['points'] ?? '',
          date: docs.documents[i].data['date'] ?? '',
          time: docs.documents[i].data['time'] ?? ''
        ));
      }

    }
    allSpecificNurseSupplies=[
      Supplying(
          time: '13:24',
          date: '12-10-2020',
          points: '100'
      ),
      Supplying(
          time: '13:24',
          date: '12-10-2020',
          points: '10'
      ),Supplying(
          time: '13:24',
          date: '12-10-2020',
          points: '700'
      ),
    ];
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
    String isValid = 'yes';
    if (allService.length != 0) {
      for (int i = 0; i < allService.length; i++) {
        if (allService[i].serviceName == serviceName) {
          isValid = 'not valid';
        }
      }
    }

    if (isValid == 'yes') {
      await services.document().setData({
        'serviceName': serviceName,
        'price': price,
      }, merge: true);
      await getAllServices();
      isValid = 'scuess';
    }
    return isValid;
  }

  Future getAllServices() async {
    var services = databaseReference.collection("services");
    var docs = await services.getDocuments();
    allService.clear();
    allServicesType =
    translator.currentLanguage == "en" ? ['Analysis'] : ['تحاليل'];
    if (docs.documents.length != 0) {
      for (int i = 0; i < docs.documents.length; i++) {
        allService.add(Service(
          id: docs.documents[i].documentID,
          price: docs.documents[i].data['price'],
          serviceName: docs.documents[i].data['serviceName'],
        ));
        allServicesType.add(docs.documents[i].data['serviceName']);
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

  Future<String> addAnalysis({String analysisName, String price}) async {
    var analysis = databaseReference.collection("analysis");
    String isValid = 'yes';
    if (allAnalysis.length != 0) {
      for (int i = 0; i < allAnalysis.length; i++) {
        if (allAnalysis[i].analysisName == analysisName) {
          isValid = 'not valid';
        }
      }
    }

    if (isValid == 'yes') {
      await analysis.document().setData({
        'analysisName': analysisName,
        'price': price,
      }, merge: true);
      await getAllAnalysis();
      isValid = 'scuess';
    }
    return isValid;
  }

  Future getAllAnalysis() async {
    var analysis = databaseReference.collection("analysis");
    var docs = await analysis.getDocuments();
    if (docs.documents.length != 0) {
      allAnalysis.clear();
      allAnalysisType.clear();
      for (int i = 0; i < docs.documents.length; i++) {
        allAnalysis.add(Analysis(
          id: docs.documents[i].documentID,
          price: docs.documents[i].data['price'],
          analysisName: docs.documents[i].data['analysisName'],
        ));
        allAnalysisType.add(docs.documents[i].data['analysisName']);
      }
    }
    notifyListeners();
  }

  Future<bool> deleteAnalysis({String analysisId}) async {
    var services = databaseReference.collection("analysis");
    await services.document(analysisId).delete();
    allAnalysis.removeWhere((x) => x.id == analysisId);
    notifyListeners();
    return true;
  }

  Future<String> verifyCoupon({String couponName}) async {
    var services = databaseReference.collection("coupons");
    QuerySnapshot docs = await services
        .where('couponName', isEqualTo: couponName)
        .getDocuments();
    if (docs.documents.length == 0) {
      return 'false';
    } else {
      List<String> date  = docs.documents[0].data['expiryDate'].toString().split('-');
      print(date);
      DateTime time =DateTime(int.parse(date[2]),
          int.parse(date[1]),
          int.parse(date[0])
          );
      if (price.isAddingDiscount == false && price.servicePrice != 0.0 && docs.documents[0].data['numberOfUses']!='0' && time.isAfter(DateTime.now())) {
        coupon = Coupon(
          docId: docs.documents[0].documentID,
          couponName: docs.documents[0].data['couponName'],
          discountPercentage: docs.documents[0].data['discountPercentage'],
          expiryDate: docs.documents[0].data['expiryDate'],
          numberOfUses: docs.documents[0].data['numberOfUses'],
        );
        double prices = price.servicePrice;
        priceBeforeDiscount = price.servicePrice;
        discount = prices * (double.parse(coupon.discountPercentage) / 100);
        List<String> x = price.allServiceType;
        price = Price(
            servicePrice: (prices - discount),
            isAddingDiscount: true,
            allServiceType: x);
        notifyListeners();
        return 'true';
      } else if (price.servicePrice == 0.0) {
        return 'add service before discount';
      }else if(!time.isAfter(DateTime.now())|| docs.documents[0].data['numberOfUses']=='0'){
        return 'Coupon not Avilable';
      } else {
        return 'already discount';
      }
    }
  }

  Future<void> unVerifyCoupon() async {
    double prices = price.servicePrice;
    List<String> x = price.allServiceType;
    price = Price(
        servicePrice: (prices + discount),
        isAddingDiscount: false,
        allServiceType: x);
    notifyListeners();
  }

  Future<String> addCoupon(
      {String couponName,
      String discountPercentage,
      String numberOfUses,
      String expiryDate}) async {
    var coupon = databaseReference.collection("coupons");
    String isValid = 'yes';
//    var docs = await services.getDocuments();
//
    if (allCoupons.length != 0) {
      for (int i = 0; i < allCoupons.length; i++) {
        if (allCoupons[i].couponName == couponName) {
          isValid = 'not valid';
        }
      }
    }

    if (isValid == 'yes') {
      await coupon.document().setData({
        'couponName': couponName,
        'discountPercentage': discountPercentage,
        'numberOfUses': numberOfUses,
        'expiryDate': expiryDate
      }, merge: true);
      await getAllCoupons();
      isValid = 'scuess';
    }
    return isValid;
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

  Future<bool> addPatientRequest(
      {String analysisType,
      String patientName,
      String patientPhone,
      String patientLocation,
      String patientAge,
      String patientGender,
      String numOfPatients,
      String serviceType,
      String nurseGender,
      String suppliesFromPharmacy,
      File picture,
      String discountCoupon,
      String startVisitDate,
      String endVisitDate,
      String visitDays,
      String visitTime,
      String notes}) async {
    String imgUrl = '';
    var users = databaseReference.collection("users");
    var _coupons = databaseReference.collection("coupons");
    print('patientPhone');
    print(patientPhone);
    var docs =
        await users.where('phoneNumber', isEqualTo: patientPhone).getDocuments();
    print(docs.documents);
    if (picture != null) {
      try {
        var storageReference = FirebaseStorage.instance.ref().child(
            '$serviceType/$patientName/$patientPhone/${path.basename(picture.path)}');
        StorageUploadTask uploadTask = storageReference.putFile(picture);
        await uploadTask.onComplete;
        await storageReference.getDownloadURL().then((fileURL) async {
          imgUrl = fileURL;
        });
      } catch (e) {
        print(e);
      }
    }
    print('docs.documents[0].documentID');
    print(docs.documents[0].documentID);
    DateTime dateTime = DateTime.now().toUtc();
      DocumentReference x =
          await databaseReference.collection('requests').add({
        'nurseId':'',
        'patientId':
            docs.documents.length != 0 ? docs.documents[0].documentID : '',
        'patientName': patientName,
        'patientPhone': patientPhone,
        'patientLocation': patientLocation,
        'patientAge': patientAge,
        'patientGender': patientGender,
        'numOfPatients': numOfPatients,
        'serviceType': serviceType,
        'analysisType': analysisType,
        'nurseGender': nurseGender,
        'date': '${dateTime.day}/${dateTime.month}/${dateTime.year}',
        'time': '${dateTime.hour}:${dateTime.minute}',
        'servicePrice': discountCoupon == ''
            ? price.servicePrice.toString()
            : priceBeforeDiscount.toString(),
        'suppliesFromPharmacy': suppliesFromPharmacy,
        'picture': imgUrl,
        'discountPercentage': coupon.discountPercentage,
        'discountCoupon': discountCoupon,
        'startVisitDate': startVisitDate,
        'endVisitDate': endVisitDate,
        'visitDays': visitDays,
        'visitTime': visitTime,
        'notes': notes,
        'priceBeforeDiscount': discountCoupon == ''
            ? price.servicePrice.toString()
            : priceBeforeDiscount.toString(),
        'priceAfterDiscount': price.servicePrice,
      });
      if (docs.documents.length != 0) {
        await users
            .document(docs.documents[0].documentID)
            .collection('requests')
            .document(x.documentID)
            .setData({'docId': x.documentID});
      }
    if(coupon.docId != ''){
      int x = int.parse(coupon.numberOfUses);
      if(x != 0){
        x =x-1;
      }
      _coupons.document(coupon.docId).updateData({
        'numberOfUses': x,
      });
    }
    return true;
  }

  Future getAllAnalysisRequests() async {
    var requests = databaseReference.collection('requests');
    requests.where('serviceType',whereIn: ['Analysis','تحاليل']).snapshots().listen((docs){
      print(docs);
      print('csdv xsvxs');
      allAnalysisRequests.clear();
      if (docs.documents.length != 0) {
        for (int i = 0; i < docs.documents.length; i++) {
          allAnalysisRequests.add(Requests(
              nurseId: docs.documents[i].data['nurseId'] ?? '',
              patientId: docs.documents[i].data['patientId'] ?? '',
              docId: docs.documents[i].documentID,
              visitTime: docs.documents[i].data['visitTime'] ?? '',
              visitDays: docs.documents[i].data['visitDays'] ?? '',
              suppliesFromPharmacy:
              docs.documents[i].data['suppliesFromPharmacy'] ?? '',
              startVisitDate: docs.documents[i].data['startVisitDate'] ?? '',
              serviceType: docs.documents[i].data['serviceType'] ?? '',
              picture: docs.documents[i].data['picture'] ?? '',
              patientPhone: docs.documents[i].data['patientPhone'] ?? '',
              patientName: docs.documents[i].data['patientName'] ?? '',
              patientLocation: docs.documents[i].data['patientLocation'] ?? '',
              patientGender: docs.documents[i].data['patientGender'] ?? '',
              time: docs.documents[i].data['time'] ?? '',
              date: docs.documents[i].data['date'] ?? '',
              discountPercentage:
              docs.documents[i].data['discountPercentage'] ?? '',
              patientAge: docs.documents[i].data['patientAge'] ?? '',
              servicePrice: docs.documents[i].data['servicePrice'] ?? '',
              nurseGender: docs.documents[i].data['nurseGender'] ?? '',
              numOfPatients: docs.documents[i].data['numOfPatients'] ?? '',
              endVisitDate: docs.documents[i].data['endVisitDate'] ?? '',
              discountCoupon: docs.documents[i].data['discountCoupon'] ?? '',
              priceBeforeDiscount:
              docs.documents[i].data['priceBeforeDiscount'] ?? '',
              analysisType: docs.documents[i].data['analysisType'] ?? '',
              notes: docs.documents[i].data['notes'] ?? '',
              priceAfterDiscount:
              docs.documents[i].data['priceAfterDiscount'].toString() ?? ''));
        }
      }else{
        allAnalysisRequests.clear();
      }
      notifyListeners();
    });

  }
  Future<UserData> getUserData({String type,String userId})async{
    var nursesCollection = databaseReference.collection("nurses");
    var patientCollection = databaseReference.collection("users");
    UserData user;
    if(type == 'Patient'){
      DocumentSnapshot doc =await patientCollection.document(userId).get();
      user = UserData(
        name: doc.data['name'],
        docId: doc.documentID,
        nationalId: doc.data['nationalId'] ?? '',
        gender: doc.data['gender'] ?? '',
        birthDate: doc.data['birthDate'] ?? '',
        address: doc.data['address'] ?? '',
        phoneNumber: doc.data['phoneNumber'] ?? '',
        imgUrl: doc.data['imgUrl'] ?? '',
        email: doc.data['email'] ?? '',
        aboutYou: doc.data['aboutYou'] ?? '',
        points: doc.data['points'] ?? '',
      );
    }else{
      DocumentSnapshot doc =await nursesCollection.document(userId).get();
      user = UserData(
        name: doc.data['name'],
        docId: doc.documentID,
        nationalId: doc.data['nationalId'] ?? '',
        gender: doc.data['gender'] ?? '',
        birthDate: doc.data['birthDate'] ?? '',
        address: doc.data['address'] ?? '',
        phoneNumber: doc.data['phoneNumber'] ?? '',
        imgUrl: doc.data['imgUrl'] ?? '',
        email: doc.data['email'] ?? '',
        aboutYou: doc.data['aboutYou'] ?? '',
        points: doc.data['points'] ?? '',
      );
    }
    return user;
  }
  Future getAllPatientsRequests() async {
    var requests = databaseReference.collection('requests');
    requests.where('analysisType',isEqualTo: '').snapshots().listen((docs){
      allPatientsRequests.clear();
      if (docs.documents.length != 0) {
        for (int i = 0; i < docs.documents.length; i++) {
          allPatientsRequests.add(Requests(

              patientId: docs.documents[i].data['patientId'] ?? '',
              docId: docs.documents[i].documentID,
              visitTime: docs.documents[i].data['visitTime'] == '[]'
                  ? ''
                  : docs.documents[i].data['visitTime'] ?? '',
              visitDays: docs.documents[i].data['visitDays'] == '[]'
                  ? ''
                  : docs.documents[i].data['visitDays'] ?? '',
              nurseId: docs.documents[i].data['nurseId'] ?? '',
              suppliesFromPharmacy:
              docs.documents[i].data['suppliesFromPharmacy'] ?? '',
              startVisitDate: docs.documents[i].data['startVisitDate'] ?? '',
              serviceType: docs.documents[i].data['serviceType'] ?? '',
              picture: docs.documents[i].data['picture'] ?? '',
              patientPhone: docs.documents[i].data['patientPhone'] ?? '',
              patientName: docs.documents[i].data['patientName'] ?? '',
              patientLocation: docs.documents[i].data['patientLocation'] ?? '',
              patientGender: docs.documents[i].data['patientGender'] ?? '',
              patientAge: docs.documents[i].data['patientAge'] ?? '',
              servicePrice: docs.documents[i].data['servicePrice'] ?? '',
              time: docs.documents[i].data['time'] ?? '',
              date: docs.documents[i].data['date'] ?? '',
              discountPercentage:
              docs.documents[i].data['discountPercentage'] ?? '',
              nurseGender: docs.documents[i].data['nurseGender'] ?? '',
              numOfPatients: docs.documents[i].data['numOfPatients'] ?? '',
              endVisitDate: docs.documents[i].data['endVisitDate'] ?? '',
              discountCoupon: docs.documents[i].data['discountCoupon'] ?? '',
              priceBeforeDiscount:
              docs.documents[i].data['priceBeforeDiscount'] ?? '',
              analysisType: docs.documents[i].data['analysisType'] ?? '',
              notes: docs.documents[i].data['notes'] ?? '',
              priceAfterDiscount:
              docs.documents[i].data['priceAfterDiscount'].toString() ?? ''));
        }
      }else{
        allPatientsRequests.clear();
      }
      notifyListeners();
    });

  }
}
