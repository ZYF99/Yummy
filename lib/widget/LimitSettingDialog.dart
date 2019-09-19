import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sample/Utils/SharedUtil.dart';

class LimitSettingDialog extends StatefulWidget {
  final Function onConfirmClick;
  final Function onCancelClick;
  final int limitType;
  static const int MONTHLIMIT = 0;
  static const int DAYLIMIT = 1;

  const LimitSettingDialog(
      {Key key, this.onConfirmClick, this.onCancelClick, this.limitType})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LimitSettingDialogState();
  }
}

class LimitSettingDialogState extends State<LimitSettingDialog> {
  bool isInit = true;
  double _sliderValue = 100;

  double getSliderValue() {
    if (isInit) {
      isInit = false;
      if (widget.limitType == LimitSettingDialog.DAYLIMIT) {
        return 200;
      } else {
        return 3000;
      }
    } else {
      return _sliderValue;
    }
  }

  @override
  void initState() {
    super.initState();
    SharedUtil.getLimit(widget.limitType).then((newValue) {
      setState(() {
        _sliderValue = newValue;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      //创建透明层
      type: MaterialType.transparency, //透明类型
      child: new Center(
        //保证控件居中效果
        child: new Container(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
            width: 300,
            height: 200,
            decoration: ShapeDecoration(
              color: Color(0xffffffff),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
            ),
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Column(
                    children: <Widget>[
                      Text(
                        getTitle(),
                        style: new TextStyle(fontSize: 18.0),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                        child: Slider(
                          divisions: getDivisions(),
                          value: getSliderValue(),
                          max: getMaxValue(),
                          min: getMinValue(),
                          activeColor: Colors.orange,
                          onChanged: (double val) {
                            this.setState(() {
                              this._sliderValue = val;
                            });
                          },
                          label: "${getSliderValue().floor()} 元",
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                    child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Row(
                    children: <Widget>[
                      //取消
                      Expanded(
                          child: FlatButton(
                              onPressed: () {
                                widget.onCancelClick();
                              },
                              child: Text(
                                "取消",
                                style: TextStyle(fontSize: 20.0),
                              ))),
                      //确定
                      Expanded(
                          child: FlatButton(
                              onPressed: () {
                                widget.onConfirmClick(getSliderValue());
                              },
                              child: Text(
                                "确定",
                                style: TextStyle(fontSize: 20.0),
                              )))
                    ],
                  ),
                ))
              ],
            ))),
      ),
    );
  }

  double getMaxValue() {
    if (widget.limitType == LimitSettingDialog.DAYLIMIT) {
      return 200;
    } else {
      return 3000;
    }
  }

  double getMinValue() {
    if (widget.limitType == LimitSettingDialog.DAYLIMIT) {
      return 10;
    } else {
      return 500;
    }
  }

  String getTitle() {
    if (widget.limitType == LimitSettingDialog.MONTHLIMIT) {
      return "每月上限";
    } else {
      return "每日上限";
    }
  }

  int getDivisions() {
    int interval = 0;
    if (widget.limitType == LimitSettingDialog.DAYLIMIT) {
      interval = 10;
    } else {
      interval = 100;
    }
    return (getMaxValue() - getMinValue()) ~/ interval;
  }
}
