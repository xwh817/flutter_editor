// Copyright (c) 2018, the Zefyr project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:io';

import 'package:flutter/material.dart';
import 'src/my_editor.dart';

import 'localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(ZefyrApp());
}

List<Locale> an = [
  const Locale('zh', 'CH'),
  const Locale('en', 'US'),
];
List<Locale> ios = [
  const Locale('en', 'US'),
  const Locale('zh', 'CH'),
];

class ZefyrApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Editor',
      home: HomePage(),
      routes: {
        "/editor_light": (context) => MyEditorPage(darkTheme: false),
        "/editor_dark": (context) => MyEditorPage(darkTheme: true),
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        ChineseCupertinoLocalizations.delegate,
      ],
      supportedLocales: Platform.isIOS ? ios : an,
    );
  }

}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final nav = Navigator.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Demo')),
      body: Column(
        children: <Widget>[
          Expanded(child: Container()),
          RaisedButton(
            onPressed: () => nav.pushNamed('/editor_light'),
            child: Text('白天模式'),
          ),
          RaisedButton(
            onPressed: () => nav.pushNamed('/editor_dark'),
            child: Text('夜间模式'),
          ),
          RaisedButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MyEditorPage(darkTheme: false, inited: true))),
            child: Text('打开文章'),
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}
