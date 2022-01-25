import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../views/home_page.dart';

void main() {
  runApp(MyApp());

  startServer();
}

HttpServer server;

startServer() async {
  server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);

  await for (var request in server) {
    final getRequestAsBytes = await request.first;

    final json = utf8.decode(getRequestAsBytes);
    request.response
      ..headers.contentType = new ContentType("application", "json", charset: "utf-8")
      ..write(json)
      ..close();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      debugShowCheckedModeBanner: false,
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
