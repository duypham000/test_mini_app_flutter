import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:test_mini_app/newPage.dart';
import 'package:test_mini_app/webview_event_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class WebView extends StatefulWidget {
  const WebView({super.key});

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
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
              children: [
                InAppWebView(
                  key: webViewKey,
                  initialSettings: settings,
                  initialUrlRequest:
                      URLRequest(url: WebUri("https://simplize.vn/")),
                  pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                    eventWebviewController.controller = controller;
                    eventWebviewController.initHandle();
                  },
                  onLoadStart: (controller, url) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onPermissionRequest: (controller, request) async {
                    return PermissionResponse(
                        resources: request.resources,
                        action: PermissionResponseAction.GRANT);
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var uri = navigationAction.request.url!;

                    if (![
                      "http",
                      "https",
                      "file",
                      "chrome",
                      "data",
                      "javascript",
                      "about"
                    ].contains(uri.scheme)) {
                      if (await canLaunchUrl(uri)) {
                        // Launch the App
                        await launchUrl(
                          uri,
                        );
                        // and cancel the request
                        return NavigationActionPolicy.CANCEL;
                      }
                    }

                    return NavigationActionPolicy.ALLOW;
                  },
                  onLoadStop: (controller, url) async {
                    pullToRefreshController?.endRefreshing();
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onReceivedError: (controller, request, error) {
                    pullToRefreshController?.endRefreshing();
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      pullToRefreshController?.endRefreshing();
                    }
                    setState(() {
                      this.progress = progress / 100;
                      urlController.text = url;
                    });
                  },
                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                    setState(() {
                      this.url = url.toString();
                      urlController.text = this.url;
                    });
                  },
                  onConsoleMessage: (controller, consoleMessage) {
                    if (kDebugMode) {
                      print(consoleMessage);
                    }
                  },
                ),
                progress < 1.0
                    ? LinearProgressIndicator(value: progress)
                    : Container(),
              ],
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
                  // eventWebviewController.call(
                  //   name: "test-params",
                  //   params: {'text': 'hello', 'num': 123, 'db': 1.25},
                  //   controller: webViewController,
                  // );
                  // webViewController?.goForward();
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const NewPage();
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
