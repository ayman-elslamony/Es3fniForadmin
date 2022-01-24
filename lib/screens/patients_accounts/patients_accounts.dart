import 'package:es3fniforadmin/core/models/device_info.dart';
import 'package:es3fniforadmin/core/ui_components/info_widget.dart';
import 'package:es3fniforadmin/models/user_data.dart';
import 'package:es3fniforadmin/providers/home.dart';
import 'package:es3fniforadmin/screens/patients_accounts/verify_patient_account.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class PatientsAccounts extends StatefulWidget {
  @override
  _PatientsAccountsState createState() => _PatientsAccountsState();
}

class _PatientsAccountsState extends State<PatientsAccounts> {
  late Home _home;
  bool loadingBody = false;
  List<UserData> patientAccountsThatToVerify=[];
  Widget content({UserData? userData, required DeviceInfo infoWidget}) {
    return InkWell(
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>VerifyPatientAccount(userData: userData,)));
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Container(
          color: Colors.blue[100],
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      translator.activeLanguageCode == 'en'
                          ? 'Patient Name: ${userData!.name}'
                          : 'اسم المريض: ${userData!.name}',
                      style: infoWidget.title,
                    ),
                    Text(
                      translator.activeLanguageCode == 'en'
                          ? 'Date: ${userData.date}'
                          : 'تاريخ: ${userData.date} ',
                      style: infoWidget.subTitle,
                    ),
                    Text(
                      translator.activeLanguageCode == 'en'
                          ? 'Time: ${userData.time}'
                          : 'الوقت: ${userData.time} ',
                      style: infoWidget.subTitle,
                    ),
                  ],
                ),
                SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getPatientAccountsThatToVerify() async {
    if (_home.patientAccountsThatToVerify.length == 0) {
      setState(() {
        loadingBody = true;
      });
      await _home.getPatientAccountsThatToVerify();
      setState(() {
        loadingBody = false;
      });
    }

  }

  @override
  void initState() {
    _home = Provider.of<Home>(context, listen: false);
    getPatientAccountsThatToVerify();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InfoWidget(
      builder: (context, infoWidget) {
        return SafeArea(
          child: Directionality(
            textDirection: translator.activeLanguageCode == "en"
                ? TextDirection.ltr
                : TextDirection.rtl,
            child: RefreshIndicator(
              color: Colors.indigo,
              backgroundColor: Colors.white,
              onRefresh: () async {
                await _home.getAllParamedics();
              },
              child: Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: Text(
                    translator.activeLanguageCode == "en"
                        ? "Patient accounts"
                        : 'حسابات المرضي',
                    style: infoWidget.titleButton,
                  ),
                  shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40))),
                  leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        size: infoWidget.orientation == Orientation.portrait
                            ? infoWidget.screenWidth! * 0.05
                            : infoWidget.screenWidth! * 0.035,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                ),
                body:

                loadingBody
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
                          height: infoWidget.screenHeight! * 0.15,
                        ),
                      ),
                    ),
                    itemCount: 5,
                  ),
                )
                    : Consumer<Home>(
                  builder: (context, data, _) {
                    if (data.patientAccountsThatToVerify.length == 0) {
                      return Center(
                        child: Text(
                          translator.activeLanguageCode == "en"
                              ? 'there is no any requests'
                              : 'لا يوجد طلبات للقبول',
                          style: infoWidget.titleButton!
                              .copyWith(color: Colors.indigo),
                        ),
                      );
                    } else {
                      return ListView.builder(
                          itemCount: data.patientAccountsThatToVerify.length,
                          itemBuilder: (context, index) => content(
                              infoWidget: infoWidget,
                              userData: data.patientAccountsThatToVerify[index]));
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
