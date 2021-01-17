library smarthome.globals;

import 'dart:convert';
import 'package:smarthome/ds/setting.dart';
import 'package:http/http.dart' as http;

Setting setting = Setting("");
var setState;
refreshToken() async {
  try {
    var res = await http.post(
      "https://center.hdc-smart.com/v3/auth/login",
      headers: {'Authorization': setting.uuid},
    ).timeout(Duration(seconds: 3), onTimeout: () {
      return http.Response('timeout', 200);
    });
    print(res.body);
    if (res.body == 'timeout') return false;
    var json = jsonDecode(res.body);
    setState(() {
      setting.AccessToken = json['access-token'] ?? '';
    });
    return true;
  } catch (e) {
    return false;
  }
}
