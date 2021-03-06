// Copyright (c) 2018, the Zefyr project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notus/notus.dart';

import 'code.dart';
import 'common.dart';
import 'controller.dart';
import 'cursor_timer.dart';
import 'editor.dart';
import 'image.dart';
import 'input.dart';
import 'list.dart';
import 'mode.dart';
import 'paragraph.dart';
import 'quote.dart';
import 'render_context.dart';
import 'scope.dart';
import 'selection.dart';
import 'theme.dart';

/// Core widget responsible for editing Zefyr documents.
///
/// Depends on presence of [ZefyrTheme] and [ZefyrScope] somewhere up the
/// widget tree.
///
/// Consider using [ZefyrEditor] which wraps this widget and adds a toolbar to
/// edit style attributes.
class ZefyrEditableText extends StatefulWidget {
  const ZefyrEditableText({
    Key key,
    @required this.controller,
    @required this.focusNode,
    @required this.imageDelegate,
    this.selectionControls,
    this.autofocus = false,
    this.mode = ZefyrMode.edit,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.physics,
    this.keyboardAppearance = Brightness.light,
  })  : assert(mode != null),
        assert(controller != null),
        assert(focusNode != null),
        assert(keyboardAppearance != null),
        super(key: key);

  /// Controls the document being edited.
  final ZefyrController controller;

  /// Controls whether this editor has keyboard focus.
  final FocusNode focusNode;
  final ZefyrImageDelegate imageDelegate;

  /// Whether this text field should focus itself if nothing else is already
  /// focused.
  ///
  /// If true, the keyboard will open as soon as this text field obtains focus.
  /// Otherwise, the keyboard is only shown after the user taps the text field.
  ///
  /// Defaults to true. Cannot be null.
  final bool autofocus;

  /// Editing mode of this text field.
  final ZefyrMode mode;

  /// Controls physics of scrollable text field.
  final ScrollPhysics physics;

  /// Optional delegate for building the text selection handles and toolbar.
  ///
  /// If not provided then platform-specific implementation is used by default.
  final TextSelectionControls selectionControls;

  /// Padding around editable area.
  final EdgeInsets padding;

  /// The appearance of the keyboard.
  ///
  /// This setting is only honored on iOS devices.
  ///
  /// If unset, defaults to the brightness of [Brightness.light].
  final Brightness keyboardAppearance;

  @override
  _ZefyrEditableTextState createState() => _ZefyrEditableTextState();
}

class _ZefyrEditableTextState extends State<ZefyrEditableText>
    with AutomaticKeepAliveClientMixin {
  //
  // New public members
  //

  /// Document controlled by this widget.
  NotusDocument get document => widget.controller.document;

  /// Current text selection.
  TextSelection get selection => widget.controller.selection;

  FocusNode _focusNode;
  FocusAttachment _focusAttachment;

  bool isEmpty = true; // 内容是否为空

  /// Express interest in interacting with the keyboard.
  ///
  /// If this control is already attached to the keyboard, this function will
  /// request that the keyboard become visible. Otherwise, this function will
  /// ask the focus system that it become focused. If successful in acquiring
  /// focus, the control will then attach to the keyboard and request that the
  /// keyboard become visible.
  void requestKeyboard() {
    if (_focusNode.hasFocus) {
      _input.openConnection(
          widget.controller.plainTextEditingValue, widget.keyboardAppearance);
    } else {
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  void focusOrUnfocusIfNeeded() {
    if (!_didAutoFocus && widget.autofocus && widget.mode.canEdit) {
      FocusScope.of(context).autofocus(_focusNode);
      _didAutoFocus = true;
    }
    if (!widget.mode.canEdit && _focusNode.hasFocus) {
      _didAutoFocus = false;
      _focusNode.unfocus();
    }
  }

  TextSelectionControls defaultSelectionControls(BuildContext context) {
    TargetPlatform platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS) {
      return cupertinoTextSelectionControls;
    }
    return materialTextSelectionControls;
  }

  //
  // Overridden members of State
  //

  @override
  Widget build(BuildContext context) {
    _focusAttachment.reparent();
    super.build(context); // See AutomaticKeepAliveState.

    Widget body = ListBody(children: _buildChildren(context));
    if (widget.padding != null) {
      body = Padding(padding: widget.padding, child: body);
    }

    body = SingleChildScrollView(
      physics: widget.physics,
      controller: _scrollController,
      child: body,
    );

    //return Stack(fit: StackFit.expand, children: layers);
    Color bgColor =
        ZefyrTheme.isThemeDark(context) ? Color(0xFF111111) : Colors.white;
    return Container(
        color: bgColor,
        child: Stack(fit: StackFit.expand, children: [
          body,
          ZefyrSelectionOverlay(
            controls: defaultSelectionControls(context),
          )
        ]));
  }

  @override
  void initState() {
    _focusNode = widget.focusNode;
    super.initState();
    _focusAttachment = _focusNode.attach(context);
    _input = InputConnectionController(_handleRemoteValueChange);
    _updateSubscriptions();

    isEmpty = widget.controller.title.isEmpty;

    _scrollController.addListener((){
      //print('_scrollController: ${_scrollController.offset}');
      ZefyrController.scrollOffset = _scrollController.offset;
    });
  }

  @override
  void didUpdateWidget(ZefyrEditableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_focusNode != widget.focusNode) {
      _focusAttachment.detach();
      _focusNode = widget.focusNode;
      _focusAttachment = _focusNode.attach(context);
    }
    _updateSubscriptions(oldWidget);
    focusOrUnfocusIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = ZefyrScope.of(context);
    if (_renderContext != scope.renderContext) {
      _renderContext?.removeListener(_handleRenderContextChange);
      _renderContext = scope.renderContext;
      _renderContext.addListener(_handleRenderContextChange);
    }
    if (_cursorTimer != scope.cursorTimer) {
      _cursorTimer?.stop();
      _cursorTimer = scope.cursorTimer;
      _cursorTimer.startOrStop(_focusNode, selection);
    }
    focusOrUnfocusIfNeeded();
  }

  @override
  void dispose() {
    _focusAttachment.detach();
    _cancelSubscriptions();
    super.dispose();
  }

  //
  // Overridden members of AutomaticKeepAliveClientMixin
  //

  @override
  bool get wantKeepAlive => _focusNode.hasFocus;

  //
  // Private members
  //

  final ScrollController _scrollController = ScrollController();
  ZefyrRenderContext _renderContext;
  CursorTimer _cursorTimer;
  InputConnectionController _input;
  bool _didAutoFocus = false;

  List<Widget> _buildChildren(BuildContext context) {
    final result = <Widget>[];

    result.add(_buildTitle());

    for (var node in document.root.children) {
      result.add(_defaultChildBuilder(context, node));
    }

    if (result.length > 1) {
      Widget hintTarget = result[1];
      result[1] = _addHintText(hintTarget);
    }

    return result;
  }


  final GlobalKey globalKey = GlobalKey();
  
  Widget _buildTitle() {
    Color textColor =
        Color(ZefyrTheme.isThemeDark(context) ? 0x99FFFFFF : 0xDE000000);
    Color hintTextColor =
        Color(ZefyrTheme.isThemeDark(context) ? 0x66FFFFFF : 0x99000000);

    // 初始化输入框，光标处于最后
    TextEditingController controller = TextEditingController.fromValue(
        TextEditingValue(
            text: widget.controller.title,
            selection: TextSelection.fromPosition(TextPosition(
                affinity: TextAffinity.downstream,
                offset: widget.controller.title.length))));

    return TextField(
        key: globalKey,
        autofocus: widget.controller.title.isEmpty,
        readOnly: !widget.mode.canEdit,
        controller: controller,
        onChanged: (text) {
          widget.controller.title = text;
          ZefyrController.titleHeight = globalKey.currentContext.size.height;
          //print('title height: ${globalKey.currentContext.size.height}');
        },
        keyboardType: TextInputType.multiline,
        maxLines: null, // 通过设置keyboardType自动换行
        style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: ScreenUtil().setSp(20),
            height: 1.25),
        decoration: InputDecoration(
          hintText: '请输入标题',
          hintStyle:
              TextStyle(color: hintTextColor, fontWeight: FontWeight.normal),
          border: InputBorder.none,
          contentPadding: EdgeInsets.fromLTRB(0, 18, 0, 10), // 标题的padding
        ));
  }

  // 控件的hintText居然在底部，只能自己模拟实现了
  Widget _addHintText(Widget target) {
    Color hintTextColor =
        Color(ZefyrTheme.isThemeDark(context) ? 0x66FFFFFF : 0x99000000);
    if (this.isEmpty) {
      return Stack(
        children: <Widget>[
          target,
          Padding(
              padding: EdgeInsets.only(
                  top: ScreenUtil().setHeight(4) +
                      MediaQuery.of(context).devicePixelRatio * 1.5),
              child: Text('开始讲述你的故事...',
                  style: TextStyle(
                      color: hintTextColor, fontSize: ScreenUtil().setSp(18))))
        ],
      );
    } else {
      return target;
    }
  }

  Widget _defaultChildBuilder(BuildContext context, Node node) {
    if (node is LineNode) {
      if (node.hasEmbed) {
        return ZefyrLine(node: node);
      } else if (node.style.contains(NotusAttribute.heading)) {
        return ZefyrHeading(node: node);
      }
      return ZefyrParagraph(node: node);

      /* return Text(
        node.toPlainText(),
        maxLines: null,
        style: TextStyle(height: 1.5, fontSize: 18),
      ); */
    }

    final BlockNode block = node;
    final blockStyle = block.style.get(NotusAttribute.block);
    if (blockStyle == NotusAttribute.block.code) {
      return ZefyrCode(node: block);
    } else if (blockStyle == NotusAttribute.block.bulletList) {
      return ZefyrList(node: block);
    } else if (blockStyle == NotusAttribute.block.numberList) {
      return ZefyrList(node: block);
    } else if (blockStyle == NotusAttribute.block.quote) {
      return ZefyrQuote(node: block);
    }

    throw UnimplementedError('Block format $blockStyle.');
  }

  void _updateSubscriptions([ZefyrEditableText oldWidget]) {
    if (oldWidget == null) {
      widget.controller.addListener(_handleLocalValueChange);
      _focusNode.addListener(_handleFocusChange);
      return;
    }

    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_handleLocalValueChange);
      widget.controller.addListener(_handleLocalValueChange);
      _input.updateRemoteValue(widget.controller.plainTextEditingValue);
    }
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChange);
      widget.focusNode.addListener(_handleFocusChange);
      updateKeepAlive();
    }
  }

  void _cancelSubscriptions() {
    _renderContext.removeListener(_handleRenderContextChange);
    widget.controller.removeListener(_handleLocalValueChange);
    _focusNode.removeListener(_handleFocusChange);
    _input.closeConnection();
    _cursorTimer.stop();
  }

  // Triggered for both text and selection changes.
  void _handleLocalValueChange() {
    //print('_handleLocalValueChange');
    if (widget.mode.canEdit &&
        widget.controller.lastChangeSource == ChangeSource.local) {
      // Only request keyboard for user actions.
      requestKeyboard();
    }
    _input.updateRemoteValue(widget.controller.plainTextEditingValue);
    _cursorTimer.startOrStop(_focusNode, selection);

    bool isEmpty = widget.controller.document.toString().length <= 4;
    //print("isEmpty: ${isEmpty}, text内容：" + widget.controller.document.toString());
    setState(() {
      this.isEmpty = isEmpty;
    });
  }

  void _handleFocusChange() {
    _input.openOrCloseConnection(_focusNode,
        widget.controller.plainTextEditingValue, widget.keyboardAppearance);
    _cursorTimer.startOrStop(_focusNode, selection);
    updateKeepAlive();
  }

  void _handleRemoteValueChange(
      int start, String deleted, String inserted, TextSelection selection) {
    widget.controller
        .replaceText(start, deleted.length, inserted, selection: selection);
  }

  void _handleRenderContextChange() {
    setState(() {
      // nothing to update internally.
    });
  }
}
