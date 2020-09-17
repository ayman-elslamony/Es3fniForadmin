import 'package:admin/screens/paramedics/paramedics.dart';
import 'package:admin/screens/patient_requests/add_patient_request.dart';
import 'package:admin/screens/patient_requests/patient_requests.dart';
import 'package:admin/screens/sign_in_and_up/sign_in.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:admin/core/models/device_info.dart';
import 'package:admin/core/ui_components/info_widget.dart';
import 'package:admin/providers/auth.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';
import 'analysis/analysis.dart';
import 'analysis_requests/analysis_request.dart';
import 'coupons_and_discounts/coupons_and_discounts.dart';
import 'services_and_prices/services_and_prices.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _textEditingController = TextEditingController();
  int _page = 0;
  GlobalKey _bottomNavigationKey = GlobalKey();
  final GlobalKey<ScaffoldState> mainKey = GlobalKey<ScaffoldState>();
  List<String> type =  ['Patients requests', 'Analysis request'];
  PageController _pageController;
  String _searchContent;
  List<String> _suggestionList = List<String>();
  Auth _auth;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _auth = Provider.of<Auth>(context, listen: false);

    type = translator.currentLanguage == "en"
        ? ['Patients requests', 'Analysis request']
        : ['طلبات المرضي','طلبات التحليل'];
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
                      accountEmail: Text(translator.currentLanguage == "en"
                          ?'Points supplied: ${_auth.userData.points}':' النقاط المورده: ${_auth.userData.points}'),
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
                    _drawerListTile(
                        name: translator.currentLanguage == "en"
                            ? "Patients requests"
                            : 'طلبات المسعفين',
                        isIcon: true,
                        icon: Icons.remove_from_queue,
                        infoWidget: infoWidget,
                        onTap: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _page = 0;
                          });
                          _pageController.jumpToPage(_page);
                        }),
                    _drawerListTile(
                        name: translator.currentLanguage == "en"
                            ? "Analysis requests"
                            : 'طلبات التحليل',
                        isIcon: true,
                        icon: Icons.redeem,
                        infoWidget: infoWidget,
                        onTap: () async {
                          Navigator.of(context).pop();
                          setState(() {
                            _page = 1;
                          });
                          _pageController.jumpToPage(_page);
                        }),
                    _drawerListTile(
                        name: translator.currentLanguage == "en"
                            ? "Nurses"
                            : 'المسعفين',
                        isIcon: true,
                        icon: Icons.people,
                        infoWidget: infoWidget,
                        onTap: () async {

                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => Paramedics()));
                        }),
                    _drawerListTile(
                        name: translator.currentLanguage == "en"
                            ? "Services and prices"
                            : 'الخدمات والاسعار',
                        isIcon: true,
                        icon: Icons.filter_frames,
                        infoWidget: infoWidget,
                        onTap: () {
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
                          await Provider.of<Auth>(context, listen: false)
                              .logout();
                          Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => CouponsAndDiscounts()));
                        }),
                    _drawerListTile(
                        name: translator.currentLanguage == "en"
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
                            ? "Patients requests"
                            : 'طلبات المرضي')
                    : _iconNavBar(infoWidget: infoWidget, iconPath: Icons.remove_from_queue),
                _page != 1
                    ? _iconNavBar(
                        infoWidget: infoWidget,
                        iconPath: Icons.redeem,
                        title: translator.currentLanguage == "en"
                            ? 'Analysis requests'
                            : 'طلبات التحليل')
                    : _iconNavBar(
                        infoWidget: infoWidget, iconPath: Icons.redeem),
//                _page != 2
//                    ? _iconNavBar(
//                        infoWidget: infoWidget,
//                        iconPath: Icons.person,
//                        title: translator.currentLanguage == "en"
//                            ? 'Services and prices'
//                            : 'الخدمات والاسعار')
//                    : _iconNavBar(
//                        infoWidget: infoWidget, iconPath: Icons.person),
              ],
              onTap: (index) {
                setState(() {
                  _page = index;
                });
                _pageController.jumpToPage(_page);
                //_textEditingController.clear();
              },
            ),
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
                  PatientsRequests(),
                  AnalysisRequests(),
               // ServicesAndPrices(),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AddPatientRequest()));
              },
              tooltip: translator.currentLanguage == "en" ? 'add' : 'اضافه',
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
              backgroundColor: Colors.indigo,
            ),
            floatingActionButtonLocation:
            FloatingActionButtonLocation.endFloat,
          ),
        );
      },
    );
  }
}
