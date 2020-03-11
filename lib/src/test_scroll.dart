import 'package:flutter/material.dart';

class TestScroll extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
            child: ListBody(children: <Widget>[
          Container(height: 200, color: Colors.green),
          Container(height: 200, color: Colors.red),
          _buildItem(),
          _buildItem(),
          _buildItem(),
          Container(height: 200, color: Colors.orange),
          Container(height: 200, color: Colors.pink),
          Container(height: 200, color: Colors.deepPurple),
        ])));
  }

  Widget _buildItem() {
    return Container(
      //height: 200,
      child: TextField(
        keyboardType: TextInputType.multiline,
        maxLines: null,
        decoration: InputDecoration(border: InputBorder.none), // 通过设置keyboardType自动换行
      ),
    );
  }
}
