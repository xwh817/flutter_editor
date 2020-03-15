// Copyright (c) 2018, the Zefyr project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:notus/notus.dart';
import 'package:zefyr/zefyr.dart';

import 'editable_box.dart';
import 'horizontal_rule.dart';
import 'image.dart';
import 'rich_text.dart';
import 'scope.dart';
import 'theme.dart';

/// Represents single line of rich text document in Zefyr editor.
class ZefyrLine extends StatefulWidget {

  static double caretPosition = 0.0;  // 光标在当前段距离段首的位置
  static double fullHeight = 0.0;     // 当前段的高度
  

  const ZefyrLine({Key key, @required this.node, this.style, this.padding})
      : assert(node != null),
        super(key: key);

  /// Line in the document represented by this widget.
  final LineNode node;

  /// Style to apply to this line. Required for lines with text contents,
  /// ignored for lines containing embeds.
  final TextStyle style;

  /// Padding to add around this paragraph.
  final EdgeInsets padding;

  @override
  _ZefyrLineState createState() => _ZefyrLineState();
}


class _ZefyrLineState extends State<ZefyrLine> {
  final LayerLink _link = LayerLink();

  @override
  Widget build(BuildContext context) {
    final scope = ZefyrScope.of(context);
    
    if (scope.isEditable) {
      // 有可能光标位置信息还没更新，这里做延时。
      Future.delayed(Duration(milliseconds: 100), ()=>ensureVisible(context, scope));
    }

    final theme = Theme.of(context);

    Widget content;
    if (widget.node.hasEmbed) {
      content = buildEmbed(context, scope);
    } else {
      assert(widget.style != null);
      content = ZefyrRichText(
        node: widget.node,
        text: buildText(context),
      );
    }

    if (scope.isEditable) {
      Color cursorColor;
      switch (theme.platform) {
        case TargetPlatform.iOS:
          cursorColor ??= CupertinoTheme.of(context).primaryColor;
          break;

        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
          cursorColor = theme.cursorColor;
          break;
      }

      content = EditableBox(
        child: content,
        node: widget.node,
        layerLink: _link,
        renderContext: scope.renderContext,
        showCursor: scope.showCursor,
        selection: scope.selection,
        selectionColor: theme.textSelectionColor,
        cursorColor: cursorColor,
      );
      content = CompositedTransformTarget(link: _link, child: content);
    }

    if (widget.padding != null) {
      return Padding(padding: widget.padding, child: content);
    }
    return content;
  }

  void ensureVisible(BuildContext context, ZefyrScope scope) {
    if (scope.selection.isCollapsed &&
        widget.node.containsOffset(scope.selection.extentOffset)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        bringIntoView(context);
      });
    }
  }

  void bringIntoView(BuildContext context) {
    ScrollableState scrollable = Scrollable.of(context);
    final object = context.findRenderObject();
    assert(object.attached);
    final RenderAbstractViewport viewport = RenderAbstractViewport.of(object);
    assert(viewport != null);

    // offset为界面滚动位置
    final double offset = scrollable.position.pixels;
    double targetTop = viewport.getOffsetToReveal(object, 0.0).offset + ZefyrLine.caretPosition;
    if (targetTop - offset < 0.0) {  // target为输入位置，如果在滚动位置上面，向上滚
      scrollable.position.jumpTo(targetTop);
      //print('targetTop:$targetTop, offset: $offset, jump to top: $targetTop ');
    } else {
      // viewport.getOffsetToReveal(object, 1.0).offset 到这个位置需要滚动的距离（为负数表示当前位置还要向下滚）
      double targetBottom = viewport.getOffsetToReveal(object, 1.0).offset - (ZefyrLine.fullHeight - ZefyrLine.caretPosition) ;
      if ((ZefyrLine.fullHeight > 0.0 ||ZefyrLine.caretPosition==0.0) && targetBottom - offset > 0.0) {
        scrollable.position.jumpTo(targetBottom);
        //print('${DateTime.now().millisecondsSinceEpoch} targetBottom: $targetBottom,  offset: $offset, jump to bottom: $targetBottom  fullHeight: ${ZefyrLine.fullHeight}');
      }
    }

  }

  TextSpan buildText(BuildContext context) {
    final theme = ZefyrTheme.of(context);
    final List<TextSpan> children = widget.node.children
        .map((node) => _segmentToTextSpan(node, theme))
        .toList(growable: false);
    return TextSpan(style: widget.style, children: children);
  }

  TextSpan _segmentToTextSpan(Node node, ZefyrThemeData theme) {
    final TextNode segment = node;
    final attrs = segment.style;

    return TextSpan(
      text: segment.value,
      style: _getTextStyle(attrs, theme),
    );
  }

  TextStyle _getTextStyle(NotusStyle style, ZefyrThemeData theme) {
    TextStyle result = TextStyle();
    if (style.containsSame(NotusAttribute.bold)) {
      result = result.merge(theme.attributeTheme.bold);
    }
    if (style.containsSame(NotusAttribute.italic)) {
      result = result.merge(theme.attributeTheme.italic);
    }
    if (style.contains(NotusAttribute.link)) {
      result = result.merge(theme.attributeTheme.link);
    }
    return result;
  }

  Widget buildEmbed(BuildContext context, ZefyrScope scope) {
    EmbedNode node = widget.node.children.single;
    EmbedAttribute embed = node.style.get(NotusAttribute.embed);

    if (embed.type == EmbedType.horizontalRule) {
      return ZefyrHorizontalRule(ZefyrTheme.isThemeDark(context), node: node);
    } else if (embed.type == EmbedType.image) {
      return ZefyrImage(node: node, delegate: scope.imageDelegate);
    } else {
      throw UnimplementedError('Unimplemented embed type ${embed.type}');
    }
  }
}
