import 'package:admin/core/models/device_info.dart';
import 'package:admin/core/ui_components/info_widget.dart';
import 'package:admin/models/coupon.dart';
import 'package:admin/providers/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:toast/toast.dart';

class CouponsAndDiscounts extends StatefulWidget {
  @override
  _CouponsAndDiscountsState createState() => _CouponsAndDiscountsState();
}

class _CouponsAndDiscountsState extends State<CouponsAndDiscounts> {
  TextEditingController coupon=TextEditingController();
  TextEditingController discountPercentage=TextEditingController();
  TextEditingController numberOfUses=TextEditingController();
  String _expiryDate='';
  Home _home;
  bool loadingBody = true;
  bool isLoading= false;
  final GlobalKey<FormState> _formKey = GlobalKey();
  addCoupon() async {
    if (_formKey.currentState.validate() && _expiryDate !='') {
      _formKey.currentState.save();
      setState(() {
        isLoading = true;
      });
      String auth = await _home.addCoupon(
          couponName: coupon.text.trim(),
          discountPercentage: discountPercentage.text.trim(),
      numberOfUses:numberOfUses.text.trim(),
      expiryDate: _expiryDate
      );
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
  Widget content({Coupon coupon,DeviceInfo infoWidget}) {
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
                Text(translator.currentLanguage =='en'?'Coupon: ${coupon.couponName}':'كوبون: ${coupon.couponName}',
                  style: infoWidget.title,)  ,
                Text(translator.currentLanguage =='en'?'discount percentage: ${coupon.discountPercentage}':'نسبه الخصم: ${coupon.discountPercentage} ',
                  style: infoWidget.subTitle,),
                Text(translator.currentLanguage =='en'?'Number of uses: ${coupon.numberOfUses}':'عدد مرات الاستخدام: ${coupon.numberOfUses} ',
                  style: infoWidget.subTitle,)  ,
                Text(translator.currentLanguage =='en'?'Expiry date: ${coupon.expiryDate}':'تاريخ الانتهاء: ${coupon.expiryDate} ',
                  style: infoWidget.subTitle,)  ,
              ],),
              Column(children: <Widget>[
                coupon.loading
                    ? Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.indigo,
                    ))
                    : RaisedButton(
                  onPressed: () async {
                    setState(() {
                      coupon.loading = true;
                    });
                    bool x = await _home.deleteCoupon(couponId: coupon.docId);
                    if (x) {
                      Toast.show(
                          translator.currentLanguage == "en"
                              ? "successfully deleted"
                              : 'نجح الحذف',
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
                      coupon.loading = false;
                    });
                  },
                  child: Text(
                    translator.currentLanguage == 'en'
                        ? 'delete'
                        : 'حذف',
                    style: infoWidget.titleButton,
                  ),
                  color: Colors.indigo,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                )
              ],)
            ],
          ),
        ),
      ),
    );
  }
  getAllCoupons() async {
    if (_home.allCoupons.length == 0) {
      await _home.getAllCoupons();
    }
    setState(() {
      loadingBody = false;
    });
  }

  @override
  void initState() {
    _home = Provider.of<Home>(context, listen: false);
    getAllCoupons();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return InfoWidget(
      builder: (context,infoWidget){
        return Directionality(
          textDirection: translator.currentLanguage == "en"?TextDirection.ltr:TextDirection.rtl,
          child: RefreshIndicator(
            color: Colors.indigo,
            backgroundColor: Colors.white,
            onRefresh: () async {
              await _home.getAllCoupons();
            },
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
                        height: infoWidget.screenHeight * 0.23,
                      ),
                    ),
                  ),
                  itemCount: 5,
                ),
              )
                  : Consumer<Home>(
                builder: (context, data, _) {
                  if (data.allCoupons.length == 0) {
                    return Center(
                      child: Text(
                        translator.currentLanguage == "en"
                            ? 'there is no any cupons'
                            : 'لا يوجد كوبونات',
                        style: infoWidget.titleButton
                            .copyWith(color: Colors.indigo),
                      ),
                    );
                  } else {
                    return ListView.builder(
                        itemCount: data.allCoupons.length,
                        itemBuilder: (context, index) => content(
                            infoWidget: infoWidget,
                           coupon: data.allCoupons[index]));
                  }
                },
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: (){
                  showDialog(
                      context: context,
                      builder: (ctx) => Directionality(
                        textDirection: translator.currentLanguage == "en"?TextDirection.ltr:TextDirection.rtl,
                        child: StatefulBuilder(
                          builder: (context, setState) =>
                              AlertDialog(
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
                                  child: Form(
                                    key: _formKey,
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
                                              // ignore: missing_return
                                              validator: (val) {
                                                if (val.isEmpty) {
                                                  return translator
                                                      .currentLanguage ==
                                                      "en"
                                                      ? 'enter coupon'
                                                      : 'ادخل الكوبون';
                                                }
                                              },
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
                                                hintText:  translator
                                                    .currentLanguage ==
                                                    "en"
                                                    ?'20':'20'
                                              ),
                                              // ignore: missing_return
                                              validator: (val) {
                                                if (val.isEmpty) {
                                                  return translator
                                                      .currentLanguage ==
                                                      "en"
                                                      ? 'enter discount percentage'
                                                      : 'ادخل النسبه';
                                                }
                                              },
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
                                // ignore: missing_return
                                validator: (val) {
                                    if (val.isEmpty) {
                                      return translator
                                          .currentLanguage ==
                                          "en"
                                          ? 'Invalid number'
                                          : 'ادخل عدد مرات الاستخدام';
                                    }
                                },
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
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text(translator.currentLanguage == "en"?'Cancel':'الغاء',style: infoWidget.subTitle.copyWith(color: Colors.indigo),),
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
                                child: Text(translator.currentLanguage == "en"?'Add':'اضافه',style: infoWidget.subTitle.copyWith(color: Colors.indigo),),
                                onPressed: addCoupon,
                              )
                            ],
                          ),
                        ),
                      ));
                },
                tooltip: translator.currentLanguage == "en"?'add':'اضافه',
                child: Icon(Icons.add,color: Colors.white,),
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
