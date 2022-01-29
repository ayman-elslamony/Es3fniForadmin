import 'dart:convert';

import 'package:es3fniforadmin/core/models/device_info.dart';
import 'package:es3fniforadmin/core/ui_components/info_widget.dart';
import 'package:es3fniforadmin/models/requests.dart';
import 'package:es3fniforadmin/providers/auth.dart';
import 'package:es3fniforadmin/providers/home.dart';
import 'package:es3fniforadmin/screens/patient_requests/add_patient_request.dart';
import 'package:es3fniforadmin/screens/shared_widget/zoom_in_and_out_to_image.dart';
import 'package:es3fniforadmin/screens/user_profile/show_profile.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';


class AnalysisRequests extends StatefulWidget {
  @override
  _AnalysisRequestsState createState() => _AnalysisRequestsState();
}

class _AnalysisRequestsState extends State<AnalysisRequests> {
  late Home _home;
  late Auth _auth;
  bool loadingBody = false;
  Widget content({required Requests request, required DeviceInfo infoWidget}) {
    String visitDays = '';
    String visitTime = '';
    if (request.visitDays != '[]') {
      var x = request.visitDays!.replaceFirst('[', '');
      visitDays = x.replaceAll(']', '');
    }
    if (request.visitTime != '[]') {
      var x = request.visitTime!.replaceFirst('[', '');
      visitTime = x.replaceAll(']', '');
    }

    print(request.patientName);
    print(request.visitDays);
    print(request.visitTime);
    print(request.discountPercentage);

    return InkWell(
      onTap: () {
        showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10))),
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Directionality(
                  textDirection: translator.activeLanguageCode == "en"
                      ? TextDirection.ltr:TextDirection.rtl,
                  child: SizedBox(
                    width: infoWidget.screenWidth,
                    height: infoWidget.screenHeight!*0.55,
                    child: ListView(
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            SizedBox(),
                            Text(
                              translator.activeLanguageCode == "en"
                                  ? 'All Information':'البيانات بالكامل',
                              style: infoWidget.titleButton!
                                  .copyWith(color: Colors.indigo),
                            ),
//                          IconButton(
//                              icon: Icon(
//                                Icons.edit,
//                                color: Colors.indigo,
//                              ),
//                              onPressed: () {})
                            SizedBox(),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        request.patientId != ''
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            request.patientName != ''
                                ? Expanded(

                              child: rowWidget(
                                  title:
                                  translator.activeLanguageCode == "en"
                                      ? 'Patient Name: '
                                      : 'اسم المريض: ',
                                  content: request.patientName!,
                                  infoWidget: infoWidget),
                            )
                                : SizedBox(),
                            IconButton(icon: Icon(Icons.more_horiz,color: Colors.indigo,), onPressed: (){
                              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ShowUserProfile(
                                type: translator.activeLanguageCode == "en"
                                    ?'Patient':'مريض',
                                userId: request.patientId,
                              )));
                            }),
                          ],
                        )
                            : request.patientName != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Patient Name: '
                                : 'اسم المريض: ',
                            content: request.patientName!,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.patientPhone != ''
                            ? InkWell(
                          onTap: (){
                            launch("tel://${request.patientPhone}");
                          },
                          child: rowWidget(
                              title: translator.activeLanguageCode == "en"
                                  ? 'Patient Phone: '
                                  : 'رقم الهاتف: ',
                              content: request.patientPhone!,
                              infoWidget: infoWidget),
                        )
                            : SizedBox(),
                        request.patientLocation != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Patient Location: '
                                : 'موقع المريض: ',
                            content: request.patientLocation!,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.distance != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Distance between you: '
                                : 'المسافه بينكم: ',
                            content:  translator.activeLanguageCode == "en"
                                ? '${request.distance} KM':'${request.distance} كم ',
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.patientAge != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Patient Age: '
                                : 'عمر المريض: ',
                            content: request.patientAge!,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.patientGender != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Patient Gender: '
                                : 'نوع المريض: ',
                            content: request.patientGender!,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.serviceType != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Service Type: '
                                : 'نوع الخدمه: ',
                            content: request.serviceType!,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.servicePrice != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Service Price: '
                                : 'سعر الخدمه: ',
                            content: request.servicePrice!,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.analysisType != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Analysis Type: '
                                : 'نوع التحليل: ',
                            content: request.analysisType!,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.suppliesFromPharmacy != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Supplies From Pharmacy: '
                                : 'مستلزمات من الصيدليه: ',
                            content: request.suppliesFromPharmacy!,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.picture!=''?
                        Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  translator.activeLanguageCode == "en"
                                      ? 'Roshita or analysis Picture: '
                                      : 'صوره الروشته او التحليل: ',
                                  style: infoWidget.titleButton!.copyWith(color: Colors.indigo),
                                ),
                                RaisedButton(
                                  padding: EdgeInsets.all(0.0),
                                  onPressed:
                                      (){
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ShowImage(
                                      title: translator.activeLanguageCode == "en" ? 'Roshita or analysis Picture'
                                          : 'صوره الروشته او التحليل',
                                      imgUrl: request.picture,
                                      isImgUrlAsset: false,
                                    )));
                                  },
                                  color: Colors.indigo,
                                  child: Text(
                                    translator.activeLanguageCode == "en" ?'Show':'اظهار',
                                    style: infoWidget.titleButton!
                                        .copyWith(color: Colors.white),
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        ):SizedBox(),
                        request.startVisitDate != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Start Visit Date: '
                                : 'بدايه تاريخ الزياره: ',
                            content: request.startVisitDate!,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.endVisitDate != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'End Visit Date: '
                                : 'انتهاء تاريخ الزياره: ',
                            content: request.endVisitDate!,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        visitDays != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Visit Days: '
                                : 'ايام الزياره: ',
                            content: visitDays,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        visitTime != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Visit Time: '
                                : 'وقت الزياره: ',
                            content: visitTime,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.discountCoupon != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Discount Coupon: '
                                : 'كوبون الخصم: ',
                            content: request.discountCoupon!,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.discountPercentage != '0.0'
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Discount Percentage: '
                                : 'نسبه الخصم: ',
                            content: '${request.discountPercentage} %',
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.numOfPatients != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Num Of Patients use service: '
                                : 'عدد مستخدمى الخدمه: ',
                            content: request.numOfPatients!,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.priceBeforeDiscount != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'priceBeforeDiscount: '
                                : 'السعر قبل الخصم: ',
                            content: request.priceBeforeDiscount!,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.priceAfterDiscount != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Price After Discount: '
                                : 'السعر بعد الخصم: ',
                            content: request.priceAfterDiscount!,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.notes != ''
                            ? rowWidget(
                            title: translator.activeLanguageCode == "en"
                                ? 'Notes: '
                                : 'ملاحظات: ',
                            content: request.notes!,
                            infoWidget: infoWidget)
                            : SizedBox(),
                      ],
                    ),
                  ),
                ),
              );
            });
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Container(
          color: Colors.blue[100],
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    width: infoWidget.screenWidth!*0.06,
                    height:infoWidget.screenWidth!*0.06
                    ,child: LoadingIndicator(

    colors: [
    request.nurseId==''?Colors.red:Colors.indigo,
    ],
                    indicatorType: Indicator.ballScale,
                  ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      request.patientName != ''
                          ? Text(
                        translator.activeLanguageCode == 'en'
                            ? 'Patient Name: ${request.patientName}'
                            : 'اسم المريض: ${request.patientName}',
                        style: infoWidget.titleButton!
                            .copyWith(color: Colors.indigo),
                      )
                          : SizedBox(),
                      request.patientLocation != ''
                          ? Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              translator.activeLanguageCode == 'en'
                                  ? 'Patient Location: ${request.patientLocation}'
                                  : 'موقع المريض: ${request.patientLocation}',
                              style: infoWidget.titleButton!
                                  .copyWith(color: Colors.indigo),
                              maxLines: 3,
                            ),
                          ),
                          SizedBox(
                            width: 0.1,
                          ),
                        ],
                      )
                          : SizedBox(),
                      request.serviceType != ''
                          ? Text(
                        translator.activeLanguageCode == 'en'
                            ? 'Service Type: ${request.serviceType}'
                            : 'نوع الخدمه: ${request.serviceType}',
                        style: infoWidget.titleButton!
                            .copyWith(color: Colors.indigo),
                      )
                          : SizedBox(),
                      request.analysisType != ''
                          ? Text(
                        translator.activeLanguageCode == 'en'
                            ? 'Analysis Type: ${request.priceBeforeDiscount} EGP'
                            : 'نوع التحليل: ${request.analysisType}',
                        style: infoWidget.titleButton!
                            .copyWith(color: Colors.indigo),
                      )
                          : SizedBox(),
                      request.specialization != ''
                          ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            translator.activeLanguageCode == 'en'
                                ? 'Specialization: '
                                : 'التخصص: ',
                            style: infoWidget.titleButton!
                                .copyWith(color: Colors.indigo),
                          ),
                          Expanded(
                            child: Text(
                              translator.activeLanguageCode == 'en'
                                  ? request.specializationBranch != ''
                                  ? '${request.specialization}-${request
                                  .specializationBranch}'
                                  : '${request.specialization}'
                                  : request.specializationBranch != ''
                                  ? '${request.specialization} - ${request
                                  .specializationBranch}'
                                  : '${request.specialization}',
                              style: infoWidget.titleButton!
                                  .copyWith(color: Colors.indigo),
                            ),
                          ),
                        ],
                      )
                          : SizedBox(),
                      request.date != ''
                          ? Text(
                        translator.activeLanguageCode == 'en'
                            ? 'Dtate: ${request.date}'
                            : 'التاريخ: ${request.date}',
                        style: infoWidget.subTitle,
                      )
                          : SizedBox(),
                      request.time != ''
                          ? Text(
                        translator.activeLanguageCode == 'en'
                            ? 'Time: ${request.time}'
                            : 'الوقت: ${request.time}',
                        style: infoWidget.subTitle,
                      )
                          : SizedBox(),
                      request.priceBeforeDiscount != ''
                          ? Text(
                        translator.activeLanguageCode == 'en'
                            ? 'Price before discount: ${request.priceBeforeDiscount} EGP'
                            : 'السعر قبل الخصم: ${request.priceBeforeDiscount} جنيه ',
                        style: infoWidget.subTitle,
                      )
                          : SizedBox(),
                      request.priceAfterDiscount != ''
                          ? Text(
                        translator.activeLanguageCode == 'en'
                            ? 'Price after discount: ${request.priceAfterDiscount} EGP'
                            : 'السعر بعد الخصم: ${request.priceAfterDiscount} جنيه ',
                        style: infoWidget.subTitle,
                      )
                          : SizedBox(),
                      request.nurseId==''?Text(
                        translator.activeLanguageCode == 'en'
                            ? 'Status: pending'
                            : 'الحاله: قيد الانتظار',
                        style: infoWidget.titleButton!
                            .copyWith(color: Colors.red),
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              translator.activeLanguageCode == 'en'
                                  ? 'Status: Accepted'
                                  : 'الحاله: تم القبول',
                              style: infoWidget.titleButton!
                                  .copyWith(color: Colors.indigo),
                            ),
                          ),
                          request.nurseId !=''?IconButton(padding: EdgeInsets.all(0.0),icon: Icon(Icons.more_horiz,color: Colors.indigo,), onPressed: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ShowUserProfile(
                              type: translator.activeLanguageCode == 'en'
                                  ?'Nurse':'ممرض',
                              userId: request.nurseId,
                            ) ));
                          }):SizedBox()
                        ],
                      ),
                      request.acceptTime==''?SizedBox():Text(
                        translator.activeLanguageCode == 'en'
                            ? 'Time of acceptance: ${request.acceptTime}'
                            : ' وقت القبول: ${request.acceptTime}',
                        style: infoWidget.subTitle!
                            .copyWith(color: Colors.indigo),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget  rowWidget({required String title,required String content,required DeviceInfo infoWidget}){
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(title,style: infoWidget.titleButton!.copyWith(color: Colors.indigo),
            ),
            Expanded(
              child: Text(content,style: infoWidget.subTitle,maxLines: 2,
              ),
            ),
          ],
        ) ,SizedBox(height: 5,),
      ],
    );
  }

  getAllAnalysisRequests() async {
    if(_home.refreshWhenChangeFilters[2]){
      _home.allAnalysisRequests.clear();
      _home.refreshWhenChangeFilters[2] = false;
    }
    if(_home.allAnalysisRequests.length ==0){
      setState(() {
        loadingBody = true;
      });
      await getLocationAndRadiusFromLocalStorage();
      print('edgdeg');
      await _home.getAllAnalysisRequests(
        userLat: _auth.lat.toString(),
        userLong: _auth.lng.toString()
      );
      setState(() {
        loadingBody = false;
      });
    }

  }
  Future<void> getLocationAndRadiusFromLocalStorage()async{
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic>? _filter;
    if(_home.radiusForAllRequests==1.0){
      if (prefs.containsKey('filter')) {
        _filter = await json
            .decode(prefs.getString('filter')!) as Map<String, dynamic>?;
        print(_filter!['filter']);
        _home.radiusForAllRequests =double.parse( (_filter['radiusForAllRequests'] as String));
      }else{
        _home.radiusForAllRequests = 10.0;
      }
    }
    if(_auth.lat==30.033333 && _auth.lng == 31.233334){
      if (prefs.containsKey('filter')) {
        if(_filter == null){
          _filter = await json
              .decode(prefs.getString('filter')!) as Map<String, dynamic>?;
        }
        _auth.lat = double.parse(_filter!['lat'] as String);
        _auth.lng = double.parse(_filter['lng'] as String);
        _auth.address = _filter['address'] as String?;

      }else{
        _auth.lat= 30.033333;
        _auth.lng= 31.233334;
        _auth.address =translator.activeLanguageCode=='en'?'Cairo':'القاهره';
        _home.radiusForAllRequests = 10.0;
      }
    }
  }
  @override
  void initState() {
    _home = Provider.of<Home>(context, listen: false);
    _auth = Provider.of<Auth>(context, listen: false);
    getAllAnalysisRequests();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return InfoWidget(
        builder: (context,infoWidget)=>Scaffold(
          body:  loadingBody
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
                    height: infoWidget.screenHeight! * 0.27,
                  ),
                ),
              ),
              itemCount: 5,
            ),
          )
              : RefreshIndicator(
            color: Colors.indigo,
            backgroundColor: Colors.white,
            onRefresh: ()async{
              _home.getAllAnalysisRequests( userLat: _auth.lat.toString(),
                  userLong: _auth.lng.toString());
            },
            child: Consumer<Home>(
              builder: (context, data, _) {
                if (data.allAnalysisRequests.length == 0) {
                  return Center(
                    child: Text(
                      translator.activeLanguageCode == "en"
                          ? 'There is no any requests'
                          : 'لا يوجد طلبات',
                      style: infoWidget.titleButton!
                          .copyWith(color: Colors.indigo),
                    ),
                  );
                } else {
                  return ListView.builder(
                      itemCount: data.allAnalysisRequests.length,
                      itemBuilder: (context, index) =>
                          content(
                              infoWidget: infoWidget,
                              request: data.allAnalysisRequests[index])

                  );
                }
              },
            ),
          ),
        )
    );
  }
}
