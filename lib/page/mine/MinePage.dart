import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../widget/LimitSettingDialog.dart';
import 'LimitCard.dart';

class MinePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MinePageState();
  }
}

class MinePageState extends State<MinePage> {
  static const TextStyle tipTextStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black);


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 255, 210, 220),
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage("images/m.png"),
          fit: BoxFit.fill,
        )),
        child: NestedScrollView(
            headerSliverBuilder: _sliverBuilder,
            body: Container(
              margin: const EdgeInsets.fromLTRB(0, 100, 0, 0),
              child: Column(
                children: <Widget>[
                  //每月限制
                  LimitCard(LimitSettingDialog.MONTHLIMIT),
                  LimitCard(LimitSettingDialog.DAYLIMIT)
                ],
              ),
            )),
      ),
    );
  }



  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        //展开高度
        expandedHeight: 150.0,
        //是否固定在顶部
        pinned: false,
        snap: true,
        //是否随着滑动隐藏标题
        floating: true,
        flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Container(
              margin: const EdgeInsets.only(top: 20),
              child: Text("Biu",
                  style: TextStyle(
                    fontSize: 80,
                    fontFamily: 'orangejuice',
                    color: Colors.white,
                    backgroundColor: Colors.transparent,
                  )),
            )),
      ),
    ];
  }
}
