import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:test_mini_app/webview_event_controller.dart';
import 'package:test_mini_app/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class NewPage extends StatefulWidget {
  const NewPage({super.key});

  @override
  State<NewPage> createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  final GlobalKey webViewKey = GlobalKey();
  WebviewEventController eventWebviewController = WebviewEventController();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    enableViewportScale: true,
    cacheEnabled: true,
    supportZoom: false,
    transparentBackground: true,
    isInspectable: kDebugMode,
    builtInZoomControls: false,
  );

  PullToRefreshController? pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

    pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(
              color: Colors.blue,
            ),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Official InAppWebView website")),
        body: SafeArea(
            child: Column(children: <Widget>[
          Expanded(
            child: Stack(
              children: [],
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                child: const Icon(Icons.account_box),
                onPressed: () {
                  eventWebviewController.call(
                    name: "test",
                    params: null,
                    controller: webViewController,
                  );
                },
              ),
              ElevatedButton(
                child: const Icon(Icons.abc),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const WebView();
                  }));
                },
              ),
              ElevatedButton(
                child: const Icon(Icons.refresh),
                onPressed: () {
                  webViewController?.reload();
                },
              ),
              ElevatedButton(
                child: const Icon(Icons.play_circle),
                onPressed: () {
                  webViewController?.loadUrl(
                      urlRequest: URLRequest(
                          url: WebUri("https://mini-duyn.vercel.app/")));
                },
              ),
              ElevatedButton(
                child: const Icon(Icons.ac_unit),
                onPressed: () {
                  webViewController?.loadUrl(
                      urlRequest:
                          URLRequest(url: WebUri("https://simplize.vn/")));
                },
              ),
            ],
          ),
        ])));
  }
}
