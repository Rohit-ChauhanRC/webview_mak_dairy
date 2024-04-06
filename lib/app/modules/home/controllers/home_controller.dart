import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_download_manager/flutter_download_manager.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:webview_mak_inapp/app/constants/constants.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HomeController extends GetxController {
  //
  final GlobalKey webViewKey = GlobalKey();

  static final box = GetStorage();
  final downloadManager = DownloadManager();

  // var no = box.read(Constants.cred);

  final RxString _mobileNumber = ''.obs;
  String get mobileNumber => _mobileNumber.value;
  set mobileNumber(String mobileNumber) => _mobileNumber.value = mobileNumber;

  final RxBool _circularProgress = true.obs;
  bool get circularProgress => _circularProgress.value;
  set circularProgress(bool v) => _circularProgress.value = v;

  final RxDouble _progress = 0.0.obs;
  double get progress => _progress.value;
  set progress(double i) => _progress.value = i;

  // WebViewController webViewController = WebViewController();

  InAppWebViewController? webViewController;

  final ReceivePort _port = ReceivePort();

  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone;storage",
    iframeAllowFullscreen: true,
    allowFileAccessFromFileURLs: true,
    allowContentAccess: true,
    allowFileAccess: true,
    allowsBackForwardNavigationGestures: true,
    useOnDownloadStart: true,
    allowUniversalAccessFromFileURLs: true,
  );

  PullToRefreshController? pullToRefreshController;

  Future<void> permisions() async {
    await Permission.storage.request();
    await Permission.camera.request();
    await Permission.mediaLibrary.request();
    await Permission.microphone.request();
    await Permission.photos.request();
    await Permission.notification.request();
  }

  final count = 0.obs;
  @override
  void onInit() async {
    super.onInit();
    mobileNumber = box.read(Constants.cred) ?? Get.arguments;
    await permisions();

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

    // IsolateNameServer.registerPortWithName(
    //     _port.sendPort, 'downloader_send_port');
    // _port.listen((dynamic data) {
    //   String id = data[0];
    //   DownloadTaskStatus status = data;

    //   if (status == DownloadTaskStatus.complete) {
    //     ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
    //       content: Text("Download $id completed!"),
    //     ));
    //   }
    // });
    // FlutterDownloader.registerCallback(downloadCallback as DownloadCallback);

    // webViewController
    //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //   ..setBackgroundColor(const Color(0x00000000))
    //   ..setNavigationDelegate(
    //     NavigationDelegate(
    //       onProgress: (int p) {
    //         // Update loading bar.
    //         progress = p;
    //       },
    //       onPageStarted: (String url) {
    //         progress = 1;
    //       },
    //       onPageFinished: (String url) {
    //         circularProgress = false;
    //       },
    //       onWebResourceError: (WebResourceError error) {},
    //       onNavigationRequest: (NavigationRequest request) {
    //         // if (request.url.startsWith('http://app.maklifedairy.in:5011/')) {
    //         //   return NavigationDecision.prevent;
    //         // }
    //         return NavigationDecision.navigate;
    //       },
    //     ),
    //   )
    //   ..loadRequest(
    //     Uri.https('app.maklifedairy.in:5017',
    //         '/index.php/Login/Check_Login/${mobileNumber.toString()}'),
    //     // method: LoadRequestMethod.post,
    //   )
    //   ..reload();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }

  void handleClick(WebUri url) async {
    await webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri(url.toString())));
  }

  Future<void> downloadFile(String url, [String? filename]) async {
    var hasStoragePermission = await Permission.storage.isGranted;
    if (!hasStoragePermission) {
      final status = await Permission.storage.request();
      hasStoragePermission = status.isGranted;
    }
    if (hasStoragePermission) {
      final taskId = await FlutterDownloader.enqueue(
        url: url,
        headers: {},
        // optional: header send with url (auth token etc)
        savedDir: (await getApplicationDocumentsDirectory()).path,
        saveInPublicStorage: true,
        showNotification: true,
        openFileFromNotification: true,
        fileName: filename,
        allowCellular: true,
      );

      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
        content: Text("Download $filename completed!"),
      ));
    }
  }
}
