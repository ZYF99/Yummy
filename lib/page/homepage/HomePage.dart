
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:flutter_sample/bean/Cost.dart';
import '../../DatabaseHelper.dart';
import 'DateCard.dart';

//首页
class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  static const TextStyle titleStyle = TextStyle(
      fontSize: 40, color: Colors.white, fontFamily: 'adam_gorry_lights');

  String title = "Yummy";

  List<MyTab> tabList = [];

  changeState() {
    print("datePage刷新！");
    tabList.forEach((tab) {
      _query(tab);
    });
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh(){
    getTabList(DateTime.now());
    _tabController = new TabController(vsync: this, length: tabList.length);
    tabList.forEach((tab) {
      _query(tab);
    });
  }


  //获取Tab列表
  getTabList(DateTime dateTime) {
    DateTime endTime = dateTime;
    print("now   $endTime");
    List<MyTab> list = [];
    DateTime subDateTime = endTime;
    for (int i = 0; i < 15; i++) {
      MyTab myTab = MyTab();
      myTab.dateTime = subDateTime;
      myTab.costList = [];
      list.add(myTab);
      subDateTime = subDateTime.subtract(new Duration(days: 1));
    }
    tabList = list;
  }

  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
        backgroundColor: Color.fromARGB(255, 255, 210, 220),
        //展开高度
        expandedHeight: 180.0,
        //是否固定在顶部
        pinned: true,
        snap: true,
        //是否随着滑动隐藏标题
        floating: true,
        flexibleSpace: FlexibleSpaceBar(
            //centerTitle: true,
            title: Container(
          padding: const EdgeInsets.only(bottom: 56.0),
          child: Text(title, style: titleStyle),
        )),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96.0),
          child: new Theme(
            data: Theme.of(context).copyWith(accentColor: Colors.white),
            child: new Container(
                height: 96.0,
                child: Column(
                  children: <Widget>[
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                            margin: const EdgeInsets.only(left: 20),
                            child: Row(
                              children: <Widget>[
                                IconButton(
                                    iconSize: 25,
                                    icon: Icon(Icons.date_range,
                                        color: Colors.white),
                                    onPressed: () {
                                      showPickerDate(context);
                                    }),
                                Text(
                                  "最近15天的记录",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ))),
                    TabBar(
                        isScrollable: true,
                        controller: _tabController,
                        labelColor: Colors.white,
                        indicatorColor: Colors.white,
                        tabs: tabList.map((MyTab tab) {
                          return new Tab(
                            text: "${tab.dateTime.month}月${tab.dateTime.day}日",
                          );
                        }).toList())
                  ],
                )),
          ),
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage("images/bg.jpg"),
        fit: BoxFit.fill,
      )),
      child: NestedScrollView(
          headerSliverBuilder: _sliverBuilder,
          body: Container(
            child: TabBarView(
              controller: _tabController,
              children: getTabs(),
            ),
          )),
    );
  }

  List<Widget> getTabs() {
    List<Widget> list = [];
    for (int i = 0; i < tabList.length; i++) {
      list.add(DateCard(
        costList: tabList[i].costList,
        dateTime: tabList[i].dateTime,
        notifyCallBack: () {
          setState(() {
            getTabList(DateTime.now());
            tabList.forEach((tab) {
              _query(tab);
            });
          });
        },
      ));
    }

    return list;
  }

  _query(MyTab tab) async {
    var db = DatabaseHelper();
    List<Cost> costList = [];
    List tempList = await db.getDayCosts(tab.dateTime);
    if (tempList.length > 0) {
      costList = Cost.fromMapList(tempList);
    }
    //await db.close();
    setState(() {
      tabList[tabList.indexOf(tab)].costList = costList;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  showPickerDate(BuildContext context) {
    new Picker(
        hideHeader: true,
        adapter: new DateTimePickerAdapter(type: 7),
        title: new Text("你想看哪天的记录？"),
        onConfirm: (Picker picker, List value) {
          setState(() {
            getTabList((picker.adapter as DateTimePickerAdapter).value);
            tabList.forEach((tab) {
              _query(tab);
            });
          });
        }).showDialog(context);
  }
}
