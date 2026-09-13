# Generate QR Codes with qr_flutter

Uses [`qr_flutter`](https://pub.dev/packages/qr_flutter) **4.1.x** — render QR codes as widgets or export them as
images. Pure Dart: works on every platform.

Generating only — to **scan** QR codes use a camera package such as
[`mobile_scanner`](https://pub.dev/packages/mobile_scanner).

## Steps

### 1. Add dependency
```bash
flutter pub add qr_flutter
```

### 2. Widget
```dart
import 'package:qr_flutter/qr_flutter.dart';

QrImageView(
  data: 'https://pub.dev/packages/qr_flutter',
  version: QrVersions.auto,                       // smallest version that fits the data
  size: 240,
  backgroundColor: Colors.white,                  // default is transparent
  errorCorrectionLevel: QrErrorCorrectLevel.M,    // L 7% · M 15% · Q 25% · H 30%
  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
  dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: Colors.black),
  embeddedImage: const AssetImage('assets/icon/icon.png'),
  embeddedImageStyle: const QrEmbeddedImageStyle(size: Size.square(48)),
  errorStateBuilder: (context, error) => const Center(child: Text('Too much data')),
  semanticsLabel: 'QR code',
)
```
- **Contrast:** keep dark modules on a light background, also in dark mode — many scanners can't read inverted
  codes. The default colors (black on transparent) are invisible on a dark theme.
- **Logo:** it hides modules → use error correction **H** and keep the logo ≲ 20% of the code.
- **Data size:** the more data, the denser the code. Keep URLs short; max ≈ 2,300 bytes at level M.
- `foregroundColor` is deprecated — use `eyeStyle` / `dataModuleStyle`.

### 3. Validate first
**Required for user input.** Data that doesn't fit into a QR code (version 40) throws `QrInputTooLongException`
**inside `QrImageView`'s build** — `errorStateBuilder` doesn't catch it, and `QrValidator.validate` /
`QrCode.fromData` report it as valid because they encode lazily. Found by `test/qr_and_chat_test.dart` with
3,000 characters. Force the encoding yourself, then build from the result:
```dart
/// null = too much data
QrCode? encode(String data, int errorCorrectLevel) {
  try {
    final qr = QrCode.fromData(data: data, errorCorrectLevel: errorCorrectLevel);
    QrImage(qr);                     // builds the modules → throws if the data doesn't fit
    return qr;                       // qr.typeNumber (1–40), qr.moduleCount
  } on Exception {
    return null;
  }
}

final qr = encode(text, QrErrorCorrectLevel.M);
return qr == null
    ? const Text('Too much data')
    : QrImageView.withQr(qr: qr, size: 240, eyeStyle: …, dataModuleStyle: …);
```

### 4. Export as PNG
`QrPainter` is a `CustomPainter`. Its `toImageData()` has a **transparent** background, so paint it onto white:
```dart
final painter = QrPainter.withQr(
  qr: validation.qrCode!,
  gapless: true,                                   // QrPainter default is false, QrImageView's true
  eyeStyle: eyeStyle,
  dataModuleStyle: moduleStyle,
  embeddedImage: logoUiImage,                      // ui.Image here, not ImageProvider
);

const size = 1024.0, quietZone = 64.0;
final recorder = ui.PictureRecorder();
final canvas = Canvas(recorder)..drawRect(const Rect.fromLTWH(0, 0, size, size), Paint()..color = Colors.white);
canvas.translate(quietZone, quietZone);            // scanners need a light margin
painter.paint(canvas, const Size.square(size - quietZone * 2));
final image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
final png = (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
image.dispose();
```
Save it with `file_selector` / `path_provider`, or share it with `share_plus`.

### 5. Demo — `lib/qr/qr_code_page.dart`
**Home → Demos → QR code**: edit the content, see the version/module count, switch error correction, rounded
modules and a logo (forces H), export a 1024 px PNG. Test: `test/qr_and_chat_test.dart`.

## Notes
- Payload formats scanners understand: `https://…`, `mailto:a@b.com`, `tel:+90…`, `WIFI:T:WPA;S:ssid;P:pass;;`,
  vCard (`BEGIN:VCARD…`).
- `QrImageView(data: …)` re-creates the code on every build; `QrImageView.withQr` reuses your encoded `QrCode`.
