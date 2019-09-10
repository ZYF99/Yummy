import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sample/Utils/SharedUtil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../DatabaseHelper.dart';
import '../../widget/LimitSettingDialog.dart';

class LimitCard extends StatefulWidget {
  final int type;

  const LimitCard(this.type);

  @override
  State<StatefulWidget> createState() {
    return LimitCardState();
  }
}

class LimitCardState extends State<LimitCard> {
  static const TextStyle tipTextStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black);

  bool _switch = false;
  String _balanceTip = "已开启金额限制～";

  @override
  void initState() {
    super.initState();
    getSwitchState();
    getBalanceTip(DateTime.now(), widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(40, 0, 40, 20),
      child: Card(
        elevation: 10,
        color: Color.fromARGB(220, 255, 255, 255),
        child: Container(
            padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
            child: Column(
              children: <Widget>[
                Offstage(
                  child: Text(_balanceTip),
                  offstage: !_switch,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      getTitle(),
                      style: tipTextStyle,
                    ),
                    Expanded(
                        child: Align(
                            alignment: FractionalOffset.centerRight,
                            child: Switch(
                              value: _switch, //当前状态
                              onChanged: (newValue) {
                                //开启时弹窗
                                if (newValue) {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return LimitSettingDialog(
                                          limitType: widget.type,
                                          onConfirmClick: (limitValue) {
                                            saveLimit(limitValue);
                                            Navigator.of(context).pop();
                                            getBalanceTip(
                                                DateTime.now(), widget.type);
                                          },
                                          onCancelClick: () {
                                            this.setState(() {
                                              saveSwitchState(false);
                                              setSwitchState(false);
                                            });
                                            //saveLimit(0);
                                            Navigator.of(context).pop();
                                          },
                                        );
                                      });
                                }
                                //重新构建页面
                                setState(() {
                                  setSwitchState(newValue);
                                });
                              },
                            )))
                  ],
                )
              ],
            )),
      ),
    );
  }

  getTitle() {
    if (widget.type == LimitSettingDialog.MONTHLIMIT) {
      return "每月上限";
    } else {
      return "每日上限";
    }
  }

  getSwitchState() {
    Future getSwitch() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      setState(() {
        if (widget.type == LimitSettingDialog.MONTHLIMIT) {
          _switch = preferences.getBool('monthLimitSwitch');
        } else {
          _switch = preferences.getBool('dayLimitSwitch');
        }

        if (null == _switch) {
          _switch = false;
        }
      });
    }

    getSwitch();
  }

  //设置限制按钮状态
  setSwitchState(bool value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    this._switch = value;
    if (widget.type == LimitSettingDialog.MONTHLIMIT) {
      preferences.setBool('monthLimitSwitch', value);
    } else {
      preferences.setBool('dayLimitSwitch', value);
    }
  }

  //存储限制金额到本地
  saveLimit(double limitValue) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (widget.type == LimitSettingDialog.MONTHLIMIT) {
      preferences.setDouble('monthLimit', limitValue);
    } else {
      preferences.setDouble('dayLimit', limitValue);
    }
  }

  //存储限制按钮状态到本地
  saveSwitchState(bool value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (widget.type == LimitSettingDialog.MONTHLIMIT) {
      preferences.setBool('monthLimitSwitch', value);
    } else {
      preferences.setBool('dayLimitSwitch', value);
    }
  }

  //获取余额提示
  getBalanceTip(DateTime dateTime, int type) {
    double _balance = 0;
    //从本地shared和数据库读取
    _queryForTotal() async {
      var db = DatabaseHelper();
      List list = [];
      if (type == LimitSettingDialog.MONTHLIMIT) {
        list = await db.getMonthCostsForTotal(DateTime.now());
      } else {
        list = await db.getDayCostsForTotal(DateTime.now());
      }

      SharedUtil.getLimit(type).then((limitValue) {
        _balance = limitValue;

        if (list.length > 0) {
          list.forEach((row) {
            _balance -= row['money'];
          });
        }
        setState(() {
          if (type == LimitSettingDialog.MONTHLIMIT) {
            if (_balance > 0) {
              _balanceTip = "这个月还有 $_balance元 可以用～";
            } else {
              _balanceTip = "这个月已经没有钱可以用了～";
            }
          } else {
            if (_balance > 0) {
              _balanceTip = "今天还有 $_balance元 可以用～";
            } else {
              _balanceTip = "今天已经没有钱可以用了～";
            }
          }
        });
      });
    }

    _queryForTotal();
  }
}
