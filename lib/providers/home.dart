import 'dart:io';
import 'dart:math';
import 'package:es3fniforadmin/models/analysis.dart';
import 'package:es3fniforadmin/models/price.dart';
import 'package:es3fniforadmin/models/requests.dart';
import 'package:es3fniforadmin/models/supplying.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:path/path.dart' as path;
import 'package:es3fniforadmin/models/coupon.dart';
import 'package:es3fniforadmin/models/http_exception.dart';
import 'package:es3fniforadmin/models/service.dart';
import 'package:es3fniforadmin/models/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home with ChangeNotifier {
  final  FirebaseAuth fireBaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore databaseReference = FirebaseFirestore.instance;


  double totalRatingForNurse = 0.0;
  List<Requests> allArchivedRequests = [];
  List<Service> allService = [];
  List<Analysis> allAnalysis = [];
  List<UserData> patientAccountsThatToVerify=[];
  List<String?> allServicesType =
      translator.activeLanguageCode == "en" ? ['Analysis'] : ['تحاليل'];
  List<String?> allAnalysisType = [];
  List<UserData> allNurses = [];
  List<UserData> allNursesSupplies = [];
  List<Supplying> allSpecificNurseSupplies = [];
  List<Coupon> allCoupons = [];
  List<Requests> allAnalysisRequests = [];
  List<Requests> allPhysicalTherapyRequests = [];
  List<Requests> allHumanMedicineRequests = [];
  List<Requests> allPatientsRequests = [];
  double radiusForAllRequests= 1.0;
  List<bool> refreshWhenChangeFilters=[false,false,false,false];
  Price price = Price(allServiceType: [], servicePrice: 0.0);
  Coupon coupon = Coupon(
      docId: '', couponName: '', discountPercentage: '0.0', numberOfUses: '0');
  double discount = 0.0;
  double priceBeforeDiscount = 0.0;

  addToPrice({String? type, String? serviceType}) {
    if (type == 'analysis') {
      if (!price.allServiceType!.contains(serviceType)) {
        int index =
            allAnalysis.indexWhere((x) => x.analysisName == serviceType);
        List<String?> x = price.allServiceType!;
        x.add(serviceType);
        price = Price(
            servicePrice:
                price.servicePrice + double.parse(allAnalysis[index].price!),
            allServiceType: x);
      }
    } else {
      if (!price.allServiceType!.contains(serviceType)) {
        int index = allService.indexWhere((x) => x.serviceName == serviceType);
        List<String?> x = price.allServiceType!;
        // priceBeforeDiscount =price.servicePrice + double.parse(allService[index].price);
        x.add(serviceType);
        price = Price(
            servicePrice:
                price.servicePrice + double.parse(allService[index].price!),
            allServiceType: x);
      }
    }
    notifyListeners();
  }

  resetPrice() {
    price = Price(allServiceType: [], servicePrice: 0.0);
  }
  changeRadiusForAllRequests(double val){
    print(val);
    radiusForAllRequests = val;
    notifyListeners();
  }
  removeFromPrice({String? type, String? serviceType}) {
    if (type == 'analysis') {
      if (!price.allServiceType!.contains(serviceType)) {
        int index =
            allAnalysis.indexWhere((x) => x.analysisName == serviceType);
        List<String?> x = price.allServiceType!;
        x.add(serviceType);
        price = Price(
            servicePrice:
                price.servicePrice + double.parse(allAnalysis[index].price!),
            allServiceType: x);
      }
    } else {
      if (!price.allServiceType!.contains(serviceType)) {
        int index = allService.indexWhere((x) => x.serviceName == serviceType);
        List<String?> x = price.allServiceType!;
        x.add(serviceType);
        price = Price(
            servicePrice:
                price.servicePrice + double.parse(allService[index].price!),
            allServiceType: x);
      }
    }
    notifyListeners();
  }

  Future<bool> createAccountForNurse(
      {String? name, required String email, required String password, String? nationalId,String specialization='',String? specializationBranch=''}) async {
    UserCredential auth;
    try {
      auth = await fireBaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (auth.user != null) {
        var users = databaseReference.collection("nurses");
        DocumentSnapshot doc = await users.doc(auth.user!.uid).get();
        if (!doc.exists) {
          await users.doc(auth.user!.uid).set({
            'nationalId': nationalId,
            'password': password,
            'email': email,
            'name': name,
            'specialization':specialization,
            'specializationBranch':specializationBranch
            ,'points': '0'
          }, SetOptions(merge: true));
        }
        await getAllParamedics();
      }
      print(auth.user);
      return true;
    } catch (e) {
      print(e);
      throw HttpException(e.toString());
    }
  }
  isDocContains({required document,required String key}){
    if(document.data().toString().contains(key)){
      return document.get(key);
    }else {
      return null;
    }
  }
  Future getAllParamedics() async {
    CollectionReference nursesCollection = databaseReference.collection("nurses");
    double ratingForNurse =0.0;
    databaseReference.collection("nurses").snapshots().listen((docs) async{
      if (docs.docs.isNotEmpty) {
        allNurses.clear();

        for (int i = 0; i < docs.docs.length; i++) {
          print('scv');

          DocumentSnapshot rating = await nursesCollection.doc(
              docs.docs[i].id).collection('rating').doc(
              'rating').get();

          if (rating.exists== true) {
            int one = rating.get('1') == null ? 0 : int.parse(
                rating.get('1'));
            int two = rating.get('2') == null ? 0 : int.parse(
                rating.get('2'));
            int three = rating.get('3') == null ? 0 : int.parse(
                rating.get('3'));
            int four = rating.get('4') == null ? 0 : int.parse(
                rating.get('4'));
            int five = rating.get('5') == null ? 0 : int.parse(
                rating.get('5'));
            ratingForNurse =
                (5 * five + 4 * four + 3 * three + 2 * two + 1 * one) /
                    (one + two + three + four + five);
          }else{
            ratingForNurse=0.0;
          }

          allNurses.add(UserData(
              specializationBranch:
              isDocContains(document: docs.docs[i],key:'specializationBranch' )?? '',
              specialization: isDocContains(document: docs.docs[i],key:'specialization' )?? '',
              rating: ratingForNurse.toString(),
              isActive: isDocContains(document: docs.docs[i],key:'isActive' ) ?? false,
              lat: isDocContains(document: docs.docs[i],key:'lat' )?? '',
              lng: isDocContains(document: docs.docs[i],key:'lng' )?? '',
              aboutYou: isDocContains(document: docs.docs[i],key:'aboutYou' ) ?? '',
              docId: docs.docs[i].id,
              email: isDocContains(document: docs.docs[i],key:'email') ?? '',
              password: isDocContains(document: docs.docs[i],key:'password') ?? '',
              points: isDocContains(document: docs.docs[i],key:'points') ?? '0',
              name: isDocContains(document: docs.docs[i],key:'name') ?? '',
              phoneNumber: isDocContains(document: docs.docs[i],key:'phoneNumber') ?? '',
              imgUrl: isDocContains(document: docs.docs[i],key:'imgUrl') ?? '',
              address: isDocContains(document: docs.docs[i],key:'address') ?? '',
              birthDate: isDocContains(document: docs.docs[i],key:'birthDate') ?? '',
              gender: isDocContains(document: docs.docs[i],key:'gender') ?? '',
              nationalId: isDocContains(document: docs.docs[i],key:'nationalId') ?? ''));
        }
      }
        else{
        allNurses.clear();
      }
        notifyListeners();
    });
  }

  Future getAllNursesSupplies() async {
    CollectionReference nursesCollection = databaseReference.collection("nurses");
    double ratingForNurse =0.0;
    databaseReference.collection("nurses").snapshots().listen((docs)async{
      if (docs.docs.length != 0) {
        allNursesSupplies.clear();
        for (int i = 0; i < docs.docs.length; i++) {
          DocumentSnapshot rating = await nursesCollection.doc(docs.docs[i].id).collection('rating').doc('rating').get();
           if(rating.exists) {
             int one = rating.get('1') == null ? 0 : int.parse(rating.get('1'));
             int two = rating.get('2')== null ? 0 : int.parse(rating.get('2'));
             int three = rating.get('3') == null ? 0 : int.parse(rating.get('3'));
             int four = rating.get('4') == null ? 0 : int.parse(rating.get('4'));
             int five = rating.get('5') == null ? 0 : int.parse(rating.get('5'));
             ratingForNurse =
                 (5 * five + 4 * four + 3 * three + 2 * two + 1 * one) /
                     (one + two + three + four + five);
           }else{
              ratingForNurse =0.0;
           }
           allNursesSupplies.add(UserData(
               specializationBranch:isDocContains(document: docs.docs[i],key:'specializationBranch')?? '',
               specialization: isDocContains(document: docs.docs[i],key:'specialization') ?? '',
               rating: ratingForNurse.toString(),
               isActive: isDocContains(document: docs.docs[i],key:'isActive') ?? false,
               lat: isDocContains(document: docs.docs[i],key:'lat') ?? '',
               lng: isDocContains(document: docs.docs[i],key:'lng') ?? '',
               aboutYou: isDocContains(document: docs.docs[i],key:'aboutYou') ?? '',
               docId: docs.docs[i].id,
               email: isDocContains(document: docs.docs[i],key:'email') ?? '',
               password: isDocContains(document: docs.docs[i],key:'password') ?? '',
               points: isDocContains(document: docs.docs[i],key:'points') ?? '0',
               name: isDocContains(document: docs.docs[i],key:'name') ?? '',
               phoneNumber: isDocContains(document: docs.docs[i],key:'phoneNumber') ?? '',
               imgUrl: isDocContains(document: docs.docs[i],key:'imgUrl') ?? '',
               address: isDocContains(document: docs.docs[i],key:'address') ?? '',
               birthDate: isDocContains(document: docs.docs[i],key:'birthDate') ?? '',
               gender: isDocContains(document: docs.docs[i],key:'gender') ?? '',
               nationalId: isDocContains(document: docs.docs[i],key:'nationalId') ?? ''));
        }
      }
      notifyListeners();
    });
  }

  Future getSpecificNurseSupplies({String? nurseId}) async {
    var nurses = databaseReference.collection("nurses");
    var docs = await nurses.doc(nurseId).collection('supplying').get();
    String time='';
    if (docs.docs.isNotEmpty) {
      allSpecificNurseSupplies.clear();
      for (int i = 0; i < docs.docs.length; i++) {
        if(isDocContains(document: docs.docs[i],key:'time') !=null&&isDocContains(document: docs.docs[i],key:'time') !=''){
          time=convertTimeToAMOrPM(time: isDocContains(document: docs.docs[i],key:'time'));
        }else{
          time='';
        }
        allSpecificNurseSupplies.add(Supplying(
            points: isDocContains(document: docs.docs[i],key:'points') ?? '0',
            date: isDocContains(document: docs.docs[i],key:'date') ?? '',
            time: time ));
      }
    }else{
      allSpecificNurseSupplies.clear();
    }
    print(allSpecificNurseSupplies.length);
    notifyListeners();
  }

  Future nurseSupplying({String? nurseId,String? adminId,required String points}) async {
    DateTime dateTime = DateTime.now();
    var admin = databaseReference.collection("admins");
    CollectionReference nurses = databaseReference.collection("nurses");
    DocumentSnapshot getPoints=await nurses
        .doc(nurseId).get();
    await nurses.doc(nurseId).collection('supplying').add({
      'points': getPoints.get('points'),
      'date': '${dateTime.year}-${dateTime.month}-${dateTime.day}',
      'time': '${dateTime.hour}:${dateTime.minute}',
    });
    int allPoints = int.parse(points) + int.parse(getPoints.get('points'));
    await admin.doc(adminId).update({
      'points': allPoints.toString()
    });
    await nurses
        .doc(nurseId).update({
      'points':'0'
    });
    return true;
  }

  Future getAllArchivedRequests({String userLat='0.0',String userLong='0.0'}) async {
    String time='';
    String acceptTime='';
    double distance = 0.0;
    List<String> convertAllVisitsTime=[];
    CollectionReference requests = databaseReference.collection('archived requests');
    CollectionReference archivedForPatients = databaseReference.collection('archivedForPatients');
    CollectionReference patientCollection = databaseReference.collection("users");
    QuerySnapshot docsForArchivedRequestsForNoAccount = await requests.get();
    QuerySnapshot docsForArchivedForPatients = await archivedForPatients.get();
    allArchivedRequests.clear();
    print('A');
    if (docsForArchivedRequestsForNoAccount.docs.isNotEmpty) {
      print('B');

      for (int i = 0; i < docsForArchivedRequestsForNoAccount.docs.length; i++) {
        distance = _calculateDistance(
            userLat != '0.0'? double.parse(userLat):0.0,
            userLong != '0.0'? double.parse(userLong):0.0,
            double.parse(docsForArchivedRequestsForNoAccount.docs[i].get('lat')??'0.0'),
            double.parse(docsForArchivedRequestsForNoAccount.docs[i].get('long')??'0.0'));
        if(docsForArchivedRequestsForNoAccount.docs[i].get('time') !=''){
          time=convertTimeToAMOrPM(time: docsForArchivedRequestsForNoAccount.docs[i].get('time'));
        }else{
          time='';
        }
        if(docsForArchivedRequestsForNoAccount.docs[i].get('acceptTime') !=null && docsForArchivedRequestsForNoAccount.docs[i].get('acceptTime') !=''){
          acceptTime=convertTimeToAMOrPM(time: docsForArchivedRequestsForNoAccount.docs[i].get('acceptTime'));
        }else{
          acceptTime='';
        }
        if (docsForArchivedRequestsForNoAccount.docs[i].get('visitTime') != '[]') {
          var x = docsForArchivedRequestsForNoAccount.docs[i].get('visitTime').replaceFirst('[', '').toString();
          String visitTime = x.replaceAll(')', '');
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
specialization: docsForArchivedRequestsForNoAccount.docs[i].get('specialization') ?? '',
            specializationBranch: docsForArchivedRequestsForNoAccount.docs[i].get('specializationBranch') ?? '',
            acceptTime: acceptTime,
distance:  distance.floor().toString(),
lat:  docsForArchivedRequestsForNoAccount.docs[i].get('lat') ?? '',
long:  docsForArchivedRequestsForNoAccount.docs[i].get('long') ?? '',
            nurseId: docsForArchivedRequestsForNoAccount.docs[i].get('nurseId') ?? '',
            patientId: docsForArchivedRequestsForNoAccount.docs[i].get('patientId') ?? '',
            docId: docsForArchivedRequestsForNoAccount.docs[i].id,
            visitTime: convertAllVisitsTime.toString() == '[]'
                ? ''
                : convertAllVisitsTime.toString(),

            visitDays: docsForArchivedRequestsForNoAccount.docs[i].get('visitDays') == '[]'
                ? ''
                : docsForArchivedRequestsForNoAccount.docs[i].get('visitDays') ?? '',
            suppliesFromPharmacy:
                docsForArchivedRequestsForNoAccount.docs[i].get('suppliesFromPharmacy') ?? '',
            startVisitDate: docsForArchivedRequestsForNoAccount.docs[i].get('startVisitDate') ?? '',
            serviceType: docsForArchivedRequestsForNoAccount.docs[i].get('serviceType') ?? '',
            picture: docsForArchivedRequestsForNoAccount.docs[i].get('picture') ?? '',
            patientPhone: docsForArchivedRequestsForNoAccount.docs[i].get('patientPhone') ?? '',
            patientName: docsForArchivedRequestsForNoAccount.docs[i].get('patientName') ?? '',
            patientLocation: docsForArchivedRequestsForNoAccount.docs[i].get('patientLocation') ?? '',
            patientGender: docsForArchivedRequestsForNoAccount.docs[i].get('patientGender') ?? '',
            patientAge: docsForArchivedRequestsForNoAccount.docs[i].get('patientAge') ?? '',
            servicePrice: docsForArchivedRequestsForNoAccount.docs[i].get('servicePrice') ?? '',
            time: time,

            date: docsForArchivedRequestsForNoAccount.docs[i].get('date') ?? '',
            discountPercentage:
                docsForArchivedRequestsForNoAccount.docs[i].get('discountPercentage') ?? '',
            nurseGender: docsForArchivedRequestsForNoAccount.docs[i].get('nurseGender') ?? '',
            numOfPatients: docsForArchivedRequestsForNoAccount.docs[i].get('numOfPatients') ?? '',
            endVisitDate: docsForArchivedRequestsForNoAccount.docs[i].get('endVisitDate') ?? '',
            discountCoupon: docsForArchivedRequestsForNoAccount.docs[i].get('discountCoupon') ?? '',
            priceBeforeDiscount:
                docsForArchivedRequestsForNoAccount.docs[i].get('priceBeforeDiscount') ?? '',
            analysisType: docsForArchivedRequestsForNoAccount.docs[i].get('analysisType') ?? '',
            notes: docsForArchivedRequestsForNoAccount.docs[i].get('notes') ?? '',
            priceAfterDiscount:
                docsForArchivedRequestsForNoAccount.docs[i].get('priceAfterDiscount').toString()));
      }
      print('dfbfdsndd');
      print(allArchivedRequests.length);

    }
    if (docsForArchivedForPatients.docs.length != 0) {
     time='';
     acceptTime='';
     convertAllVisitsTime=[];

      for (int i = 0; i < docsForArchivedForPatients.docs.length; i++) {
        DocumentSnapshot doc = await patientCollection.doc(
            docsForArchivedForPatients.docs[i].get('patientId'))
            .collection('archived requests').doc(
            docsForArchivedForPatients.docs[i].id)
            .get();
        print('rrrrrrrrrrrrrrrrrrrrrr');
        print(doc.id);
          if(doc.exists){
            distance = _calculateDistance(
                userLat != '0.0'? double.parse(userLat):0.0,
                userLong != '0.0'? double.parse(userLong):0.0,
                double.parse(doc.get('lat')??'0.0'),
                double.parse(doc.get('long')??'0.0'));
            print('dis');
            print(distance);
        if (doc.get('time') !=
            '') {
          time = convertTimeToAMOrPM(
              time: doc.get('time'));
        } else {
          time = '';
        }
        if (doc.get('acceptTime') != null && doc.get('acceptTime') !='') {
          print('doc.data acceptTime');
          print(doc.get('acceptTime'));
          acceptTime = convertTimeToAMOrPM(
              time: doc.get('acceptTime'));
        } else {
          acceptTime = '';
        }
        if (doc.get('visitTime') != '[]') {
          var x = doc.get('visitTime').replaceFirst('[', '').toString();
          String visitTime = x.replaceAll(')', '');
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
            specialization: doc.get('specialization') ?? '',
            specializationBranch: doc.get('specializationBranch') ?? '',
            acceptTime: acceptTime,
            nurseId: doc.get('nurseId') ?? '',
            patientId: doc .get('patientId') ?? '',
            docId:doc.id,
            distance:  distance.floor().toString(),
            lat:  doc.get('lat') ?? '',
            long:  doc.get('long') ?? '',
            visitTime: convertAllVisitsTime.toString() == '[]'
                ? ''
                : convertAllVisitsTime.toString(),

            visitDays:doc.get('visitDays') == '[]'
                ? ''
                :doc.get('visitDays') ?? '',
            suppliesFromPharmacy:
            doc.get('suppliesFromPharmacy') ?? '',
            startVisitDate:doc.get('startVisitDate') ?? '',
            serviceType:doc.get('serviceType') ?? '',
            picture: doc.get('picture') ?? '',
            patientPhone: doc.get('patientPhone') ?? '',
            patientName:doc.get('patientName') ?? '',
            patientLocation:doc.get('patientLocation') ?? '',
            patientGender:doc.get('patientGender') ?? '',
            patientAge: doc.get('patientAge') ?? '',
            servicePrice: doc.get('servicePrice') ?? '',
            time: time,
            date: doc.get('date') ?? '',
            discountPercentage:
            doc.get('discountPercentage') ?? '',
            nurseGender: doc.get('nurseGender') ?? '',
            numOfPatients: doc.get('numOfPatients') ?? '',
            endVisitDate: doc.get('endVisitDate') ?? '',
            discountCoupon: doc.get('discountCoupon') ?? '',
            priceBeforeDiscount:
            doc.get('priceBeforeDiscount') ?? '',
            analysisType:doc.get('analysisType') ?? '',
            notes: doc.get('notes') ?? '',
            priceAfterDiscount:
            doc.get('priceAfterDiscount').toString()));
      }
        }
        print('dfbfdsndd');
        print(allArchivedRequests.length);

    }

    notifyListeners();
  }

  Future<bool> deleteParamedic({required UserData userData}) async {
    String userId;
    if (userData.email != null && userData.password != null) {
      try {
        UserCredential auth = await fireBaseAuth.signInWithEmailAndPassword(
          email: userData.email!,
          password: userData.password!,
        );
        if (auth != null) {
          userId = auth.user!.uid;
          await auth.user!.delete();
          var nurses = databaseReference.collection("nurses");
          await nurses.doc(userId).delete();
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

  Future<String> addServices({String? serviceName, String? price}) async {
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
      await services.doc().set({
        'serviceName': serviceName,
        'price': price,
      }, SetOptions(merge: true));
      await getAllServices();
      isValid = 'scuess';
    }
    return isValid;
  }

  Future getAllServices() async {
    var services = databaseReference.collection("services");
    var docs = await services.get();
    allService.clear();
    allServicesType =
        translator.activeLanguageCode == "en" ? ['Analysis'] : ['تحاليل'];
    if (docs.docs.length != 0) {
      for (int i = 0; i < docs.docs.length; i++) {
        allService.add(Service(
          id: docs.docs[i].id,
          price: docs.docs[i].get('price'),
          serviceName: docs.docs[i].get('serviceName'),
        ));
        allServicesType.add(docs.docs[i].get('serviceName'));
      }
    }
    notifyListeners();
  }

  Future<bool> deleteService({String? serviceId}) async {
    var services = databaseReference.collection("services");
    await services.doc(serviceId).delete();
    allService.removeWhere((x) => x.id == serviceId);
    notifyListeners();
    return true;
  }

  Future<String> addAnalysis({String? analysisName, String? price}) async {
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
      await analysis.doc().set({
        'analysisName': analysisName,
        'price': price,
      }, SetOptions(merge: true));
      await getAllAnalysis();
      isValid = 'scuess';
    }
    return isValid;
  }

  Future getAllAnalysis() async {
    var analysis = databaseReference.collection("analysis");
    var docs = await analysis.get();
    if (docs.docs.length != 0) {
      allAnalysis.clear();
      allAnalysisType.clear();
      for (int i = 0; i < docs.docs.length; i++) {
        allAnalysis.add(Analysis(
          id: docs.docs[i].id,
          price: docs.docs[i].get('price'),
          analysisName: docs.docs[i].get('analysisName'),
        ));
        allAnalysisType.add(docs.docs[i].get('analysisName'));
      }
    }
    notifyListeners();
  }

  Future<bool> deleteAnalysis({String? analysisId}) async {
    var services = databaseReference.collection("analysis");
    await services.doc(analysisId).delete();
    allAnalysis.removeWhere((x) => x.id == analysisId);
    notifyListeners();
    return true;
  }

  Future<String> verifyCoupon({String? phoneNumber='',String? couponName}) async {
    CollectionReference services = databaseReference.collection("coupons");
    CollectionReference users = databaseReference.collection("users");
    String _return='';
    if(phoneNumber==''){
      _return= 'add Phone';
    }else{
      QuerySnapshot isHaveAccount=await users
          .where('phoneNumber', isEqualTo: phoneNumber).get();
      if(isHaveAccount.docs.length != 0){
        QuerySnapshot isUsedBefore=await users
            .doc(isHaveAccount.docs[0].id)
            .collection('coupons').where('couponName', isEqualTo: couponName).get();
        if(isUsedBefore.docs.length != 0){
          _return= 'isUserBefore';
        }
      }else{
        QuerySnapshot docs = await services
            .where('couponName', isEqualTo: couponName)
            .get();
        if (docs.docs.length == 0) {
          _return= 'false';
        } else {
          List<String> date =
          docs.docs[0].get('expiryDate').toString().split('-');
          print(date);
          DateTime time =
          DateTime(int.parse(date[0]), int.parse(date[1]), int.parse(date[2]));
          if (price.isAddingDiscount == false &&
              price.servicePrice != 0.0 &&
              docs.docs[0].get('numberOfUses').toString() != '0' &&
              time.isAfter(DateTime.now())) {
            coupon = Coupon(
              docId: docs.docs[0].id,
              couponName: docs.docs[0].get('couponName'),
              discountPercentage: docs.docs[0].get('discountPercentage'),
              expiryDate: docs.docs[0].get('expiryDate'),
              numberOfUses: docs.docs[0].get('numberOfUses').toString(),
            );
            double prices = price.servicePrice;
            priceBeforeDiscount = price.servicePrice;
            discount = prices * (double.parse(coupon.discountPercentage!) / 100);
            List<String?>? x = price.allServiceType;
            price = Price(
                servicePrice: (prices - discount),
                isAddingDiscount: true,
                allServiceType: x);
            notifyListeners();
            _return= 'true';
          } else if (price.servicePrice == 0.0) {
            return 'add service before discount';
          } else if (!time.isAfter(DateTime.now()) ||
              docs.docs[0].get('numberOfUses') == '0') {
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
    List<String?>? x = price.allServiceType;
    price = Price(
        servicePrice: (prices + discount),
        isAddingDiscount: false,
        allServiceType: x);
    notifyListeners();
  }

  Future<String> addCoupon(
      {String? couponName,
      String? discountPercentage,
      String? numberOfUses,
      String? expiryDate}) async {
    var coupon = databaseReference.collection("coupons");
    String isValid = 'yes';
//    var docs = await services.get();
//
    if (allCoupons.length != 0) {
      for (int i = 0; i < allCoupons.length; i++) {
        if (allCoupons[i].couponName == couponName) {
          isValid = 'not valid';
        }
      }
    }

    if (isValid == 'yes') {
      await coupon.doc().set({
        'couponName': couponName,
        'discountPercentage': discountPercentage,
        'numberOfUses': numberOfUses,
        'expiryDate': expiryDate
      }, SetOptions(merge: true));
      await getAllCoupons();
      isValid = 'scuess';
    }
    return isValid;
  }

  Future<bool> deleteCoupon({String? couponId}) async {
    var coupons = databaseReference.collection("coupons");
    await coupons.doc(couponId).delete();
    allCoupons.removeWhere((x) => x.docId == couponId);
    notifyListeners();
    return true;
  }

  Future getAllCoupons() async {
    var coupons = databaseReference.collection("coupons");
    var docs = await coupons.get();
    if (docs.docs.length != 0) {
      allCoupons.clear();
      for (int i = 0; i < docs.docs.length; i++) {
        allCoupons.add(Coupon(
          docId: docs.docs[i].id,
          couponName: docs.docs[i].get('couponName'),
          discountPercentage: docs.docs[i].get('discountPercentage'),
          expiryDate: docs.docs[i].get('expiryDate'),
          numberOfUses: docs.docs[i].get('numberOfUses').toString(),
        ));
      }
    }
    notifyListeners();
  }

  String convertTimeToAMOrPM({required String time}) {
    List<String> split = time.split(':');
    int clock = int.parse(split[0]);
    String realTime = '';
    print('clock: $clock');
    switch (clock) {
      case 13:
        realTime = translator.activeLanguageCode == 'en'
            ? '1:${split[1]} PM'
            : '1:${split[1]} م ';
        break;
      case 14:
        realTime = translator.activeLanguageCode == 'en'
            ? '2:${split[1]} PM'
            : '2:${split[1]} م ';
        break;
      case 15:
        realTime = translator.activeLanguageCode == 'en'
            ? '3:${split[1]} PM'
            : '3:${split[1]} م ';
        break;
      case 16:
        realTime = translator.activeLanguageCode == 'en'
            ? '4:${split[1]} PM'
            : '4:${split[1]} م ';
        break;
      case 17:
        realTime = translator.activeLanguageCode == 'en'
            ? '5:${split[1]} PM'
            : '5:${split[1]} م ';
        break;
      case 18:
        realTime = translator.activeLanguageCode == 'en'
            ? '6:${split[1]} PM'
            : '6:${split[1]} م ';
        break;
      case 19:
        realTime = translator.activeLanguageCode == 'en'
            ? '7:${split[1]} PM'
            : '7:${split[1]} م ';
        break;
      case 20:
        realTime = translator.activeLanguageCode == 'en'
            ? '8:${split[1]} PM'
            : '8:${split[1]} م ';
        break;
      case 21:
        realTime = translator.activeLanguageCode == 'en'
            ? '9:${split[1]} PM'
            : '9:${split[1]} م ';
        break;
      case 22:
        realTime = translator.activeLanguageCode == 'en'
            ? '10:${split[1]} PM'
            : '10:${split[1]} م ';
        break;
      case 23:
        realTime = translator.activeLanguageCode == 'en'
            ? '11:${split[1]} PM'
            : '11:${split[1]} م ';
        break;
      case 00:
      case 0:
        realTime = translator.activeLanguageCode == 'en'
            ? '12:${split[1]} PM'
            : '12:${split[1]} م ';
        break;
      case 01:
        realTime = translator.activeLanguageCode == 'en'
            ? '1:${split[1]} AM'
            : '1:${split[1]} ص ';
        break;
      case 02:
        realTime = translator.activeLanguageCode == 'en'
            ? '2:${split[1]} AM'
            : '2:${split[1]} ص ';
        break;
      case 03:
        realTime = translator.activeLanguageCode == 'en'
            ? '3:${split[1]} AM'
            : '3:${split[1]} ص ';
        break;
      case 04:
        realTime = translator.activeLanguageCode == 'en'
            ? '4:${split[1]} AM'
            : '4:${split[1]} ص ';
        break;
      case 05:
        realTime = translator.activeLanguageCode == 'en'
            ? '5:${split[1]} AM'
            : '5:${split[1]} ص ';
        break;
      case 06:
        realTime = translator.activeLanguageCode == 'en'
            ? '6:${split[1]} AM'
            : '6:${split[1]} ص ';
        break;
      case 07:
        realTime = translator.activeLanguageCode == 'en'
            ? '7:${split[1]} AM'
            : '7:${split[1]} ص ';
        break;
      case 08:
        realTime = translator.activeLanguageCode == 'en'
            ? '8:${split[1]} AM'
            : '8:${split[1]} ص ';
        break;
      case 09:
        realTime = translator.activeLanguageCode == 'en'
            ? '9:${split[1]} AM'
            : '9:${split[1]} ص ';
        break;
      case 10:
        realTime = translator.activeLanguageCode == 'en'
            ? '10:${split[1]} AM'
            : '10:${split[1]} ص ';
        break;
      case 11:
        realTime = translator.activeLanguageCode == 'en'
            ? '11:${split[1]} AM'
            : '11:${split[1]} ص ';
        break;
      case 12:
        realTime = translator.activeLanguageCode == 'en'
            ? '12:${split[1]} AM'
            : '12:${split[1]} ص ';
        break;
    }
    return realTime;
  }

  String convertTimeTo24Hour({String? time}) {
    String realTime = '';
    print('time: $time');

    if (translator.activeLanguageCode == 'en') {
      if (time!.contains('AM')) {
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
      if (time!.contains('ص')) {
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
      {String? analysisType,
      String? patientName,
  String specialization='',String? specializationBranch='',
      String? patientPhone,
      String? patientLocation,
      String? patientAge,
      String? patientGender,
      String? numOfPatients,
      String? serviceType,
      String? lat,
      String? long,
      String? nurseGender,
      String? suppliesFromPharmacy,
      File? picture,
      String? discountCoupon,
      String? startVisitDate,
      String? endVisitDate,
      String? visitDays,
      String? visitTime,
      String? notes}) async {
    String imgUrl = '';
    var users = databaseReference.collection("users");
    var _coupons = databaseReference.collection("coupons");
    print('patientPhone');
    print(patientPhone);
    var docs = await users
        .where('phoneNumber', isEqualTo: patientPhone)
        .get();
    print(docs.docs);
    if (picture != null) {
      try {

        var storageReference = FirebaseStorage.instance.ref().child(
            '$serviceType/$patientName/$patientPhone/${path.basename(picture.path)}');
        UploadTask uploadTask = storageReference.putFile(picture);
         uploadTask.then((p){
            storageReference.getDownloadURL().then((fileURL) async {
             imgUrl = fileURL;
           });
        });
      } catch (e) {
        print(e);
      }
    }
   // print('docs.docs[0].id');
  //  print(docs.docs[0].id);
    DateTime dateTime = DateTime.now();
    await databaseReference.collection('requests').add({
      'nurseId': '',
      'patientId':
          docs.docs.length != 0 ? docs.docs[0].id : '',
      'patientName': patientName,
      'patientPhone': patientPhone,
      'patientLocation': patientLocation,
      'patientAge': patientAge,
      'patientGender': patientGender,
      'numOfPatients': numOfPatients,
      'serviceType': serviceType,
      'analysisType': analysisType,
      'specialization':specialization,
      'lat':lat,
      'long' : long,
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
      int x = int.parse(coupon.numberOfUses!);
      if (x != 0) {
        x = x - 1;
      }
      _coupons.doc(coupon.docId).update({
        'numberOfUses': x.toString(),
      });
      if (docs.docs.length != 0) {
        await users
            .doc(docs.docs[0].id)
            .collection('coupons')
            .doc(coupon.docId)
            .set({'couponName': coupon.couponName});
      }
    }
    return true;
  }

  Future<bool> editProfile(
      {String? type,
      String? nurseId,
      String? address,
      String? lat,
      String? lng,
      String? userName,
      String? phone,
      File? picture,
      String? aboutYou}) async {
    print('iam here');
    print(lat);
    print(lng);
    var nurseData = databaseReference.collection("nurses");
    try {
      if (type == 'image') {
        String imgUrl = '';
        if (picture != null) {
          try {
          FirebaseStorage firebaseStorage = FirebaseStorage.instance;
          Reference storageReference =
            firebaseStorage.ref()
                .child('$userName/${path.basename(picture.path)}');
            UploadTask uploadTask = storageReference.putFile(picture);
            TaskSnapshot uploadState = await uploadTask;
          if(uploadState.state == TaskState.success){
             imgUrl = await uploadState.ref.getDownloadURL();
          }
          } catch (e) {
            print(e);
          }
        }
        nurseData.doc(nurseId).set({
          'imgUrl': imgUrl,
        }, SetOptions(merge: true));
      }
      if (type == 'Another Info') {
        nurseData
            .doc(nurseId)
            .set({'aboutYou': aboutYou}, SetOptions(merge: true));
      }
      if (type == 'Address') {
        nurseData.doc(nurseId).set(
            {'address': address, 'lat': lat ?? '', 'lng': lng ?? ''},
            SetOptions(merge: true));
      }
      if (type == 'Phone Number') {
        nurseData.doc(nurseId).set({
          'phoneNumber': phone,
        }, SetOptions(merge: true));
      }
      if (type == 'Name') {
        nurseData.doc(nurseId).set({
          'name': userName,
        }, SetOptions(merge: true));
      }
//      DocumentSnapshot doc;
//        doc = await nurseData.doc(nurseId).get();
//      UserData _userData = UserData(
//        name: doc.get('name'),
//        docId: doc.id,
//        nationalId: doc.get('nationalId') ?? '',
//        gender: doc.get('gender') ?? '',
//        birthDate: doc.get('birthDate') ?? '',
//        address: doc.get('address') ?? '',
//        phoneNumber: doc.get('phoneNumber') ?? '',
//        imgUrl: doc.get('imgUrl') ?? '',
//        email: doc.get('email') ?? '',
//        lat: doc.get('lat') ?? '',
//        lng: doc.get('lng') ?? '',
//        aboutYou: doc.get('aboutYou') ?? '',
//        points: doc.get('points') ?? '',
//      );
//     int index= allNurses.indexWhere((uploadState)=>uploadState.docId == nurseId);
//     allNurses.insert(index, _userData);
//      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> getAllAnalysisRequests({String userLat='0.0',String userLong='0.0'}) async {
    var requests = databaseReference.collection('requests');
    double distance = 0.0;
    requests
        .where('serviceType', whereIn: ['Analysis', 'تحاليل'])
        .snapshots()
        .listen((docs) {
          print(docs);
          print('csdv xsvxs');
          distance=0.0;
          allAnalysisRequests.clear();
          if (docs.docs.length != 0) {
            String time='';
            String acceptTime='';
            List<String> convertAllVisitsTime=[];
            for (int i = 0; i < docs.docs.length; i++) {
              print('nnnnn');
              distance = _calculateDistance(
                  userLat != '0.0'? double.parse(userLat):0.0,
                  userLong != '0.0'? double.parse(userLong):0.0,
                  double.parse(isDocContains(document: docs.docs[i],key:'lat')??'0.0'),
                  double.parse(isDocContains(document: docs.docs[i],key:'long')??'0.0'));
              print(userLat);
              print(userLong);
              print(isDocContains(document: docs.docs[i],key:'lat'));
              print(distance);
              print(radiusForAllRequests);
              if (distance <= radiusForAllRequests) {
                print('yyyy');
              if(isDocContains(document: docs.docs[i],key:'time') !=''){
                time=convertTimeToAMOrPM(time: isDocContains(document: docs.docs[i],key:'time'));
              }else{
                time='';
              }
              if(isDocContains(document: docs.docs[i],key:'acceptTime') !=null&& isDocContains(document: docs.docs[i],key:'acceptTime') !=''){
                acceptTime=convertTimeToAMOrPM(time: isDocContains(document: docs.docs[i],key:'acceptTime'));
              }else{
                acceptTime='';
              }
              if (isDocContains(document: docs.docs[i],key:'visitTime') != '[]') {
                print('ttttttttttyyyy');
                var x = isDocContains(document: docs.docs[i],key:'visitTime').replaceFirst('[', '').toString();
                String visitTime = x.replaceAll(')', '');
                List<String> times=visitTime.split(',');
                if(times.length !=0){
                  for(int i=0; i<times.length; i++){
                    convertAllVisitsTime.add(convertTimeToAMOrPM(time: times[i]));
                  }
                }
              }else{
                convertAllVisitsTime=[];
              }
              print('tttttttttt');
              allAnalysisRequests.add(Requests(
                  specialization: isDocContains(document: docs.docs[i],key:'specialization') ?? '',
                  specializationBranch: isDocContains(document: docs.docs[i],key:'specializationBranch') ?? '',
                  acceptTime: acceptTime,
                  nurseId: isDocContains(document: docs.docs[i],key:'nurseId') ?? '',
                  distance:  distance.floor().toString(),
                  lat:  isDocContains(document: docs.docs[i],key:'lat') ?? '',
                  long:  isDocContains(document: docs.docs[i],key:'long') ?? '',
                  patientId: isDocContains(document: docs.docs[i],key:'patientId') ?? '',
                  docId: docs.docs[i].id,
                  visitTime: convertAllVisitsTime.toString() == '[]'
                      ? ''
                      : convertAllVisitsTime.toString(),
                  visitDays: isDocContains(document: docs.docs[i],key:'visitDays') ?? '',
                  suppliesFromPharmacy:
                      isDocContains(document: docs.docs[i],key:'suppliesFromPharmacy') ?? '',
                  startVisitDate:
                      isDocContains(document: docs.docs[i],key:'startVisitDate') ?? '',
                  serviceType: isDocContains(document: docs.docs[i],key:'serviceType') ?? '',
                  picture: isDocContains(document: docs.docs[i],key:'picture') ?? '',
                  patientPhone: isDocContains(document: docs.docs[i],key:'patientPhone') ?? '',
                  patientName: isDocContains(document: docs.docs[i],key:'patientName') ?? '',
                  patientLocation:
                      isDocContains(document: docs.docs[i],key:'patientLocation') ?? '',
                  patientGender: isDocContains(document: docs.docs[i],key:'patientGender') ?? '',
                  time: time,
                  date: isDocContains(document: docs.docs[i],key:'date') ?? '',
                  discountPercentage:
                      isDocContains(document: docs.docs[i],key:'discountPercentage') ?? '',
                  patientAge: isDocContains(document: docs.docs[i],key:'patientAge') ?? '',
                  servicePrice: isDocContains(document: docs.docs[i],key:'servicePrice') ?? '',
                  nurseGender: isDocContains(document: docs.docs[i],key:'nurseGender') ?? '',
                  numOfPatients: isDocContains(document: docs.docs[i],key:'numOfPatients') ?? '',
                  endVisitDate: isDocContains(document: docs.docs[i],key:'endVisitDate') ?? '',
                  discountCoupon:
                      isDocContains(document: docs.docs[i],key:'discountCoupon') ?? '',
                  priceBeforeDiscount:
                      isDocContains(document: docs.docs[i],key:'priceBeforeDiscount') ?? '',
                  analysisType: isDocContains(document: docs.docs[i],key:'analysisType') ?? '',
                  notes: isDocContains(document: docs.docs[i],key:'notes') ?? '',
                  priceAfterDiscount:
                      isDocContains(document: docs.docs[i],key:'priceAfterDiscount').toString()
                          ));
            }
          }
          } else {
            allAnalysisRequests.clear();
          }
          notifyListeners();
        });
  }
  Future<void> getAllPhysicalTherapyRequests({String userLat='0.0',String userLong='0.0'}) async {
    var requests = databaseReference.collection('requests');
    double distance = 0.0;
    requests
        .where('specialization', whereIn: ['Physiotherapy', 'علاج طبيعى'])
        .snapshots()
        .listen((docs) {
          print(docs);
          print('csdv xsvxs');
          distance=0.0;
          allPhysicalTherapyRequests.clear();
          if (docs.docs.length != 0) {
            String time='';
            String acceptTime='';
            List<String> convertAllVisitsTime=[];
            for (int i = 0; i < docs.docs.length; i++) {
              distance = _calculateDistance(
                  userLat != '0.0'? double.parse(userLat):0.0,
                  userLong != '0.0'? double.parse(userLong):0.0,
                  double.parse(isDocContains(document: docs.docs[i],key:'lat')??'0.0'),
                  double.parse(isDocContains(document: docs.docs[i],key:'long')??'0.0'));
              if (distance <= radiusForAllRequests) {
              if(isDocContains(document: docs.docs[i],key:'time') !=''){
                time=convertTimeToAMOrPM(time: isDocContains(document: docs.docs[i],key:'time'));
              }else{
                time='';
              }
              if(isDocContains(document: docs.docs[i],key:'acceptTime') !=null&& isDocContains(document: docs.docs[i],key:'acceptTime') !=''){
                acceptTime=convertTimeToAMOrPM(time: isDocContains(document: docs.docs[i],key:'acceptTime'));
              }else{
                acceptTime='';
              }
              if (isDocContains(document: docs.docs[i],key:'visitTime') != '[]') {
                var x = isDocContains(document: docs.docs[i],key:'visitTime').replaceFirst('[', '').toString();
                String visitTime = x.replaceAll(')', '');
                List<String> times=visitTime.split(',');
                if(times.length !=0){
                  for(int i=0; i<times.length; i++){
                    convertAllVisitsTime.add(convertTimeToAMOrPM(time: times[i]));
                  }
                }
              }else{
                convertAllVisitsTime=[];
              }
              allPhysicalTherapyRequests.add(Requests(
                  specialization: isDocContains(document: docs.docs[i],key:'specialization') ?? '',
                  specializationBranch: isDocContains(document: docs.docs[i],key:'specializationBranch') ?? '',
                  acceptTime: acceptTime,
                  nurseId: isDocContains(document: docs.docs[i],key:'nurseId') ?? '',
                  distance:  distance.floor().toString(),
                  lat:  isDocContains(document: docs.docs[i],key:'lat') ?? '',
                  long:  isDocContains(document: docs.docs[i],key:'long') ?? '',
                  patientId: isDocContains(document: docs.docs[i],key:'patientId') ?? '',
                  docId: docs.docs[i].id,
                  visitTime: convertAllVisitsTime.toString() == '[]'
                      ? ''
                      : convertAllVisitsTime.toString(),
                  visitDays: isDocContains(document: docs.docs[i],key:'visitDays') ?? '',
                  suppliesFromPharmacy:
                      isDocContains(document: docs.docs[i],key:'suppliesFromPharmacy') ?? '',
                  startVisitDate:
                      isDocContains(document: docs.docs[i],key:'startVisitDate') ?? '',
                  serviceType: isDocContains(document: docs.docs[i],key:'serviceType') ?? '',
                  picture: isDocContains(document: docs.docs[i],key:'picture') ?? '',
                  patientPhone: isDocContains(document: docs.docs[i],key:'patientPhone') ?? '',
                  patientName: isDocContains(document: docs.docs[i],key:'patientName') ?? '',
                  patientLocation:
                      isDocContains(document: docs.docs[i],key:'patientLocation') ?? '',
                  patientGender: isDocContains(document: docs.docs[i],key:'patientGender') ?? '',
                  time: time,
                  date: isDocContains(document: docs.docs[i],key:'date') ?? '',
                  discountPercentage:
                      isDocContains(document: docs.docs[i],key:'discountPercentage') ?? '',
                  patientAge: isDocContains(document: docs.docs[i],key:'patientAge') ?? '',
                  servicePrice: isDocContains(document: docs.docs[i],key:'servicePrice') ?? '',
                  nurseGender: isDocContains(document: docs.docs[i],key:'nurseGender') ?? '',
                  numOfPatients: isDocContains(document: docs.docs[i],key:'numOfPatients') ?? '',
                  endVisitDate: isDocContains(document: docs.docs[i],key:'endVisitDate') ?? '',
                  discountCoupon:
                      isDocContains(document: docs.docs[i],key:'discountCoupon') ?? '',
                  priceBeforeDiscount:
                      isDocContains(document: docs.docs[i],key:'priceBeforeDiscount') ?? '',
                  analysisType: isDocContains(document: docs.docs[i],key:'analysisType') ?? '',
                  notes: isDocContains(document: docs.docs[i],key:'notes') ?? '',
                  priceAfterDiscount:
                      isDocContains(document: docs.docs[i],key:'priceAfterDiscount').toString()
                          ));
            }
          }
          } else {
            allPhysicalTherapyRequests.clear();
          }
          notifyListeners();
        });
  }

  Future<void> getAllHumanMedicineRequests({String userLat='0.0',String userLong='0.0'}) async {
    CollectionReference requests = databaseReference.collection('requests');
    double distance = 0.0;
      requests
          .where('specialization', whereIn: ['Human medicine','طب بشرى'])
          .snapshots()
          .listen((docs) {
        print('csdv xsvxs');
        distance = 0.0;
        allHumanMedicineRequests.clear();
        if (docs.docs.length != 0) {
          String time = '';
          String acceptTime = '';
          List<String> convertAllVisitsTime = [];
          for (int i = 0; i < docs.docs.length; i++) {
            distance = _calculateDistance(
                userLat != '0.0' ? double.parse(userLat) : 0.0,
                userLong != '0.0' ? double.parse(userLong) : 0.0,
                double.parse(isDocContains(document: docs.docs[i],key:'lat') ?? '0.0'),
                double.parse(isDocContains(document: docs.docs[i],key:'long') ?? '0.0'));
            print('egedgdr');
            if (distance <= radiusForAllRequests) {
              if (isDocContains(document: docs.docs[i],key:'time') != '') {
                time =
                    convertTimeToAMOrPM(time: isDocContains(document: docs.docs[i],key:'time'));
              } else {
                time = '';
              }
              if (isDocContains(document: docs.docs[i],key:'acceptTime') != null &&
                  isDocContains(document: docs.docs[i],key:'acceptTime') != '') {
                acceptTime = convertTimeToAMOrPM(
                    time: isDocContains(document: docs.docs[i],key:'acceptTime'));
              } else {
                acceptTime = '';
              }
              if (isDocContains(document: docs.docs[i],key:'visitTime') != '[]') {
                var x = isDocContains(document: docs.docs[i],key:'visitTime').replaceFirst(
                    '[', '').toString();
                String visitTime = x.replaceAll(')', '');
                List<String> times = visitTime.split(',');
                if (times.length != 0) {
                  for (int i = 0; i < times.length; i++) {
                    convertAllVisitsTime.add(
                        convertTimeToAMOrPM(time: times[i]));
                  }
                }
              } else {
                convertAllVisitsTime = [];
              }
              allHumanMedicineRequests.add(Requests(
                  specialization: isDocContains(document: docs.docs[i],key:'specialization') ??
                      '',
                  specializationBranch: docs.docs[i]
                      .get('specializationBranch') ?? '',
                  acceptTime: acceptTime,
                  nurseId: isDocContains(document: docs.docs[i],key:'nurseId') ?? '',
                  distance: distance.floor().toString(),
                  lat: isDocContains(document: docs.docs[i],key:'lat') ?? '',
                  long: isDocContains(document: docs.docs[i],key:'long') ?? '',
                  patientId: isDocContains(document: docs.docs[i],key:'patientId') ?? '',
                  docId: docs.docs[i].id,
                  visitTime: convertAllVisitsTime.toString() == '[]'
                      ? ''
                      : convertAllVisitsTime.toString(),
                  visitDays: isDocContains(document: docs.docs[i],key:'visitDays') ?? '',
                  suppliesFromPharmacy:
                  isDocContains(document: docs.docs[i],key:'suppliesFromPharmacy') ?? '',
                  startVisitDate:
                  isDocContains(document: docs.docs[i],key:'startVisitDate') ?? '',
                  serviceType: isDocContains(document: docs.docs[i],key:'serviceType') ?? '',
                  picture: isDocContains(document: docs.docs[i],key:'picture') ?? '',
                  patientPhone: isDocContains(document: docs.docs[i],key:'patientPhone') ?? '',
                  patientName: isDocContains(document: docs.docs[i],key:'patientName') ?? '',
                  patientLocation:
                  isDocContains(document: docs.docs[i],key:'patientLocation') ?? '',
                  patientGender: isDocContains(document: docs.docs[i],key:'patientGender') ?? '',
                  time: time,
                  date: isDocContains(document: docs.docs[i],key:'date') ?? '',
                  discountPercentage:
                  isDocContains(document: docs.docs[i],key:'discountPercentage') ?? '',
                  patientAge: isDocContains(document: docs.docs[i],key:'patientAge') ?? '',
                  servicePrice: isDocContains(document: docs.docs[i],key:'servicePrice') ?? '',
                  nurseGender: isDocContains(document: docs.docs[i],key:'nurseGender') ?? '',
                  numOfPatients: isDocContains(document: docs.docs[i],key:'numOfPatients') ?? '',
                  endVisitDate: isDocContains(document: docs.docs[i],key:'endVisitDate') ?? '',
                  discountCoupon:
                  isDocContains(document: docs.docs[i],key:'discountCoupon') ?? '',
                  priceBeforeDiscount:
                  isDocContains(document: docs.docs[i],key:'priceBeforeDiscount') ?? '',
                  analysisType: isDocContains(document: docs.docs[i],key:'analysisType') ?? '',
                  notes: isDocContains(document: docs.docs[i],key:'notes') ?? '',
                  priceAfterDiscount:
                  isDocContains(document: docs.docs[i],key:'priceAfterDiscount').toString()
                      ));
            }
          }
        } else {
          allHumanMedicineRequests.clear();
        }
        notifyListeners();
      });

  }

  Future<UserData> getUserData({String? type, String? userId}) async {
    var nursesCollection = databaseReference.collection("nurses");
    var patientCollection = databaseReference.collection("users");
    UserData user;
    if (type == 'Patient' || type == 'مريض') {
      DocumentSnapshot doc = await patientCollection.doc(userId).get();
      user = UserData(
        name: doc.get('name'),
        docId: doc.id,
        specialization: '',
        specializationBranch: '',
        rating: '0.0',
        nationalId: doc.get('nationalId') ?? '',
        gender: doc.get('gender') ?? '',
        birthDate: doc.get('birthDate') ?? '',
        address: doc.get('address') ?? '',
        phoneNumber: doc.get('phoneNumber') ?? '',
        imgUrl: doc.get('imgUrl') ?? '',
        email: doc.get('email') ?? '',
        lng: doc.get('lng') ?? '',
        lat: doc.get('lat') ?? '',
        aboutYou: doc.get('aboutYou') ?? '',
        points: doc.get('points') ?? '0',
      );
    } else {
      DocumentSnapshot doc = await nursesCollection.doc(userId).get();
      DocumentSnapshot rating = await nursesCollection.doc(userId).collection('rating').doc('rating').get();
      if(rating.exists) {
        int one = rating.get('1') == null ? 0 : int.parse(rating.get('1'));
        int two = rating.get('2') == null ? 0 : int.parse(rating.get('2'));
        int three = rating.get('3') == null ? 0 : int.parse(rating.get('3'));
        int four = rating.get('4') == null ? 0 : int.parse(rating.get('4'));
        int five = rating.get('5') == null ? 0 : int.parse(rating.get('5'));
        totalRatingForNurse =
            (5 * five + 4 * four + 3 * three + 2 * two + 1 * one) /
                (one + two + three + four + five);
      }
      print('evedwgew');
      print(totalRatingForNurse);
      print(doc.get('specializationBranch'));
      print(doc.get('specialization'));
      user = UserData(
        specializationBranch: doc.get('specializationBranch')?? '',
        specialization: doc.get('specialization') ?? '',
        rating: totalRatingForNurse.toString(),
        name: doc.get('name'),
        docId: doc.id,
        nationalId: doc.get('nationalId') ?? '',
        gender: doc.get('gender') ?? '',
        birthDate: doc.get('birthDate') ?? '',
        address: doc.get('address') ?? '',
        phoneNumber: doc.get('phoneNumber') ?? '',
        imgUrl: doc.get('imgUrl') ?? '',
        email: doc.get('email') ?? '',
        lng: doc.get('lng') ?? '',
        lat: doc.get('lat') ?? '',
        aboutYou: doc.get('aboutYou') ?? '',
        points: doc.get('points') ?? '0',
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

  Future getAllPatientsRequests({double? lat,double? long}) async {
    var requests = databaseReference.collection('requests');
    requests.where('analysisType', isEqualTo: '').where('specialization',isEqualTo: '').snapshots().listen((docs) {
      double distance = 0.0;
      allPatientsRequests.clear();
      if (docs.docs.length != 0) {
        String time='';
        String acceptTime='';
        List<String> convertAllVisitsTime=[];
        for (int i = 0; i < docs.docs.length; i++) {
          print('userlat:$lat');
          print('lat:${isDocContains(document: docs.docs[i],key:'lat')}');
          print('userlng:$long');
          print('lng:${isDocContains(document: docs.docs[i],key:'long')}');
          distance = _calculateDistance(
            lat!,
              long!,
              double.parse(isDocContains(document: docs.docs[i],key:'lat') ?? 0.0 as String),
              double.parse(isDocContains(document: docs.docs[i],key:'long') ?? 0.0 as String));
          print('distance::$distance');
          if (distance <= radiusForAllRequests) {
          if (isDocContains(document: docs.docs[i],key:'time') != '') {
            time = convertTimeToAMOrPM(time: isDocContains(document: docs.docs[i],key:'time'));
          } else {
            time = '';
          }
          if (isDocContains(document: docs.docs[i],key:'acceptTime') != null &&
              isDocContains(document: docs.docs[i],key:'acceptTime') != '') {
            acceptTime =
                convertTimeToAMOrPM(time: isDocContains(document: docs.docs[i],key:'acceptTime'));
          } else {
            acceptTime = '';
          }
          if (isDocContains(document: docs.docs[i],key:'visitTime') != '[]') {
            var x = isDocContains(document: docs.docs[i],key:'visitTime')
                .replaceFirst('[', '')
                .toString();
            String visitTime = x.replaceAll(')', '');
            List<String> times = visitTime.split(',');
            if (times.length != 0) {
              for (int i = 0; i < times.length; i++) {
                convertAllVisitsTime.add(convertTimeToAMOrPM(time: times[i]));
              }
            }
          } else {
            convertAllVisitsTime = [];
          }
          print(isDocContains(document: docs.docs[i],key:'specialization'));
          print(docs.docs[i]
              .get('specializationBranch'));
          allPatientsRequests.add(Requests(
              specialization: isDocContains(document: docs.docs[i],key:'specialization') ?? '',
              specializationBranch: docs.docs[i]
                  .get('specializationBranch') ?? '',
              acceptTime: acceptTime,
              distance:  distance.floor().toString(),
              lat:  isDocContains(document: docs.docs[i],key:'lat') ?? '',
              long:  isDocContains(document: docs.docs[i],key:'long') ?? '',
              patientId: isDocContains(document: docs.docs[i],key:'patientId') ?? '',
              docId: docs.docs[i].id,
              visitTime: convertAllVisitsTime.toString() == '[]'
                  ? ''
                  : convertAllVisitsTime.toString(),
              visitDays: isDocContains(document: docs.docs[i],key:'visitDays') == '[]'
                  ? ''
                  : isDocContains(document: docs.docs[i],key:'visitDays') ?? '',
              nurseId: isDocContains(document: docs.docs[i],key:'nurseId') ?? '',
              suppliesFromPharmacy:
              isDocContains(document: docs.docs[i],key:'suppliesFromPharmacy') ?? '',
              startVisitDate: isDocContains(document: docs.docs[i],key:'startVisitDate') ?? '',
              serviceType: isDocContains(document: docs.docs[i],key:'serviceType') ?? '',
              picture: isDocContains(document: docs.docs[i],key:'picture') ?? '',
              patientPhone: isDocContains(document: docs.docs[i],key:'patientPhone') ?? '',
              patientName: isDocContains(document: docs.docs[i],key:'patientName') ?? '',
              patientLocation: isDocContains(document: docs.docs[i],key:'patientLocation') ?? '',
              patientGender: isDocContains(document: docs.docs[i],key:'patientGender') ?? '',
              patientAge: isDocContains(document: docs.docs[i],key:'patientAge') ?? '',
              servicePrice: isDocContains(document: docs.docs[i],key:'servicePrice') ?? '',
              time: time,
              date: isDocContains(document: docs.docs[i],key:'date') ?? '',
              discountPercentage:
              isDocContains(document: docs.docs[i],key:'discountPercentage') ?? '',
              nurseGender: isDocContains(document: docs.docs[i],key:'nurseGender') ?? '',
              numOfPatients: isDocContains(document: docs.docs[i],key:'numOfPatients') ?? '',
              endVisitDate: isDocContains(document: docs.docs[i],key:'endVisitDate') ?? '',
              discountCoupon: isDocContains(document: docs.docs[i],key:'discountCoupon') ?? '',
              priceBeforeDiscount:
              isDocContains(document: docs.docs[i],key:'priceBeforeDiscount') ?? '',
              analysisType: isDocContains(document: docs.docs[i],key:'analysisType') ?? '',
              notes: isDocContains(document: docs.docs[i],key:'notes') ?? '',
              priceAfterDiscount:
              isDocContains(document: docs.docs[i],key:'priceAfterDiscount').toString()
                  ));
        }
        }
      } else {
        allPatientsRequests.clear();
      }
      notifyListeners();
    });
  }

  Future<bool> acceptAccount({String? id})async{
    CollectionReference patientCollection = databaseReference.collection("users");
     await  patientCollection.doc(id).set({
        'isVerify':'true'
      },SetOptions(merge: true));
    return true;
  }
  Future<bool> deleteAccount({String? id})async{
    CollectionReference patientCollection = databaseReference.collection("users");
    await  patientCollection.doc(id).delete();
    return true;
  }
Future<void> getPatientAccountsThatToVerify()async{

    CollectionReference patientCollection = databaseReference.collection("users");
     patientCollection.where('isVerify',isEqualTo: 'false').snapshots().listen((docs){
       String time='';
       if (docs.docs.isNotEmpty) {
         patientAccountsThatToVerify.clear();
         for (int i = 0; i < docs.docs.length; i++) {
           if(isDocContains(document: docs.docs[i],key:'time') !=null&&isDocContains(document: docs.docs[i],key:'time') !=''){
             time=convertTimeToAMOrPM(time: isDocContains(document: docs.docs[i],key:'time'));
           }else{
             time='';
           }
           print(' isDocContains(document: docs.docs[i],key:pictureId]');
           print( isDocContains(document: docs.docs[i],key:'pictureId'));
           patientAccountsThatToVerify.add(UserData(
               imgId: isDocContains(document: docs.docs[i],key:'pictureId') ?? '',
               date: isDocContains(document: docs.docs[i],key:'date') ?? '',
               time: time,
               lat: isDocContains(document: docs.docs[i],key:'lat') ?? '',
               lng: isDocContains(document: docs.docs[i],key:'lng') ?? '',
               aboutYou: isDocContains(document: docs.docs[i],key:'aboutYou') ?? '',
               docId: docs.docs[i].id,
               email: isDocContains(document: docs.docs[i],key:'email') ?? '',
               password: isDocContains(document: docs.docs[i],key:'password') ?? '',
               points: isDocContains(document: docs.docs[i],key:'points') ?? '0',
               name: isDocContains(document: docs.docs[i],key:'name') ?? '',
               phoneNumber: isDocContains(document: docs.docs[i],key:'phoneNumber') ?? '',
               imgUrl: isDocContains(document: docs.docs[i],key:'imgUrl') ?? '',
               address: isDocContains(document: docs.docs[i],key:'address') ?? '',
               birthDate: isDocContains(document: docs.docs[i],key:'birthDate') ?? '',
               gender: isDocContains(document: docs.docs[i],key:'gender') ?? '',
               nationalId: isDocContains(document: docs.docs[i],key:'nationalId') ?? ''));
         }
       }else{
         patientAccountsThatToVerify.clear();
       }
       notifyListeners();
   });
}
}
