import 'dart:async';
import 'dart:html' as html;

class FilePickerResult {
  final String? dataUrl;
  FilePickerResult(this.dataUrl);
}

Future<FilePickerResult?> pickImage() async {
  final completer = Completer<FilePickerResult?>();
  final input = html.FileUploadInputElement()..accept = 'image/*';
  input.click();
  input.onChange.listen((_) {
    final file = input.files?.first;
    if (file == null) {
      completer.complete(null);
      return;
    }
    final reader = html.FileReader();
    reader.readAsDataUrl(file);
    reader.onLoadEnd.listen((_) {
      completer.complete(FilePickerResult(reader.result as String));
    });
  });
  return completer.future;
}

void openWindow(String url, String target) {
  html.window.open(url, target);
}

void removeElement(String id) {
  html.document.getElementById(id)?.remove();
}

void showTrailerOverlay({
  required String embedUrl,
  required String containerId,
  required String adVideoUrl,
  required void Function(void Function()) setState,
  required void Function() onAdComplete,
  void Function()? onClose,
}) {
  final existing = html.document.getElementById(containerId);
  if (existing != null) return;

  Timer? adTimer;

  void showTrailer() {
    final c = html.document.getElementById(containerId);
    if (c == null) return;
    c.innerHtml = '';
    final wrapper = html.DivElement()
      ..style.position = 'relative'
      ..style.width = '90%'
      ..style.maxWidth = '800px'
      ..style.aspectRatio = '16/9';
    final closeBtn = html.DivElement()
      ..style.position = 'absolute'
      ..style.top = '12px'
      ..style.right = '12px'
      ..style.zIndex = '10000'
      ..style.width = '40px'
      ..style.height = '40px'
      ..style.background = 'rgba(0,0,0,0.7)'
      ..style.borderRadius = '50%'
      ..style.display = 'flex'
      ..style.alignItems = 'center'
      ..style.justifyContent = 'center'
      ..style.cursor = 'pointer'
      ..style.border = '2px solid rgba(255,255,255,0.25)'
      ..style.boxShadow = '0 2px 12px rgba(0,0,0,0.5)'
      ..innerHtml = '<span style="color:white;font-size:20px;font-weight:800;font-family:Arial,sans-serif">X</span>'
      ..onClick.listen((_) => c.remove());
    final iframe = html.IFrameElement()
      ..src = embedUrl
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.border = 'none'
      ..style.borderRadius = '12px'
      ..allow = 'autoplay; encrypted-media; fullscreen'
      ..allowFullscreen = true;
    wrapper.append(closeBtn);
    wrapper.append(iframe);
    c.append(wrapper);
  }

  final container = html.DivElement()
    ..id = containerId
    ..style.position = 'fixed'
    ..style.top = '0'
    ..style.left = '0'
    ..style.width = '100%'
    ..style.height = '100%'
    ..style.zIndex = '9999'
    ..style.background = 'rgba(0,0,0,0.85)'
    ..style.display = 'flex'
    ..style.alignItems = 'center'
    ..style.justifyContent = 'center';
  html.document.body?.append(container);

  // Show ad first
  final adWrapper = html.DivElement()
    ..style.position = 'relative'
    ..style.width = '90%'
    ..style.maxWidth = '800px'
    ..style.aspectRatio = '16/9'
    ..style.overflow = 'hidden';
  final adCloseBtn = html.DivElement()
    ..style.position = 'absolute'
    ..style.top = '12px'
    ..style.right = '12px'
    ..style.zIndex = '10000'
    ..style.width = '40px'
    ..style.height = '40px'
    ..style.background = 'rgba(0,0,0,0.7)'
    ..style.borderRadius = '50%'
    ..style.display = 'flex'
    ..style.alignItems = 'center'
    ..style.justifyContent = 'center'
    ..style.cursor = 'pointer'
    ..style.border = '2px solid rgba(255,255,255,0.25)'
    ..style.boxShadow = '0 2px 12px rgba(0,0,0,0.5)'
    ..innerHtml = '<span style="color:white;font-size:20px;font-weight:800;font-family:Arial,sans-serif">X</span>'
    ..onClick.listen((_) {
      adTimer?.cancel();
      container.remove();
      onClose?.call();
    });

  // Skeleton loading
  final skeleton = html.DivElement()
    ..style.position = 'absolute'
    ..style.top = '0'
    ..style.left = '0'
    ..style.width = '100%'
    ..style.height = '100%'
    ..style.background = '#1a1a2e'
    ..style.borderRadius = '12px'
    ..style.display = 'flex'
    ..style.alignItems = 'center'
    ..style.justifyContent = 'center'
    ..style.zIndex = '9998'
    ..style.setProperty('flex-direction', 'column')
    ..style.setProperty('gap', '16px')
    ..innerHtml = '''
      <style>
        @keyframes shimmer {
          0% { opacity: 0.3; }
          50% { opacity: 0.8; }
          100% { opacity: 0.3; }
        }
      </style>
      <div style="width:60px;height:60px;border-radius:16px;background:#2a2a4e;animation:shimmer 1.5s ease-in-out infinite;"></div>
      <div style="width:120px;height:12px;border-radius:6px;background:#2a2a4e;animation:shimmer 1.5s ease-in-out infinite;"></div>
    ''';

  final adIframe = html.IFrameElement()
    ..src = adVideoUrl
    ..style.width = '100%'
    ..style.height = '100%'
    ..style.border = 'none'
    ..style.borderRadius = '12px'
    ..allow = 'autoplay; encrypted-media; fullscreen'
    ..allowFullscreen = true
    ..style.pointerEvents = 'none'
    ..style.display = 'none';
  final skipBtn = html.DivElement()
    ..style.position = 'absolute'
    ..style.bottom = '24px'
    ..style.right = '24px'
    ..style.zIndex = '10001'
    ..style.background = '#FBBF24'
    ..style.color = 'black'
    ..style.padding = '10px 20px 10px 18px'
    ..style.borderRadius = '8px'
    ..style.fontFamily = 'Poppins, sans-serif'
    ..style.fontSize = '14px'
    ..style.fontWeight = '700'
    ..style.cursor = 'pointer'
    ..style.display = 'none'
    ..style.alignItems = 'center'
    ..style.setProperty('gap', '6px')
    ..style.boxShadow = '0 4px 16px rgba(0,0,0,0.3)'
    ..style.transition = 'opacity 0.2s ease'
    ..innerHtml = '''
      <span style="font-size:18px;line-height:1">▶</span>
      Skip &nbsp;›
    '''
    ..onClick.listen((_) {
      adTimer?.cancel();
      container.remove();
      showTrailer();
    });

  adWrapper.append(skeleton);
  adWrapper.append(adIframe);
  adWrapper.append(skipBtn);
  adWrapper.append(adCloseBtn);
  container.append(adWrapper);

  // Wait for iframe load then show skip
  adIframe.onLoad.listen((_) {
    adIframe.style.display = 'block';
    // Hide skeleton after a moment
    Future.delayed(const Duration(seconds: 1), () {
      skeleton.style.display = 'none';
      skipBtn.style.display = 'flex';
    });
  });

  // Auto skip after 10s
  adTimer = Timer(const Duration(seconds: 10), () {
    container.remove();
    onAdComplete();
    showTrailer();
  });
}

void injectSimpleOverlay({
  required String containerId,
  required String embedUrl,
}) {
  final container = html.DivElement()
    ..id = containerId
    ..style.position = 'fixed'
    ..style.top = '0'
    ..style.left = '0'
    ..style.width = '100%'
    ..style.height = '100%'
    ..style.zIndex = '9999'
    ..style.background = '#000';
  final closeBtn = html.DivElement()
    ..style.position = 'absolute'
    ..style.top = '16px'
    ..style.left = '16px'
    ..style.zIndex = '10000'
    ..style.width = '40px'
    ..style.height = '40px'
    ..style.background = 'rgba(0,0,0,0.6)'
    ..style.borderRadius = '12px'
    ..style.display = 'flex'
    ..style.alignItems = 'center'
    ..style.justifyContent = 'center'
    ..style.cursor = 'pointer'
    ..innerHtml = '<span style="color:white;font-size:24px;font-weight:700">&#x2715;</span>'
    ..onClick.listen((_) => container.remove());
  final iframe = html.IFrameElement()
    ..src = embedUrl
    ..style.width = '100%'
    ..style.height = '100%'
    ..style.border = 'none'
    ..allow = 'autoplay; encrypted-media; fullscreen'
    ..allowFullscreen = true;
  container.append(iframe);
  container.append(closeBtn);
  html.document.body?.append(container);
}

void removeAllChildren(String id) {
  final el = html.document.getElementById(id);
  if (el != null) el.innerHtml = '';
}
