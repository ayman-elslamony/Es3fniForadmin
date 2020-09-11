import 'package:admin/core/models/device_info.dart';
import 'package:admin/core/ui_components/info_widget.dart';
import 'package:admin/screens/user_profile/show_profile.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class Paramedics extends StatefulWidget {
  @override
  _ParamedicsState createState() => _ParamedicsState();
}

class _ParamedicsState extends State<Paramedics> {
  TextEditingController paramedicName=TextEditingController();
  TextEditingController password=TextEditingController();
  Widget content({String paramedicName='',String numberOfPoints,DeviceInfo infoWidget}) {
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
                Text(translator.currentLanguage =='en'?'Paramedic: $paramedicName':'مسعف: $paramedicName',
                  style: infoWidget.title,)  ,
                Text(translator.currentLanguage =='en'?'Number of points: $numberOfPoints':'عدد النقاط: $numberOfPoints ',
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
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  InkWell(
                  onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ShowUserProfile(

                      )));
                  }
                  ,child: content(infoWidget: infoWidget,paramedicName: 'احمد ابراهيم',numberOfPoints: '50')),
                  content(infoWidget: infoWidget,paramedicName:'محمد محمود',numberOfPoints: '50'),
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
                          translator.currentLanguage == "en"?'add Paramedic':'اضافه مسعف',
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
                                      controller: paramedicName,
                                      decoration: InputDecoration(
                                        labelText: translator.currentLanguage == "en"?'Paramedic name':'اسم المسعف',
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
                                      controller: password,
                                      decoration: InputDecoration(
                                        labelText: translator.currentLanguage == "en"?'Password':'كلمه المرور',
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
