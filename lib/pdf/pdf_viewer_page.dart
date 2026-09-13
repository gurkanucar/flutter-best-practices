import 'package:material_ui/material_ui.dart';
import 'package:pdfrx/pdfrx.dart';

import '../l10n/l10n_extension.dart';

class PdfViewerPage extends StatefulWidget {
  const PdfViewerPage({super.key});

  static const sampleAsset = 'assets/pdf/sample.pdf'; // declared in pubspec.yaml

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  final _controller = PdfViewerController();
  int _pageCount = 0;
  int _pageNumber = 1;

  void _goTo(int pageNumber) {
    if (pageNumber < 1 || pageNumber > _pageCount) return;
    _controller.goToPage(pageNumber: pageNumber);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageCount == 0 ? l10n.pdfTitle : l10n.pdfPage(_pageNumber, _pageCount)),
        actions: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up),
            tooltip: l10n.previousPage,
            onPressed: _pageNumber > 1 ? () => _goTo(_pageNumber - 1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            tooltip: l10n.nextPage,
            onPressed: _pageNumber < _pageCount ? () => _goTo(_pageNumber + 1) : null,
          ),
        ],
      ),
      // Other sources: PdfViewer.file(path), PdfViewer.uri(Uri.parse(url)), PdfViewer.data(bytes, sourceName: ...)
      body: PdfViewer.asset(
        PdfViewerPage.sampleAsset,
        controller: _controller,
        params: PdfViewerParams(
          onViewerReady: (document, controller) =>
              setState(() => _pageCount = document.pages.length),
          onPageChanged: (pageNumber) {
            if (pageNumber != null) setState(() => _pageNumber = pageNumber);
          },
        ),
      ),
    );
  }
}
