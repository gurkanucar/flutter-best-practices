import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pdfrx/pdfrx.dart';

import '../l10n/l10n_extension.dart';

class DocumentScannerPage extends StatefulWidget {
  const DocumentScannerPage({super.key});

  /// Android: Google ML Kit document scanner (Play services). iOS: VisionKit. No other platform.
  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  @override
  State<DocumentScannerPage> createState() => _DocumentScannerPageState();
}

class _DocumentScannerPageState extends State<DocumentScannerPage> {
  final _scanner = FlutterDocScanner();

  List<String> _images = const [];
  String? _pdfPath;
  int _pdfPages = 0;
  int _pageLimit = 4;
  bool _busy = false;
  String? _error;

  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  @override
  void dispose() {
    _deleteScans();
    super.dispose();
  }

  /// Scans are written to the cache (Android) or the Documents folder (iOS) and nobody deletes them.
  /// The demo keeps nothing; a real app moves the files it keeps, uploads or deletes the rest.
  void _deleteScans() {
    for (final path in [..._images, ?_pdfPath]) {
      try {
        File(path).deleteSync();
      } on FileSystemException {
        // already gone
      }
    }
  }

  /// Android returns `file://` URIs, iOS plain paths.
  static String _toFilePath(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && uri.scheme == 'file' ? uri.toFilePath() : value;
  }

  Future<void> _scan({required bool asPdf}) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (asPdf) {
        final result = await _scanner.getScannedDocumentAsPdf(page: _pageLimit);
        if (result == null || !mounted) return; // cancelled
        _deleteScans();
        setState(() {
          _images = const [];
          _pdfPath = _toFilePath(result.pdfUri);
          _pdfPages = result.pageCount;
        });
      } else {
        final result = await _scanner.getScannedDocumentAsImages(page: _pageLimit);
        if (result == null || !mounted) return;
        _deleteScans();
        setState(() {
          _pdfPath = null;
          _images = result.images.map(_toFilePath).toList();
        });
      }
    } on DocScanException catch (error) {
      // The plugin wraps PlatformException — `on PlatformException` never matches here.
      if (error.code != 'CANCELLED' && mounted) setState(() => _error = '${error.code}: ${error.message}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.docScanTitle)),
      body: !DocumentScannerPage.isSupported
          ? Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(l10n.docScanUnsupported)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.docScanIntro),
                if (_isAndroid) ...[
                  // iOS VisionKit has no page limit.
                  const SizedBox(height: 16),
                  Text(l10n.docScanPageLimit(_pageLimit)),
                  Slider(
                    value: _pageLimit.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: '$_pageLimit',
                    onChanged: (value) => setState(() => _pageLimit = value.round()),
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      icon: const Icon(Icons.document_scanner),
                      label: Text(l10n.docScanImages),
                      onPressed: _busy ? null : () => _scan(asPdf: false),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: Text(l10n.docScanPdf),
                      onPressed: _busy ? null : () => _scan(asPdf: true),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_busy) const LinearProgressIndicator(),
                if (_error != null) Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                if (_images.isNotEmpty) ...[
                  Text(l10n.docScanPages(_images.length), style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.7,
                    children: [
                      for (final path in _images)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(File(path), key: ValueKey(path), fit: BoxFit.cover),
                        ),
                    ],
                  ),
                ],
                if (_pdfPath != null) ...[
                  // iOS doesn't report the page count.
                  Text(
                    _pdfPages > 0 ? l10n.docScanPages(_pdfPages) : l10n.docScanPdfReady,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(height: 480, child: PdfViewer.file(_pdfPath!, key: ValueKey(_pdfPath))),
                ],
              ],
            ),
    );
  }
}
