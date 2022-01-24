import 'package:es3fniforadmin/core/models/device_info.dart';
import 'package:es3fniforadmin/core/ui_components/info_widget.dart';
import 'package:es3fniforadmin/models/coupon.dart';
import 'package:es3fniforadmin/providers/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class CouponsAndDiscounts extends StatefulWidget {
  @override
  _CouponsAndDiscountsState createState() => _CouponsAndDiscountsState();
}

class _CouponsAndDiscountsState extends State<CouponsAndDiscounts> {
  TextEditingController coupon=TextEditingController();
  TextEditingController discountPercentage=TextEditingController();
  TextEditingController numberOfUses=TextEditingController();
  String _expiryDate='';
  late Home _home;
  bool loadingBody = true;
  bool isLoading= false;
  final GlobalKey<FormState> _formKey = GlobalKey();
  addCoupon() async {
    if (_formKey.currentState!.validate() && _expiryDate !='') {
      _formKey.currentState!.save();
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
        Fluttertoast.showToast(msg: translator.activeLanguageCode == "en"
            ? "successfully Added"
            : 'نجحت الاضافه',
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,

        );
        Navigator.of(context).pop();
        setState(() {
          isLoading = false;
        });
      }
      if(auth == 'not valid'){
        Fluttertoast.showToast(msg: translator.activeLanguageCode == "en"
            ? "Already exists"
            : 'موجود بالفعل',
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,

        );
        setState(() {
          isLoading = false;
        });
      }
    }
  }
  Widget content({required Coupon coupon,required DeviceInfo infoWidget}) {
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
                Text(translator.activeLanguageCode =='en'?'Coupon: ${coupon.couponName}':'كوبون: ${coupon.couponName}',
                  style: infoWidget.title,)  ,
                Text(translator.activeLanguageCode =='en'?'discount percentage: ${coupon.discountPercentage}':'نسبه الخصم: ${coupon.discountPercentage} ',
                  style: infoWidget.subTitle,),
                Text(translator.activeLanguageCode =='en'?'Number of uses: ${coupon.numberOfUses}':'عدد مرات الاستخدام: ${coupon.numberOfUses} ',
                  style: infoWidget.subTitle,)  ,
                Text(translator.activeLanguageCode =='en'?'Expiry date: ${coupon.expiryDate}':'تاريخ الانتهاء: ${coupon.expiryDate} ',
                  style: infoWidget.subTitle,)  ,
              ],),
              Column(children: <Widget>[
                coupon.loading
                    ?const Center(
                    child: const CircularProgressIndicator(color:  Colors.indigo,))
                    : RaisedButton(
                  onPressed: () async {
                    setState(() {
                      coupon.loading = true;
                    });
                    bool x = await _home.deleteCoupon(couponId: coupon.docId);
                    if (x) {
                      Fluttertoast.showToast(msg: translator.activeLanguageCode == "en"
                          ? "successfully deleted"
                          : 'نجح الحذف',
                        gravity: ToastGravity.BOTTOM,
                        toastLength: Toast.LENGTH_SHORT,

                      );
                    } else {
                      Fluttertoast.showToast(msg: translator.activeLanguageCode == "en"
                          ? "try again later"
                          : 'حاول مره اخرى',
                        gravity: ToastGravity.BOTTOM,
                        toastLength: Toast.LENGTH_SHORT,

                      );
                    }
                    setState(() {
                      coupon.loading = false;
                    });
                  },
                  child: Text(
                    translator.activeLanguageCode == 'en'
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
          textDirection: translator.activeLanguageCode == "en"?TextDirection.ltr:TextDirection.rtl,
          child: RefreshIndicator(
            color: Colors.indigo,
            backgroundColor: Colors.white,
            onRefresh: () async {
              await _home.getAllCoupons();
            },
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text(translator.activeLanguageCode == "en"
                    ? "Coupons and discounts"
                    : 'الكوبونات والخصومات',
                  style: infoWidget.titleButton,),
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
                              size: infoWidget.orientation==Orientation.portrait?infoWidget.screenHeight! * 0.04:infoWidget.screenHeight! * 0.07,
                            ),
                            Positioned(
                                right: 2.9,
                                top: 2.8,
                                child: Container(
                                  width: infoWidget.orientation==Orientation.portrait?infoWidget.screenWidth! * 0.023:infoWidget.screenWidth! * 0.014,
                                  height: infoWidget.orientation==Orientation.portrait?infoWidget.screenWidth! * 0.023:infoWidget.screenWidth!* 0.014,
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
                        height: infoWidget.screenHeight! * 0.23,
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
                        translator.activeLanguageCode == "en"
                            ? 'there is no any cupons'
                            : 'لا يوجد كوبونات',
                        style: infoWidget.titleButton!
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
                        textDirection: translator.activeLanguageCode == "en"?TextDirection.ltr:TextDirection.rtl,
                        child: StatefulBuilder(
                          builder: (context, setState) =>
                              AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(25.0))),
                            contentPadding: EdgeInsets.only(top: 10.0),
                            title: Text(
                              translator.activeLanguageCode == "en"
                                  ? "Add Coupon"
                                  : 'اضافه كوبون',
                              textAlign: TextAlign.center,
                              style: infoWidget.title,
                            ),
                            content: Container(
                              height: infoWidget.screenHeight!*0.45,
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
                                                labelText: translator.activeLanguageCode == "en"?'Coupon':'كوبون',
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
                                                if (val!.isEmpty) {
                                                  return translator
                                                      .activeLanguageCode ==
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
                                                labelText: translator.activeLanguageCode == "en"?'discount percentage':'النسبه',
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
                                                    .activeLanguageCode ==
                                                    "en"
                                                    ?'20':'20'
                                              ),
                                              // ignore: missing_return
                                              validator: (val) {
                                                if (val!.isEmpty) {
                                                  return translator
                                                      .activeLanguageCode ==
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
                                      labelText: translator.activeLanguageCode == "en"?'Number of uses':'عدد مرات الاستخدام',
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
                                    if (val!.isEmpty) {
                                      return translator
                                          .activeLanguageCode ==
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
                                                    '${date.year}-${date.month}-${date.month}';
                                                  });
                                                },
                                                currentTime: DateTime.now(),
                                                locale: translator.activeLanguageCode == "en"
                                                    ? LocaleType.en
                                                    : LocaleType.ar);
                                          },
                                          color: Colors.indigo,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10)),
                                          child: Text(
                                            translator.activeLanguageCode == "en"
                                                ? _expiryDate==''?'Expiry Date':_expiryDate
                                                : _expiryDate==''?'تاريخ الانتهاء':_expiryDate,
                                            style:
                                            TextStyle(color: Colors.white, fontSize: 18),
                                          ),
                                        ):
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              translator.activeLanguageCode == "en"
                                                 ?'Expiry Date:  '
                                                  : 'تاريخ الانتهاء:  ',
                                              style:
                                              infoWidget.subTitle!.copyWith(color: Colors.indigo),
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
                                                    locale: translator.activeLanguageCode == "en"
                                                        ? LocaleType.en
                                                        : LocaleType.ar);
                                              },
                                              color: Colors.indigo,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10)),
                                              child: Text(
                                                translator.activeLanguageCode == "en"
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
                                child: Text(translator.activeLanguageCode == "en"?'Cancel':'الغاء',style: infoWidget.subTitle!.copyWith(color: Colors.indigo),),
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
                                    color: Colors.indigo,
                                  )
                                ],
                              )
                                  : FlatButton(
                                child: Text(translator.activeLanguageCode == "en"?'Add':'اضافه',style: infoWidget.subTitle!.copyWith(color: Colors.indigo),),
                                onPressed: addCoupon,
                              )
                            ],
                          ),
                        ),
                      ));
                },
                tooltip: translator.activeLanguageCode == "en"?'add':'اضافه',
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
