import 'package:es3fniforadmin/core/models/device_info.dart';
import 'package:es3fniforadmin/core/ui_components/info_widget.dart';
import 'package:es3fniforadmin/models/service.dart';
import 'package:es3fniforadmin/providers/auth.dart';
import 'package:es3fniforadmin/providers/home.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../widgets.dart';


class ServicesAndPrices extends StatefulWidget {
  @override
  _ServicesAndPricesState createState() => _ServicesAndPricesState();
}

class _ServicesAndPricesState extends State<ServicesAndPrices> {
  TextEditingController serviceName = TextEditingController();
  TextEditingController priceService = TextEditingController();
  late Home _home;
  bool loadingBody = true;
  bool isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey();

  Widget content({required Service service, required DeviceInfo infoWidget}) {
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
                    translator.activeLanguageCode == 'en'
                        ? 'Service Type: ${service.serviceName}'
                        : 'نوع الخدمه: ${service.serviceName}',
                    style: infoWidget.title,
                  ),
                  Text(
                    translator.activeLanguageCode == 'en'
                        ? 'Price: ${service.price} EGP'
                        : 'السعر: ${service.price} جنيه ',
                    style: infoWidget.subTitle,
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  service.loading ?Center(child:const CircularProgressIndicator(color:  Colors.indigo,)):RaisedButton(
                    onPressed: () async{
                     setState(() {
                       service.loading = true;
                     });
                      bool x =await  _home.deleteService(serviceId: service.id);
                    if(x){
                      flutterToast(
                                      msg:
                          translator.activeLanguageCode == "en"
                              ? "successfully deleted"
                              : 'نجح الحذف',
                           );
                    }else{
                      flutterToast(
                                      msg:
                          translator.activeLanguageCode == "en"
                              ? "try again later"
                              : 'حاول مره اخرى',
                           );
                    }
                     setState(() {
                       service.loading = false;
                     });
                     },
                    child: Text(
                      translator.activeLanguageCode == 'en' ? 'delete' : 'حذف',
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

  addServices() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isLoading = true;
      });
      String auth = await _home.addServices(
          serviceName: serviceName.text.trim(),
          price: priceService.text.trim());
      print('welcome');
      if (auth == 'scuess') {
        flutterToast(
                                      msg:
            translator.activeLanguageCode == "en"
                ? "successfully Added"
                : 'نجحت الاضافه',
             );
        Navigator.of(context).pop();
        setState(() {
          isLoading = false;
        });
      }
      if(auth == 'not valid'){
        flutterToast(
                                      msg:
            translator.activeLanguageCode == "en"
                ? "Already exists"
                : 'موجود بالفعل',
             );
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  getAllServices() async {
    if(_home.allService.length ==0){
      await _home.getAllServices();
    }
    setState(() {
      loadingBody = false;
    });
  }

  @override
  void initState() {
    _home = Provider.of<Home>(context, listen: false);
    getAllServices();
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
            onRefresh: ()async{
              await _home.getAllServices();
            },
            child: Scaffold(

              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  translator.activeLanguageCode == "en"
                      ? "Services and prices"
                      : 'الخدمات والاسعار',
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
                              height: infoWidget.screenHeight! *0.15,
                            ),
                          ),
                        ),
                        itemCount: 5,
                      ),
                  )
                  : Consumer<Home>(
                      builder: (context, data, _) {
                        if (data.allService.length == 0) {
                          return Center(
                            child: Text(
                              translator.activeLanguageCode == "en"
                                  ? 'there is no any services'
                                  : 'لا يوجد خدمات',
                              style: infoWidget.titleButton!
                                  .copyWith(color: Colors.indigo),
                            ),
                          );
                        } else {
                          return ListView.builder(
                              itemCount: data.allService.length,
                              itemBuilder: (context, index) => content(
                                  infoWidget: infoWidget,
                                 service: data.allService[index]));
                        }
                      },
                    ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (ctx) => Directionality(
                            textDirection: translator.activeLanguageCode == "en"
                                ? TextDirection.ltr
                                : TextDirection.rtl,
                            child: StatefulBuilder(
                              builder: (context, setState) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25.0))),
                                contentPadding: EdgeInsets.only(top: 10.0),
                                title: Text(
                                  translator.activeLanguageCode == "en"
                                      ? 'add service'
                                      : 'اضافه خدمه',
                                  textAlign: TextAlign.center,
                                  style: infoWidget.title,
                                ),
                                content: Container(
                                  height: infoWidget.screenHeight! * 0.25,
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
                                                  controller: serviceName,
                                                  decoration: InputDecoration(
                                                    labelText: translator
                                                                .activeLanguageCode ==
                                                            "en"
                                                        ? 'service name'
                                                        : 'اسم الخدمه',
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
                                                    if (val!.isEmpty) {
                                                      return translator
                                                                  .activeLanguageCode ==
                                                              "en"
                                                          ? 'Invalid service'
                                                          : 'لايوجد خدمه';
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
                                                  controller: priceService,
                                                  decoration: InputDecoration(
                                                      labelText: translator
                                                                  .activeLanguageCode ==
                                                              "en"
                                                          ? 'service price'
                                                          : 'سعر الخدمه',
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
                                                                  .activeLanguageCode ==
                                                              "en"
                                                          ? '50 EGP'
                                                          : '50 جنيه'),
                                                  // ignore: missing_return
                                                  validator: (val) {
                                                    if (val!.isEmpty) {
                                                      return translator
                                                                  .activeLanguageCode ==
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
                                      translator.activeLanguageCode == "en"
                                          ? 'Cancel'
                                          : 'الغاء',
                                      style: infoWidget.subTitle!
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
                                            const CircularProgressIndicator(color:  Colors.indigo,)
                                          ],
                                        )
                                      : FlatButton(
                                          child: Text(
                                            translator.activeLanguageCode == "en"
                                                ? 'Add'
                                                : 'اضافه',
                                            style: infoWidget.subTitle!
                                                .copyWith(color: Colors.indigo),
                                          ),
                                          onPressed: addServices,
                                        )
                                ],
                              ),
                            ),
                          ));
                },
                tooltip: translator.activeLanguageCode == "en" ? 'add' : 'اضافه',
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
