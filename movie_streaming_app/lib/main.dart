import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:movie_streaming_app/crawler/FlutterScreenCrawler.dart';

import '../views/home_page.dart';

void main() {
  runApp(MyApp());

  startServer();
}

// create an instance of `RouteObserver`
final RouteObserver<PageRoute> routeObserver = RouteObserver();

startServer() async {
  HttpServer server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);

  await for (var request in server) {
    var defaultResponse = '{"code": 405, "message": "No route found for \'${request.method} ${request.uri.path}\': Method Not Allowed"}';

    if (request.method == "GET" && request.uri.path == "/getCurrentWidgetTree") {
      FlutterScreenCrawler.instance.takeScreenSnapshot((json) {
        request.response
          ..statusCode = 200
          ..headers.contentType = new ContentType("application", "json", charset: "utf-8")
          ..write(json)
          ..close();
      });
    } else {
      request.response
        ..headers.contentType = new ContentType("application", "json", charset: "utf-8")
        ..statusCode = 405
        ..write(defaultResponse)
        ..close();
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xff091A2A),
        accentColor: Color(0xffE50914),
        fontFamily: 'Poppins',
      ),
      home: HomePage(),
    );
  }
}
