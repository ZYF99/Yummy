import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:flutter_sample/bean/Cost.dart';
import 'package:flutter_sample/DatabaseHelper.dart';
import 'package:flutter_sample/page/homepage/HomePage.dart';
import 'package:flutter_sample/page/mine/MinePage.dart';

void main() {
  runApp(MyApp());
  if (Platform.isAndroid) {
    // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sample App',
      theme: new ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final GlobalKey<HomePageState> datePageKey = GlobalKey();
  static int _navigatorSelectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  List<Widget> _navigatorPage() {
    return <Widget>[
      HomePage(
        key: datePageKey,
      ),
      null,
      MinePage()
    ];
  }

  void _onItemTapped(int index) {
    if (index != 1) {
      setState(() {
        _navigatorSelectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: _navigatorPage().elementAt(_navigatorSelectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 10,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.list), title: Text('账单')),
            BottomNavigationBarItem(icon: Icon(Icons.remove), title: Text('')),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), title: Text('个人')),
          ],
          currentIndex: _navigatorSelectedIndex,
          selectedItemColor: Color.fromARGB(255, 255, 210, 220),
          onTap: _onItemTapped,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              elevation: 5,
              onPressed: () {
                showAddRecordSheet();
              },
              child: Container(
                width: 60,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: ExactAssetImage(
                      'images/icon_mao.png',
                    )),
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white),
              )),
        ));
  }

  //添加记录的弹窗******************************************
  void showAddRecordSheet() {
    showModalBottomSheet(
      backgroundColor: Color.fromARGB(125, 255, 210, 220),
      context: context,
      shape: RoundedRectangleBorder(
          side: BorderSide.none, borderRadius: BorderRadius.circular(16.0)),
      builder: (BuildContext context) {
        return RecordSheet(
          onConfirmClick: () {
            datePageKey.currentState.changeState();
          },
        );
      },
    );
  }
}

//添加记录的弹窗
class RecordSheet extends StatefulWidget {
  final Function onConfirmClick;

  const RecordSheet({Key key, this.onConfirmClick}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RecordSheetState();
  }
}

class RecordSheetState extends State<RecordSheet> {
  String _type = "选择类型";
  final textController = TextEditingController();

  Color _typeColor = Colors.grey;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/popgirl.png"),
            fit: BoxFit.fitHeight,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(64.0, 40.0, 80.0, 72.0),
        child: Column(
          children: <Widget>[
            createCostInputWidget(),
            createTypeWidget(),
            createSubButton(),
          ],
        ));
  }

  Widget createCostInputWidget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
      child: TextField(
          controller: textController,
          maxLength: 8,
          keyboardType: TextInputType.numberWithOptions(signed: true,decimal: false),
          // 设置字体样式
          textAlign: TextAlign.center,
          //输入的内容在水平方向如何显示
          decoration: new InputDecoration(
            labelText: "消费",
            icon: new Icon(Icons.attach_money),
            border: new OutlineInputBorder(),
            // 边框样式
            //helperText: 'required',
            hintText: '请输入花费',
          ),
          inputFormatters: <TextInputFormatter>[
            WhitelistingTextInputFormatter(RegExp("[0-9.]")), //只输入数字
            LengthLimitingTextInputFormatter(8) //限制长度
          ]),
    );
  }

  Widget createTypeWidget() {
    return Center(
        child: Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              children: <Widget>[
                Icon(Icons.list, size: 25, color: _typeColor),
                Expanded(
                    child: GestureDetector(
                        onTap: () {
                          showTypePicker(context);
                          _typeColor = Colors.orange;
                          setState(() {});
                        },
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                          padding: const EdgeInsets.all(16.0),
                          child: Text(_type,
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16)),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              border:
                                  Border.all(color: _typeColor, width: 1.0)),
                        )))
              ],
            )));
  }

  Widget createSubButton() {
    return Expanded(
        child: Container(
            margin: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
            child: IconButton(
              iconSize: 60,
              onPressed: () async {
                _add();
              },
              color: Colors.white,
              icon: Icon(Icons.check_circle),
            )));
  }

  Future<Null> _add() async {
    if (_type != "选择类型" && textController.text.length > 0) {
      Cost cost = new Cost();
      cost.dateTime = DateTime.now().millisecondsSinceEpoch;
      cost.name = _type;
      cost.money = double.parse(textController.text);
      var db = DatabaseHelper();
      await db.saveCost(cost);
      //await db.close();
      Navigator.of(context).pop();
    } else {
      _typeColor = Color.fromARGB(255, 255, 210, 220);
    }
    widget.onConfirmClick();
  }

  showTypePicker(BuildContext context) {
    const PickerData2 = '''
[
    [
        "吃饭饭",
        "交通",
        "学习",
        "购物",
        "社交",
        "娱乐",
        "健身"
    ]
]
    ''';

    new Picker(
        adapter: PickerDataAdapter<String>(
            pickerdata: new JsonDecoder().convert(PickerData2), isArray: true),
        changeToFirst: true,
        hideHeader: true,
        title: new Text("你买了啥？"),
        onConfirm: (Picker picker, List value) {
          setState(() {
            _type = picker.getSelectedValues()[0];
          });
          _typeColor = Colors.grey;
        },
        onCancel: () {
          _typeColor = Colors.grey;
        }).showDialog(context);
  }
}
