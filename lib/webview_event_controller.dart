import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';

class WebviewEventController {
  WebviewEventController(
      //   {
      //   required this.controller,
      // }
      );

  InAppWebViewController? controller;

  List<JavascriptHandle> listHandle = [
    JavascriptHandle(
      name: "JsToNative_toast",
      callback: (args) {
        Fluttertoast.showToast(msg: args[0].toString());
      },
    ),
  ];

  call({required name, required params, required controller}) {
    // print('EventController.call({name: "' + name + ' ",})');
    if (controller == null) return;
    var res = json.encode(params);
    var req =
        'EventController.call({name: "' + name + '", params: ' + res + '})';
    controller!.callAsyncJavaScript(
        // ignore: prefer_interpolation_to_compose_strings
        functionBody: req);
  }

  registerHandle({required name, required callback}) {
    if (controller == null) {
      listHandle.add(JavascriptHandle(name: name, callback: callback));
    } else {
      controller!.addJavaScriptHandler(
        handlerName: name,
        callback: callback,
      );
    }
  }

  initHandle() {
    if (controller == null) return;
    for (var e in listHandle) {
      controller!.addJavaScriptHandler(
        handlerName: e.name,
        callback: e.callback,
      );
    }
  }
}

class JavascriptHandle {
  const JavascriptHandle({
    required this.name,
    required this.callback,
  });
  final String name;
  final Function(List<dynamic>) callback;
}
