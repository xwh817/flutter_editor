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
            padding: EdgeInsets.symmetric(horizontal: 12),
            //physics: NeverScrollableScrollPhysics(),
            child: ListBody(children: <Widget>[
              _buildTitle(),
              _buildItem(controller: _editingController),
              _buildItem(),
              _buildItem(),
              Container(height: 200, color: Colors.orange),
              Container(height: 200, color: Colors.pink),
              Container(height: 200, color: Colors.deepPurple),
            ])));
  }

  Widget _buildTitle() {
    return TextField(
        autofocus: true,
        keyboardType: TextInputType.multiline,
        maxLines: null, // 通过设置keyboardType自动换行
        style: TextStyle(
            color: Color(0xDE000000),
            fontWeight: FontWeight.w600,
            fontSize: 20,
            height: 1.25),
        decoration: InputDecoration(
          hintText: '请输入标题',
          hintStyle: TextStyle(
              color: Color(0x99000000), fontWeight: FontWeight.normal),
          border: InputBorder.none,
          contentPadding: EdgeInsets.fromLTRB(0, 16, 0, 8), // 标题的padding
        ));
  }

  Widget _buildItem({TextEditingController controller}) {
    return Container(
      //height: 200,
      child: TextField(
        keyboardType: TextInputType.multiline,
        maxLines: null,
        controller: controller,
        focusNode: FocusNode(onKey: (focusNode, event) {
          print('onKey: $event');
          return false;
        }),
        style: TextStyle(height: 1.5, fontSize: 18),
        decoration:
            InputDecoration(
              hintText: '开始讲述你的故事...',
              border: InputBorder.none), // 通过设置keyboardType自动换行
      ),
    );
  }
}
