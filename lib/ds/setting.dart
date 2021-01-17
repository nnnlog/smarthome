import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info/device_info.dart';
import 'package:path_provider/path_provider.dart';

_getUUID() async {
  String uuid;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid)
    uuid = (await deviceInfo.androidInfo).androidId;
  else
    uuid = (await deviceInfo.iosInfo).identifierForVendor;
  return sha1.convert(utf8.encode(uuid)).toString().substring(0, 16).toUpperCase();
}

_getPath() async {
  Directory dir = await getApplicationDocumentsDirectory();
  return dir.path + "/data.json";
}

class Setting {
  String _uuid, url, AccessToken;
  get uuid => _uuid;

  static Future<Setting> loadFromFile() async {
    Map json = {
      "uuid": await _getUUID()
    };
    var path = await _getPath();
    if (await FileSystemEntity.isFile(path)) {
      try {
        var tmp = jsonDecode(File(path).readAsStringSync());
        for (var e in json.keys) {
          json[e] = tmp[e] ?? json[e];
        }
      } catch (e) {}
    }

    return Setting(json['uuid']);
  }

  Setting(this._uuid);
}
