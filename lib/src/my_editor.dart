// Copyright (c) 2018, the Zefyr project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';

import 'images.dart';

enum _Options { darkTheme }

class MyEditorPage extends StatefulWidget {
  @override
  _MyEditorPageState createState() => _MyEditorPageState();
}

class _MyEditorPageState extends State<MyEditorPage> {
  final ZefyrController _controller = ZefyrController(NotusDocument());
  final FocusNode _focusNode = FocusNode();

  bool _darkTheme = true;
  bool showHint = true;

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
            decoration: InputDecoration(
                hintText: '请输入标题',
                hintStyle: TextStyle(color: Colors.black38, fontSize: 14))),
        buildEditor(),
      ],
    );

    final result = Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
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
              onPressed: () {},
            ),
          ),

          /* PopupMenuButton<_Options>(
            itemBuilder: buildPopupMenu,
            onSelected: handlePopupItemSelected,
          ) */
        ],
      ),
      body: ZefyrScaffold(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: form,
        ),
      ),
    );

    /* if (_darkTheme) {
      return Theme(data: ThemeData.dark(), child: result);
    } else {
      return Theme(data: ThemeData(primarySwatch: Colors.cyan), child: result);
    } */

    return result;
  }

  Widget buildEditor() {
    return Expanded(
        child: Stack(
      children: <Widget>[
        ZefyrField(
          height: 300.0,
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
            child: IgnorePointer(child:Text(this.showHint ? '开始讲述你的故事...' : '',
                style: TextStyle(color: Colors.black38)))),
      ],
    ));
  }

  void handlePopupItemSelected(value) {
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
  }
}
