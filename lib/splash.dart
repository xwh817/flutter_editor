import 'package:flutter/material.dart';
import 'main.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2)).then((value) => {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false)
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ConstrainedBox(
            constraints: BoxConstraints.expand(),
            child: Center(
                child: Image.asset(
                'images/ic_launcher.png',
                fit: BoxFit.fill,
              ),
            )));
  }
}
