import 'package:flutter/material.dart';
import 'package:es3fniforadmin/core/functions/get_device_type.dart';
import 'package:es3fniforadmin/core/models/device_info.dart';


class InfoWidget extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceInfo deviceInfo)? builder;

  const InfoWidget({Key? key, this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQueryData = MediaQuery.of(context);
    var deviceInfo = DeviceInfo(
        orientation: mediaQueryData.orientation,
        deviceType: getDeviceType(mediaQueryData),
        screenWidth: mediaQueryData.size.width,
        screenHeight: mediaQueryData.size.height,
        titleButton: TextStyle(
            fontSize: mediaQueryData.orientation==Orientation.portrait?mediaQueryData.size.width * 0.04:mediaQueryData.size.width * 0.025,
            color: Colors.white,
            fontWeight: FontWeight.bold),
        title: TextStyle(
            fontSize: mediaQueryData.orientation==Orientation.portrait?mediaQueryData.size.width * 0.048:mediaQueryData.size.width * 0.032,
            color: Colors.indigo,
            fontWeight: FontWeight.bold),
        subTitle: TextStyle(
            fontSize: mediaQueryData.orientation==Orientation.portrait?mediaQueryData.size.width * 0.035:mediaQueryData.size.width * 0.024,
            color: Color(0xff484848),
            fontWeight: FontWeight.bold),
        defaultVerticalPadding: mediaQueryData.orientation==Orientation.portrait?mediaQueryData.size.width * 0.015:mediaQueryData.size.width * 0.009,
        defaultHorizontalPadding: mediaQueryData.orientation==Orientation.portrait?mediaQueryData.size.height * 0.01:mediaQueryData.size.height * 0.02);
    return builder!(context, deviceInfo);
  }
}
