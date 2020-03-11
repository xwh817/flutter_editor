import 'package:flutter/material.dart';

class TestScroll extends StatelessWidget {
  TestScroll() {
    init();
  }

  final TextEditingController _editingController = TextEditingController();
  void init() {
    _editingController.addListener(() {
      //print('Editing: ' + _editingController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
            child: ListBody(children: <Widget>[
          Container(height: 200, color: Colors.green),
          Container(height: 200, color: Colors.red),
          _buildItem(controller:_editingController),
          _buildItem(),
          _buildItem(),
          Container(height: 200, color: Colors.orange),
          Container(height: 200, color: Colors.pink),
          Container(height: 200, color: Colors.deepPurple),
        ])));
  }

  Widget _buildItem({TextEditingController controller}) {
    return Container(
      //height: 200,
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        keyboardType: TextInputType.multiline,
        maxLines: null,
        controller: controller,
        focusNode: FocusNode(
          onKey:(focusNode, event) {
            print('onKey: $event');
            return false;
          }
        ),
        style: TextStyle(height: 1.5, fontSize: 18),
        decoration:
            InputDecoration(border: InputBorder.none), // 通过设置keyboardType自动换行
      ),
    );
  }
}
