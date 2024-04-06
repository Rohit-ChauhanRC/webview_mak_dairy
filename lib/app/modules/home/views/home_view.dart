import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../controllers/home_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('HomeView'),
      //   centerTitle: true,
      // ),
      body: SafeArea(
        child: Stack(
          children: [
            // WebViewWidget(
            //   controller: controller.webViewController,
            // ),
            // Obx(
            //   () => controller.circularProgress
            //       ? Center(
            //           child: CircularProgressIndicator(
            //             value: controller.progress.toDouble(),
            //             backgroundColor: Colors.purple[900],
            //           ),
            //         )
            //       : const Stack(),
            // )

            InAppWebView(
              key: controller.webViewKey,
              initialUrlRequest: URLRequest(
                  url: WebUri(
                      "https://app.maklifedairy.in:5017/index.php/Login/Check_Login/${controller.mobileNumber.toString()}")),
              initialSettings: controller.settings,
              // pullToRefreshController: controller.pullToRefreshController,
              onWebViewCreated: (cx) {
                controller.webViewController = cx;
              },

              onPermissionRequest: (controller, request) async {
                return PermissionResponse(
                    resources: request.resources,
                    action: PermissionResponseAction.GRANT);
              },
              // onReceivedError: (cx, request, error) {
              //   controller.pullToRefreshController!.endRefreshing();
              // },
              // onProgressChanged: (cx, progress) {
              //   controller.progress = progress / 100;
              // },
              // onUpdateVisitedHistory: (controller, url, androidIsReload) {},
              onConsoleMessage: (cx, consoleMessage) {
                if (kDebugMode) {
                  print(consoleMessage);
                }
              },
              shouldOverrideUrlLoading: (cx, navigationAction) async {
                if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
                  final shouldPerformDownload =
                      navigationAction.shouldPerformDownload ?? false;
                  final url = navigationAction.request.url;
                  if (shouldPerformDownload && url != null) {
                    await controller.downloadFile(url.toString());
                    return NavigationActionPolicy.DOWNLOAD;
                  }
                }
                return NavigationActionPolicy.ALLOW;
              },
              onDownloadStartRequest: (cx, request) async {
                if (kDebugMode) {
                  print('onDownloadStart ${request.url.toString()}');
                }
                // final taskId = await FlutterDownloader.enqueue(
                //   url: request.url.toString(),
                //   savedDir: (await getDownloadsDirectory())!.path,
                //   showNotification: true,
                //   saveInPublicStorage: true,
                //   openFileFromNotification: true,
                // );
                // controller.handleClick(request.url);
                await controller.downloadFile(
                    request.url.toString(), request.suggestedFilename);
              },
            ),
            // controller.progress < 1.0
            //     ? LinearProgressIndicator(value: controller.progress)
            //     : Container(),
          ],
        ),
      ),
    );
  }
}
