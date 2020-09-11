import 'package:admin/core/models/device_info.dart';
import 'package:admin/core/ui_components/info_widget.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'add_paramedics_request.dart';

class ParamedicsRequests extends StatefulWidget {
  @override
  _ParamedicsRequestsState createState() => _ParamedicsRequestsState();
}

class _ParamedicsRequestsState extends State<ParamedicsRequests> {


  Widget content({String type='',String price,DeviceInfo infoWidget}){
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
                  style: infoWidget.subTitle,)
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
  Widget  rowWidget({String title,String content,DeviceInfo infoWidget}){
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(title,style: infoWidget.titleButton.copyWith(color: Colors.indigo),
            ),
            Text(content,style: infoWidget.subTitle,
            ),
          ],
        ) ,SizedBox(height: 5,),
      ],
    );
    }
  @override
  Widget build(BuildContext context) {
    return InfoWidget(
      builder: (context,infoWidget)=>Scaffold(
        body: SingleChildScrollView(
          child: Column(
            textDirection: translator.currentLanguage == "en" ?TextDirection.ltr:TextDirection.rtl,
            children: <Widget>[
              InkWell(onTap: (){
                showModalBottomSheet(
                    context: context ,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(10),topLeft: Radius.circular(10))),
                    builder: (context){
                      return Padding(
                        padding: const EdgeInsets.only(left:15 , right: 15),
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: ListView(
                            children: <Widget>[
                              SizedBox(height: 20,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  SizedBox(),
                                  Text('البيانات بالكامل' , style: infoWidget.titleButton.copyWith(color: Colors.indigo) ,),
                                  IconButton(icon: Icon(Icons.edit,color: Colors.indigo,), onPressed: (){})
                                ],
                              ),
                              SizedBox(height: 10,),

                                rowWidget(infoWidget: infoWidget,title: translator.currentLanguage == "en"?'service type: ':'نوع الخدمه: ',content: 'حقنه')
                              ,rowWidget(infoWidget: infoWidget,title: translator.currentLanguage == "en"?'price: ':'السعر: ',content: '20')
                            ],
                          ),
                        ),
                      );
                    }
                );
              },child: content(infoWidget: infoWidget,type: 'حقنه',price: '20')),
              content(infoWidget: infoWidget,type:'كسترا',price: '15'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>AddParamedicsRequest()));
          },
          tooltip: translator.currentLanguage == "en"?'add':'اضافه',
          child: Icon(Icons.add,color: Colors.white,),
          backgroundColor: Colors.indigo,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      )
    );
  }
}
