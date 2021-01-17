import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smarthome/ds/APTInfo.dart';
import 'package:http/http.dart' as http;
import 'package:smarthome/util/toast.dart';
import '../util/globals.dart' as globals;

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage> {
  List<APTInfo> _APTLists = [], _searchLists = [];
  int selectedIdx = 0, status = 1;
  String transaction = "";
  TextEditingController searchTextController = TextEditingController(),
      verifyTextController = TextEditingController(),
      dongTextController = TextEditingController(),
      hoTextController = TextEditingController(),
      nameTextController = TextEditingController();

  _RegisterPageState() {
    http.get("https://center.hdc-smart.com/v3/auth/valley").then((res) {
      var json = jsonDecode(res.body);
      List<APTInfo> tmp = [];
      for (var obj in json) {
        tmp.add(APTInfo.parse(obj));
      }
      tmp.sort();
      this.setState(() {
        this._APTLists = tmp;
        this._searchLists = tmp;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("스마트홈")),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: <Widget>[
                  Flexible(
                    child: TextFormField(
                      decoration: InputDecoration(hintText: "아파트 명을 입력하세요."),
                      controller: searchTextController,
                    ),
                  ),
                  FlatButton(
                    onPressed: () async {
                      setState(() {
                        this._searchLists = this
                            ._APTLists
                            .where((apt) =>
                                apt.name.indexOf(searchTextController.text) >
                                -1)
                            .toList();
                        if (this._searchLists.isEmpty) {
                          toast("검색 결과가 없습니다.");
                          this._searchLists = this._APTLists;
                        }
                        this.selectedIdx = 0;
                      });
                    },
                    child: Icon(Icons.search),
                    minWidth: 0,
                    height: 0,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.all(1),
                  ),
                ],
              ),
              DropdownButton(
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down),
                items: this
                    ._searchLists
                    .asMap()
                    .entries
                    .map<DropdownMenuItem>((e) => DropdownMenuItem(
                          child: Text(e.value.name),
                          value: e.key,
                        ))
                    .toList(),
                value: this.selectedIdx,
                iconSize: 24,
                elevation: 16,
                onChanged: (idx) {
                  setState(() async {
                    this.selectedIdx = idx;
                  });
                },
              ),
              Flexible(
                child: TextFormField(
                  decoration: InputDecoration(hintText: "이름을 입력하세요."),
                  controller: nameTextController,
                ),
              ),
              Row(
                children: [
                  Flexible(
                    child: TextFormField(
                      decoration: InputDecoration(hintText: "동을 입력하세요."),
                      controller: dongTextController,
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(10)),
                  Flexible(
                    child: TextFormField(
                      decoration: InputDecoration(hintText: "호수를 입력하세요."),
                      controller: hoTextController,
                    ),
                  ),
                ],
              ),
              FlatButton(
                  onPressed: () async {
                    var res = await http.post(
                        "https://center.hdc-smart.com/v3/auth/registration",
                        body: jsonEncode({
                          "site": this._searchLists[this.selectedIdx].code,
                          "identifier": this.dongTextController.text +
                              "/" +
                              this.hoTextController.text,
                          "alias": this.nameTextController.text
                        }),
                        headers: {
                          "Content-Type": "application/json",
                          "Authorization": globals.setting.uuid
                        });
                    var json = jsonDecode(res.body);
                    if (json["err"] != null)
                      toast(json["err"]["msg"]);
                    else
                      setState(() {
                        this.status = 2;
                        this.transaction = json["transaction"];
                        toast("월패드에 나타나는 인증번호를 입력해주세요.");
                      });
                  },
                  child: Text("기기 등록하기")),
              Visibility(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(hintText: "인증 번호를 입력하세요."),
                      controller: this.verifyTextController,
                    ),
                    FlatButton(
                        onPressed: () async {
                          var res = await http.post(
                              "https://center.hdc-smart.com/v3/auth/verify",
                              body: jsonEncode({
                                "transaction": this.transaction,
                                "password": this.verifyTextController.text,
                              }),
                              headers: {
                                "Content-Type": "application/json",
                                "Authorization": globals.setting.uuid
                              });
                          if (res.statusCode == 200) {
                            await globals.getToken();
                            Navigator.pop(context);
                          } else {
                            var json = jsonDecode(res.body);
                            toast(json["err"]["msg"]);
                          }
                        },
                        child: Text("인증 번호 입력")),
                  ],
                ),
                visible: this.status == 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
