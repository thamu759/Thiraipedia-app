import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final uri = Uri.tryParse(embedUrl);
  String? videoId;
  if (uri != null && uri.pathSegments.length == 2) {
    videoId = uri.pathSegments[1];
  }

  if (videoId != null) {
    launchUrl(
      Uri.parse('https://youtu.be/$videoId'),
      mode: LaunchMode.externalApplication,
    );
  }
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
