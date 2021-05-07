import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayWebView extends StatefulWidget {

  final url;
  final pa;
  final md;
  final creq;
  final termurl;

  PayWebView(this.url, this.pa, this.md, this.creq, this.termurl);

  @override
  _PayWebViewState createState() => _PayWebViewState();
}

class _PayWebViewState extends State<PayWebView> {

  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  JavascriptChannel _channel = JavascriptChannel(
    name: 'jsMessageReceived',
    onMessageReceived: (JavascriptMessage message) {
      print(message);
      if (message.message == 'impayapp::close()') {
        //Navigator.pop(context);
      }
  });

  String _3dsData(url, pa, md, creq, termurl) {
    return Uri.dataFromString(
        '<body onload="onload()">тест'+
            '<form name="formpay" action="'+url+'" method="POST">'+
              (creq.isNotEmpty ?
                '<input type="hidden" name="creq" value="'+creq+'">' :
                ('<input type="hidden" name="PaReq" value="'+pa+'">'+ '<input type="hidden" name="MD" value="'+md+'">')
              ) +
              '<input type="hidden" name="TermUrl" value="'+termurl+'">'+
              '<input type="submit" value="submit">'+
            '</form>'+
            '<script>document.formpay.submit();</script>'+
        '</body>',
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(children: <Widget>[
      Container(
        alignment: Alignment.bottomRight,
        padding: EdgeInsets.only(top: 30.0),
        child: IconButton(icon: Icon(Icons.close), onPressed: () {
          Navigator.pop(context);
        })
      ),
      Container(
        height: MediaQuery.of(context).size.height - 30.0,
        child: WebView(
          initialUrl: _3dsData(widget.url, widget.pa, widget.md, widget.creq, widget.termurl),
          javascriptMode: JavascriptMode.unrestricted,
          javascriptChannels: {_channel},
            onWebViewCreated: (WebViewController webViewController) {
              _controller = webViewController;
              _controller!.loadUrl(_3dsData(widget.url, widget.pa, widget.md, widget.creq, widget.termurl));
            }
        )
      )
    ]));
  }
}