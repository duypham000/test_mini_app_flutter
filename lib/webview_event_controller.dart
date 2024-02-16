import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebviewEventController {
  const WebviewEventController({
    required this.controller,
  });

  final InAppWebViewController controller;

  call({name, params}) {
    // print('EventController.call({name: "' + name + ' ",})');
    var param = {'text': 'hello', 'num': 123, 'db': 1.25};
    var res = json.encode(param);
    var req =
        'EventController.call({name: "' + name + '", params: ' + res + '})';
    controller.callAsyncJavaScript(
        // ignore: prefer_interpolation_to_compose_strings
        functionBody: req);
  }
}
