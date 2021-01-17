import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'package:smarthome/util/toast.dart';
import '../util/globals.dart' as globals;

class LightControlPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LightControlPage();
  }
}

class _LightControlPage extends State<LightControlPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  bool isLoading = false;

  Map<int, Map<String, bool>> light = {};
  Map<int, String> name = {};

  Map<String, bool> livingroom = {};

  _LightControlPage() {
    this._fetchData();
  }

  _changeLivingRoomState(String unit, bool turnOn) async {
    try {
      var res = await http
          .put("${globals.setting.url}/v2/api/features/livinglight/0/apply",
              headers: {'access-token': globals.setting.AccessToken},
              body: jsonEncode(
                  {"unit": unit, "state": turnOn ? "on" : "off", "name": ""}))
          .timeout(Duration(seconds: 3), onTimeout: () {
        return http.Response('timeout', 200);
      });
      var json = jsonDecode(res.body);
      if (json["result"] == "ok") {
        Map<String, bool> tmp = {};
        for (var obj in json['units'])
          tmp[obj['unit']] = (obj['state'] == 'on');

        setState(() {
          livingroom = tmp;
        });
        return true;
      }
      throw new Error();
    } catch (e) {
      toast("상태 변경에 실패했습니다.\n인터넷 접속을 확인해주세요.");
      return false;
    }
  }

  _fetchData() async {
    if (mounted)
      setState(() {
        isLoading = true;
      });
    var f = await globals.getFeatures();
    {
      var units = jsonDecode((await http.get(
              "${globals.setting.url}/v2/api/features/livinglight/0/apply",
              headers: {'access-token': globals.setting.AccessToken}))
          .body)['units'];
      Map<String, bool> tmp = {};
      livingroom.clear();
      for (var obj in units) tmp[obj['unit']] = (obj['state'] == 'on');

      setState(() {
        livingroom = tmp;
      });
    }

    {
      Map<int, Map<String, bool>> tmp = {};
      Map<int, String> tmp2 = {};
      for (var i = 1; i <= f['light']; i++) {
        var res = jsonDecode((await http.get(
                "${globals.setting.url}/v2/api/features/light/$i/apply",
                headers: {'access-token': globals.setting.AccessToken}))
            .body);
        tmp[i] = {};
        tmp2[i] = res['map']['name'];
        for (var obj in res['units'])
          tmp[i][obj['unit']] = obj['state'] == 'on';
      }

      setState(() {
        light = tmp;
        name = tmp2;
      });
    }

    if (mounted)
      setState(() {
        isLoading = false;
      });
  }

  _refresh() async {
    _fetchData();
    this._refreshController.refreshCompleted();
  }

  _load() {
    _fetchData();
    this._refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("조명 제어")),
        body: SmartRefresher(
          controller: _refreshController,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: isLoading
                  ? [
                      LinearProgressIndicator(),
                    ]
                  : [
                      Align(
                        child: Text(
                          " 거실",
                          style: TextStyle(fontSize: 32),
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                      Divider(),
                      Column(
                        children: livingroom.entries
                            .map<SwitchListTile>((e) => SwitchListTile(
                                  title: Text(e.key.replaceAll("switch", "스위치")),
                                  value: livingroom[e.key],
                                  onChanged: (bool value) async {
                                    if (await _changeLivingRoomState(
                                        e.key, value))
                                      setState(() {
                                        livingroom[e.key] = value;
                                      });
                                  },
                                ))
                            .toList(),
                      ),
                    ],
            ),
          ),
          onRefresh: _refresh,
          onLoading: _load,
        ));
  }
}
