import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../l10n/l10n_extension.dart';
import 'locale_matching.dart';

class SpeechToTextPage extends StatefulWidget {
  const SpeechToTextPage({super.key});

  /// speech_to_text: Android, iOS, macOS, web (Chrome/Edge), Windows (beta). No Linux.
  static bool get isSupported => kIsWeb || defaultTargetPlatform != TargetPlatform.linux;

  /// Windows: SAPI dictation, English only, marked "not ready for production" by the package.
  static bool get isBeta => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  @override
  State<SpeechToTextPage> createState() => _SpeechToTextPageState();
}

class _SpeechToTextPageState extends State<SpeechToTextPage> {
  final _speech = SpeechToText(); // singleton

  bool _started = false;
  bool? _available;
  bool _permissionDenied = false;
  List<LocaleName> _locales = const [];
  String? _localeId;

  String _words = '';
  bool _isFinal = false;
  double? _confidence;
  String? _error;

  // Sound level units differ per platform (Android rms dB ≈ -2..10, Apple dB) → normalize by observed range.
  double _level = 0;
  double _minLevel = double.infinity;
  double _maxLevel = double.negativeInfinity;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started || !SpeechToTextPage.isSupported) return;
    _started = true;
    _init(Localizations.localeOf(context));
  }

  @override
  void dispose() {
    _speech
      ..errorListener = null
      ..statusListener = null;
    if (_speech.isListening) _speech.cancel();
    super.dispose();
  }

  Future<void> _init(Locale appLocale) async {
    var available = false;
    try {
      // Asks for the microphone (and speech recognition on Apple) permission.
      // androidNoBluetooth: don't request BLUETOOTH_CONNECT for headset microphones.
      available = await _speech.initialize(
        onError: _onError,
        onStatus: _onStatus,
        options: [SpeechToText.androidNoBluetooth],
      );
    } on PlatformException catch (error) {
      // Android can throw (e.g. recognizerNotAvailable) instead of returning false.
      _error = error.message ?? error.code;
    }
    // Singleton: a second initialize() returns the cached result and ignores the new callbacks.
    _speech
      ..errorListener = _onError
      ..statusListener = _onStatus;

    var locales = const <LocaleName>[];
    String? localeId;
    var permissionDenied = false;
    if (available) {
      locales = await _speech.locales();
      localeId = bestLocaleMatch(locales.map((locale) => locale.localeId), appLocale) ??
          (await _speech.systemLocale())?.localeId;
    } else {
      try {
        permissionDenied = !await _speech.hasPermission;
      } on PlatformException {
        permissionDenied = false;
      }
    }

    if (!mounted) return;
    setState(() {
      _available = available;
      _permissionDenied = permissionDenied;
      _locales = locales;
      _localeId = localeId;
    });
  }

  void _onStatus(String status) {
    if (mounted) setState(() {}); // isListening changed
  }

  void _onError(SpeechRecognitionError error) {
    if (!mounted) return;
    setState(() => _error = error.errorMsg == 'error_no_match' ? context.l10n.sttNoMatch : error.errorMsg);
  }

  void _onResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    setState(() {
      _words = result.recognizedWords;
      _isFinal = result.finalResult;
      _confidence = result.hasConfidenceRating ? result.confidence : null;
    });
  }

  void _onSoundLevel(double level) {
    if (!mounted) return;
    setState(() {
      _level = level;
      _minLevel = min(_minLevel, level);
      _maxLevel = max(_maxLevel, level);
    });
  }

  double get _normalizedLevel =>
      _maxLevel > _minLevel ? ((_level - _minLevel) / (_maxLevel - _minLevel)).clamp(0.0, 1.0) : 0;

  Future<void> _toggleListening() async {
    if (_speech.isListening) {
      await _speech.stop(); // delivers the final result; cancel() would drop it
      if (mounted) setState(() {});
      return;
    }

    setState(() {
      _words = '';
      _isFinal = false;
      _confidence = null;
      _error = null;
      _minLevel = double.infinity;
      _maxLevel = double.negativeInfinity;
    });

    try {
      await _speech.listen(
        onResult: _onResult,
        onSoundLevelChange: _onSoundLevel,
        // 7.x: options moved from listen() parameters into SpeechListenOptions.
        listenOptions: SpeechListenOptions(
          localeId: _localeId,
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.dictation,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
        ),
      );
    } on ListenFailedException catch (error) {
      if (mounted) setState(() => _error = error.message);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    if (!SpeechToTextPage.isSupported) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.sttTitle)),
        body: Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(l10n.sttUnsupported))),
      );
    }

    final listening = _speech.isListening;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sttTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (SpeechToTextPage.isBeta)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(l10n.sttWindowsBeta, style: TextStyle(color: theme.colorScheme.error)),
            ),
          if (_available == null)
            const LinearProgressIndicator()
          else if (_available == false) ...[
            Text(_permissionDenied ? l10n.sttPermissionDenied : l10n.sttUnavailable),
            if (_error != null) Text(_error!),
            if (_permissionDenied && !kIsWeb) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.settings),
                label: Text(l10n.sttOpenSettings),
                onPressed: () => AppSettings.openAppSettings(),
              ),
            ],
          ] else ...[
            if (_locales.isEmpty)
              Text(l10n.sttNoLocales)
            else
              DropdownMenu<String>(
                key: ValueKey('locale-$_localeId'),
                initialSelection: _localeId,
                enabled: !listening,
                expandedInsets: EdgeInsets.zero,
                enableFilter: true,
                requestFocusOnTap: true,
                menuHeight: 320,
                leadingIcon: const Icon(Icons.translate),
                label: Text(l10n.sttLanguage),
                dropdownMenuEntries: [
                  for (final locale in _locales)
                    DropdownMenuEntry(value: locale.localeId, label: '${locale.name} (${locale.localeId})'),
                ],
                onSelected: (localeId) => setState(() => _localeId = localeId),
              ),
            const SizedBox(height: 32),
            Center(
              child: IconButton.filled(
                iconSize: 48,
                padding: const EdgeInsets.all(24),
                tooltip: listening ? l10n.sttStop : l10n.sttStart,
                icon: Icon(listening ? Icons.stop : Icons.mic),
                onPressed: _toggleListening,
              ),
            ),
            const SizedBox(height: 12),
            Center(child: Text(listening ? l10n.sttListening : l10n.sttTapToSpeak)),
            const SizedBox(height: 8),
            // Android, iOS and macOS report sound levels; Windows and web don't.
            LinearProgressIndicator(value: listening ? _normalizedLevel : 0),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_words.isEmpty ? l10n.sttEmpty : _words, style: theme.textTheme.headlineSmall),
                    if (_words.isNotEmpty)
                      Text(
                        [
                          _isFinal ? l10n.sttFinal : l10n.sttPartial,
                          if (_confidence != null) l10n.sttConfidence((_confidence! * 100).round()),
                        ].join(' · '),
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              ),
          ],
        ],
      ),
    );
  }
}
