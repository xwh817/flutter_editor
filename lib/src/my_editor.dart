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

  @override
  Widget build(BuildContext context) {
    final form = Column(
      children: <Widget>[
        TextField(
            keyboardType: TextInputType.multiline,
            maxLines: null, // 通过设置keyboardType自动换行
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            decoration: InputDecoration(
                hintText: '请输入标题',
                hintStyle: TextStyle(color: Colors.black38, fontWeight: FontWeight.normal),
                border: InputBorder.none,
                contentPadding: EdgeInsets.fromLTRB(16, 24, 16, 0),
                )),
                //Container(height: 20, color: Colors.green,),
        buildEditor(),
      ],
    );

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
              child: Text('草稿箱', style: TextStyle(color: Colors.white60)),
              onPressed: () {},
            ),
          ),
          Container(
            width: 72,
            margin: EdgeInsets.only(right: 6),
            child: FlatButton(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Text('发表', style: TextStyle(color: Colors.white)),
              onPressed: () {
                String text = _controller.document.toJson().toString();
                print("发表：$text");
              },
            ),
          ),
        ],
      ),
      body: ZefyrScaffold(
        /* child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: form,
        ), */
        child:form,
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
    return Expanded(
        child: Stack(
      children: <Widget>[
        ZefyrField(
          height: double.infinity,        
          decoration: InputDecoration(
              hintText: '', // 去掉默认的hint，不知道为啥就是不能顶部对齐。
              border: InputBorder.none),
          controller: _controller,
          focusNode: _focusNode,
          autofocus: false,
          imageDelegate: CustomImageDelegate(),
          physics: ClampingScrollPhysics(),
        ),
        Positioned(
            top: 20,
            left: 16,
            child: IgnorePointer(
                // 使用IgnorePointer不响应事件，防止挡住后面。
                child: Text(this.showHint ? '开始讲述你的故事...' : '',
                    style: TextStyle(color: Colors.black38, fontSize: 15)))),
      ],
    ));
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
