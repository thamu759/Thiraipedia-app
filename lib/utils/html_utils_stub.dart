import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FilePickerResult {
  final String? dataUrl;
  FilePickerResult(this.dataUrl);
}

Future<FilePickerResult?> pickImage() async => null;

void openWindow(String url, String target) {
  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

void removeElement(String id) {}

String? getElement(String id) => null;

void setInnerHtml(String id, String html) {}

void showTrailerPopup({
  required BuildContext context,
  required String embedUrl,
  required String adVideoUrl,
  required String containerId,
  required void Function(void Function()) setState,
}) {
  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse(embedUrl));
  final uri = Uri.tryParse(embedUrl);
  String? videoId;
  if (uri != null && uri.pathSegments.length == 2) {
    videoId = uri.pathSegments[1];
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black,
    builder: (ctx) => Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                  if (videoId != null)
                    TextButton.icon(
                      onPressed: () => launchUrl(
                        Uri.parse('https://youtu.be/$videoId'),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.open_in_new, color: Colors.white70, size: 18),
                      label: const Text('Open in YouTube',
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Poppins')),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: WebViewWidget(controller: controller),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void showTrailerOverlay({
  required String embedUrl,
  required String containerId,
  required String adVideoUrl,
  required void Function(void Function()) setState,
  required void Function() onAdComplete,
  void Function()? onClose,
}) {
  final uri = Uri.tryParse(embedUrl);
  if (uri != null) {
    final videoId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
    if (videoId != null) {
      launchUrl(
        Uri.parse('https://youtu.be/$videoId'),
        mode: LaunchMode.externalApplication,
      );
    }
  }
}

void injectSimpleOverlay({
  required String containerId,
  required String embedUrl,
}) {
  final uri = Uri.tryParse(embedUrl);
  if (uri != null) {
    final videoId = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
    if (videoId != null) {
      launchUrl(
        Uri.parse('https://youtu.be/$videoId'),
        mode: LaunchMode.externalApplication,
      );
    }
  }
}
