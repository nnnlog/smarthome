import 'dart:math';

class APTInfo extends Comparable {
  String name, address, code;
  APTInfo(this.name, this.address, this.code);
  static APTInfo parse(dynamic obj) {
    return APTInfo(obj["name"], obj["address"], obj["code"]);
  }

  @override
  int compareTo(other) {
    return this.name.compareTo(other.name);
  }
}
