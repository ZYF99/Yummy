import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sample/bean/Cost.dart';
import 'package:flutter_sample/widget/ListPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../DatabaseHelper.dart';

//每日的消费界面
class DateCard extends StatefulWidget {
  const DateCard({Key key, this.costList, this.dateTime, this.notifyCallBack}) : super(key: key);

  final notifyCallBack;
  final DateTime dateTime;
  final List<Cost> costList;

  @override
  State<StatefulWidget> createState() {
    return _DateCardState(costList);
  }
}

class _DateCardState extends State<DateCard> {
  _DateCardState(List<Cost> _costList);

  String _tvBalance = "等待";

  static const TextStyle nameStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white);

  static const TextStyle textStyle = TextStyle(
      fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Container(
      child: ListPage(widget.costList,
          headerList: [createHeader()], itemWidgetCreator: createCostItem,
          headerCreator: (BuildContext context, int position) {
        if (position == 0) {
          return createHeader();
        } else {
          return null;
        }
      }),
    )
        //ListPage(_costList, //错误示范

        );
  }

  Widget createHeader() {
    double _balance = 0;

    void _getLimit() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      _balance = preferences.getDouble('dayLimit');
      bool dayLimitSwitch = preferences.getBool('dayLimitSwitch');
      _tvBalance = "$_balance";

      if (dayLimitSwitch != null && dayLimitSwitch && _balance != null) {
        widget.costList.forEach((cost) {
          if (_balance > cost.money) {
            _balance -= cost.money;
          } else {
            _balance = 0;
          }
        });
        if (_balance > 0) {
          _tvBalance = "来自阿峰的提醒！\n今天还有 $_balance 元可以用～";
        } else {
          _tvBalance = "今天已经没有钱可以用了！";
        }
      } else {
        _tvBalance = "你还没设置上限的嘛";
      }
      if (mounted) {
        setState(() {});
      }
    }

    _getLimit();

    return Container(
      child: Text(
        _tvBalance,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 14,
            color: Colors.white,
            backgroundColor: Colors.transparent,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget createCostItem(BuildContext context, int pos) {
    Cost cost = widget.costList[pos];
    return GestureDetector(
      onLongPress: () {
        showDeleteDialog(cost.id);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(32, 20, 32, 0),
        child: Card(
            elevation: 10,
            color: Color.fromARGB(230, 255, 210, 220),
            child: Container(
                child: Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                            child: new Text("${cost.name}", style: nameStyle)),
                        new Icon(Icons.attach_money,
                            size: 25.0, color: textStyle.color),
                        new Text("${cost.money}", style: textStyle),
                      ],
                    ),
                    Container(
                        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                  child: Align(
                                alignment: Alignment.centerRight,
                                child: Icon(Icons.access_time,
                                    size: 18.0, color: Colors.white),
                              )),
                              Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Text(_getTime(cost.dateTime),
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12))),
                            ],
                          ),
                        ))
                  ],
                ),
              ),
            ))),
      ),
    );
  }

  //展示删除弹窗
  showDeleteDialog(int id) {
    _deleteCostRecord() async {
      var db = DatabaseHelper();
      db.deleteCost(id);
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('你正在删除记录'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('删除此记录将永远不能恢复，真的要删除吗？'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                  child: Text('取消'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              FlatButton(
                  child: Text('删除'),
                  onPressed: () {
                    _deleteCostRecord();
                    widget.notifyCallBack();
                    Navigator.of(context).pop();
                  })
            ],
          );
        });

  }

  String _getTime(int mill) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(mill);
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }
}

class MyTab {
  DateTime dateTime;
  List<Cost> costList;
}
