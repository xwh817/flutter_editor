import 'package:flutter/material.dart';
import 'package:markdown_editor/src/form.dart';
import 'package:markdown_editor/src/view.dart';

import 'src/full_page.dart';
import 'src/my_editor.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      routes: {
        "/fullPage": (context) => FullPageEditorScreen(),
        "/form": (context) => FormEmbeddedScreen(),
        "/view": (context) => ViewScreen(),
        "/myEditor": (context) => MyEditorPage(),
      },
    );
  }
}


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final nav = Navigator.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('MD Editor')),
      body: Column(
        children: <Widget>[
          Expanded(child: Container()),
          RaisedButton(
            onPressed: () => nav.pushNamed('/fullPage'),
            child: Text('Full page editor'),
          ),
          RaisedButton(
            onPressed: () => nav.pushNamed('/form'),
            child: Text('Embedded in a form'),
          ),
          RaisedButton(
            onPressed: () => nav.pushNamed('/view'),
            child: Text('Read-only embeddable view'),
          ),
          RaisedButton(
            onPressed: () => nav.pushNamed('/myEditor'),
            child: Text('MyEditor'),
          ),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}
