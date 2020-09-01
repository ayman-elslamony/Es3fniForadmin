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

  @override
  Widget build(BuildContext context) {
    return InfoWidget(
      builder: (context,infoWidget)=>Scaffold(
        body: SingleChildScrollView(
          child: Column(
            textDirection: translator.currentLanguage == "en" ?TextDirection.ltr:TextDirection.rtl,
            children: <Widget>[
              content(infoWidget: infoWidget,type: 'حقنه',price: '20'),
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
