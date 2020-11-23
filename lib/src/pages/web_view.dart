import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class open_webview extends StatelessWidget {
  String url;
  InAppWebViewController _webViewController;

  open_webview(this.url);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: <Widget>[
        Expanded(
          child: Container(
            decoration:
                BoxDecoration(border: Border.all(color: Colors.blueAccent)),
            child: InAppWebView(
              initialUrl: url,
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                debuggingEnabled: true,
              )),
              onWebViewCreated: (InAppWebViewController controller) {
                _webViewController = controller;
              },
              onLoadStart: (InAppWebViewController controller, String url) {},
              onLoadStop:
                  (InAppWebViewController controller, String url) async {},
              onProgressChanged:
                  (InAppWebViewController controller, int progress) {},
            ),
          ),
        ),
      ],
    ));
  }
}
