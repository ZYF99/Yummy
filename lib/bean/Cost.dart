//一笔消费
class Cost {
  int id;
  int dateTime;
  String name;
  double money;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();

    map['dateTime'] = dateTime;
    map['name'] = name;
    map['money'] = money;
    return map;
  }

  static Cost fromMap(Map<String, dynamic> map) {
    Cost cost = new Cost();
    cost.id = map["id"];
    cost.dateTime = map["dateTime"];
    cost.name = map["name"];
    cost.money = map["money"];

    return cost;
  }

  static List<Cost> fromMapList(dynamic mapList) {
    List<Cost> list = new List(mapList.length);
    for (int i = 0; i < mapList.length; i++) {
      list[i] = fromMap(mapList[i]);
    }
    return list;
  }
}
