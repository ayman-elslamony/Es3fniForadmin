import 'package:fluttertoast/fluttertoast.dart';

 flutterToast({required String msg}){
   Fluttertoast.showToast(msg: msg,
    gravity: ToastGravity.BOTTOM,
    toastLength: Toast.LENGTH_SHORT,

  );

}