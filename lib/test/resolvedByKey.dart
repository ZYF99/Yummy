import 'package:flutter/material.dart';

void main() => runApp(DemoApp());

class DemoApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DemoAppState();
  }
}

class _DemoAppState extends State<DemoApp> {
  GlobalKey<DemoPageState> _demoPageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: Scaffold(
        body: Scaffold(
          body:
              DemoPage(key: _demoPageKey, title: "Test",  count: 30),
        ),
        floatingActionButton: FloatingActionButton(onPressed: () {
/*          setState(() {
            data = "setState";
          });*/

          _demoPageKey.currentState.changeText("上级Widget直接改变子Widget的Text");
        }),
      ),
    );
  }
}

class DemoPage extends StatefulWidget {


  const DemoPage({Key key, this.title, this.count})
      : super(key: key);

  final String title;

  final int count;
  @override
  DemoPageState createState() => DemoPageState();
}

class DemoPageState extends State<DemoPage> {
  String data = "init";

  DemoPageState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: new ListView.builder(
          itemBuilder: (context, index) {
            return new Text(getText());
          },
          itemCount: widget.count,
        )
// This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  changeText(String newText) {
    setState(() {
      data = newText;
    });
  }

  getText() {
    return data;
  }
}
