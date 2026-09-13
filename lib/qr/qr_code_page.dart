import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../l10n/l10n_extension.dart';

class QrCodePage extends StatefulWidget {
  const QrCodePage({super.key});

  @override
  State<QrCodePage> createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> {
  static const _logoAsset = 'assets/icon/icon.png';
  static const _dark = Color(0xFF000000);
  static const _light = Color(0xFFFFFFFF);

  final _controller = TextEditingController(text: 'https://pub.dev/packages/qr_flutter');
  int _errorCorrection = QrErrorCorrectLevel.M;
  bool _rounded = false;
  bool _withLogo = false;

  // A logo hides modules → use the highest error correction (≈30% of the code can be restored).
  int get _level => _withLogo ? QrErrorCorrectLevel.H : _errorCorrection;

  QrEyeStyle get _eyeStyle => QrEyeStyle(
        eyeShape: _rounded ? QrEyeShape.circle : QrEyeShape.square,
        color: _dark,
      );

  QrDataModuleStyle get _moduleStyle => QrDataModuleStyle(
        dataModuleShape: _rounded ? QrDataModuleShape.circle : QrDataModuleShape.square,
        color: _dark,
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Returns null when the data doesn't fit into a QR code (version 40).
  ///
  /// QrValidator.validate and QrCode.fromData encode lazily and report too-long data as valid;
  /// the QrInputTooLongException is only thrown when the modules are built — inside QrImageView's
  /// build, where errorStateBuilder doesn't catch it. Building a QrImage here forces the encoding.
  static QrCode? _encode(String data, int errorCorrectLevel) {
    try {
      final qr = QrCode.fromData(data: data, errorCorrectLevel: errorCorrectLevel);
      QrImage(qr);
      return qr;
    } on Exception {
      return null;
    }
  }

  Future<void> _exportPng(QrCode qr) async {
    final l10n = context.l10n;
    const size = 1024.0;
    const quietZone = 64.0; // scanners need a light margin around the code

    ui.Image? logo;
    if (_withLogo) {
      final data = await rootBundle.load(_logoAsset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: 200, targetHeight: 200);
      logo = (await codec.getNextFrame()).image;
      codec.dispose();
    }

    final painter = QrPainter.withQr(
      qr: qr,
      gapless: true,
      eyeStyle: _eyeStyle,
      dataModuleStyle: _moduleStyle,
      embeddedImage: logo, // QrPainter takes a ui.Image, QrImageView an ImageProvider
      embeddedImageStyle: const QrEmbeddedImageStyle(size: Size.square(200)),
    );

    // painter.toImageData() has a transparent background → paint onto white ourselves.
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..drawRect(const Rect.fromLTWH(0, 0, size, size), Paint()..color = _light);
    canvas.translate(quietZone, quietZone);
    painter.paint(canvas, const Size.square(size - quietZone * 2));
    final image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    logo?.dispose();

    if (byteData == null || !mounted) return;
    final bytes = byteData.buffer.asUint8List();
    // Save with file_selector / share with share_plus — out of scope for this demo.
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.qrExported((bytes.length / 1024).ceil())),
        content: Image.memory(bytes, width: 240, height: 240),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(MaterialLocalizations.of(context).closeButtonLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final qr = _encode(_controller.text, _level);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.qrTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _controller,
            minLines: 1,
            maxLines: 4,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l10n.qrData,
              helperText: l10n.qrCharacters(_controller.text.length),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                // Always dark modules on a light background, also in dark mode:
                // many scanners can't read inverted codes.
                color: _light,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              // Build from the pre-encoded QrCode (see _encode) instead of QrImageView(data: ...).
              child: qr == null
                  ? SizedBox.square(
                      dimension: 240,
                      child: Center(
                        child: Text(l10n.qrTooLong, textAlign: TextAlign.center, style: const TextStyle(color: _dark)),
                      ),
                    )
                  : QrImageView.withQr(
                      qr: qr,
                      size: 240,
                      padding: EdgeInsets.zero,
                      eyeStyle: _eyeStyle,
                      dataModuleStyle: _moduleStyle,
                      embeddedImage: _withLogo ? const AssetImage(_logoAsset) : null,
                      embeddedImageStyle: const QrEmbeddedImageStyle(size: Size.square(48)),
                      semanticsLabel: l10n.qrTitle,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          if (qr != null)
            Center(child: Text(l10n.qrInfo(qr.typeNumber, qr.moduleCount), style: theme.textTheme.bodySmall)),
          const SizedBox(height: 16),
          Text(l10n.qrErrorCorrection, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: [
              for (final (level, label) in [
                (QrErrorCorrectLevel.L, 'L 7%'),
                (QrErrorCorrectLevel.M, 'M 15%'),
                (QrErrorCorrectLevel.Q, 'Q 25%'),
                (QrErrorCorrectLevel.H, 'H 30%'),
              ])
                ButtonSegment(value: level, label: Text(label)),
            ],
            selected: {_level},
            onSelectionChanged: _withLogo ? null : (selection) => setState(() => _errorCorrection = selection.first),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.qrRounded),
            value: _rounded,
            onChanged: (value) => setState(() => _rounded = value),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.qrLogo),
            subtitle: Text(l10n.qrLogoHint),
            value: _withLogo,
            onChanged: (value) => setState(() => _withLogo = value),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            icon: const Icon(Icons.download),
            label: Text(l10n.qrExport),
            onPressed: qr == null ? null : () => _exportPng(qr),
          ),
        ],
      ),
    );
  }
}
