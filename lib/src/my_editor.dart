// Copyright (c) 2018, the Zefyr project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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

  @override
  Widget build(BuildContext context) {
    final form = ListView(
      children: <Widget>[
        TextField(decoration: InputDecoration(hintText: '请输入标题')),
        buildEditor()
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
            margin: EdgeInsets.only(right:6),
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
          padding: const EdgeInsets.all(8.0),
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
    return ZefyrField(
      height: 200.0,
      decoration: InputDecoration(hintText: '开始讲述你的故事...'),
      controller: _controller,
      focusNode: _focusNode,
      autofocus: false,
      imageDelegate: CustomImageDelegate(),
      physics: ClampingScrollPhysics(),
    );
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
