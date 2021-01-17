library smarthome.globals;

import 'dart:convert';
import 'package:smarthome/ds/setting.dart';
import 'package:http/http.dart' as http;

Setting setting = Setting("");
var setState;

getFeatures() async {
  try {
    var res = await http.get(
      "${setting.url}/v2/api/features/apply",
      headers: {'access-token': setting.AccessToken},
    ).timeout(Duration(seconds: 3), onTimeout: () {
      return http.Response('timeout', 200);
    });
    var json = jsonDecode(res.body);
    if (json["result"] == "ok") {
      var ret = {};
      json["features"].forEach((obj) {
        ret[obj['name']] = obj['quantity'];
      });
      return ret;
    } else throw new Error();
  } catch (e) {

  }
  return null;
}

getToken() async {
  try {
    var res = await http.post(
      "https://center.hdc-smart.com/v3/auth/login",
      headers: {'Authorization': setting.uuid},
    ).timeout(Duration(seconds: 3), onTimeout: () {
      return http.Response('timeout', 200);
    });
    if (res.body == 'timeout') return false;
    var json = jsonDecode(res.body);
    setState(() {
      setting.AccessToken = json['access-token'] ?? '';
      setting.url = json['url'] ?? '';
      if (setting.AccessToken != '') getFeatures();
    });
    return true;
  } catch (e) {
    return false;
  }
}
