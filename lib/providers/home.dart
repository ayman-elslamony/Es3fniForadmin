import 'dart:io';
import 'dart:math';
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
  double totalRatingForNurse = 0.0;
  List<Requests> allArchivedRequests = [];
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
  double radiusForAllRequests= 1.0;
  Price price = Price(allServiceType: [], servicePrice: 0.0);
  Coupon coupon = Coupon(
      docId: '', couponName: '', discountPercentage: '0.0', numberOfUses: '0');
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
  changeRadiusForAllRequests(double val){
    radiusForAllRequests = val;
    notifyListeners();
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
      {String name, String email, String password, String nationalId,String specialization='',String specializationBranch=''}) async {
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
            'specialization':specialization,
            'specializationBranch':specializationBranch
            ,'points': '0'
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
    databaseReference.collection("nurses").snapshots().listen((docs) async{

      CollectionReference nursesCollection = databaseReference.collection("nurses");
      allNurses.clear();
      double ratingForNurse =0.0;
      if (docs.documents.length != 0) {
        for (int i = 0; i < docs.documents.length; i++) {
          DocumentSnapshot rating = await nursesCollection.document(docs.documents[i].documentID).collection('rating').document('rating').get();
          if(rating.exists) {
            int one = rating.data['1'] == null ? 0 : int.parse(rating.data['1']);
            int two = rating.data['2'] == null ? 0 : int.parse(rating.data['2']);
            int three = rating.data['3'] == null ? 0 : int.parse(rating.data['3']);
            int four = rating.data['4'] == null ? 0 : int.parse(rating.data['4']);
            int five = rating.data['5'] == null ? 0 : int.parse(rating.data['5']);
            ratingForNurse =
                (5 * five + 4 * four + 3 * three + 2 * two + 1 * one) /
                    (one + two + three + four + five);
          }
          allNurses.add(UserData(
              specializationBranch:docs.documents[i].data['specializationBranch'].toString() ?? '',
              specialization: docs.documents[i].data['specialization'].toString() ?? '',
              rating: ratingForNurse.toString(),
              isActive: docs.documents[i].data['isActive'] ?? false,
              lat: docs.documents[i].data['lat'] ?? '',
              lng: docs.documents[i].data['lng'] ?? '',
              aboutYou: docs.documents[i].data['aboutYou'] ?? '',
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
    });
  }

  Future getAllNursesSupplies() async {
    databaseReference.collection("nurses").snapshots().listen((docs)async{
      CollectionReference nursesCollection = databaseReference.collection("nurses");
      double ratingForNurse =0.0;

      allNursesSupplies.clear();
      if (docs.documents.length != 0) {
        for (int i = 0; i < docs.documents.length; i++) {
          DocumentSnapshot rating = await nursesCollection.document(docs.documents[i].documentID).collection('rating').document('rating').get();
          if(rating.exists) {
            int one = rating.data['1'] == null ? 0 : int.parse(rating.data['1']);
            int two = rating.data['2'] == null ? 0 : int.parse(rating.data['2']);
            int three = rating.data['3'] == null ? 0 : int.parse(rating.data['3']);
            int four = rating.data['4'] == null ? 0 : int.parse(rating.data['4']);
            int five = rating.data['5'] == null ? 0 : int.parse(rating.data['5']);
            ratingForNurse =
                (5 * five + 4 * four + 3 * three + 2 * two + 1 * one) /
                    (one + two + three + four + five);
          }
          allNursesSupplies.add(UserData(
              specializationBranch:docs.documents[i].data['specializationBranch'].toString() ?? '',
              specialization: docs.documents[i].data['specialization'].toString() ?? '',
              rating: ratingForNurse.toString(),
              isActive: docs.documents[i].data['isActive'] ?? false,
              lat: docs.documents[i].data['lat'] ?? '',
              lng: docs.documents[i].data['lng'] ?? '',
              aboutYou: docs.documents[i].data['aboutYou'] ?? '',
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
    });
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
            time: docs.documents[i].data['time'] ?? ''));
      }
    }
    allSpecificNurseSupplies = [
      Supplying(time: '13:24', date: '12-10-2020', points: '100'),
      Supplying(time: '13:24', date: '12-10-2020', points: '10'),
      Supplying(time: '13:24', date: '12-10-2020', points: '700'),
    ];
    notifyListeners();
  }

  Future nurseSupplying({String nurseId, String points}) async {}

  Future getAllArchivedRequests() async {
    String time='';
    String acceptTime='';
    List<String> convertAllVisitsTime=[];
    CollectionReference requests = databaseReference.collection('archived requests');
    CollectionReference archivedForPatients = databaseReference.collection('archivedForPatients');
    CollectionReference patientCollection = databaseReference.collection("users");
    QuerySnapshot docsForArchivedRequestsForNoAccount = await requests.getDocuments();
    QuerySnapshot docsForArchivedForPatients = await archivedForPatients.getDocuments();
    allArchivedRequests.clear();
    print('A');
    if (docsForArchivedRequestsForNoAccount.documents.length != 0) {
      print('B');

      for (int i = 0; i < docsForArchivedRequestsForNoAccount.documents.length; i++) {
        if(docsForArchivedRequestsForNoAccount.documents[i].data['time'] !=''){
          time=convertTimeToAMOrPM(time: docsForArchivedRequestsForNoAccount.documents[i].data['time']);
        }else{
          time='';
        }
        if(docsForArchivedRequestsForNoAccount.documents[i].data['acceptTime'] !=null && docsForArchivedRequestsForNoAccount.documents[i].data['acceptTime'] !=''){
          acceptTime=convertTimeToAMOrPM(time: docsForArchivedRequestsForNoAccount.documents[i].data['acceptTime']);
        }else{
          acceptTime='';
        }
        if (docsForArchivedRequestsForNoAccount.documents[i].data['visitTime'] != '[]') {
          var x = docsForArchivedRequestsForNoAccount.documents[i].data['visitTime'].replaceFirst('[', '').toString();
          String visitTime = x.replaceAll(']', '');
          List<String> times=visitTime.split(',');
          if(times.length !=0){
            for(int i=0; i<times.length; i++){
              convertAllVisitsTime.add(convertTimeToAMOrPM(time: times[i]));
            }
          }
        }else{
          convertAllVisitsTime=[];
        }
        allArchivedRequests.add(Requests(
specialization: docsForArchivedRequestsForNoAccount.documents[i].data['specialization'] ?? '',
            specializationBranch: docsForArchivedRequestsForNoAccount.documents[i].data['specializationBranch'] ?? '',
            acceptTime: acceptTime,
            nurseId: docsForArchivedRequestsForNoAccount.documents[i].data['nurseId'] ?? '',
            patientId: docsForArchivedRequestsForNoAccount.documents[i].data['patientId'] ?? '',
            docId: docsForArchivedRequestsForNoAccount.documents[i].documentID,
            visitTime: convertAllVisitsTime.toString() == '[]'
                ? ''
                : convertAllVisitsTime.toString(),

            visitDays: docsForArchivedRequestsForNoAccount.documents[i].data['visitDays'] == '[]'
                ? ''
                : docsForArchivedRequestsForNoAccount.documents[i].data['visitDays'] ?? '',
            suppliesFromPharmacy:
                docsForArchivedRequestsForNoAccount.documents[i].data['suppliesFromPharmacy'] ?? '',
            startVisitDate: docsForArchivedRequestsForNoAccount.documents[i].data['startVisitDate'] ?? '',
            serviceType: docsForArchivedRequestsForNoAccount.documents[i].data['serviceType'] ?? '',
            picture: docsForArchivedRequestsForNoAccount.documents[i].data['picture'] ?? '',
            patientPhone: docsForArchivedRequestsForNoAccount.documents[i].data['patientPhone'] ?? '',
            patientName: docsForArchivedRequestsForNoAccount.documents[i].data['patientName'] ?? '',
            patientLocation: docsForArchivedRequestsForNoAccount.documents[i].data['patientLocation'] ?? '',
            patientGender: docsForArchivedRequestsForNoAccount.documents[i].data['patientGender'] ?? '',
            patientAge: docsForArchivedRequestsForNoAccount.documents[i].data['patientAge'] ?? '',
            servicePrice: docsForArchivedRequestsForNoAccount.documents[i].data['servicePrice'] ?? '',
            time: time,
            date: docsForArchivedRequestsForNoAccount.documents[i].data['date'] ?? '',
            discountPercentage:
                docsForArchivedRequestsForNoAccount.documents[i].data['discountPercentage'] ?? '',
            nurseGender: docsForArchivedRequestsForNoAccount.documents[i].data['nurseGender'] ?? '',
            numOfPatients: docsForArchivedRequestsForNoAccount.documents[i].data['numOfPatients'] ?? '',
            endVisitDate: docsForArchivedRequestsForNoAccount.documents[i].data['endVisitDate'] ?? '',
            discountCoupon: docsForArchivedRequestsForNoAccount.documents[i].data['discountCoupon'] ?? '',
            priceBeforeDiscount:
                docsForArchivedRequestsForNoAccount.documents[i].data['priceBeforeDiscount'] ?? '',
            analysisType: docsForArchivedRequestsForNoAccount.documents[i].data['analysisType'] ?? '',
            notes: docsForArchivedRequestsForNoAccount.documents[i].data['notes'] ?? '',
            priceAfterDiscount:
                docsForArchivedRequestsForNoAccount.documents[i].data['priceAfterDiscount'].toString() ?? ''));
      }
      print('dfbfdsndd');
      print(allArchivedRequests.length);

    }
    if (docsForArchivedForPatients.documents.length != 0) {
     time='';
     acceptTime='';
     convertAllVisitsTime=[];

      for (int i = 0; i < docsForArchivedForPatients.documents.length; i++) {
        DocumentSnapshot doc = await patientCollection.document(
            docsForArchivedForPatients.documents[i].data['patientId'])
            .collection('archived requests').document(
            docsForArchivedForPatients.documents[i].documentID)
            .get();
          if(doc.exists){

        if (doc.data['time'] !=
            '') {
          time = convertTimeToAMOrPM(
              time: doc.data['time']);
        } else {
          time = '';
        }
        if (doc.data['acceptTime'] != null && doc.data['acceptTime'] !='') {
          print('doc.data acceptTime');
          print(doc.data['acceptTime']);
          acceptTime = convertTimeToAMOrPM(
              time: doc.data['acceptTime']);
        } else {
          acceptTime = '';
        }
        if (doc.data['visitTime'] != '[]') {
          var x = doc.data['visitTime'].replaceFirst('[', '').toString();
          String visitTime = x.replaceAll(']', '');
          List<String> times = visitTime.split(',');
          if (times.length != 0) {
            for (int i = 0; i < times.length; i++) {
              convertAllVisitsTime.add(convertTimeToAMOrPM(time: times[i]));
            }
          }
        } else {
          convertAllVisitsTime = [];
        }
        allArchivedRequests.add(Requests(
            specialization: doc.data['specialization'] ?? '',
            specializationBranch: doc.data['specializationBranch'] ?? '',
            acceptTime: acceptTime,
            nurseId: doc.data['nurseId'] ?? '',
            patientId: doc .data['patientId'] ?? '',
            docId:doc.documentID,
            visitTime: convertAllVisitsTime.toString() == '[]'
                ? ''
                : convertAllVisitsTime.toString(),

            visitDays:doc.data['visitDays'] == '[]'
                ? ''
                :doc.data['visitDays'] ?? '',
            suppliesFromPharmacy:
            doc.data['suppliesFromPharmacy'] ?? '',
            startVisitDate:doc.data['startVisitDate'] ?? '',
            serviceType:doc.data['serviceType'] ?? '',
            picture: doc.data['picture'] ?? '',
            patientPhone: doc.data['patientPhone'] ?? '',
            patientName:doc.data['patientName'] ?? '',
            patientLocation:doc.data['patientLocation'] ?? '',
            patientGender:doc.data['patientGender'] ?? '',
            patientAge: doc.data['patientAge'] ?? '',
            servicePrice: doc.data['servicePrice'] ?? '',
            time: time,
            date: doc.data['date'] ?? '',
            discountPercentage:
            doc.data['discountPercentage'] ?? '',
            nurseGender: doc.data['nurseGender'] ?? '',
            numOfPatients: doc.data['numOfPatients'] ?? '',
            endVisitDate: doc.data['endVisitDate'] ?? '',
            discountCoupon: doc.data['discountCoupon'] ?? '',
            priceBeforeDiscount:
            doc.data['priceBeforeDiscount'] ?? '',
            analysisType:doc.data['analysisType'] ?? '',
            notes: doc.data['notes'] ?? '',
            priceAfterDiscount:
            doc.data['priceAfterDiscount'].toString() ?? ''));
      }
        }
        print('dfbfdsndd');
        print(allArchivedRequests.length);

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

  Future<String> verifyCoupon({String phoneNumber='',String couponName}) async {
    CollectionReference services = databaseReference.collection("coupons");
    CollectionReference users = databaseReference.collection("users");
    String _return='';
    if(phoneNumber==''){
      _return= 'add Phone';
    }else{
      QuerySnapshot isHaveAccount=await users
          .where('phoneNumber', isEqualTo: phoneNumber).getDocuments();
      if(isHaveAccount.documents.length != 0){
        QuerySnapshot isUsedBefore=await users
            .document(isHaveAccount.documents[0].documentID)
            .collection('coupons').where('couponName', isEqualTo: couponName).getDocuments();
        if(isUsedBefore.documents.length != 0){
          _return= 'isUserBefore';
        }
      }else{
        QuerySnapshot docs = await services
            .where('couponName', isEqualTo: couponName)
            .getDocuments();
        if (docs.documents.length == 0) {
          _return= 'false';
        } else {
          List<String> date =
          docs.documents[0].data['expiryDate'].toString().split('-');
          print(date);
          DateTime time =
          DateTime(int.parse(date[0]), int.parse(date[1]), int.parse(date[2]));
          if (price.isAddingDiscount == false &&
              price.servicePrice != 0.0 &&
              docs.documents[0].data['numberOfUses'].toString() != '0' &&
              time.isAfter(DateTime.now())) {
            coupon = Coupon(
              docId: docs.documents[0].documentID,
              couponName: docs.documents[0].data['couponName'],
              discountPercentage: docs.documents[0].data['discountPercentage'],
              expiryDate: docs.documents[0].data['expiryDate'],
              numberOfUses: docs.documents[0].data['numberOfUses'].toString(),
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
            _return= 'true';
          } else if (price.servicePrice == 0.0) {
            return 'add service before discount';
          } else if (!time.isAfter(DateTime.now()) ||
              docs.documents[0].data['numberOfUses'] == '0') {
            _return= 'Coupon not Avilable';
          } else {
            _return= 'already discount';
          }
        }
      }
    }
    return _return;
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
          numberOfUses: docs.documents[i].data['numberOfUses'].toString(),
        ));
      }
    }
    notifyListeners();
  }

  String convertTimeToAMOrPM({String time}) {
    List<String> split = time.split(':');
    int clock = int.parse(split[0]);
    String realTime = '';
    print('clock: $clock');
    switch (clock) {
      case 13:
        realTime = translator.currentLanguage == 'en'
            ? '1:${split[1]} PM'
            : '1:${split[1]} م ';
        break;
      case 14:
        realTime = translator.currentLanguage == 'en'
            ? '2:${split[1]} PM'
            : '2:${split[1]} م ';
        break;
      case 15:
        realTime = translator.currentLanguage == 'en'
            ? '3:${split[1]} PM'
            : '3:${split[1]} م ';
        break;
      case 16:
        realTime = translator.currentLanguage == 'en'
            ? '4:${split[1]} PM'
            : '4:${split[1]} م ';
        break;
      case 17:
        realTime = translator.currentLanguage == 'en'
            ? '5:${split[1]} PM'
            : '5:${split[1]} م ';
        break;
      case 18:
        realTime = translator.currentLanguage == 'en'
            ? '6:${split[1]} PM'
            : '6:${split[1]} م ';
        break;
      case 19:
        realTime = translator.currentLanguage == 'en'
            ? '7:${split[1]} PM'
            : '7:${split[1]} م ';
        break;
      case 20:
        realTime = translator.currentLanguage == 'en'
            ? '8:${split[1]} PM'
            : '8:${split[1]} م ';
        break;
      case 21:
        realTime = translator.currentLanguage == 'en'
            ? '9:${split[1]} PM'
            : '9:${split[1]} م ';
        break;
      case 22:
        realTime = translator.currentLanguage == 'en'
            ? '10:${split[1]} PM'
            : '10:${split[1]} م ';
        break;
      case 23:
        realTime = translator.currentLanguage == 'en'
            ? '11:${split[1]} PM'
            : '11:${split[1]} م ';
        break;
      case 00:
      case 0:
        realTime = translator.currentLanguage == 'en'
            ? '12:${split[1]} PM'
            : '12:${split[1]} م ';
        break;
      case 01:
        realTime = translator.currentLanguage == 'en'
            ? '1:${split[1]} AM'
            : '1:${split[1]} ص ';
        break;
      case 02:
        realTime = translator.currentLanguage == 'en'
            ? '2:${split[1]} AM'
            : '2:${split[1]} ص ';
        break;
      case 03:
        realTime = translator.currentLanguage == 'en'
            ? '3:${split[1]} AM'
            : '3:${split[1]} ص ';
        break;
      case 04:
        realTime = translator.currentLanguage == 'en'
            ? '4:${split[1]} AM'
            : '4:${split[1]} ص ';
        break;
      case 05:
        realTime = translator.currentLanguage == 'en'
            ? '5:${split[1]} AM'
            : '5:${split[1]} ص ';
        break;
      case 06:
        realTime = translator.currentLanguage == 'en'
            ? '6:${split[1]} AM'
            : '6:${split[1]} ص ';
        break;
      case 07:
        realTime = translator.currentLanguage == 'en'
            ? '7:${split[1]} AM'
            : '7:${split[1]} ص ';
        break;
      case 08:
        realTime = translator.currentLanguage == 'en'
            ? '8:${split[1]} AM'
            : '8:${split[1]} ص ';
        break;
      case 09:
        realTime = translator.currentLanguage == 'en'
            ? '9:${split[1]} AM'
            : '9:${split[1]} ص ';
        break;
      case 10:
        realTime = translator.currentLanguage == 'en'
            ? '10:${split[1]} AM'
            : '10:${split[1]} ص ';
        break;
      case 11:
        realTime = translator.currentLanguage == 'en'
            ? '11:${split[1]} AM'
            : '11:${split[1]} ص ';
        break;
      case 12:
        realTime = translator.currentLanguage == 'en'
            ? '12:${split[1]} AM'
            : '12:${split[1]} ص ';
        break;
    }
    return realTime;
  }

  String convertTimeTo24Hour({String time}) {
    String realTime = '';
    print('time: $time');

    if (translator.currentLanguage == 'en') {
      if (time.contains('AM')) {
        String splitter = time.replaceAll('AM', '').trim();
        List<String> splitTime = splitter.split(':');
        print('SplitTime: ${splitTime.toString()} ');
        switch (int.parse(splitTime[0])) {
          case 1:
            realTime = '01:${splitTime[1]}';
            break;
          case 2:
            realTime = '02:${splitTime[1]}';
            break;
          case 3:
            realTime = '03:${splitTime[1]}';
            break;
          case 4:
            realTime = '04:${splitTime[1]}';
            break;
          case 5:
            realTime = '05:${splitTime[1]}';
            break;
          case 6:
            realTime = '06:${splitTime[1]}';
            break;
          case 7:
            realTime = '07:${splitTime[1]}';
            break;
          case 8:
            realTime = '08:${splitTime[1]}';
            break;
          case 9:
            realTime = '09:${splitTime[1]}';
            break;
          case 10:
            realTime = '10:${splitTime[1]}';
            break;
          case 11:
            realTime = '11:${splitTime[1]}';
            break;
          case 12:
            realTime = '12:${splitTime[1]}';
            break;
        }
        print('realTime:: $realTime');
      }
      if (time.contains('PM')) {
        String splitter = time.replaceAll('PM', '').trim();
        List<String> splitTime = splitter.split(':');
        print('SplitTime: ${splitTime.toString()} ');
        switch (int.parse(splitTime[0])) {
          case 1:
            realTime = '13:${splitTime[1]}';
            break;
          case 2:
            realTime = '14:${splitTime[1]}';
            break;
          case 3:
            realTime = '15:${splitTime[1]}';
            break;
          case 4:
            realTime = '16:${splitTime[1]}';
            break;
          case 5:
            realTime = '17:${splitTime[1]}';
            break;
          case 6:
            realTime = '18:${splitTime[1]}';
            break;
          case 7:
            realTime = '19:${splitTime[1]}';
            break;
          case 8:
            realTime = '20:${splitTime[1]}';
            break;
          case 9:
            realTime = '21:${splitTime[1]}';
            break;
          case 10:
            realTime = '22:${splitTime[1]}';
            break;
          case 11:
            realTime = '23:${splitTime[1]}';
            break;
          case 12:
            realTime = '00:${splitTime[1]}';
            break;
        }
        print('realTime:: $realTime');
      }
    } else {
      if (time.contains('ص')) {
        String splitter = time.replaceAll('ص', '').trim();
        List<String> splitTime = splitter.split(':');
        print('SplitTime: ${splitTime.toString()} ');
        switch (int.parse(splitTime[0])) {
          case 1:
            realTime = '01:${splitTime[1]}';
            break;
          case 2:
            realTime = '02:${splitTime[1]}';
            break;
          case 3:
            realTime = '03:${splitTime[1]}';
            break;
          case 4:
            realTime = '04:${splitTime[1]}';
            break;
          case 5:
            realTime = '05:${splitTime[1]}';
            break;
          case 6:
            realTime = '06:${splitTime[1]}';
            break;
          case 7:
            realTime = '07:${splitTime[1]}';
            break;
          case 8:
            realTime = '08:${splitTime[1]}';
            break;
          case 9:
            realTime = '09:${splitTime[1]}';
            break;
          case 10:
            realTime = '10:${splitTime[1]}';
            break;
          case 11:
            realTime = '11:${splitTime[1]}';
            break;
          case 12:
            realTime = '12:${splitTime[1]}';
            break;
        }
        print('realTime:: $realTime');
      }
      if (time.contains('م')) {
        String splitter = time.replaceAll('م', '').trim();
        List<String> splitTime = splitter.split(':');
        print('SplitTime: ${splitTime.toString()} ');
        switch (int.parse(splitTime[0])) {
          case 1:
            realTime = '13:${splitTime[1]}';
            break;
          case 2:
            realTime = '14:${splitTime[1]}';
            break;
          case 3:
            realTime = '15:${splitTime[1]}';
            break;
          case 4:
            realTime = '16:${splitTime[1]}';
            break;
          case 5:
            realTime = '17:${splitTime[1]}';
            break;
          case 6:
            realTime = '18:${splitTime[1]}';
            break;
          case 7:
            realTime = '19:${splitTime[1]}';
            break;
          case 8:
            realTime = '20:${splitTime[1]}';
            break;
          case 9:
            realTime = '21:${splitTime[1]}';
            break;
          case 10:
            realTime = '22:${splitTime[1]}';
            break;
          case 11:
            realTime = '23:${splitTime[1]}';
            break;
          case 12:
            realTime = '00:${splitTime[1]}';
            break;
        }
        print('realTime:: $realTime');
      }
    }
    return realTime;
  }

  Future<bool> addPatientRequest(
      {String analysisType,
      String patientName,
  String specialization='',String specializationBranch='',
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
    var docs = await users
        .where('phoneNumber', isEqualTo: patientPhone)
        .getDocuments();
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
    DateTime dateTime = DateTime.now();
    await databaseReference.collection('requests').add({
      'nurseId': '',
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
    'specialization':specialization,
    'specializationBranch':specializationBranch,
      'nurseGender': nurseGender,
      'date': '${dateTime.year}-${dateTime.month}-${dateTime.day}',
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

    if (coupon.docId != '') {
      int x = int.parse(coupon.numberOfUses);
      if (x != 0) {
        x = x - 1;
      }
      _coupons.document(coupon.docId).updateData({
        'numberOfUses': x.toString(),
      });
      if (docs.documents.length != 0) {
        await users
            .document(docs.documents[0].documentID)
            .collection('coupons')
            .document(coupon.docId)
            .setData({'couponName': coupon.couponName});
      }
    }
    return true;
  }

  Future<bool> editProfile(
      {String type,
      String nurseId,
      String address,
      String lat,
      String lng,
      String userName,
      String phone,
      File picture,
      String aboutYou}) async {
    print('iam here');
    print(lat);
    print(lng);
    var nurseData = databaseReference.collection("nurses");
    try {
      if (type == 'image') {
        String imgUrl = '';
        if (picture != null) {
          try {
            var storageReference = FirebaseStorage.instance
                .ref()
                .child('$userName/${path.basename(picture.path)}');
            StorageUploadTask uploadTask = storageReference.putFile(picture);
            await uploadTask.onComplete;
            await storageReference.getDownloadURL().then((fileURL) async {
              imgUrl = fileURL;
            });
          } catch (e) {
            print(e);
          }
        }
        nurseData.document(nurseId).setData({
          'imgUrl': imgUrl,
        }, merge: true);
      }
      if (type == 'Another Info') {
        nurseData
            .document(nurseId)
            .setData({'aboutYou': aboutYou}, merge: true);
      }
      if (type == 'Address') {
        nurseData.document(nurseId).setData(
            {'address': address, 'lat': lat ?? '', 'lng': lng ?? ''},
            merge: true);
      }
      if (type == 'Phone Number') {
        nurseData.document(nurseId).setData({
          'phoneNumber': phone,
        }, merge: true);
      }
      if (type == 'Name') {
        nurseData.document(nurseId).setData({
          'name': userName,
        }, merge: true);
      }
//      DocumentSnapshot doc;
//        doc = await nurseData.document(nurseId).get();
//      UserData _userData = UserData(
//        name: doc.data['name'],
//        docId: doc.documentID,
//        nationalId: doc.data['nationalId'] ?? '',
//        gender: doc.data['gender'] ?? '',
//        birthDate: doc.data['birthDate'] ?? '',
//        address: doc.data['address'] ?? '',
//        phoneNumber: doc.data['phoneNumber'] ?? '',
//        imgUrl: doc.data['imgUrl'] ?? '',
//        email: doc.data['email'] ?? '',
//        lat: doc.data['lat'] ?? '',
//        lng: doc.data['lng'] ?? '',
//        aboutYou: doc.data['aboutYou'] ?? '',
//        points: doc.data['points'] ?? '',
//      );
//     int index= allNurses.indexWhere((x)=>x.docId == nurseId);
//     allNurses.insert(index, _userData);
//      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future getAllAnalysisRequests() async {
    var requests = databaseReference.collection('requests');
    requests
        .where('serviceType', whereIn: ['Analysis', 'تحاليل'])
        .snapshots()
        .listen((docs) {
          print(docs);
          print('csdv xsvxs');
          allAnalysisRequests.clear();
          if (docs.documents.length != 0) {
            String time='';
            String acceptTime='';
            List<String> convertAllVisitsTime=[];
            for (int i = 0; i < docs.documents.length; i++) {
              if(docs.documents[i].data['time'] !=''){
                time=convertTimeToAMOrPM(time: docs.documents[i].data['time']);
              }else{
                time='';
              }
              if(docs.documents[i].data['acceptTime'] !=null&& docs.documents[i].data['acceptTime'] !=''){
                acceptTime=convertTimeToAMOrPM(time: docs.documents[i].data['acceptTime']);
              }else{
                acceptTime='';
              }
              if (docs.documents[i].data['visitTime'] != '[]') {
                var x = docs.documents[i].data['visitTime'].replaceFirst('[', '').toString();
                String visitTime = x.replaceAll(']', '');
                List<String> times=visitTime.split(',');
                if(times.length !=0){
                  for(int i=0; i<times.length; i++){
                    convertAllVisitsTime.add(convertTimeToAMOrPM(time: times[i]));
                  }
                }
              }else{
                convertAllVisitsTime=[];
              }
              allAnalysisRequests.add(Requests(
                  specialization: docs.documents[i].data['specialization'] ?? '',
                  specializationBranch: docs.documents[i].data['specializationBranch'] ?? '',
                  acceptTime: acceptTime,
                  nurseId: docs.documents[i].data['nurseId'] ?? '',
                  patientId: docs.documents[i].data['patientId'] ?? '',
                  docId: docs.documents[i].documentID,
                  visitTime: convertAllVisitsTime.toString() == '[]'
                      ? ''
                      : convertAllVisitsTime.toString(),
                  visitDays: docs.documents[i].data['visitDays'] ?? '',
                  suppliesFromPharmacy:
                      docs.documents[i].data['suppliesFromPharmacy'] ?? '',
                  startVisitDate:
                      docs.documents[i].data['startVisitDate'] ?? '',
                  serviceType: docs.documents[i].data['serviceType'] ?? '',
                  picture: docs.documents[i].data['picture'] ?? '',
                  patientPhone: docs.documents[i].data['patientPhone'] ?? '',
                  patientName: docs.documents[i].data['patientName'] ?? '',
                  patientLocation:
                      docs.documents[i].data['patientLocation'] ?? '',
                  patientGender: docs.documents[i].data['patientGender'] ?? '',
                  time: time,
                  date: docs.documents[i].data['date'] ?? '',
                  discountPercentage:
                      docs.documents[i].data['discountPercentage'] ?? '',
                  patientAge: docs.documents[i].data['patientAge'] ?? '',
                  servicePrice: docs.documents[i].data['servicePrice'] ?? '',
                  nurseGender: docs.documents[i].data['nurseGender'] ?? '',
                  numOfPatients: docs.documents[i].data['numOfPatients'] ?? '',
                  endVisitDate: docs.documents[i].data['endVisitDate'] ?? '',
                  discountCoupon:
                      docs.documents[i].data['discountCoupon'] ?? '',
                  priceBeforeDiscount:
                      docs.documents[i].data['priceBeforeDiscount'] ?? '',
                  analysisType: docs.documents[i].data['analysisType'] ?? '',
                  notes: docs.documents[i].data['notes'] ?? '',
                  priceAfterDiscount:
                      docs.documents[i].data['priceAfterDiscount'].toString() ??
                          ''));
            }
          } else {
            allAnalysisRequests.clear();
          }
          notifyListeners();
        });
  }

  Future<UserData> getUserData({String type, String userId}) async {
    var nursesCollection = databaseReference.collection("nurses");
    var patientCollection = databaseReference.collection("users");
    UserData user;
    if (type == 'Patient' || type == 'مريض') {
      DocumentSnapshot doc = await patientCollection.document(userId).get();
      user = UserData(
        name: doc.data['name'],
        docId: doc.documentID,
        specialization: '',
        specializationBranch: '',
        rating: '0.0',
        nationalId: doc.data['nationalId'] ?? '',
        gender: doc.data['gender'] ?? '',
        birthDate: doc.data['birthDate'] ?? '',
        address: doc.data['address'] ?? '',
        phoneNumber: doc.data['phoneNumber'] ?? '',
        imgUrl: doc.data['imgUrl'] ?? '',
        email: doc.data['email'] ?? '',
        lng: doc.data['lng'] ?? '',
        lat: doc.data['lat'] ?? '',
        aboutYou: doc.data['aboutYou'] ?? '',
        points: doc.data['points'] ?? '',
      );
    } else {
      DocumentSnapshot doc = await nursesCollection.document(userId).get();
      DocumentSnapshot rating = await nursesCollection.document(userId).collection('rating').document('rating').get();
      if(rating.exists) {
        int one = rating.data['1'] == null ? 0 : int.parse(rating.data['1']);
        int two = rating.data['2'] == null ? 0 : int.parse(rating.data['2']);
        int three = rating.data['3'] == null ? 0 : int.parse(rating.data['3']);
        int four = rating.data['4'] == null ? 0 : int.parse(rating.data['4']);
        int five = rating.data['5'] == null ? 0 : int.parse(rating.data['5']);
        totalRatingForNurse =
            (5 * five + 4 * four + 3 * three + 2 * two + 1 * one) /
                (one + two + three + four + five);
      }
      print('evedwgew');
      print(totalRatingForNurse);
      print(doc.data['specializationBranch']);
      print(doc.data['specialization']);
      user = UserData(
        specializationBranch: doc.data['specializationBranch'].toString() ?? '',
        specialization: doc.data['specialization'].toString() ?? '',
        rating: totalRatingForNurse.toString(),
        name: doc.data['name'],
        docId: doc.documentID,
        nationalId: doc.data['nationalId'] ?? '',
        gender: doc.data['gender'] ?? '',
        birthDate: doc.data['birthDate'] ?? '',
        address: doc.data['address'] ?? '',
        phoneNumber: doc.data['phoneNumber'] ?? '',
        imgUrl: doc.data['imgUrl'] ?? '',
        email: doc.data['email'] ?? '',
        lng: doc.data['lng'] ?? '',
        lat: doc.data['lat'] ?? '',
        aboutYou: doc.data['aboutYou'] ?? '',
        points: doc.data['points'] ?? '',
      );
    }
    return user;
  }
  double deg2rad(double deg) {
    return (deg * pi / 180.0);
  }

  double rad2deg(double rad) {
    return (rad * 180.0 / pi);
  }
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    double theta = lon1 - lon2;
    double dist = sin(deg2rad(lat1)) * sin(deg2rad(lat2)) +
        cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * cos(deg2rad(theta));
    dist = acos(dist);
    dist = rad2deg(dist);
    dist = dist * 60 * 1.1515;
    return dist * 1.609344;
  }

  Future getAllPatientsRequests({double lat,double long}) async {
    var requests = databaseReference.collection('requests');
    requests.where('analysisType', isEqualTo: '').snapshots().listen((docs) {
      double distance = 0.0;
      allPatientsRequests.clear();
      if (docs.documents.length != 0) {
        String time='';
        String acceptTime='';
        List<String> convertAllVisitsTime=[];
        for (int i = 0; i < docs.documents.length; i++) {
          print('userlat:$lat');
          print('lat:${docs.documents[i].data['lat']}');
          print('userlng:$long');
          print('lng:${docs.documents[i].data['long']}');
          distance = _calculateDistance(
            lat,
              long,
              double.parse(docs.documents[i].data['lat'] ?? 0.0),
              double.parse(docs.documents[i].data['long'] ?? 0.0));
          print('distance::$distance');
          if (distance <= radiusForAllRequests) {
          if (docs.documents[i].data['time'] != '') {
            time = convertTimeToAMOrPM(time: docs.documents[i].data['time']);
          } else {
            time = '';
          }
          if (docs.documents[i].data['acceptTime'] != null &&
              docs.documents[i].data['acceptTime'] != '') {
            acceptTime =
                convertTimeToAMOrPM(time: docs.documents[i].data['acceptTime']);
          } else {
            acceptTime = '';
          }
          if (docs.documents[i].data['visitTime'] != '[]') {
            var x = docs.documents[i].data['visitTime']
                .replaceFirst('[', '')
                .toString();
            String visitTime = x.replaceAll(']', '');
            List<String> times = visitTime.split(',');
            if (times.length != 0) {
              for (int i = 0; i < times.length; i++) {
                convertAllVisitsTime.add(convertTimeToAMOrPM(time: times[i]));
              }
            }
          } else {
            convertAllVisitsTime = [];
          }
          allPatientsRequests.add(Requests(
              specialization: docs.documents[i].data['specialization'] ?? '',
              specializationBranch: docs.documents[i]
                  .data['specializationBranch'] ?? '',
              acceptTime: acceptTime,
              patientId: docs.documents[i].data['patientId'] ?? '',
              docId: docs.documents[i].documentID,
              visitTime: convertAllVisitsTime.toString() == '[]'
                  ? ''
                  : convertAllVisitsTime.toString(),
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
              time: time,
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
              docs.documents[i].data['priceAfterDiscount'].toString() ??
                  ''));
        }
        }
      } else {
        allPatientsRequests.clear();
      }
      notifyListeners();
    });
  }
}
