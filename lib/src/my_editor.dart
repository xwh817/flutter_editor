import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';
import 'package:quill_delta/quill_delta.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'images.dart';

class MyEditorPage extends StatefulWidget {
  final bool darkTheme;
  final bool inited;
  MyEditorPage({Key key, this.darkTheme = false, this.inited = false})
      : super(key: key);

  @override
  _MyEditorPageState createState() => _MyEditorPageState();
}

class _MyEditorPageState extends State<MyEditorPage> {
  ZefyrController _controller;
  final FocusNode _focusNode = FocusNode();
  String _title;

  Delta getDelta() {
    String initText = r'[{"title":"好好学习天天向上"},{"insert":"我们要好好学习天天向上好好学习天天向上好好学习天天向上。\n"},{"insert":"​","attributes":{"embed":{"type":"hr"}}},{"insert":"\n1111"},{"insert":"\n","attributes":{"block":"ul"}},{"insert":"2222222"},{"insert":"\n","attributes":{"block":"ul"}},{"insert":"33333333"},{"insert":"\n","attributes":{"block":"ul"}},{"insert":"好好学习天天向上好好学习天天向上好好学习天天向上好好学习天天向上好好学习天天向上。"},{"insert":"\n","attributes":{"block":"quote"}},{"insert":"很长很长的段落很长很长的文本很长很长的段落很长很长的文本很长很长的段落很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本很长很长的文本\n"}]';
    //String initText = r'[{"title":"好好学习天天向上"},{"insert":"123我们要好好学习天天向上好好学习天天向上好好学习天天向上。    我们要好好学习天天向上好好学习天天向上好好学习天天向上。我们要好好学习天天向上好好学习天天向上好好学习天天向上。我们要好好学习天天向上好好学习天天向上好好学习天天向上。我们要好好学习天天向上好好学习天天向上好好学习天天向上。我们要好好学习天天向上好好学习天天向上好好学习天天向上。我们要好好学习天天向上好好学习天天向上好好学习天天向上。我们要好好学习天天向上好好学习天天向上好好学习天天向上。我们要好好学习天天向上好好学习天天向上好好学习天天向上。我们要好好学习天天向上好好学习天天向上好好学习天天向上。我们要好好学习天天向上好好学习天天向上好好学习天天向上。我们要好好学习天天向上好好学习天天向上好好学习天天向上。我们要好好学习天天向上好好学习天天向上好好学习天天向上。我们要好好学习天天向上好好学习天天向上好好学习天天向上。我们要好好学习天天向上好好学习天天向上好好学习天天向上。我们要好好学习天天向上123。\n"}]';
    List items = json.decode(initText) as List;
    _title = items[0]['title'];
    return Delta.fromJson(items.sublist(1));
  }

  @override
  void initState() {
    //print('initState');
    resetStatic();

    _controller = ZefyrController(
        widget.inited ? NotusDocument.fromDelta(getDelta()) : NotusDocument());
    _controller.document.changes.listen((change) {
      // 注意加上这行，文本变化的时候，可能会刷新下面的按钮。
      setState(() {});
    });
    if (_title != null) {
      _controller.title = _title;
    }
    super.initState();
  }

  /// 为了在之前的代码上实现功能，添加了一写static变量来传递值，注意每次打开要恢复。
  void resetStatic() {
    ZefyrLine.caretPosition = 0.0;
    ZefyrLine.fullHeight = 0.0;
    ZefyrController.titleHeight = 50.0;
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

    TextStyle buttonStyle = TextStyle(
        color: Color(widget.darkTheme ? 0xDEFFFFFF : 0xDE000000),
        fontSize: ScreenUtil().setSp(16));

    TextStyle buttonStyleGrey = TextStyle(
        color: Color(widget.darkTheme ? 0x99FFFFFF : 0x99000000),
        fontSize: ScreenUtil().setSp(16));

    final result = Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(ScreenUtil().setHeight(40)),
          child: AppBar(
            elevation: 0.5,
            actions: [
              Container(
                width: ScreenUtil().setWidth(90),
                child: FlatButton(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: Text('草稿箱', style: buttonStyleGrey),
                  onPressed: () {
                    
                  },
                ),
              ),
              Container(
                width: ScreenUtil().setWidth(60),
                margin: EdgeInsets.only(right: 6),
                child: FlatButton(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: Text('发表', style: buttonStyle),
                  onPressed: () {
                    String text = _controller.document.toJsonText(_controller.title);
                    print("发表：${_controller.document.length}, content:$text");
                    if (_controller.document.length <= 1) {
                      _showInfoDialog('您需要先写点东西，然后才能发表哦');
                    } else if (_controller.title.length ==0) {
                      _showInfoDialog('您需要填写标题哦');
                    }

                  },
                ),
              ),
            ],
          )),
      body: ZefyrScaffold(
        child: ZefyrField(
          height: double.infinity,
          controller: _controller,
          focusNode: _focusNode,
          autofocus: false,
          imageDelegate: CustomImageDelegate(),
          physics: ClampingScrollPhysics(),
          //mode: widget.inited ? ZefyrMode.select : ZefyrMode.edit,
        ),
      ),
    );

    if (widget.darkTheme) {
      return Theme(
          data: ThemeData(
              brightness: Brightness.dark,
              primaryColorBrightness: Brightness.dark,
              appBarTheme: AppBarTheme(
                  color: Color(0xFF282828),
                  iconTheme: IconThemeData(color: Color(0x99FFFFFF)))),
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

  void _showInfoDialog(String info) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => AlertDialog(
              contentPadding: EdgeInsets.fromLTRB(24, 24, 16, 16),
              backgroundColor:
                  widget.darkTheme ? Color(0x66ffffff) : Colors.white,
              content: Text(info,
                  style:
                      TextStyle(fontSize: ScreenUtil().setSp(17), height: 1.5)),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("我知道了",
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: ScreenUtil().setSp(16))),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                SizedBox(width: 2)
              ],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30))),
            ));
  }
}
