import 'package:admin/core/models/device_info.dart';
import 'package:admin/core/ui_components/info_widget.dart';
import 'package:admin/models/requests.dart';
import 'package:admin/providers/home.dart';
import 'package:admin/screens/patient_requests/add_patient_request.dart';
import 'package:admin/screens/user_profile/show_profile.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';


class AnalysisRequests extends StatefulWidget {
  @override
  _AnalysisRequestsState createState() => _AnalysisRequestsState();
}

class _AnalysisRequestsState extends State<AnalysisRequests> {
  Home _home;
  bool loadingBody = true;
  bool _showFloating = true;

  ScrollController _scrollController;
  Widget content({Requests request, DeviceInfo infoWidget}) {
    String visitDays = '';
    String visitTime = '';
    if (request.visitDays != '[]') {
      var x = request.visitDays.replaceFirst('[', '');
      visitDays = x.replaceAll(']', '');
    }
    if (request.visitTime != '[]') {
      var x = request.visitTime.replaceFirst('[', '');
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
                  textDirection: translator.currentLanguage == "en"
                      ? TextDirection.ltr:TextDirection.rtl,
                  child: SizedBox(
                    width: infoWidget.screenWidth,
                    height: infoWidget.screenHeight*0.55,
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
                              translator.currentLanguage == "en"
                                  ? 'All Information':'البيانات بالكامل',
                              style: infoWidget.titleButton
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
                                  translator.currentLanguage == "en"
                                      ? 'Patient Name: '
                                      : 'اسم المريض: ',
                                  content: request.patientName,
                                  infoWidget: infoWidget),
                            )
                                : SizedBox(),
                            IconButton(icon: Icon(Icons.more_horiz,color: Colors.indigo,), onPressed: (){
                              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ShowUserProfile(
                                type: translator.currentLanguage == "en"
                                    ?'Patient':'مريض',
                                userId: request.patientId,
                              )));
                            }),
                          ],
                        )
                            : request.patientName != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Patient Name: '
                                : 'اسم المريض: ',
                            content: request.patientName,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.patientPhone != ''
                            ? InkWell(
                          onTap: (){
                            launch("tel://${request.patientPhone}");
                          },
                          child: rowWidget(
                              title: translator.currentLanguage == "en"
                                  ? 'Patient Phone: '
                                  : 'رقم الهاتف: ',
                              content: request.patientPhone,
                              infoWidget: infoWidget),
                        )
                            : SizedBox(),
                        request.patientLocation != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Patient Location: '
                                : 'موقع المريض: ',
                            content: request.patientLocation,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.patientAge != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Patient Age: '
                                : 'عمر المريض: ',
                            content: request.patientAge,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.patientGender != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Patient Gender: '
                                : 'نوع المريض: ',
                            content: request.patientGender,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.serviceType != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Service Type: '
                                : 'نوع الخدمه: ',
                            content: request.serviceType,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.servicePrice != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Service Price: '
                                : 'سعر الخدمه: ',
                            content: request.servicePrice,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.analysisType != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Analysis Type: '
                                : 'نوع التحليل: ',
                            content: request.analysisType,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.suppliesFromPharmacy != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Supplies From Pharmacy: '
                                : 'مستلزمات من الصيدليه: ',
                            content: request.suppliesFromPharmacy,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.startVisitDate != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Start Visit Date: '
                                : 'بدايه تاريخ الزياره: ',
                            content: request.startVisitDate,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.endVisitDate != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'End Visit Date: '
                                : 'انتهاء تاريخ الزياره: ',
                            content: request.endVisitDate,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        visitDays != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Visit Days: '
                                : 'ايام الزياره: ',
                            content: visitDays,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        visitTime != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Visit Time: '
                                : 'وقت الزياره: ',
                            content: visitTime,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.discountCoupon != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Discount Coupon: '
                                : 'كوبون الخصم: ',
                            content: request.discountCoupon,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.discountPercentage != '0.0'
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Discount Percentage: '
                                : 'نسبه الخصم: ',
                            content: '${request.discountPercentage} %',
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.numOfPatients != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Num Of Patients use service: '
                                : 'عدد مستخدمى الخدمه: ',
                            content: request.numOfPatients,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.priceBeforeDiscount != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'priceBeforeDiscount: '
                                : 'السعر قبل الخصم: ',
                            content: request.priceBeforeDiscount,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.priceAfterDiscount != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Price After Discount: '
                                : 'السعر بعد الخصم: ',
                            content: request.priceAfterDiscount,
                            infoWidget: infoWidget)
                            : SizedBox(),
                        request.notes != ''
                            ? rowWidget(
                            title: translator.currentLanguage == "en"
                                ? 'Notes: '
                                : 'ملاحظات: ',
                            content: request.notes,
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
                    width: infoWidget.screenWidth*0.06,
                    height:infoWidget.screenWidth*0.06
                    ,child: LoadingIndicator(
                    color: request.nurseId==''?Colors.red:Colors.indigo,
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
                        translator.currentLanguage == 'en'
                            ? 'Patient Name: ${request.patientName}'
                            : 'اسم المريض: ${request.patientName}',
                        style: infoWidget.titleButton
                            .copyWith(color: Colors.indigo),
                      )
                          : SizedBox(),
                      request.patientLocation != ''
                          ? Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              translator.currentLanguage == 'en'
                                  ? 'Patient Location: ${request.patientLocation}'
                                  : 'موقع المريض: ${request.patientLocation}',
                              style: infoWidget.titleButton
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
                        translator.currentLanguage == 'en'
                            ? 'Service Type: ${request.serviceType}'
                            : 'نوع الخدمه: ${request.serviceType}',
                        style: infoWidget.titleButton
                            .copyWith(color: Colors.indigo),
                      )
                          : SizedBox(),
                      request.analysisType != ''
                          ? Text(
                        translator.currentLanguage == 'en'
                            ? 'Analysis Type: ${request.priceBeforeDiscount} EGP'
                            : 'نوع التحليل: ${request.analysisType}',
                        style: infoWidget.titleButton
                            .copyWith(color: Colors.indigo),
                      )
                          : SizedBox(),
                      request.date != ''
                          ? Text(
                        translator.currentLanguage == 'en'
                            ? 'Dtate: ${request.date}'
                            : 'التاريخ: ${request.date}',
                        style: infoWidget.subTitle,
                      )
                          : SizedBox(),
                      request.time != ''
                          ? Text(
                        translator.currentLanguage == 'en'
                            ? 'Time: ${request.time}'
                            : 'الوقت: ${request.time}',
                        style: infoWidget.subTitle,
                      )
                          : SizedBox(),
                      request.priceBeforeDiscount != ''
                          ? Text(
                        translator.currentLanguage == 'en'
                            ? 'Price before discount: ${request.priceBeforeDiscount} EGP'
                            : 'السعر قبل الخصم: ${request.priceBeforeDiscount} جنيه ',
                        style: infoWidget.subTitle,
                      )
                          : SizedBox(),
                      request.priceAfterDiscount != ''
                          ? Text(
                        translator.currentLanguage == 'en'
                            ? 'Price after discount: ${request.priceAfterDiscount} EGP'
                            : 'السعر بعد الخصم: ${request.priceAfterDiscount} جنيه ',
                        style: infoWidget.subTitle,
                      )
                          : SizedBox(),
                      request.nurseId==''?Text(
                        translator.currentLanguage == 'en'
                            ? 'Status: pending'
                            : 'الحاله: قيد الانتظار',
                        style: infoWidget.titleButton
                            .copyWith(color: Colors.red),
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              translator.currentLanguage == 'en'
                                  ? 'Status: Accepted'
                                  : 'الحاله: تم القبول',
                              style: infoWidget.titleButton
                                  .copyWith(color: Colors.indigo),
                            ),
                          ),
                          request.nurseId !=''?IconButton(padding: EdgeInsets.all(0.0),icon: Icon(Icons.more_horiz,color: Colors.indigo,), onPressed: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ShowUserProfile(
                              type: translator.currentLanguage == 'en'
                                  ?'Nurse':'ممرض',
                              userId: request.nurseId,
                            ) ));
                          }):SizedBox()
                        ],
                      ),
                      request.acceptTime==''?SizedBox():Text(
                        translator.currentLanguage == 'en'
                            ? 'Time of acceptance: ${request.acceptTime}'
                            : ' وقت القبول: ${request.acceptTime}',
                        style: infoWidget.subTitle
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
  Widget  rowWidget({String title,String content,DeviceInfo infoWidget}){
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(title,style: infoWidget.titleButton.copyWith(color: Colors.indigo),
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
  bool get _isAppBarExpanded {
    return _scrollController.hasClients &&
        _scrollController.offset < (MediaQuery.of(context).size.height*0.1 - kToolbarHeight);
  }
  getAllAnalysisRequests() async {
    if(_home.allAnalysisRequests.length ==0){
      await _home.getAllAnalysisRequests();
    }
    setState(() {
      loadingBody = false;
    });
  }

  @override
  void initState() {
    _home = Provider.of<Home>(context, listen: false);
    _scrollController = ScrollController()
      ..addListener(() {
        _isAppBarExpanded
            ? setState(() {
          _showFloating = true;
        })
            : setState(() {
          _showFloating = false;
        });
      });
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
                    height: infoWidget.screenHeight * 0.27,
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
              _home.getAllAnalysisRequests();
            },
            child: Consumer<Home>(
              builder: (context, data, _) {
                if (data.allAnalysisRequests.length == 0) {
                  return Center(
                    child: Text(
                      translator.currentLanguage == "en"
                          ? 'There is no any requests'
                          : 'لا يوجد طلبات',
                      style: infoWidget.titleButton
                          .copyWith(color: Colors.indigo),
                    ),
                  );
                } else {
                  return ListView.builder(
                    controller: _scrollController,
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
