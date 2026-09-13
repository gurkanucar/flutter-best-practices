# Scan Documents with flutter_doc_scanner

Uses [`flutter_doc_scanner`](https://pub.dev/packages/flutter_doc_scanner) **0.0.x** — the system document scanner
(edge detection, perspective correction, multiple pages) returning images or a PDF.

| Android | iOS | macOS | Windows | Linux | Web |
|:-:|:-:|:-:|:-:|:-:|:-:|
| ✅ ML Kit | ✅ VisionKit | ❌ | ❌ | ❌ | ❌ |

Desktop plugins only answer `getPlatformVersion`; web is unimplemented → guard by platform.

## Steps

### 1. Add dependency
```bash
flutter pub add flutter_doc_scanner
```

### 2. Platform setup
**Android** — nothing in the manifest, no camera permission: Google Play services shows the scanner UI (the module
is downloaded on first use). Devices **without Play services** (Huawei, some tablets, AOSP emulators) can't scan —
use a "Google Play" emulator image. minSdk 21.

**iOS** — `NSCameraUsageDescription` in `Info.plist` (VisionKit, iOS 13+). The README's Podfile
`PERMISSION_CAMERA=1` step is for `permission_handler`, not this package.

### 3. Scan
```dart
final scanner = FlutterDocScanner();

try {
  final ImageScanResult? images = await scanner.getScannedDocumentAsImages(page: 4);
  if (images == null) return;                     // cancelled
  final paths = images.images.map(toFilePath).toList();

  final PdfScanResult? pdf = await scanner.getScannedDocumentAsPdf(page: 4);
  // pdf.pdfUri, pdf.pageCount (0 on iOS)
} on DocScanException catch (e) {
  // e.code: CANCELLED, SCAN_IN_PROGRESS, SCAN_FAILED, PDF_CREATION_ERROR, NO_ACTIVITY, UNSUPPORTED_PLATFORM
}

/// Android returns file:// URIs, iOS plain paths.
String toFilePath(String value) {
  final uri = Uri.tryParse(value);
  return uri != null && uri.scheme == 'file' ? uri.toFilePath() : value;
}
```
- Catch **`DocScanException`** — the plugin converts `PlatformException`, so the README's `on PlatformException`
  never matches.
- Prefer the typed methods: `getScanDocuments()` returns a Map on Android but a `List` on iOS.
- `page` (page limit) only works on Android; VisionKit has no limit. On iOS `imageFormat`/`quality` are ignored
  (PNG).

### 4. Clean up
Scans go to the cache (Android) or the **Documents** directory (iOS) and are never deleted by the plugin; on iOS two
scans in the same second can even overwrite each other. Move the files you keep, delete the rest:
```dart
for (final path in paths) {
  try { File(path).deleteSync(); } on FileSystemException { /* already gone */ }
}
```

### 5. Demo — `lib/documents/document_scanner_page.dart`
**Home → Demos → Document scanner**: page limit slider (Android), "Scan as images" (grid preview) and "Scan as PDF"
(shown with pdfrx, [016](016-add-pdfrx.md)). Previous scans are deleted on a new scan and when leaving the page.

## Notes
- For OCR, run the images through `google_mlkit_text_recognition` (Android/iOS).
- Upload scans compressed ([018](018-add-image-compress.md)); scanned PNGs are large.
- The plugin is young (0.0.x) and uses the old Kotlin DSL — re-check Android builds after Gradle/AGP upgrades.
