import 'package:admin/core/models/device_info.dart';
import 'package:admin/core/ui_components/info_widget.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ServicesAndPrices extends StatefulWidget {
  @override
  _ServicesAndPricesState createState() => _ServicesAndPricesState();
}

class _ServicesAndPricesState extends State<ServicesAndPrices> {
  TextEditingController serviceName=TextEditingController();
  TextEditingController priceService=TextEditingController();
  Widget content({String type='',String price,DeviceInfo infoWidget}) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        color: Colors.blue[100],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(children: <Widget>[
                Text(translator.currentLanguage =='en'?'Service Type: $type':'نوع الخدمه: $type',
                  style: infoWidget.title,)  ,
                Text(translator.currentLanguage =='en'?'Price: $price EGP':'السعر: $price جنيه ',
                  style: infoWidget.subTitle,)  ,
              ],),
              Column(children: <Widget>[
                RaisedButton(onPressed: (){},
                  child: Text(translator.currentLanguage =='en'?'delete':'حذف',
                    style: infoWidget.titleButton,),color: Colors.indigo,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),)
              ],)
            ],
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return InfoWidget(
      builder: (context,infoWidget){
        return Directionality(
          textDirection: translator.currentLanguage == "en"?TextDirection.ltr:TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(translator.currentLanguage == "en"?'Services And Prices':'اسعار وخدمات', style: infoWidget.titleButton,),
              leading: BackButton(
                color: Colors.white,
                onPressed: (){
                  Navigator.of(context).pop();
                },
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
                            size: infoWidget.orientation==Orientation.portrait?infoWidget.screenHeight * 0.04:infoWidget.screenHeight * 0.07,
                          ),
                          Positioned(
                              right: 2.9,
                              top: 2.8,
                              child: Container(
                                width: infoWidget.orientation==Orientation.portrait?infoWidget.screenWidth * 0.023:infoWidget.screenWidth * 0.014,
                                height: infoWidget.orientation==Orientation.portrait?infoWidget.screenWidth * 0.023:infoWidget.screenWidth* 0.014,
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
              shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  content(infoWidget: infoWidget,type: 'حقنه',price: '50'),
                  content(infoWidget: infoWidget,type:'كسترا',price: '50'),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: (){
                showDialog(
                    context: context,
                    builder: (ctx) => Directionality(
                      textDirection: translator.currentLanguage == "en"?TextDirection.ltr:TextDirection.rtl,
                      child: AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25.0))),
                        contentPadding: EdgeInsets.only(top: 10.0),
                        title: Text(
                          translator.currentLanguage == "en"?'add service':'اضافه خدمه',
                          textAlign: TextAlign.center,
                          style: infoWidget.title,
                        ),
                        content: Container(
                          height: infoWidget.screenHeight*0.25,
                          child: Center(
                            child: Column(
                              children: <Widget>[
                                Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(height: 60 ,width: MediaQuery.of(context).size.width/0.85,child: TextFormField(
                                      controller: serviceName,
                                      decoration: InputDecoration(
                                        labelText: translator.currentLanguage == "en"?'service name':'اسم الخدمه',
                                        labelStyle: TextStyle(color: Colors.indigo),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                          borderSide: BorderSide(
                                            color: Colors.indigo,
                                          ),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                          borderSide: BorderSide(
                                            color: Colors.indigo,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                          borderSide: BorderSide(color: Colors.indigo),
                                        ),
                                      ),
                                      keyboardType: TextInputType.text,
                                    ),)
                                ) ,
                                Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(height: 60 ,width: MediaQuery.of(context).size.width/0.85,child: TextFormField(
                                      controller: priceService,
                                      decoration: InputDecoration(
                                        labelText: translator.currentLanguage == "en"?'service price':'سعر الخدمه',
                                        labelStyle: TextStyle(color: Colors.indigo),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                          borderSide: BorderSide(
                                            color: Colors.indigo,
                                          ),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                          borderSide: BorderSide(
                                            color: Colors.indigo,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                          borderSide: BorderSide(color: Colors.indigo),
                                        ),
                                      ),
                                      keyboardType: TextInputType.text,
                                    ),)
                                )
                                //,Text('this is Your location',style: TextStyle(fontSize: 18,color: Colors.blue),),
                              ],
                            ),
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text(translator.currentLanguage == "en"?'Cancel':'الغاء',style: infoWidget.subTitle.copyWith(color: Colors.indigo),),
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                          ),
                          FlatButton(
                            child: Text(translator.currentLanguage == "en"?'Add':'اضافه',style: infoWidget.subTitle.copyWith(color: Colors.indigo),),
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              Navigator.of(ctx).pop();
                            },
                          )
                        ],
                      ),
                    ));
              },
              tooltip: translator.currentLanguage == "en"?'add':'اضافه',
              child: Icon(Icons.add,color: Colors.white,),
              backgroundColor: Colors.indigo,
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          ),
        );
      },
    );
  }
}
