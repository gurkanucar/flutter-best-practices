import 'package:flutter/foundation.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n_extension.dart';

class ImageCropPage extends StatefulWidget {
  const ImageCropPage({super.key});

  /// image_cropper: Android (uCrop), iOS (TOCropViewController), web (cropperjs). No desktop.
  static bool get isSupported =>
      kIsWeb || defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;

  @override
  State<ImageCropPage> createState() => _ImageCropPageState();
}

class _ImageCropPageState extends State<ImageCropPage> {
  final _picker = ImagePicker();
  final _cropper = ImageCropper();

  bool _circle = false;
  bool _busy = false;
  Uint8List? _result;
  bool _resultIsCircle = false;
  int? _originalSize;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) _recoverLostCrop();
  }

  /// Android can kill the app while the uCrop screen is open — the result is recoverable on the next start.
  Future<void> _recoverLostCrop() async {
    final lost = await _cropper.recoverImage();
    if (lost == null) return;
    final bytes = await lost.readAsBytes();
    if (mounted) setState(() => _result = bytes);
  }

  Future<void> _pickAndCrop(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked == null || !mounted) return;

    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final circle = _circle;
    final List<CropAspectRatioPresetData> presets = circle
        ? [CropAspectRatioPreset.square]
        : [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ];

    setState(() => _busy = true);
    try {
      // No await before this call: WebUiSettings needs the BuildContext.
      final cropped = await _cropper.cropImage(
        sourcePath: picked.path, // web: a blob URL from image_picker, also accepted
        aspectRatio: circle ? const CropAspectRatio(ratioX: 1, ratioY: 1) : null,
        maxWidth: 1080, // maxWidth/maxHeight/compressQuality are ignored on web
        maxHeight: 1080,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: l10n.cropTitle,
            toolbarColor: colors.surface,
            toolbarWidgetColor: colors.onSurface,
            activeControlsWidgetColor: colors.primary,
            cropStyle: circle ? CropStyle.circle : CropStyle.rectangle,
            lockAspectRatio: circle,
            initAspectRatio: circle ? CropAspectRatioPreset.square : CropAspectRatioPreset.original,
            aspectRatioPresets: presets,
          ),
          IOSUiSettings(
            title: l10n.cropTitle,
            doneButtonTitle: l10n.done,
            cancelButtonTitle: l10n.cancel,
            cropStyle: circle ? CropStyle.circle : CropStyle.rectangle,
            aspectRatioLockEnabled: circle,
            aspectRatioPresets: presets,
          ),
          // Required on web, otherwise cropImage throws.
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.dialog,
            size: const CropperSize(width: 520, height: 520),
            translations: WebTranslations(
              title: l10n.cropTitle,
              rotateLeftTooltip: l10n.cropRotateLeft,
              rotateRightTooltip: l10n.cropRotateRight,
              cancelButton: l10n.cancel,
              cropButton: l10n.cropApply,
            ),
          ),
        ],
      );
      if (cropped == null) return; // cancelled
      final originalSize = await picked.length();

      // The output is a temporary file — copy it somewhere permanent (or upload it) if you keep it.
      final bytes = await cropped.readAsBytes();
      if (!mounted) return;
      setState(() {
        _result = bytes;
        _resultIsCircle = circle;
        _originalSize = originalSize;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (!ImageCropPage.isSupported) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.cropTitle)),
        body: Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(l10n.cropUnsupported))),
      );
    }

    final result = _result;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cropTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.cropCircle),
            subtitle: Text(l10n.cropCircleHint),
            value: _circle,
            onChanged: (value) => setState(() => _circle = value),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                icon: const Icon(Icons.photo_library),
                label: Text(l10n.cropPickGallery),
                onPressed: _busy ? null : () => _pickAndCrop(ImageSource.gallery),
              ),
              if (_picker.supportsImageSource(ImageSource.camera))
                OutlinedButton.icon(
                  icon: const Icon(Icons.photo_camera),
                  label: Text(l10n.cropPickCamera),
                  onPressed: _busy ? null : () => _pickAndCrop(ImageSource.camera),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (_busy) const LinearProgressIndicator(),
          if (result == null)
            Text(l10n.cropEmpty)
          else ...[
            Center(
              child: _resultIsCircle
                  // The file is still a square image; the circle is only the crop overlay → clip when showing it.
                  ? ClipOval(child: Image.memory(result, width: 240, height: 240, fit: BoxFit.cover))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(result, height: 320, fit: BoxFit.contain),
                    ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _originalSize == null
                    ? l10n.cropResultSize((result.length / 1024).ceil())
                    : l10n.cropResultSizes((result.length / 1024).ceil(), (_originalSize! / 1024).ceil()),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
