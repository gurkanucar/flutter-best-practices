# PDF Viewer with pdfrx

Uses [`pdfrx`](https://pub.dev/packages/pdfrx) **2.6.x** — fast PDF rendering (PDFium) with zoom, scroll, text
selection and links.

| Android | iOS | macOS | Windows | Linux | Web |
|:-:|:-:|:-:|:-:|:-:|:-:|
| ✅ | ✅ 15+ | ✅ 12+ | ✅ (Developer Mode to build) | ✅ | ✅ WASM |

> pdfrx **≥ 2.5.0 depends on `material_ui`** and 2.6 requires Flutter ≥ 3.47 / Dart ≥ 3.13.
> This project is migrated to `material_ui` ([020](020-add-go-router.md#material_ui-migration)).
> If your app still uses `package:flutter/material.dart`, pin `pdfrx: ">=2.4.8 <2.5.0"`.

## Steps

### 1. Add dependency
```bash
flutter pub add "pdfrx:^2.6.1"
```

### 2. Platform setup
- **Windows:** building pdfrx needs **Developer Mode** (it creates symlinks):
  *Settings → System → For developers → Developer Mode → On*.
  Check: `Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock AllowDevelopmentWithoutDevLicense` → `1`.
- **Android / Linux / Windows:** PDFium binaries are bundled via native assets — nothing to do.
- **iOS / macOS:** PDFium XCFramework via CocoaPods/SwiftPM — nothing to do. Deployment targets iOS 15 / macOS 12.
- **Web:** nothing since 2.4.2 — `pdfium.wasm` and workers are bundled into web builds automatically
  (`dart run pdfrx:remove_wasm_modules` no longer exists).

### 3. Add a PDF asset
```yaml
flutter:
  assets:
    - assets/pdf/sample.pdf
```

### 4. Viewer — `lib/pdf/pdf_viewer_page.dart`
```dart
import 'package:pdfrx/pdfrx.dart';

class _PdfViewerPageState extends State<PdfViewerPage> {
  final _controller = PdfViewerController();
  int _pageCount = 0;
  int _pageNumber = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageCount == 0 ? l10n.pdfTitle : l10n.pdfPage(_pageNumber, _pageCount)),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: _pageNumber < _pageCount
                ? () => _controller.goToPage(pageNumber: _pageNumber + 1)
                : null,
          ),
        ],
      ),
      body: PdfViewer.asset(
        'assets/pdf/sample.pdf',
        controller: _controller,
        params: PdfViewerParams(
          onViewerReady: (document, controller) => setState(() => _pageCount = document.pages.length),
          onPageChanged: (pageNumber) {
            if (pageNumber != null) setState(() => _pageNumber = pageNumber);
          },
        ),
      ),
    );
  }
}
```

### Sources
```dart
PdfViewer.asset('assets/pdf/sample.pdf');
PdfViewer.file(path);                                                    // not on web
PdfViewer.uri(Uri.parse('https://example.com/a.pdf'),
    headers: {'Authorization': 'Bearer $token'}, preferRangeAccess: true);   // web: server must allow CORS
PdfViewer.data(bytes, sourceName: 'invoice-42.pdf');                    // e.g. from image_picker / API
```
Password-protected PDFs: `passwordProvider: () async => await askPassword()`.

### Controller & params
```dart
_controller.goToPage(pageNumber: 3);
_controller.pageCount;  _controller.pageNumber;  _controller.isReady;
_controller.zoomUp();  _controller.zoomDown();

PdfViewerParams(
  maxScale: 8,
  backgroundColor: Colors.grey,
  margin: 8,
  textSelectionParams: const PdfTextSelectionParams(enabled: true),
  loadingBannerBuilder: (context, bytesDownloaded, totalBytes) => const CircularProgressIndicator(),
  errorBannerBuilder: (context, error, stackTrace, documentRef) => Text('$error'),
  onPageChanged: (pageNumber) {},
  onViewerReady: (document, controller) {},
)
```

## Document API (no widget)
```dart
WidgetsFlutterBinding.ensureInitialized();
await pdfrxFlutterInitialize();          // only if you use PdfDocument before any PdfViewer is built
final document = await PdfDocument.openAsset('assets/pdf/sample.pdf');
final pageCount = document.pages.length;
await document.dispose();
```

## Notes
- This project generates a tiny 2-page `assets/pdf/sample.pdf` for the demo — replace it with your own.
- Large remote PDFs: `preferRangeAccess: true` (HTTP range requests) avoids downloading everything first.
- Widget tests can't render PDFium — test your page logic separately.
- Opened from **Home → Demos → PDF viewer**.
