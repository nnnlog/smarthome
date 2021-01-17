import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smarthome/ds/setting.dart';
import '../util/globals.dart' as globals;

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  String errMsg = "";

  _MainPageState() {
    globals.setState = this.setState;
    Setting.loadFromFile().then((obj) {
      obj.save();
      globals.setting = obj;
      globals.getToken().then((ret) {
        if (!ret)
          Timer.periodic(Duration(seconds: 1), (timer) async {
            if (await globals.getToken()) {
              timer.cancel();
            } else
              setState(() {
                this.errMsg = "네트워크 상태를 확인해주세요.";
              });
          });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("스마트홈")),
      body: Center(
        child: ListView(
          children: globals.setting.AccessToken == null
              ? [LinearProgressIndicator(), Text(this.errMsg)]
              : (globals.setting.AccessToken != ""
                  ? [
                      RaisedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/light/');
                          },
                          child: Text("조명 제어")),
                    ]
                  : [
                      RaisedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register/');
                          },
                          child: Text("기기 등록")),
                    ]),
          shrinkWrap: true,
          padding: EdgeInsets.all(10),
        ),
      ),
    );
  }
}
