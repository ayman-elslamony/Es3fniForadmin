import 'package:admin/core/models/device_info.dart';
import 'package:admin/core/ui_components/info_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class CouponsAndDiscounts extends StatefulWidget {
  @override
  _CouponsAndDiscountsState createState() => _CouponsAndDiscountsState();
}

class _CouponsAndDiscountsState extends State<CouponsAndDiscounts> {
  TextEditingController coupon=TextEditingController();
  TextEditingController discountPercentage=TextEditingController();
  TextEditingController numberOfUses=TextEditingController();
  String _expiryDate='';
  Widget content({String coupon='',String numbersOfUses,String discountPercentage,String expiryDate,DeviceInfo infoWidget}) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        color: Colors.blue[100],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                Text(translator.currentLanguage =='en'?'Coupon: $coupon':'كوبون: $coupon',
                  style: infoWidget.title,)  ,
                Text(translator.currentLanguage =='en'?'discount percentage: $discountPercentage':'نسبه الخصم: $discountPercentage ',
                  style: infoWidget.subTitle,),
                Text(translator.currentLanguage =='en'?'Number of uses: $numbersOfUses':'عدد مرات الاستخدام: $numbersOfUses ',
                  style: infoWidget.subTitle,)  ,
                Text(translator.currentLanguage =='en'?'Expiry date: $expiryDate':'تاريخ الانتهاء: $expiryDate ',
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
              title: Text(translator.currentLanguage == "en"
                  ? "Coupons and discounts"
                  : 'الكوبونات والخصومات',
                style: infoWidget.titleButton,),
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
                  content(infoWidget: infoWidget,coupon: 'sfdg3146',numbersOfUses: '50',discountPercentage: '10',expiryDate: '3/10/2020'),
                  content(infoWidget: infoWidget,coupon:'464fdsfd',numbersOfUses: '50',discountPercentage: '5',expiryDate: '10/10/2020'),
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
                          translator.currentLanguage == "en"
                              ? "Add Coupon"
                              : 'اضافه كوبون',
                          textAlign: TextAlign.center,
                          style: infoWidget.title,
                        ),
                        content: Container(
                          height: infoWidget.screenHeight*0.45,
                          child: Center(
                            child: SingleChildScrollView(
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(height: 60 ,width: MediaQuery.of(context).size.width/0.85,child: TextFormField(
                                        controller: coupon,
                                        decoration: InputDecoration(
                                          labelText: translator.currentLanguage == "en"?'Coupon':'كوبون',
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
                                        controller: discountPercentage,
                                        decoration: InputDecoration(
                                          labelText: translator.currentLanguage == "en"?'discount percentage':'النسبه',
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
                                        keyboardType: TextInputType.number,
                                      ),)
                                  ),
                              Padding(
                              padding: const EdgeInsets.all(8.0),
                          child: Container(height: 60 ,width: MediaQuery.of(context).size.width/0.85,child: TextFormField(
                              controller: numberOfUses,
                              decoration: InputDecoration(
                                labelText: translator.currentLanguage == "en"?'Number of uses':'عدد مرات الاستخدام',
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
                              keyboardType: TextInputType.number,
                          ),)
                      ),
                                  _expiryDate==''?RaisedButton(
                                    onPressed: () {
                                      DatePicker.showDatePicker(context,
                                          showTitleActions: true,
                                          theme: DatePickerTheme(
                                            itemStyle: TextStyle(color: Colors.indigo),
                                            backgroundColor: Colors.white,
                                            headerColor: Colors.white,
                                            doneStyle:
                                            TextStyle(color: Colors.indigoAccent),
                                            cancelStyle:
                                            TextStyle(color: Colors.black87),
                                          ),
                                          minTime: DateTime.now(),
                                          maxTime: DateTime(2080, 6, 7),
                                          onChanged: (_) {}, onConfirm: (date) {
                                            print('confirm $date');
                                            setState(() {
                                              _expiryDate =
                                              '${date.day}-${date.month}-${date.year}';
                                            });
                                          },
                                          currentTime: DateTime.now(),
                                          locale: translator.currentLanguage == "en"
                                              ? LocaleType.en
                                              : LocaleType.ar);
                                    },
                                    color: Colors.indigo,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                    child: Text(
                                      translator.currentLanguage == "en"
                                          ? _expiryDate==''?'Expiry Date':_expiryDate
                                          : _expiryDate==''?'تاريخ الانتهاء':_expiryDate,
                                      style:
                                      TextStyle(color: Colors.white, fontSize: 18),
                                    ),
                                  ):
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        translator.currentLanguage == "en"
                                           ?'Expiry Date:  '
                                            : 'تاريخ الانتهاء:  ',
                                        style:
                                        infoWidget.subTitle.copyWith(color: Colors.indigo),
                                      ),
                                      RaisedButton(
                                        onPressed: () {
                                          DatePicker.showDatePicker(context,
                                              showTitleActions: true,
                                              theme: DatePickerTheme(
                                                itemStyle: TextStyle(color: Colors.indigo),
                                                backgroundColor: Colors.white,
                                                headerColor: Colors.white,
                                                doneStyle:
                                                TextStyle(color: Colors.indigoAccent),
                                                cancelStyle:
                                                TextStyle(color: Colors.black87),
                                              ),
                                              minTime: DateTime.now(),
                                              maxTime: DateTime(2080, 6, 7),
                                              onChanged: (_) {}, onConfirm: (date) {
                                                print('confirm $date');
                                                setState(() {
                                                  _expiryDate =
                                                  '${date.day}-${date.month}-${date.year}';
                                                });
                                              },
                                              currentTime: DateTime.now(),
                                              locale: translator.currentLanguage == "en"
                                                  ? LocaleType.en
                                                  : LocaleType.ar);
                                        },
                                        color: Colors.indigo,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10)),
                                        child: Text(
                                          translator.currentLanguage == "en"
                                              ? _expiryDate==''?'Expiry Date':_expiryDate
                                              : _expiryDate==''?'تاريخ الانتهاء':_expiryDate,
                                          style:
                                          infoWidget.titleButton,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
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
