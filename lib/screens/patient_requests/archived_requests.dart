
import 'package:es3fniforadmin/core/models/device_info.dart';
import 'package:es3fniforadmin/core/ui_components/info_widget.dart';
import 'package:es3fniforadmin/models/requests.dart';
import 'package:es3fniforadmin/providers/auth.dart';
import 'package:es3fniforadmin/providers/home.dart';
import 'package:es3fniforadmin/screens/shared_widget/zoom_in_and_out_to_image.dart';
import 'package:es3fniforadmin/screens/user_profile/show_profile.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';


class ArchivedRequests extends StatefulWidget {
  @override
  _ArchivedRequestsState createState() => _ArchivedRequestsState();
}

class _ArchivedRequestsState extends State<ArchivedRequests> {
  late Home _home;
  bool loadingBody = true;
late Auth _auth;
  Widget content({required Requests request, DeviceInfo? infoWidget}) {
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
                  child: Container(
                    width: infoWidget!.screenWidth,
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
                                request.patientId !=''?IconButton(icon: Icon(Icons.more_horiz,color: Colors.indigo,), onPressed: (){
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ShowUserProfile(
                                    type: translator.activeLanguageCode == "en"
                                        ?'Patient':'مريض',
                                    userId: request.patientId,
                                  ) ));
                                }):SizedBox()
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
            child:Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
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
                        style: infoWidget!.titleButton!
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
                              style: infoWidget!.titleButton!
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
                        style: infoWidget!.titleButton!
                            .copyWith(color: Colors.indigo),
                      )
                          : SizedBox(),
                      request.analysisType != ''
                          ? Text(
                        translator.activeLanguageCode == 'en'
                            ? 'Analysis Type: ${request.priceBeforeDiscount} EGP'
                            : 'نوع التحليل: ${request.analysisType}',
                        style: infoWidget!.titleButton!
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
                            style: infoWidget!.titleButton!
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
                        style: infoWidget!.subTitle,
                      )
                          : SizedBox(),
                      request.time != ''
                          ? Text(
                        translator.activeLanguageCode == 'en'
                            ? 'Time: ${request.time}'
                            : 'الوقت: ${request.time}',
                        style: infoWidget!.subTitle,
                      )
                          : SizedBox(),
                      request.priceBeforeDiscount != ''
                          ? Text(
                        translator.activeLanguageCode == 'en'
                            ? 'Price before discount: ${request.priceBeforeDiscount} EGP'
                            : 'السعر قبل الخصم: ${request.priceBeforeDiscount} جنيه ',
                        style: infoWidget!.subTitle,
                      )
                          : SizedBox(),
                      request.priceAfterDiscount != ''
                          ? Text(
                        translator.activeLanguageCode == 'en'
                            ? 'Price after discount: ${request.priceAfterDiscount} EGP'
                            : 'السعر بعد الخصم: ${request.priceAfterDiscount} جنيه ',
                        style: infoWidget!.subTitle,
                      )
                          : SizedBox(),
                      request.nurseId != ''
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              translator.activeLanguageCode == 'en'
                                  ? 'Accepted By Nurse'
                                  : 'تم القبول بواسطه ممرض',
                              style: infoWidget!.subTitle,
                            ),
                          ),
                          IconButton(icon: Icon(Icons.more_horiz,color: Colors.indigo,), onPressed: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ShowUserProfile(
                              type: translator.activeLanguageCode == "en"
                                  ?'Nurse':'ممرض',
                              userId: request.nurseId,
                            ) ));
                          })
                        ],
                      )
                          : SizedBox(),
                    ],
                  ),
                ),
                Column(
                  children: <Widget>[
//                  RaisedButton(onPressed: (){},
//                  child: Text(translator.activeLanguageCode =='en'?'delete':'حذف',
//                    style: infoWidget.titleButton,),color: Colors.indigo,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),)
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget rowWidget({required String title, required String content, required DeviceInfo infoWidget}) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              title,
              style: infoWidget.titleButton!.copyWith(color: Colors.indigo),
            ),
            Expanded(
              child: Text(
                content,
                style: infoWidget.subTitle,
                maxLines: 2,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
      ],
    );
  }

  getAllArchivedRequests() async {
    print('dvdxvx');
    if (_home.allArchivedRequests.length == 0) {
      await _home.getAllArchivedRequests(userLong: _auth.lat.toString(),userLat: _auth.lng.toString());
    }
    setState(() {
      loadingBody = false;
    });
  }

  @override
  void initState() {
    _home = Provider.of<Home>(context, listen: false);
    _auth = Provider.of<Auth>(context, listen: false);
    getAllArchivedRequests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InfoWidget(
        builder: (context, infoWidget) => Directionality(
          textDirection: translator.activeLanguageCode == "en"
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                translator.activeLanguageCode == "en"
                    ? "Archived Requests"
                    : 'الطلبات المؤرشفه',
                style: infoWidget.titleButton,
              ),
              leading: IconButton(icon: Icon(
                Icons.arrow_back_ios,
                size: infoWidget.orientation == Orientation.portrait
                    ? infoWidget.screenWidth! * 0.05
                    : infoWidget.screenWidth! * 0.035,
              ),color: Colors.white, onPressed: () {
                Navigator.of(context).pop();
              },),
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
            ),
            body: loadingBody
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
              onRefresh: () async {
                _home.getAllArchivedRequests(userLong: _auth.lat.toString(),userLat: _auth.lng.toString());
              },
              child: Consumer<Home>(
                builder: (context, data, _) {
                  if (data.allArchivedRequests.length == 0) {
                    return Center(
                      child: Text(
                        translator.activeLanguageCode == "en"
                            ? 'There is no any archived requests'
                            : 'لا يوجد طلبات مؤرشفه',
                        style: infoWidget.titleButton!
                            .copyWith(color: Colors.indigo),
                      ),
                    );
                  } else {
                    return ListView.builder(
                        itemCount: data.allArchivedRequests.length,
                        itemBuilder: (context, index) => content(
                            infoWidget: infoWidget,
                            request: data.allArchivedRequests[index]));
                  }
                },
              ),
            ),
          ),
        ));
  }
}
