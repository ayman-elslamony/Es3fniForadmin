import 'package:admin/core/models/device_info.dart';
import 'package:admin/core/ui_components/info_widget.dart';
import 'package:admin/models/analysis.dart';
import 'package:admin/models/service.dart';
import 'package:admin/providers/auth.dart';
import 'package:admin/providers/home.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toast/toast.dart';

class Analysiss extends StatefulWidget {
  @override
  _AnalysissState createState() => _AnalysissState();
}

class _AnalysissState extends State<Analysiss> {
  TextEditingController analysisName = TextEditingController();
  TextEditingController analysisPrice = TextEditingController();
  Home _home;
  bool loadingBody = true;
  bool isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey();

  Widget content({Analysis analysis, DeviceInfo infoWidget}) {
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
                children: <Widget>[
                  Text(
                    translator.currentLanguage == 'en'
                        ? 'Analysis Type: ${analysis.analysisName}'
                        : 'نوع التحليل: ${analysis.analysisName}',
                    style: infoWidget.title,
                  ),
                  Text(
                    translator.currentLanguage == 'en'
                        ? 'Price: ${analysis.price} EGP'
                        : 'السعر: ${analysis.price} جنيه ',
                    style: infoWidget.subTitle,
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  analysis.loading ?Center(child: CircularProgressIndicator(backgroundColor: Colors.indigo,)):RaisedButton(
                    onPressed: () async{
                     setState(() {
                       analysis.loading = true;
                     });
                      bool x =await  _home.deleteAnalysis(analysisId: analysis.id);
                    if(x){
                      Toast.show(
                          translator.currentLanguage == "en"
                              ? "successfully deleted"
                              : 'نجح الحذف',
                          context,
                          duration: Toast.LENGTH_SHORT,
                          gravity: Toast.BOTTOM);
                    }else{
                      Toast.show(
                          translator.currentLanguage == "en"
                              ? "try again later"
                              : 'حاول مره اخرى',
                          context,
                          duration: Toast.LENGTH_SHORT,
                          gravity: Toast.BOTTOM);
                    }
                     setState(() {
                       analysis.loading = false;
                     });
                     },
                    child: Text(
                      translator.currentLanguage == 'en' ? 'delete' : 'حذف',
                      style: infoWidget.titleButton,
                    ),
                    color: Colors.indigo,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  addAnalysis() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        isLoading = true;
      });
      String auth = await _home.addAnalysis(
          analysisName: analysisName.text.trim(),
          price: analysisPrice.text.trim());
      print('welcome');
      if (auth == 'scuess') {
        Toast.show(
            translator.currentLanguage == "en"
                ? "successfully Added"
                : 'نجحت الاضافه',
            context,
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.BOTTOM);
        Navigator.of(context).pop();
        setState(() {
          isLoading = false;
        });
      }
      if(auth == 'not valid'){
        Toast.show(
            translator.currentLanguage == "en"
                ? "Already exists"
                : 'موجود بالفعل',
            context,
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.BOTTOM);
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  getAllAnalysis() async {
    if(_home.allAnalysis.length ==0){
      await _home.getAllAnalysis();
    }
    setState(() {
      loadingBody = false;
    });
  }

  @override
  void initState() {
    _home = Provider.of<Home>(context, listen: false);
    getAllAnalysis();
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
            onRefresh: ()async{
              await _home.getAllAnalysis();
            },
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  translator.currentLanguage == "en"
                      ? 'Medical tests'
                      : 'التحاليل الطبيه',
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
                              height: infoWidget.screenHeight *0.15,
                            ),
                          ),
                        ),
                        itemCount: 5,
                      ),
                  )
                  : Consumer<Home>(
                      builder: (context, data, _) {
                        if (data.allAnalysis.length == 0) {
                          return Center(
                            child: Text(
                              translator.currentLanguage == "en"
                                  ? 'there is no any Analysis'
                                  : 'لا يوجد تحاليل',
                              style: infoWidget.titleButton
                                  .copyWith(color: Colors.indigo),
                            ),
                          );
                        } else {
                          return ListView.builder(
                              itemCount: data.allAnalysis.length,
                              itemBuilder: (context, index) => content(
                                  infoWidget: infoWidget,
                                 analysis: data.allAnalysis[index]));
                        }
                      },
                    ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (ctx) => Directionality(
                            textDirection: translator.currentLanguage == "en"
                                ? TextDirection.ltr
                                : TextDirection.rtl,
                            child: StatefulBuilder(
                              builder: (context, setState) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25.0))),
                                contentPadding: EdgeInsets.only(top: 10.0),
                                title: Text(
                                  translator.currentLanguage == "en"
                                      ? 'add analysis'
                                      : 'اضافه تحليل',
                                  textAlign: TextAlign.center,
                                  style: infoWidget.title,
                                ),
                                content: Container(
                                  height: infoWidget.screenHeight * 0.25,
                                  child: Center(
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                height: 60,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    0.85,
                                                child: TextFormField(
                                                  controller: analysisName,
                                                  decoration: InputDecoration(
                                                    labelText: translator
                                                                .currentLanguage ==
                                                            "en"
                                                        ? 'analysis name'
                                                        : 'اسم التحليل',
                                                    labelStyle: TextStyle(
                                                        color: Colors.indigo),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0)),
                                                      borderSide: BorderSide(
                                                        color: Colors.indigo,
                                                      ),
                                                    ),
                                                    disabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0)),
                                                      borderSide: BorderSide(
                                                        color: Colors.indigo,
                                                      ),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0)),
                                                      borderSide: BorderSide(
                                                          color: Colors.indigo),
                                                    ),
                                                  ),
                                                  // ignore: missing_return
                                                  validator: (val) {
                                                    if (val.isEmpty) {
                                                      return translator
                                                                  .currentLanguage ==
                                                              "en"
                                                          ? 'Invalid analysis'
                                                          : 'لايوجد تحليل';
                                                    }
                                                  },
                                                  keyboardType:
                                                      TextInputType.text,
                                                ),
                                              )),
                                          Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                height: 60,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    0.85,
                                                child: TextFormField(
                                                  controller: analysisPrice,
                                                  decoration: InputDecoration(
                                                      labelText: translator
                                                                  .currentLanguage ==
                                                              "en"
                                                          ? 'Analysis price'
                                                          : 'سعر التحليل',
                                                      labelStyle: TextStyle(
                                                          color: Colors.indigo),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10.0)),
                                                        borderSide: BorderSide(
                                                          color: Colors.indigo,
                                                        ),
                                                      ),
                                                      disabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10.0)),
                                                        borderSide: BorderSide(
                                                          color: Colors.indigo,
                                                        ),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10.0)),
                                                        borderSide: BorderSide(
                                                            color: Colors.indigo),
                                                      ),
                                                      hintText: translator
                                                                  .currentLanguage ==
                                                              "en"
                                                          ? '50 EGP'
                                                          : '50 جنيه'),
                                                  // ignore: missing_return
                                                  validator: (val) {
                                                    if (val.isEmpty) {
                                                      return translator
                                                                  .currentLanguage ==
                                                              "en"
                                                          ? 'Invalid price'
                                                          : 'السعر غير متاح';
                                                    }
                                                  },
                                                  keyboardType:
                                                      TextInputType.number,
                                                ),
                                              ))
                                          //,Text('this is Your location',style: TextStyle(fontSize: 18,color: Colors.blue),),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text(
                                      translator.currentLanguage == "en"
                                          ? 'Cancel'
                                          : 'الغاء',
                                      style: infoWidget.subTitle
                                          .copyWith(color: Colors.indigo),
                                    ),
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                  isLoading
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            CircularProgressIndicator(
                                              backgroundColor: Colors.indigo,
                                            )
                                          ],
                                        )
                                      : FlatButton(
                                          child: Text(
                                            translator.currentLanguage == "en"
                                                ? 'Add'
                                                : 'اضافه',
                                            style: infoWidget.subTitle
                                                .copyWith(color: Colors.indigo),
                                          ),
                                          onPressed: addAnalysis,
                                        )
                                ],
                              ),
                            ),
                          ));
                },
                tooltip: translator.currentLanguage == "en" ? 'add' : 'اضافه',
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                backgroundColor: Colors.indigo,
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            ),
          ),
        );
      },
    );
  }
}
