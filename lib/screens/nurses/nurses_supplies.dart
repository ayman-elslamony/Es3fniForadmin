import 'package:admin/core/models/device_info.dart';
import 'package:admin/core/ui_components/info_widget.dart';
import 'package:admin/models/user_data.dart';
import 'package:admin/providers/auth.dart';
import 'package:admin/providers/home.dart';
import 'package:admin/screens/nurses/specific_nurse_supplies.dart';
import 'package:admin/screens/user_profile/edit_user_data/edit_user_data.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toast/toast.dart';

class NursesSupplies extends StatefulWidget {
  @override
  _NursesSuppliesState createState() => _NursesSuppliesState();
}

class _NursesSuppliesState extends State<NursesSupplies> {
  Home _home;
  Auth _auth;
  bool loadingBody = true;
  Widget content({UserData userData, DeviceInfo infoWidget}) {
    return InkWell(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => EditProfile(userData: userData,)));
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        translator.currentLanguage == 'en'
                            ? 'Paramedic: ${userData.name}'
                            : 'مسعف: ${userData.name}',
                        style: infoWidget.title,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              translator.currentLanguage == 'en'
                                  ? 'Number of points that need to supplying: ${userData.points}'
                                  : 'عدد النقاط التى تحتاج الى توريد: ${userData.points} ',
                              style: infoWidget.subTitle,
                            ),
                          ),
                         userData.points!='0'?Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: RaisedButton(
                              onPressed:  userData.points!='0'?() async {
                                setState(() {
                                  userData.loading = true;
                                });
                                bool x = await _home.nurseSupplying(
                                  adminId: _auth.userId,
                                    points: _auth.points,
                                    nurseId: userData.docId);
                                if (x) {
                                  Toast.show(
                                      translator.currentLanguage == "en"
                                          ? "Successfully applying"
                                          : 'نجح التوريد',
                                      context,
                                      duration: Toast.LENGTH_SHORT,
                                      gravity: Toast.BOTTOM);
                                } else {
                                  Toast.show(
                                      translator.currentLanguage == "en"
                                          ? "try again later"
                                          : 'حاول مره اخرى',
                                      context,
                                      duration: Toast.LENGTH_SHORT,
                                      gravity: Toast.BOTTOM);
                                }
                                setState(() {
                                 userData.loading = false;
                                });
                              }:null,
                              padding: EdgeInsets.all(0.0),
                              child: Text(
                                translator.currentLanguage == 'en'
                                    ? 'Supplying'
                                    : 'توريد',
                                style: infoWidget.titleButton.copyWith(color: Colors.indigo),
                              ),
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.indigo)),
                            ),
                          ):SizedBox()
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: <Widget>[
                    userData.loading
                        ? Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.indigo,
                        ))
                        : IconButton(
                      onPressed: () async {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) => SpecificNursesSupplies(userData: userData,)));
                      },
                      color: Colors.indigo,
                    icon: Icon(Icons.arrow_forward_ios),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  getAllNursesSupplies() async {
    if (_home.allNursesSupplies.length == 0) {
      await _home.getAllNursesSupplies();
    }
    setState(() {
      loadingBody = false;
    });
  }

  @override
  void initState() {
    _auth = Provider.of<Auth>(context, listen: false);
    _home = Provider.of<Home>(context, listen: false);
    getAllNursesSupplies();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InfoWidget(
      builder: (context, infoWidget) {
        return Directionality(
          textDirection: translator.currentLanguage == "en"
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: RefreshIndicator(
            color: Colors.indigo,
            backgroundColor: Colors.white,
            onRefresh: () async {
              await _home.getAllNursesSupplies();
            },
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  translator.currentLanguage == "en"
                      ? "Nurses Supplies"
                      : 'توريدات المسعفين',
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
                          ? infoWidget.screenWidth * 0.05
                          : infoWidget.screenWidth * 0.035,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
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
                        height: infoWidget.screenHeight * 0.15,
                      ),
                    ),
                  ),
                  itemCount: 5,
                ),
              )
                  : Consumer<Home>(
                builder: (context, data, _) {
                  if (data.allNursesSupplies.length == 0) {
                    return Center(
                      child: Text(
                        translator.currentLanguage == "en"
                            ? 'there is no any supplies'
                            : 'لا يوجد توريدات',
                        style: infoWidget.titleButton
                            .copyWith(color: Colors.indigo),
                      ),
                    );
                  } else {
                    return ListView.builder(
                        itemCount: data.allNursesSupplies.length,
                        itemBuilder: (context, index) => content(
                            infoWidget: infoWidget,
                            userData: data.allNursesSupplies[index]));
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
