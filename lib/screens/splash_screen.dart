import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              child: Center(
                  child: Image.asset('assets/logo.png',
                      fit: BoxFit.fill,
                      width: MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? MediaQuery.of(context).size.width * 0.2
                          : MediaQuery.of(context).size.width * 0.28))),
          const SizedBox(
            height: 15.0,
          ),
          AnimatedTextKit(
            animatedTexts: [
              ColorizeAnimatedText(
                  translator.activeLanguageCode == "en" ? ' Es3fni ' : 'اسعفنى',
                  textStyle: TextStyle(
                      fontSize: MediaQuery.of(context).orientation ==
                              Orientation.portrait
                          ? MediaQuery.of(context).size.width * 0.05
                          : MediaQuery.of(context).size.width * 0.032,
                      fontWeight: FontWeight.bold),
                  colors: [
                    Colors.red,
                    Colors.indigo,
                    Colors.red,
                    Colors.indigo,
                    Colors.red,
                  ],
                  textAlign: TextAlign.start,
                  textDirection: TextDirection.ltr),
            ],
            totalRepeatCount: 9,
            pause: const Duration(milliseconds: 1000),
            isRepeatingAnimation: true,
          ),
        ],
      ),
    );
  }
}
