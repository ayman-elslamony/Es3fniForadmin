import 'package:es3fniforadmin/core/models/device_info.dart';
import 'package:es3fniforadmin/core/ui_components/info_widget.dart';
import 'package:es3fniforadmin/models/supplying.dart';
import 'package:es3fniforadmin/models/user_data.dart';
import 'package:es3fniforadmin/providers/home.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';


class SpecificNursesSupplies extends StatefulWidget {
  final UserData? userData;

  SpecificNursesSupplies({this.userData});

  @override
  _SpecificNursesSuppliesState createState() => _SpecificNursesSuppliesState();
}

class _SpecificNursesSuppliesState extends State<SpecificNursesSupplies> {
  late Home _home;
  bool loadingBody = true;
  Widget content({Supplying? supplying, required DeviceInfo infoWidget}) {
    return Padding(
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
                        ? 'Num of points: ${supplying!.points}'
                        : 'عدد النقاط: ${supplying!.points}',
                    style: infoWidget.title,
                  ),
                  Text(
                    translator.activeLanguageCode == 'en'
                        ? 'Date: ${supplying.date}'
                        : 'تاريخ: ${supplying.date} ',
                    style: infoWidget.subTitle,
                  ),
                  Text(
                    translator.activeLanguageCode == 'en'
                        ? 'Time: ${supplying.time}'
                        : 'الوقت: ${supplying.time} ',
                    style: infoWidget.subTitle,
                  ),
                ],
              ),
              SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
  getSpecificNurseSupplies() async {
    if (_home.allSpecificNurseSupplies.length == 0) {
      await _home.getSpecificNurseSupplies(nurseId: widget.userData!.docId);
    }
    setState(() {
      loadingBody = false;
    });
  }

  @override
  void initState() {
    _home = Provider.of<Home>(context, listen: false);
    getSpecificNurseSupplies();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InfoWidget(
      builder: (context, infoWidget) {
        return Directionality(
          textDirection: translator.activeLanguageCode == "en"
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: RefreshIndicator(
            color: Colors.indigo,
            backgroundColor: Colors.white,
            onRefresh: () async {
              await _home.getSpecificNurseSupplies(nurseId: widget.userData!.docId);
            },
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  "${widget.userData!.name}"
                     ,
                  style: infoWidget.titleButton,
                ),
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 18, left: 10, right: 10),
                    child: Consumer<Home>(
                      builder: (context, data, _) => Text(
                        widget.userData!.points!,
                        style: infoWidget.titleButton,
                      ),
                    ),
                  ),
                ],
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
                        height: infoWidget.screenHeight! * 0.15,
                      ),
                    ),
                  ),
                  itemCount: 5,
                ),
              )
                  : Consumer<Home>(
                builder: (context, data, _) {
                  if (data.allSpecificNurseSupplies.length == 0) {
                    return Center(
                      child: Text(
                        translator.activeLanguageCode == "en"
                            ? 'there is no any supplies'
                            : 'لا يوجد توريدات',
                        style: infoWidget.titleButton!
                            .copyWith(color: Colors.indigo),
                      ),
                    );
                  } else {
                    return ListView.builder(
                        itemCount: data.allSpecificNurseSupplies.length,
                        itemBuilder: (context, index) => content(
                            infoWidget: infoWidget,
                            supplying: data.allSpecificNurseSupplies[index]));
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
