/*
自身widget管理自己状态
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TapBoxA extends StatefulWidget {
  @override
  _TapBoxAState createState() {
    return new _TapBoxAState();
  }
}

class _TapBoxAState extends State<TapBoxA> {
  bool _aActive = false;

  void _aActiveChanged() {
    setState(() {
      if (_aActive) {
        _aActive = false;
      } else {
        _aActive = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: _aActiveChanged,
      child: new Center(
        child: new Container(
          alignment: Alignment.center,
          width: 200.0,
          height: 200.0,
          child: new Text(
            _aActive ? 'Active' : 'Inactive',
            style: new TextStyle(fontSize: 50.0, color: Colors.white),
          ),
          decoration: new BoxDecoration(
              color: _aActive ? Colors.green[400] : Colors.grey),
        ),
      ),
    );
  }
}


class TapBoxB extends StatelessWidget {
  TapBoxB({Key key, this.bActive: false, this.onChanged}) : super(key: key);
  final bActive;
  final ValueChanged<bool> onChanged;

  void _bActiveChanged() {
    onChanged(!bActive);
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: _bActiveChanged,
      child: new Center(
        child: new Container(
          alignment: Alignment.center,
          width: 200.0,
          height: 200.0,
          child: new Text(
            bActive ? 'Active' : 'Inactive',
            style: new TextStyle(fontSize: 50.0, color: Colors.white),
          ),
          decoration: new BoxDecoration(
              color: bActive ? Colors.green[400] : Colors.grey),
        ),
      ),
    );
  }
}




/*
ParentWidget类是TapBoxB的父widget
他会得知盒子是否被点击从而管理盒子的状态，通过setState更新展示内容
 */
class ParentWidgetB extends StatefulWidget {
  @override
  _ParentWidgetBState createState() {
    return new _ParentWidgetBState();
  }
}

class _ParentWidgetBState extends State<ParentWidgetB> {
  bool _bActive = false;

  void _handleTapBoxBChanged(bool value) {
    setState(() {
      _bActive = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new TapBoxB(
      bActive: _bActive,
      onChanged: _handleTapBoxBChanged,
    );
  }
}




