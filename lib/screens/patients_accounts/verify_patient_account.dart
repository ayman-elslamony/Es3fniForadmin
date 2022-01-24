import 'package:es3fniforadmin/screens/shared_widget/show_user_location.dart';
import 'package:es3fniforadmin/screens/shared_widget/zoom_in_and_out_to_image.dart';
import 'package:flutter/material.dart';
import 'package:es3fniforadmin/core/models/device_info.dart';
import 'package:es3fniforadmin/core/ui_components/info_widget.dart';
import 'package:es3fniforadmin/models/user_data.dart';
import 'package:es3fniforadmin/providers/home.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hawk_fab_menu/hawk_fab_menu.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';

import 'package:url_launcher/url_launcher.dart';

import '../widgets.dart';

class VerifyPatientAccount extends StatefulWidget {
  final UserData? userData;

  VerifyPatientAccount({this.userData});

  @override
  _VerifyPatientAccountState createState() => _VerifyPatientAccountState();
}

class _VerifyPatientAccountState extends State<VerifyPatientAccount> {
  late Home _home;
  
Widget  personalInfo(
      {required String title,
      required String subtitle,
      required DeviceInfo infoWidget,
      IconData? iconData}) {
    return ListTile(
      title: Text(
        title,
        style: infoWidget.titleButton!.copyWith(color: Colors.indigo),
      ),
      leading: Icon(
        iconData,
        color: Colors.indigo,
      ),
      subtitle: Text(
        subtitle,
        style: infoWidget.subTitle!.copyWith(color: Colors.grey[600]),
      ),
    );
  }
  

  @override
  void initState() {
    _home = Provider.of<Home>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InfoWidget(
      builder: (context, infoWidget) {
        return Directionality(
          textDirection: translator.activeLanguageCode =='en'?TextDirection.ltr:TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                '${widget.userData!.name}',
                style: infoWidget.titleButton,
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: InkWell(
                    onTap: () {},
                    child: Center(
                      child: Stack(
                        children: <Widget>[
                          Icon(
                            Icons.notifications,
                            size: infoWidget.orientation == Orientation.portrait
                                ? infoWidget.screenHeight! * 0.04
                                : infoWidget.screenHeight! * 0.07,
                          ),
                          Positioned(
                              right: 2.9,
                              top: 2.8,
                              child: Container(
                                width:
                                    infoWidget.orientation == Orientation.portrait
                                        ? infoWidget.screenWidth! * 0.023
                                        : infoWidget.screenWidth! * 0.014,
                                height:
                                    infoWidget.orientation == Orientation.portrait
                                        ? infoWidget.screenWidth! * 0.023
                                        : infoWidget.screenWidth! * 0.014,
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(5)),
                              ))
                        ],
                      ),
                    ),
                  ),
                )
              ],
              leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size:
                        MediaQuery.of(context).orientation == Orientation.portrait
                            ? MediaQuery.of(context).size.width * 0.05
                            : MediaQuery.of(context).size.width * 0.035,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
            ),
            body:
            HawkFabMenu(
              icon: AnimatedIcons.menu_close,
              fabColor: Colors.indigo,
              iconColor: Colors.white,
              items: [
                HawkFabMenuItem(
                    label: translator.activeLanguageCode == "en" ? 'Accept Acount' : 'قبول الحساب',
                    ontap:() async{
                      bool x =await _home.acceptAccount(id: widget.userData!.docId);
                      if(x){
                        flutterToast(
                                      msg:
                            translator.activeLanguageCode == "en"
                                ? "Successfully accepted"
                                : 'نجح القبول',
                             );
                        Navigator.of(context).pop();
                      }
                    },
                    icon: Icon(Icons.verified_user,color: Colors.white,),
                    color: Colors.indigo,
                    labelColor: Colors.white,
                    labelBackgroundColor: Colors.indigo
                ),
                HawkFabMenuItem(
                    label: translator.activeLanguageCode == "en" ? 'Delete Account' : 'حذف الحساب',
                    ontap:() async{
                      bool x =await _home.deleteAccount(id: widget.userData!.docId);
                      if(x){
                        flutterToast(
                                      msg:
                            translator.activeLanguageCode == "en"
                                ? "Successfully deleted"
                                : 'نجح الحذف',
                             );
                        Navigator.of(context).pop();
                      }
                    },
                    icon: Icon(Icons.clear,color: Colors.white,),
                    color: Colors.indigo,
                    labelColor: Colors.white,
                    labelBackgroundColor: Colors.indigo
                ),
              ],
                 body: ListView(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, left: 2.0, right: 2.0),
                          child: InkWell(
                            onTap: (){
                              if(widget.userData!.imgUrl !='') {
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) =>
                                        ShowImage(
                                          title: translator.activeLanguageCode ==
                                              "en" ? 'personal picture'
                                              : 'الصوره الشخصيه',
                                          imgUrl: widget.userData!.imgUrl,
                                          isImgUrlAsset: false,
                                        )));
                              }
                            },
                            child: Container(
                              height: 140,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  topLeft: Radius.circular(15),
                                ),
                                color: Colors.indigo,
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 160,
                                  height: 130,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.indigo),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: ClipRRect(
                                        //backgroundColor: Colors.white,
                                        //backgroundImage:
                                        borderRadius:
                                            BorderRadius.all(Radius.circular(15)),
                                        child: FadeInImage.assetNetwork(
                                            fit: BoxFit.fill,
                                            placeholder: 'assets/user.png',
                                            image: widget.userData!.imgUrl!)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: infoWidget.screenHeight! * 0.02,
                        ),
                        widget.userData!.name==''?SizedBox():personalInfo(
                            title: translator.activeLanguageCode == "en"
                                ? 'Name'
                                : 'الاسم',
                            subtitle:
                                translator.activeLanguageCode == "en" ? widget.userData!.name! : widget.userData!.name!,
                            iconData: Icons.person,
                            infoWidget: infoWidget),
                        InkWell(
                            onTap: widget.userData!.lat !=''?(){
                              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ShowSpecificUserLocation(userData: widget.userData,)));
                            }:null,
                            child:
                            personalInfo(
                                title: translator.activeLanguageCode == "en"
                                    ? 'Address'
                                    : 'العنوان',
                                subtitle: translator.activeLanguageCode == "en"
                                    ? widget.userData!.address!
                                    : widget.userData!.address!,
                                iconData: Icons.my_location,
                                infoWidget: infoWidget)),
                        widget.userData!.nationalId == ''
                            ? SizedBox()
                            : personalInfo(
                            title: translator.activeLanguageCode == "en"
                                ? 'National Id'
                                : 'الرقم القومى',
                            subtitle:widget.userData!.nationalId!,
                            iconData: Icons.fingerprint,
                            infoWidget: infoWidget),
                        widget.userData!.imgId != ''?ListTile(
                          onTap: (){
                            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ShowImage(
                              title: translator.activeLanguageCode == "en" ? 'Picture for national id'
                                  : 'صوره البطاقه',
                              imgUrl: widget.userData!.imgId,
                              isImgUrlAsset: false,
                            )));
                          },
                          title: Text(
                            translator.activeLanguageCode == "en" ? 'Picture for national id'
                            : 'صوره البطاقه',
                            style:
                            infoWidget.titleButton!.copyWith(color: Colors.indigo),
                          ),
                          leading: Icon(
                            Icons.image,
                            color: Colors.indigo,
                          ),
                          subtitle:   Container(
                            height: infoWidget.screenHeight!*0.30,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.indigo),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ClipRRect(
                                borderRadius:
                                BorderRadius.all(Radius.circular(15)),
                                child: Image.network(widget.userData!.imgId!,fit: BoxFit.fill,)),
                          ),
                        ):SizedBox(),
                        widget.userData!.phoneNumber==''?SizedBox():
                            InkWell(
                              onTap: (){
                                launch("tel://${widget.userData!.phoneNumber}");
                              },
                                child: personalInfo(
                                    title: translator.activeLanguageCode == "en"
                                        ? 'Phone Number'
                                        : 'رقم الهاتف',
                                    subtitle: translator.activeLanguageCode == "en"
                                        ? widget.userData!.phoneNumber!
                                        : widget.userData!.phoneNumber!,
                                    iconData: Icons.phone,
                                    infoWidget: infoWidget),
                            ),
            widget.userData!.birthDate==''?SizedBox():personalInfo(
                  title: translator.activeLanguageCode == "en"
                      ? 'Birth Date'
                      : 'تاريخ الميلاد',
                  subtitle: translator.activeLanguageCode == "en"
                      ? widget.userData!.birthDate!
                      : widget.userData!.birthDate!,
                  iconData: Icons.date_range,
                  infoWidget: infoWidget),
                        widget.userData!.gender==''?SizedBox(): personalInfo(
                            title: translator.activeLanguageCode == "en"
                                ? 'Gender'
                                : 'النوع',
                            subtitle:
                                translator.activeLanguageCode == "en" ? widget.userData!.gender! : widget.userData!.gender!,
                            iconData: Icons.view_agenda,
                            infoWidget: infoWidget),
                        widget.userData!.aboutYou==''?SizedBox(): personalInfo(
                            title: translator.activeLanguageCode == "en"
                                ? 'Another Info'
                                : 'معولمات اخرى',
                            subtitle:
                            translator.activeLanguageCode == "en" ? widget.userData!.aboutYou! : widget.userData!.aboutYou!,
                            iconData: Icons.view_agenda,
                            infoWidget: infoWidget),
                        widget.userData!.points==''?SizedBox():personalInfo(
                            title: translator.activeLanguageCode == "en"
                                ? 'Points'
                                : 'النقاط',
                            subtitle:
                                translator.activeLanguageCode == "en" ? widget.userData!.points! : widget.userData!.points!,
                            iconData: Icons.trip_origin,
                            infoWidget: infoWidget),
                      ],
                    ),
               ),
          ),
        );
      },
    );
  }
}
