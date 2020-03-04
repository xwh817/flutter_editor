// Copyright (c) 2018, the Zefyr project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:notus/notus.dart';

import 'buttons.dart';
import 'scope.dart';
import 'theme.dart';

/// List of all button actions supported by [ZefyrToolbar] buttons.
enum ZefyrToolbarAction {
  bold,
  italic,
  link,
  unlink,
  clipboardCopy,
  openInBrowser,
  heading,
  headingLevel1,
  headingLevel2,
  headingLevel3,
  bulletList,
  numberList,
  code,
  quote,
  horizontalRule,
  addImage,
  divider,
  image,
  cameraImage,
  galleryImage,
  hideKeyboard,
  close,
  confirm,
}

final kZefyrToolbarAttributeActions = <ZefyrToolbarAction, NotusAttributeKey>{
  ZefyrToolbarAction.bold: NotusAttribute.bold,
  ZefyrToolbarAction.italic: NotusAttribute.italic,
  ZefyrToolbarAction.link: NotusAttribute.link,
  ZefyrToolbarAction.heading: NotusAttribute.heading,
  ZefyrToolbarAction.headingLevel1: NotusAttribute.heading.level1,
  ZefyrToolbarAction.headingLevel2: NotusAttribute.heading.level2,
  ZefyrToolbarAction.headingLevel3: NotusAttribute.heading.level3,
  ZefyrToolbarAction.bulletList: NotusAttribute.block.bulletList,
  ZefyrToolbarAction.numberList: NotusAttribute.block.numberList,
  ZefyrToolbarAction.code: NotusAttribute.block.code,
  ZefyrToolbarAction.quote: NotusAttribute.block.quote,
  ZefyrToolbarAction.horizontalRule: NotusAttribute.embed.horizontalRule,
};

/// Allows customizing appearance of [ZefyrToolbar].
abstract class ZefyrToolbarDelegate {
  /// Builds toolbar button for specified [action].
  ///
  /// Returned widget is usually an instance of [ZefyrButton].
  Widget buildButton(BuildContext context, ZefyrToolbarAction action,
      {VoidCallback onPressed});
}

/// Scaffold for [ZefyrToolbar].
class ZefyrToolbarScaffold extends StatelessWidget {
  const ZefyrToolbarScaffold({
    Key key,
    @required this.body,
    this.trailing,
    this.autoImplyTrailing = true,
  }) : super(key: key);

  final Widget body;
  final Widget trailing;
  final bool autoImplyTrailing;

  @override
  Widget build(BuildContext context) {
    final theme = ZefyrTheme.of(context).toolbarTheme;
    //final toolbar = ZefyrToolbar.of(context);
    final constraints =
        BoxConstraints.tightFor(height: ZefyrToolbar.kToolbarHeight);

    /* final children = <Widget>[
      this.trailing,
      Expanded(child: Container()),
      this.body,
    ]; */

    /* if (trailing != null) {
      children.insert(0, trailing);
      //children.add(trailing);
    } else if (autoImplyTrailing) {
      children.add(toolbar.buildButton(context, ZefyrToolbarAction.close));
    } */

    return Container(
      constraints: constraints,
      child: Material(
          color: theme.color,
          child: Row(children: [
            this.trailing,
            Expanded(child: Container()),
            this.body,
          ])),
    );
  }
}

/// Toolbar for [ZefyrEditor].
class ZefyrToolbar extends StatefulWidget implements PreferredSizeWidget {
  static const kToolbarHeight = 50.0;

  const ZefyrToolbar({
    Key key,
    @required this.editor,
    this.autoHide = false,
    this.delegate,
  }) : super(key: key);

  final ZefyrToolbarDelegate delegate;
  final ZefyrScope editor;

  /// Whether to automatically hide this toolbar when editor loses focus.
  final bool autoHide;

  static ZefyrToolbarState of(BuildContext context) {
    final _ZefyrToolbarScope scope =
        context.dependOnInheritedWidgetOfExactType<_ZefyrToolbarScope>();
    return scope?.toolbar;
  }

  @override
  ZefyrToolbarState createState() => ZefyrToolbarState();

  @override
  ui.Size get preferredSize => Size.fromHeight(ZefyrToolbar.kToolbarHeight);
}

class _ZefyrToolbarScope extends InheritedWidget {
  _ZefyrToolbarScope({Key key, @required Widget child, @required this.toolbar})
      : super(key: key, child: child);

  final ZefyrToolbarState toolbar;

  @override
  bool updateShouldNotify(_ZefyrToolbarScope oldWidget) {
    return toolbar != oldWidget.toolbar;
  }
}

class ZefyrToolbarState extends State<ZefyrToolbar>
    with SingleTickerProviderStateMixin {
  final Key _toolbarKey = UniqueKey();
  //final Key _overlayKey = UniqueKey();

  ZefyrToolbarDelegate _delegate;
  //AnimationController _overlayAnimation;
  //WidgetBuilder _overlayBuilder;
  //Completer<void> _overlayCompleter;

  //TextSelection _selection;

  /* void markNeedsRebuild() {
    setState(() {
      if (_selection != editor.selection) {
        _selection = editor.selection;
        closeOverlay();
      }_selection
    });
  } */

  Widget buildButton(BuildContext context, ZefyrToolbarAction action,
      {VoidCallback onPressed}) {
    return _delegate.buildButton(context, action, onPressed: onPressed);
  }

  /* Future<void> showOverlay(WidgetBuilder builder) async {
    assert(_overlayBuilder == null);
    final completer = Completer<void>();
    setState(() {
      _overlayBuilder = builder;
      _overlayCompleter = completer;
      _overlayAnimation.forward();
    });
    return completer.future;
  } 

  void closeOverlay() {
    if (!hasOverlay) return;
    _overlayAnimation.reverse().whenComplete(() {
      setState(() {
        _overlayBuilder = null;
        _overlayCompleter?.complete();
        _overlayCompleter = null;
      });
    });
  }
*/
  //bool get hasOverlay => _overlayBuilder != null;

  ZefyrScope get editor => widget.editor;

  @override
  void initState() {
    super.initState();
    _delegate = widget.delegate ?? _DefaultZefyrToolbarDelegate();
    //_overlayAnimation =
    //    AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    // _selection = editor.selection;
  }

  @override
  void didUpdateWidget(ZefyrToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.delegate != oldWidget.delegate) {
      _delegate = widget.delegate ?? _DefaultZefyrToolbarDelegate();
    }
  }

  @override
  void dispose() {
    //_overlayAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layers = <Widget>[];

    // Must set unique key for the toolbar to prevent it from reconstructing
    // new state each time we toggle overlay.
    final toolbar = ZefyrToolbarScaffold(
      key: _toolbarKey,
      body: ZefyrButtonList(buttons: _buildButtons(context)),
      trailing: buildButton(context, ZefyrToolbarAction.hideKeyboard),
    );

    layers.add(toolbar);

    /* if (hasOverlay) {
      Widget widget = Builder(builder: _overlayBuilder);
      assert(widget != null);
      final overlay = FadeTransition(
        key: _overlayKey,
        opacity: _overlayAnimation,
        child: widget,
      );
      layers.add(overlay);
    } */

    final constraints =
        BoxConstraints.tightFor(height: ZefyrToolbar.kToolbarHeight);
    return _ZefyrToolbarScope(
      toolbar: this,
      child:
          Container(constraints: constraints, child: Stack(children: layers)),
    );
  }

  List<Widget> _buildButtons(BuildContext context) {
    final buttons = <Widget>[
      //buildButton(context, ZefyrToolbarAction.bold),
      //buildButton(context, ZefyrToolbarAction.italic),
      //LinkButton(),
      //HeadingButton(),
      buildButton(context, ZefyrToolbarAction.bulletList),
      //buildButton(context, ZefyrToolbarAction.numberList),
      buildButton(context, ZefyrToolbarAction.quote),
      //buildButton(context, ZefyrToolbarAction.code),
      /* buildButton(context, ZefyrToolbarAction.horizontalRule, onPressed: () {
        print("add horizontalRule");
        editor.formatSelection(NotusAttribute.embed.horizontalRule);
        addNextLine();
      }), */

      buildButton(context, ZefyrToolbarAction.divider, onPressed: () {
        editor.formatSelection(NotusAttribute.embed.horizontalRule);
        addNextLine();
      }),

      buildButton(context, ZefyrToolbarAction.addImage, onPressed: () {
        showImageDialog();
      }),

      /* IconButton(
          icon: ImageIcon(AssetImage("images/image_add.png"), color:Colors.white),
          onPressed: () => {
                showImageDialog()
              }), */

      SizedBox(width: 8), // 间隔
    ];
    return buttons;
  }

  void showImageDialog() {
    showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0)),
            child: Container(
                height: 200,
                color: Colors.white.withOpacity(0.9),
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Column(children: <Widget>[
                  getMenuItem(Icons.photo_camera, '拍照', () {
                    Navigator.of(context).pop();
                    pickFromCamera();
                  }),
                  getMenuItem(Icons.photo_library, '从相册选择', () {
                    Navigator.of(context).pop();
                    pickFromGallery();
                  }),
                  getMenuItem(Icons.close, '退出', () {
                    Navigator.of(context).pop();
                  }),
                ]))));
  }

  Widget getMenuItem(IconData icon, String title, Function onPressed) {
    return FlatButton(
        child: Row(
          children: <Widget>[
            Icon(icon, size: 24, color: Colors.black54),
            SizedBox(height: 50, width: 12),
            Text(title)
          ],
        ),
        onPressed: onPressed);
  }

  void pickFromGallery() async {
    final image = await editor.imageDelegate
        .pickImage(editor.imageDelegate.gallerySource);
    if (image != null) {
      print(image);
      NotusAttribute value = NotusAttribute.embed.image(image);
      print(value);
      editor.formatSelection(value);
      addNextLine();
    }
  }

  void pickFromCamera() async {
    final image =
        await editor.imageDelegate.pickImage(editor.imageDelegate.cameraSource);
    if (image != null) {
      print(image);
      editor.formatSelection(NotusAttribute.embed.image(image));
      addNextLine();
    }
  }

  /// 自动换一行
  /// 阅读源码，总算找到地方了。
  void addNextLine() {
    // 更新cursor位置
    final cursorPosition = editor.selection.extentOffset;
    //print('光标位置：$cursorPosition , 文本长度：${editor.controller.document.length}');
    // 只有在最后位置才自动换行。中间的不用
    if (cursorPosition == editor.controller.document.length - 1) {
      editor.controller.document.insert(cursorPosition, "\n");
      editor.updateSelection(editor.selection.copyWith(
          extentOffset: cursorPosition + 1, baseOffset: cursorPosition + 1));
    }
  }
}

/// Scrollable list of toolbar buttons.
class ZefyrButtonList extends StatefulWidget {
  const ZefyrButtonList({Key key, @required this.buttons}) : super(key: key);
  final List<Widget> buttons;

  @override
  _ZefyrButtonListState createState() => _ZefyrButtonListState();
}

class _ZefyrButtonListState extends State<ZefyrButtonList> {
  //final ScrollController _controller = ScrollController();
  //bool _showLeftArrow = false;
  //bool _showRightArrow = false;

  @override
  void initState() {
    super.initState();
    //_controller.addListener(_handleScroll);
    // Workaround to allow scroll controller attach to our ListView so that
    // we can detect if overflow arrows need to be shown on init.
    // TODO: find a better way to detect overflow
    //Timer.run(_handleScroll);
  }

  @override
  Widget build(BuildContext context) {
    /* final theme = ZefyrTheme.of(context).toolbarTheme;
    final color = theme.iconColor;
    final list = ListView(
      scrollDirection: Axis.horizontal,
      controller: _controller,
      children: widget.buttons,
      physics: ClampingScrollPhysics(),
    ); */

    return Row(children: widget.buttons);
    /* final leftArrow = _showLeftArrow
        ? Icon(Icons.arrow_left, size: 18.0, color: color)
        : null;
    final rightArrow = _showRightArrow
        ? Icon(Icons.arrow_right, size: 18.0, color: color)
        : null;
    return Row(
      children: <Widget>[
        SizedBox(
          width: 12.0,
          height: ZefyrToolbar.kToolbarHeight,
          child: Container(child: leftArrow, color: theme.color),
        ),
        Expanded(child: ClipRect(child: list)),
        SizedBox(
          width: 12.0,
          height: ZefyrToolbar.kToolbarHeight,
          child: Container(child: rightArrow, color: theme.color),
        ),
      ],
    ); */
  }

  /* void _handleScroll() {
    setState(() {
      _showLeftArrow =
          _controller.position.minScrollExtent != _controller.position.pixels;
      _showRightArrow =
          _controller.position.maxScrollExtent != _controller.position.pixels;
    });
  } */
}

class _DefaultZefyrToolbarDelegate implements ZefyrToolbarDelegate {
  static const kDefaultButtonIcons = {
    ZefyrToolbarAction.bold: Icons.format_bold,
    ZefyrToolbarAction.italic: Icons.format_italic,
    ZefyrToolbarAction.link: Icons.link,
    ZefyrToolbarAction.unlink: Icons.link_off,
    ZefyrToolbarAction.clipboardCopy: Icons.content_copy,
    ZefyrToolbarAction.openInBrowser: Icons.open_in_new,
    ZefyrToolbarAction.heading: Icons.format_size,
    ZefyrToolbarAction.bulletList: Icons.format_list_bulleted,
    ZefyrToolbarAction.numberList: Icons.format_list_numbered,
    ZefyrToolbarAction.code: Icons.code,
    ZefyrToolbarAction.quote: Icons.format_quote,
    ZefyrToolbarAction.horizontalRule: Icons.more_horiz,
    ZefyrToolbarAction.image: Icons.add_photo_alternate,
    ZefyrToolbarAction.cameraImage: Icons.photo_camera,
    ZefyrToolbarAction.galleryImage: Icons.photo_library,
    ZefyrToolbarAction.hideKeyboard: Icons.keyboard_arrow_down,
    ZefyrToolbarAction.close: Icons.close,
    ZefyrToolbarAction.confirm: Icons.check,
  };

  // 本地Icons
  static const localButtonIcons = {
    ZefyrToolbarAction.addImage: "images/image_add.png",
    ZefyrToolbarAction.divider: "images/divider.png",
  };

  // 图标大小
  static const myIconSize = 20.0;
  static const kSpecialIconSizes = {
    ZefyrToolbarAction.unlink: 20.0,
    ZefyrToolbarAction.clipboardCopy: 20.0,
    ZefyrToolbarAction.openInBrowser: 20.0,
    ZefyrToolbarAction.close: 20.0,
    ZefyrToolbarAction.confirm: 20.0,
    ZefyrToolbarAction.hideKeyboard: 26.0,
  };

  static const kDefaultButtonTexts = {
    ZefyrToolbarAction.headingLevel1: 'H1',
    ZefyrToolbarAction.headingLevel2: 'H2',
    ZefyrToolbarAction.headingLevel3: 'H3',
  };

  @override
  Widget buildButton(BuildContext context, ZefyrToolbarAction action,
      {VoidCallback onPressed}) {
    final theme = Theme.of(context);
    if (kDefaultButtonIcons.containsKey(action)) {
      final icon = kDefaultButtonIcons[action];
      final size = kSpecialIconSizes[action];
      return ZefyrButton.icon(
        action: action,
        icon: icon,
        iconSize: size,
        onPressed: onPressed,
      );
    } else if (localButtonIcons.containsKey(action)) {
      return ZefyrButton.myIcon(
        action: action,
        path: localButtonIcons[action],
        iconSize: myIconSize,
        onPressed: onPressed,
      );
    } else {
      final text = kDefaultButtonTexts[action];
      assert(text != null);
      final style = theme.textTheme.caption
          .copyWith(fontWeight: FontWeight.bold, fontSize: 14.0);
      return ZefyrButton.text(
        action: action,
        text: text,
        style: style,
        onPressed: onPressed,
      );
    }
  }
}
