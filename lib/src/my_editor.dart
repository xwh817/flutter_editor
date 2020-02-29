import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';
import 'package:quill_delta/quill_delta.dart';
import 'dart:convert';

import 'images.dart';

class MyEditorPage extends StatefulWidget {
  final bool darkTheme;
  MyEditorPage(this.darkTheme, {Key key}) : super(key: key);

  @override
  _MyEditorPageState createState() => _MyEditorPageState();
}

String initText;
//String initText = r'[{"insert":"Test"}, {"insert":"\n"}]';

Delta getDelta() {
  return Delta.fromJson(json.decode(initText) as List);
}

class _MyEditorPageState extends State<MyEditorPage> {
  final ZefyrController _controller = ZefyrController(
      initText == null ? NotusDocument() : NotusDocument.fromDelta(getDelta()));
  final FocusNode _focusNode = FocusNode();

  //bool _darkTheme = true;
  bool showHint = initText == null || initText.length == 0;

  @override
  void initState() {
    print('initState');

    _controller.document.changes.listen((change) {
      setState(() {
        //获取数据的方式有一些
        /* _delta = _zefyrController.document.toDelta();
        json = _zefyrController.document.toJson();
        string = _zefyrController.document.toString();
        plainText = _zefyrController.document.toPlainText();
         */
        bool isEmpty = _controller.document.length == 1;
        //print(string.length);

        if (this.showHint != isEmpty) {
          this.setState(() {
            showHint = isEmpty;
          });
        }
      });
    });
    super.initState();
  }

  MediaQueryData mediaQueryData;

  @override
  Widget build(BuildContext context) {

    if (mediaQueryData == null) {
      MediaQueryData mediaQueryData = MediaQuery.of(context);
      final size =mediaQueryData.size;
      
      print("屏幕宽度：${size.width}, 密度：${mediaQueryData.devicePixelRatio}");
    }

    final result = Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        //leading: Icon(Icons.arrow_back_ios, size: 18),
        elevation: 0,
        actions: [
          Container(
            width: 72,
            child: FlatButton(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Text('草稿箱', style: TextStyle(color: Colors.white60, fontSize: 18.0)),
              onPressed: () {},
            ),
          ),
          Container(
            width: 72,
            margin: EdgeInsets.only(right: 6),
            child: FlatButton(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Text('发表', style: TextStyle(color: Colors.white, fontSize: 16.0)),
              onPressed: () {
                String text = _controller.document.toJson().toString();
                print("发表：$text");
              },
            ),
          ),
        ],
      ),
      body: ZefyrScaffold(
        child: ZefyrField(
          height: double.infinity,        
          /* decoration: InputDecoration(
              // 官方为解决的bug https://github.com/memspace/zefyr/issues/93
              hintText: '开始讲述你的故事...', // 去掉默认的hint，不知道为啥就是不能顶部对齐。
              border: InputBorder.none
              ), */
          controller: _controller,
          focusNode: _focusNode,
          autofocus: false,
          imageDelegate: CustomImageDelegate(),
          physics: ClampingScrollPhysics(),
        ),
      ),
    );

    if (widget.darkTheme) {
      return Theme(data: ThemeData.dark(), child: result);
    } else {
      return Theme(data: ThemeData(primarySwatch: Colors.blue), child: result);
    }

    //return result;
  }

  Widget buildEditor() {
    return Stack(
      children: <Widget>[
        ZefyrField(
          height: 200,        
          decoration: InputDecoration(
              // 官方为解决的bug https://github.com/memspace/zefyr/issues/93
              hintText: '开始讲述你的故事...', // 去掉默认的hint，不知道为啥就是不能顶部对齐。
              border: InputBorder.none
              ),
          controller: _controller,
          focusNode: _focusNode,
          autofocus: false,
          imageDelegate: CustomImageDelegate(),
          physics: ClampingScrollPhysics(),
        ),
        /* Positioned(
            top: 60,
            left: 16,
            child: IgnorePointer(
                // 使用IgnorePointer不响应事件，防止挡住后面。
                child: Text(this.showHint ? '开始讲述你的故事...' : '',
                    style: TextStyle(color: Colors.black38, fontSize: 17)))),
       */
      ],
    );
  }

  /* void handlePopupItemSelected(value) {
    if (!mounted) return;
    setState(() {
      if (value == _Options.darkTheme) {
        _darkTheme = !_darkTheme;
      }
    });
  }

  List<PopupMenuEntry<_Options>> buildPopupMenu(BuildContext context) {
    return [
      CheckedPopupMenuItem(
        value: _Options.darkTheme,
        child: Text("Dark theme"),
        checked: _darkTheme,
      ),
    ];
  } */
}
