import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';

class DeviceServer {
  static const port = 8080;

  late final HttpServer _server;

  DeviceServer() {
    _start();
  }

  Future<void> _start() async {
    String? ip = await NetworkInfo().getWifiIP();

    if(ip == null) return;

    _server = await HttpServer.bind(ip, port);
    print("Server running... (http://$ip:$port)");

    await for (var request in _server) {
      // Manejo de rutas y parámetros
      if (request.uri.path == '/') {
        print("request");

        request.response
          ..statusCode = 200
          ..write(await rootBundle.loadString("assets/web_controller/index.html"))
          ..close();
      }
    }
  }

  Future<void> stop() async => await _server.close();
}
