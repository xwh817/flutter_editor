// Copyright (c) 2018, the Zefyr project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:zefyr/zefyr.dart';

import 'images.dart';


class FullPageEditorScreen extends StatefulWidget {
  @override
  _FullPageEditorScreenState createState() => _FullPageEditorScreenState();
}


final doc =
    r'[{"insert":""},{"insert":"\n"}]';


Delta getDelta() {
  return Delta.fromJson(json.decode(doc) as List);
}

enum _Options { darkTheme }

class _FullPageEditorScreenState extends State<FullPageEditorScreen> {
  final ZefyrController _controller =
      ZefyrController(NotusDocument.fromDelta(getDelta()));
  final FocusNode _focusNode = FocusNode();
  bool _editing = true;
  StreamSubscription<NotusChange> _sub;
  bool _darkTheme = false;

  @override
  void initState() {
    super.initState();
    _sub = _controller.document.changes.listen((change) {
      print('${change.source}: ${change.change}');
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final done = _editing
        ? IconButton(onPressed: _stopEditing, icon: Icon(Icons.save))
        : IconButton(onPressed: _startEditing, icon: Icon(Icons.edit));
    final result = Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title: Text('FullPage'),
        actions: [
          done,
          PopupMenuButton<_Options>(
            itemBuilder: buildPopupMenu,
            onSelected: handlePopupItemSelected,
          )
        ],
      ),
      body: ZefyrScaffold(
        child: ZefyrEditor(
          controller: _controller,
          focusNode: _focusNode,
          mode: _editing ? ZefyrMode.edit : ZefyrMode.select,
          imageDelegate: CustomImageDelegate(),
          keyboardAppearance: _darkTheme ? Brightness.dark : Brightness.light,
        ),
      ),
    );
    if (_darkTheme) {
      return Theme(data: ThemeData.dark(), child: result);
    }
    return Theme(data: ThemeData(primarySwatch: Colors.cyan), child: result);
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

  void _startEditing() {
    setState(() {
      _editing = true;
    });
  }

  void _stopEditing() {
    setState(() {
      _editing = false;
    });
  }
}
