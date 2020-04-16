// Copyright (c) 2018, the Zefyr project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:notus/notus.dart';

import 'paragraph.dart';
import 'theme.dart';

/// Represents a quote block in a Zefyr editor.
class ZefyrQuote extends StatelessWidget {
  const ZefyrQuote({Key key, @required this.node}) : super(key: key);

  final BlockNode node;

  @override
  Widget build(BuildContext context) {
    final theme = ZefyrTheme.of(context);
    final style = theme.attributeTheme.quote.textStyle;
    List<Widget> items = [];
    items.add(Align(
        child: ImageIcon(AssetImage("images/quote.png", package: 'zefyr'),color: style.color, size: 16),
        alignment: Alignment.centerLeft));
    for (var line in node.children) {
      items.add(_buildLine(context, line, style, theme.indentWidth));
    }

    return Padding(
      padding: theme.attributeTheme.quote.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items,
      ),
    );
  }

  Widget _buildLine(BuildContext context, Node node, TextStyle blockStyle,
      double indentSize) {
    LineNode line = node;

    Widget content;
    if (line.style.contains(NotusAttribute.heading)) {
      content = ZefyrHeading(node: line, blockStyle: blockStyle);
    } else {
      content = ZefyrParagraph(node: line, blockStyle: blockStyle);
    }

    return content;

    //final row = Row(children: <Widget>[Expanded(child: content)]);
    /* return Container(
      decoration: BoxDecoration(
        color: Color(ZefyrTheme.isThemeDark(context) ? 0x11666666 : 0xFFF6F6F6),
        /* border: Border(
          left: BorderSide(width: 4.0, color: Color(0xFF8E8E8E)),
        ), */
      ),
      padding: EdgeInsets.only(left: indentSize),
      child: content,
    ); */
  }
}
