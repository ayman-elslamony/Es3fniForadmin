import 'dart:convert';

import 'package:admin/providers/home.dart';
import 'package:admin/screens/patient_requests/add_patient_request.dart';
import 'package:admin/screens/patient_requests/archived_requests.dart';
import 'package:admin/screens/patient_requests/another_patient_requests.dart';
import 'package:admin/screens/patient_requests/human_medicine_requests.dart';
import 'package:admin/screens/patient_requests/physical_therapy_requests.dart';
import 'package:admin/screens/shared_widget/edit_address.dart';
import 'package:admin/screens/sign_in_and_up/sign_in.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:admin/core/models/device_info.dart';
import 'package:admin/core/ui_components/info_widget.dart';
import 'package:admin/providers/auth.dart';
import 'package:hawk_fab_menu/hawk_fab_menu.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'analysis/analysis.dart';
import 'analysis_requests/analysis_request.dart';
import 'coupons_and_discounts/coupons_and_discounts.dart';
import 'nurses/nurses.dart';
import 'nurses/nurses_supplies.dart';
import 'patients_accounts/patients_accounts.dart';
import 'services_and_prices/services_and_prices.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;
  GlobalKey _bottomNavigationKey = GlobalKey();
  final GlobalKey<ScaffoldState> mainKey = GlobalKey<ScaffoldState>();
  List<String> type =  ["Human medicine requests","Physical therapy requests",'Analysis requests',"Another requests"];
  PageController _pageController;
  Auth _auth;
  Home _home;
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _auth = Provider.of<Auth>(context, listen: false);
    _home = Provider.of<Home>(context, listen: false);
    type = translator.currentLanguage == "en"
        ? ["Human medicine requests","Physical therapy requests",'Analysis requests',"Another requests"]
        : ['طلبات طب بشرى','طلبات العلاج الطبيعى','طلبات التحليل','طلبات اخرى'];

  }


  getAddress(String add,String lat,String lng) {
    print('add');
    print(add);
    _auth.address = add;
    _auth.lat =double.parse(lat);
    _auth.lng =double.parse(lng);
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _iconNavBar({IconData iconPath, String title, DeviceInfo infoWidget}) {
    return title == null
        ? Icon(
            iconPath,
            color: Colors.white,
          )
        : Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Column(
              children: <Widget>[
                Icon(
                  iconPath,
                  color: Colors.white,
                ),
                title == null
                    ? SizedBox()
                    : Text(
                        title,
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).orientation ==
                                    Orientation.portrait
                                ? MediaQuery.of(context).size.width * 0.035
                                : MediaQuery.of(context).size.width * 0.024,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )
              ],
            ),
          );
  }

  Widget _drawerListTile(
      {String name,
      IconData icon = Icons.settings,
      String imgPath = 'assets/icons/home.png',
      bool isIcon = false,
      DeviceInfo infoWidget,
      Function onTap}) {
    return InkWell(
      onTap: onTap,
      child: ListTile(
        dense: true,
        title: Text(
          name,
          style: infoWidget.titleButton.copyWith(color: Colors.indigo),
        ),
        leading: isIcon
            ? Icon(
                icon,
                color: Colors.indigo,
              )
            : Image.asset(
                imgPath,
                color: Colors.indigo,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InfoWidget(
      builder: (context, infoWidget) {
        print(infoWidget.screenWidth);
        print(infoWidget.screenHeight);
        return Directionality(
          textDirection: translator.currentLanguage == "en"
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: Scaffold(
            key: mainKey,
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                type[_page],
                style: infoWidget.titleButton,
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
                            size: infoWidget.orientation == Orientation.portrait
                                ? infoWidget.screenHeight * 0.04
                                : infoWidget.screenHeight * 0.07,
                          ),
                          Positioned(
                              right: 2.9,
                              top: 2.8,
                              child: Container(
                                width: infoWidget.orientation ==
                                        Orientation.portrait
                                    ? infoWidget.screenWidth * 0.023
                                    : infoWidget.screenWidth * 0.014,
                                height: infoWidget.orientation ==
                                        Orientation.portrait
                                    ? infoWidget.screenWidth * 0.023
                                    : infoWidget.screenWidth * 0.014,
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
            drawer: Container(
              width: infoWidget.orientation == Orientation.portrait
                  ? infoWidget.screenWidth * 0.61
                  : infoWidget.screenWidth * 0.50,
              height: infoWidget.screenHeight,
              child: Drawer(
                child: ListView(
                  children: <Widget>[
//                  (() {
//                    if(_auth.getUserType == 'doctor'){
//                      return Column();
//                    }
//                    return Column();
//                  }()),
                    UserAccountsDrawerHeader(
                      accountName:
                          Text("${_auth.userData.name.toUpperCase()}"),
                      accountEmail: InkWell(
                        onTap: (){
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => NursesSupplies()));
                        },
                        child: Text(translator.currentLanguage == "en"
                            ?'Points supplied: ${_auth.userData.points}':' النقاط المورده: ${_auth.userData.points}'),
                      ),
                      currentAccountPicture: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).platform == TargetPlatform.iOS
                                ? Colors.indigo
                                : Colors.white,
                        child: Text(
                          "${_auth.userData.name.substring(0, 1).toUpperCase().toUpperCase()}",
                          style: TextStyle(fontSize: 40.0),
                        ),
                      ),
                    ),
//                    _drawerListTile(
////                        name: translator.currentLanguage == "en"
////                            ? "Human medicine requests"
////                            : 'طلبات طب بشرى',
////                        isIcon: true,
////                        icon: Icons.remove_from_queue,
////                        infoWidget: infoWidget,
////                        onTap: () {
////                          Navigator.of(context).pop();
////                          setState(() {
////                            _page = 0;
////                          });
////                          _pageController.jumpToPage(_page);
////                        }),
////                    _drawerListTile(
////                        name: translator.currentLanguage == "en"
////                            ? "Physical therapy requests"
////                            : 'طلبات العلاج الطبيعى',
////                        isIcon: true,
////                        icon: Icons.chrome_reader_mode,
////                        infoWidget: infoWidget,
////                        onTap: () async {
////                          Navigator.of(context).pop();
////                          setState(() {
////                            _page = 1;
////                          });
////                          _pageController.jumpToPage(_page);
////                        }),
////                    _drawerListTile(
////                        name: translator.currentLanguage == "en"
////                            ? 'Analysis requests'
////                            : 'طلبات التحليل',
////                        isIcon: true,
////                        icon: Icons.redeem,
////                        infoWidget: infoWidget,
////                        onTap: () async {
////                          Navigator.of(context).pop();
////                          setState(() {
////                            _page = 2;
////                          });
////                          _pageController.jumpToPage(_page);
////                        }),_drawerListTile(
////                        name: translator.currentLanguage == "en"
////                            ? "Another requests"
////                            : 'طلبات اخرى',
////                        isIcon: true,
////                        icon: Icons.featured_play_list,
////                        infoWidget: infoWidget,
////                        onTap: () async {
////                          Navigator.of(context).pop();
////                          setState(() {
////                            _page = 3;
////                          });
////                          _pageController.jumpToPage(_page);
////                        }),
                    _drawerListTile(
                        name: translator.currentLanguage == "en"
                            ? "Archived requests"
                            : 'الطلبات المؤرشفه',
                        isIcon: true,
                        icon: Icons.archive,
                        infoWidget: infoWidget,
                        onTap: () async {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ArchivedRequests()));
                        }),
                    _drawerListTile(
                        name: translator.currentLanguage == "en"
                            ? "Patient accounts"
                            : 'حسابات المرضي',
                        isIcon: true,
                        icon: Icons.people,
                        infoWidget: infoWidget,
                        onTap: () async {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => PatientsAccounts()));
                        }),
                    _drawerListTile(
                        name: translator.currentLanguage == "en"
                            ? "Nurses"
                            : 'المسعفين',
                        isIcon: true,
                        icon: Icons.people,
                        infoWidget: infoWidget,
                        onTap: () async {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => Nurses()));
                        }),
                    _drawerListTile(
                        name: translator.currentLanguage == "en"
                            ? "Nurses supplies"
                            : 'توريدات المسعفين',
                        isIcon: true,
                        icon: Icons.panorama_fish_eye,
                        infoWidget: infoWidget,
                        onTap: ()  {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => NursesSupplies()));
                        }),
                    _drawerListTile(
                        name: translator.currentLanguage == "en"
                            ? "Services and prices"
                            : 'الخدمات والاسعار',
                        isIcon: true,
                        icon: Icons.filter_frames,
                        infoWidget: infoWidget,
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => ServicesAndPrices()));
                        }),
                    _drawerListTile(
                        name: translator.currentLanguage == "en"
                            ? "Medical tests"
                            : 'التحاليل الطبيه',
                        isIcon: true,
                        icon: Icons.insert_chart,
                        infoWidget: infoWidget,
                        onTap: () async {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => Analysiss()));
                        }),

                    _drawerListTile(
                        name: translator.currentLanguage == "en"
                            ? "Coupons and discounts"
                            : 'الكوبونات والخصومات',
                        isIcon: true,
                        icon: Icons.casino,
                        infoWidget: infoWidget,
                        onTap: () async {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => CouponsAndDiscounts()));
                        }),
                    _drawerListTile(
                        name: translator.currentLanguage != "en"
                            ? "English":"العربية",
                        isIcon: true,
                        icon: Icons.language,
                        infoWidget: infoWidget,
                        onTap: () {
                          translator.currentLanguage == "en"
                              ? translator.setNewLanguage(
                            context,
                            newLanguage: 'ar',
                            remember: true,
                            restart: true,
                          )
                              : translator.setNewLanguage(
                            context,
                            newLanguage: 'en',
                            remember: true,
                            restart: true,
                          );
                        }),
                    _drawerListTile(
                        name: translator.currentLanguage == "en"
                            ? "Log Out"
                            : 'تسجيل الخروج',
                        isIcon: true,
                        icon: Icons.exit_to_app,
                        infoWidget: infoWidget,
                        onTap: () async {
                          await Provider.of<Auth>(context, listen: false)
                              .logout();
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => SignIn()));
                        }),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: CurvedNavigationBar(
              height: infoWidget.screenHeight >= 960 ? 70 : 55,
              key: _bottomNavigationKey,
              backgroundColor: Colors.white,
              color: Colors.indigo,
              items: <Widget>[
                _page != 0
                    ? _iconNavBar(
                    infoWidget: infoWidget,
                    iconPath: Icons.remove_from_queue,
                    title: translator.currentLanguage == "en"
                        ? "Human medicine"
                        : 'طب بشرى')
                    : _iconNavBar(infoWidget: infoWidget, iconPath: Icons.remove_from_queue),
                _page != 1
                    ? _iconNavBar(
                    infoWidget: infoWidget,
                    iconPath: Icons.chrome_reader_mode,
                    title: translator.currentLanguage == "en"
                        ? "Physical therapy"
                        : 'العلاج الطبيعى')
                    : _iconNavBar(infoWidget: infoWidget, iconPath: Icons.chrome_reader_mode),
                _page != 2
                    ? _iconNavBar(
                        infoWidget: infoWidget,
                        iconPath: Icons.redeem,
                        title: translator.currentLanguage == "en"
                            ? 'Analysis requests'
                            : 'طلبات التحليل')
                    : _iconNavBar(
                        infoWidget: infoWidget, iconPath: Icons.redeem),
                _page != 3
                    ? _iconNavBar(
                    infoWidget: infoWidget,
                    iconPath: Icons.featured_play_list,
                    title: translator.currentLanguage == "en"
                        ? "Another requests"
                        : 'طلبات اخرى')
                    : _iconNavBar(infoWidget: infoWidget, iconPath: Icons.featured_play_list),
              ],
              onTap: (index) {
                setState(() {
                  _page = index;
                });
                _pageController.jumpToPage(_page);
                //_textEditingController.clear();
              },
            ),
            body: HawkFabMenu(
              icon: AnimatedIcons.menu_close,
              fabColor: Colors.indigo,
              iconColor: Colors.white,
              items: [
                HawkFabMenuItem(
                  label: translator.currentLanguage == "en" ? 'add' : 'اضافه',
                  ontap:() {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AddPatientRequest()));
                  },
                  icon: Icon(Icons.add,color: Colors.white,),
                  color: Colors.indigo,
                  labelColor: Colors.white,
                  labelBackgroundColor: Colors.indigo
                ),
                HawkFabMenuItem(
                  label: translator.currentLanguage == "en" ? 'Filters' : 'فلتره',
                  ontap:() {
                    showModalBottomSheet(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                topLeft: Radius.circular(10))),
                        context: context,
                        builder: (BuildContext context) {
                          return Directionality(
                            textDirection: translator.currentLanguage=='en'?TextDirection.ltr:TextDirection.rtl,
                            child: StatefulBuilder(
                              builder: (context, setState) => Container(
                                height: MediaQuery.of(context).orientation ==
                                    Orientation.portrait
                                    ? MediaQuery.of(context).size.height * 0.3
                                    : MediaQuery.of(context).size.height * 0.28,
                                padding: EdgeInsets.all(10.0),
                                child: Column(children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      SizedBox(width:1.0,),
                                      Text(
                                          translator.currentLanguage == "en"
                                              ? 'Filter Requests'
                                              : 'فلتره الطلبات',
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                  .orientation ==
                                                  Orientation.portrait
                                                  ? MediaQuery.of(context).size.width *
                                                  0.04
                                                  : MediaQuery.of(context).size.width *
                                                  0.03,
                                              color: Colors.indigo,
                                              fontWeight: FontWeight.bold)),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: InkWell(onTap: ()async{
                                          Navigator.of(context).pop();
                                          final prefs = await SharedPreferences.getInstance();
                                          final _filter = json.encode({
                                            'address': _auth.address.toString(),
                                            'radiusForAllRequests': _home.radiusForAllRequests.toString(),
                                            'lat': _auth.lat.toString(),
                                            'lng': _auth.lng.toString()
                                          });
                                          await prefs.setString('filter', _filter);
                                          _home.refreshWhenChangeFilters=[true,true,true,true];
                                          _home.refreshWhenChangeFilters[_page]=false;
                                          switch(_page){
                                            case 0:
                                              _home.getAllHumanMedicineRequests(
                                                userLong: _auth.lng.toString(),userLat: _auth.lat.toString()
                                              );
                                              break;
                                            case 1:
                                              _home.getAllPhysicalTherapyRequests(
                                                userLong: _auth.lng.toString(),userLat: _auth.lat.toString()
                                              );
                                              break;
                                            case 2:
                                              _home.getAllAnalysisRequests(
                                                  userLong: _auth.lng.toString(),userLat: _auth.lat.toString()
                                              );
                                              break;
                                            case 3:
                                              _home.getAllPatientsRequests(
                                                  long: _auth.lng,lat: _auth.lat
                                              );
                                              break;
                                          }


                                        }, child: Text(translator.currentLanguage == "en" ?'Save':'حفظ',style: infoWidget.subTitle.copyWith(color: Colors.indigo),)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10.0,
                                  ),
                                  Consumer<Home>(
                                    builder: (context,data,_)=>
                                        Slider(
                                          value: data.radiusForAllRequests,
                                          onChanged: _home.changeRadiusForAllRequests,
                                          min: 0.0,
                                          max: 100.0,
                                          divisions: 10,
                                          label: '${data.radiusForAllRequests.floor()} KM',
                                          inactiveColor: Colors.blue[100],
                                          activeColor: Colors.indigo,
                                        ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: EditAddress(
                                      getAddress: getAddress,
                                      address: _auth.address,
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                          );
                        });
                  },
                  icon: Icon(Icons.filter_list,color: Colors.white,),
                  color: Colors.indigo,
                  labelColor: Colors.white,
                  labelBackgroundColor: Colors.indigo
                ),
              ],
              body: Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: PageView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _page = index;
                    });
                    final CurvedNavigationBarState navBarState =
                        _bottomNavigationKey.currentState;
                    navBarState.setPage(_page);
                  },
                  children: <Widget>[
                    HumanMedicineRequests(),
                    PhysicalTherapyRequests(),
                    AnalysisRequests(),
                    PatientsRequests(),
                  ],
                ),
              ),
            ),

          ),
        );
      },
    );
  }
}
