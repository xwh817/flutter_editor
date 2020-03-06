import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';
import 'package:quill_delta/quill_delta.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  @override
  void initState() {
    print('initState');
    _controller.document.changes.listen((change) {
      //获取数据的方式有一些
      /* _delta = _controller.document.toDelta();
        json = _controller.document.toJson();
        plainText = _controller.document.toPlainText();
         */
      //String string = _controller.document.toString();
      // 注意加上这行，文本变化的时候，可能会刷新下面的按钮。
      setState(() {});
    });
    super.initState();
  }

  MediaQueryData mediaQueryData;

  @override
  Widget build(BuildContext context) {
    if (mediaQueryData == null) {
      mediaQueryData = MediaQuery.of(context);
      final size = mediaQueryData.size;
      print("屏幕宽度：${size.width}, 密度：${mediaQueryData.devicePixelRatio}");

      // 屏幕适配
      ScreenUtil.init(context);
      // allowFontScaling设置字体大小根据系统的“字体大小”辅助选项来进行缩放,默认为false
      ScreenUtil.init(context, width: 360, height: 640);
    }

    final result = Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(ScreenUtil().setHeight(40)),
        child:AppBar(
        elevation: 0.5,
        actions: [
          Container(
            width: ScreenUtil().setWidth(90),
            child: FlatButton(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Text('草稿箱',
                  style: TextStyle(fontSize: ScreenUtil().setSp(16))),
              onPressed: () {},
            ),
          ),
          Container(
            width: ScreenUtil().setWidth(60),
            margin: EdgeInsets.only(right: 6),
            child: FlatButton(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: Text('发表', style: TextStyle(fontSize: ScreenUtil().setSp(16))),
              onPressed: () {
                String text = _controller.document.toJson().toString();
                print("发表：$text");
              },
            ),
          ),
        ],
      )),
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
      return Theme(
          data: ThemeData(
              brightness: Brightness.dark,
              primaryColorBrightness: Brightness.dark,
              appBarTheme: AppBarTheme(
                color: Colors.black12,
              )),
          child: result);
    } else {
      return Theme(
          data: ThemeData(
              brightness: Brightness.light,
              primaryColorBrightness: Brightness.light,
              appBarTheme: AppBarTheme(
                  color: Colors.white,
                  iconTheme:
                      IconThemeData(color: Colors.black.withOpacity(0.6)))),
          child: result);
    }
  }
}
