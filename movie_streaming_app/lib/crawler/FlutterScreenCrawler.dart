import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

import 'models/TreeElement.dart';
import 'models/TreeElementList.dart';

class FlutterScreenCrawler {
  static FlutterScreenCrawler _instance = new FlutterScreenCrawler._();

  static FlutterScreenCrawler get instance => _instance;

  FlutterScreenCrawler._();

  img.Image _screenedImage;
  int _treeElementCounter = 0;

  TreeElementList _elementList;

  void init(BuildContext context) {
    _resetCounter();

    _elementList = TreeElementList();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      print("========= Start Crawling =========");

      context.visitChildElements((element) {
        _getScreenScreenshot(context, element)
            .then((value) => _visitChildren(context))
            .then((value) => print("========= Crawling has been completed ========="))
            .then((value) => _dispatchElementTree());
      });
    });
  }

  void dispose() {
    _resetCounter();
    _elementList.treeElements.clear();
  }

  void _dispatchElementTree() async {
    var url = Uri.parse('http://127.0.0.1:8080');
    await http.post(
      url,
      body: _elementList.toJson().toString(),
    );
  }

  void _resetCounter() => _treeElementCounter = 0;

  /// Image lib uses uses KML color format, convert #AABBGGRR to regular #AARRGGBB
  int _abgrToArgb(int argbColor) {
    int r = (argbColor >> 16) & 0xFF;
    int b = argbColor & 0xFF;
    return (argbColor & 0xFF00FF00) | (b << 16) | r;
  }

  /// Creates an image from the given widget by first spinning up a element and render tree,
  /// then waiting for the given [wait] amount of time and then creating an image via a [RepaintBoundary].
  ///
  /// The final image will be of size [imageSize] and the the widget will be layout, ... with the given [logicalSize].
  Future<Uint8List> _createImageFromWidget(Widget widget, {Size logicalSize, Size imageSize}) async {
    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

    final materialWidget = MaterialApp(home: widget);
    logicalSize ??= ui.window.physicalSize / ui.window.devicePixelRatio;
    imageSize ??= ui.window.physicalSize;

    assert(logicalSize.aspectRatio == imageSize.aspectRatio);

    final RenderView renderView = RenderView(
      window: null,
      child: RenderPositionedBox(alignment: Alignment.center, child: repaintBoundary),
      configuration: ViewConfiguration(
        size: logicalSize,
        devicePixelRatio: 1.0,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager.instance);

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    RenderObjectToWidgetElement<RenderBox> rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: materialWidget,
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);

    buildOwner
      ..buildScope(rootElement)
      ..finalizeTree();

    pipelineOwner
      ..flushLayout()
      ..flushCompositingBits()
      ..flushPaint();

    final ui.Image image = await repaintBoundary.toImage(pixelRatio: imageSize.width / logicalSize.width);
    final ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData.buffer.asUint8List();
  }

  Future _visitChildren(Element element) {
    element.visitChildElements((child) {
      if (child is StatefulElement || child is StatelessElement) {
        final RenderBox box = child.findRenderObject() as RenderBox;

        final width = box.size.width;
        final height = box.size.height;

        //Convert to global position
        final Offset position = box.localToGlobal(Offset.zero);
        final double x = position.dx;
        final double y = position.dy;

        //Get pixel by element position on the screen
        final int pixel32 = _screenedImage.getPixelSafe(x.toInt(), y.toInt());

        //Parse pixel color to hex
        final String hexColor = _abgrToArgb(pixel32).toRadixString(16);

        String color = hexColor;

        //In case RenderRepaintBoundary didn't rendered screen correctly, try to fetch color from the element.
        //Sometimes element's color has 0 value, probably it contains image or doesn't have backround at all
        if (child.widget is Text) {
          final textStyle = (child.widget as Text).style;
          if (textStyle != null && textStyle.color != null && textStyle.color.value != 0) {
            color = textStyle.color.value.toRadixString(16);
          }
        } else if (child.widget is Container) {
          final containerColor = (child.widget as Container).color;
          if (containerColor != null && containerColor.value != 0) {
            color = containerColor.value.toRadixString(16).toString();
          }
        }

        print("Box:${child.widget.toStringShort()} width:${child.size.width.toString()} height:${child.size.height.toString()} X:$x Y:$y Color: #$color Count: ${_treeElementCounter++}");

        _elementList.treeElements.add(TreeElement(top: x, left: y, width: width, height: height, color: '#' + color));
      }

      _visitChildren(child);
    });
    return Future.value(null);
  }

  ///Generate an image by [_createImageFromWidget] and decode it to [img.Image] type to use [getPixelSafe] later.
  Future _getScreenScreenshot(BuildContext context, Element element) async {
    final widgetImageAsByteData = await _createImageFromWidget(element.widget, logicalSize: element.size, imageSize: element.size);
    final bytesImage = widgetImageAsByteData;
    final img.Image image = img.decodeImage(bytesImage);

    _screenedImage = image;

    // showAboutDialog(context: context, children: [Image.memory(bytesImage)]);

    return Future.value(null);
  }
}
