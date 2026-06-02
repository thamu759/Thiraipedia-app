class FilePickerResult {
  final String? dataUrl;
  FilePickerResult(this.dataUrl);
}

Future<FilePickerResult?> pickImage() async => null;

void openWindow(String url, String target) {}

void removeElement(String id) {}

String? getElement(String id) => null;

void showTrailerOverlay({
  required String embedUrl,
  required String containerId,
  required String adVideoUrl,
  required void Function(void Function()) setState,
  required void Function() onAdComplete,
  void Function()? onClose,
}) {}

void setInnerHtml(String id, String html) {}

void injectSimpleOverlay({
  required String containerId,
  required String embedUrl,
}) {}
