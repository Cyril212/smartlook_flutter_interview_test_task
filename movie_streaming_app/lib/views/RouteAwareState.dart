import 'package:flutter/material.dart';
import 'package:movie_streaming_app/crawler/FlutterScreenCrawler.dart';

import '../main.dart';

abstract class RouteAwareState<T extends StatefulWidget> extends State<T> with RouteAware {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      routeObserver.subscribe(this, ModalRoute.of(context));
    });
  }

  @override
  @mustCallSuper
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  @mustCallSuper
  void didPopNext() {
    super.didPopNext();

    onEnterScreen();
  }

  @override
  void didPush() {
    super.didPush();

    onEnterScreen();
  }

  @override
  @mustCallSuper
  void didPop() {
    super.didPop();

    onLeaveScreen();
  }

  @override
  @mustCallSuper
  void didPushNext() {
    super.didPushNext();

    onLeaveScreen();
  }

  /// this method will always be executed on enter this screen
  void onEnterScreen() {
    print("SCREEN ON ${context.toString()}");
    FlutterScreenCrawler.instance.init(context);
  }

  /// this method will always be executed on leaving this screen
  void onLeaveScreen() {
    print("SCREEN LEFT ${context.toString()}");
  }
}
