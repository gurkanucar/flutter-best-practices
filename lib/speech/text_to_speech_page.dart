import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n_extension.dart';
import 'locale_matching.dart';

enum TtsStatus { idle, speaking, paused }

class TextToSpeechPage extends StatefulWidget {
  const TextToSpeechPage({super.key});

  /// flutter_tts: Android, iOS, macOS, Windows and web — no Linux implementation.
  static bool get isSupported => kIsWeb || defaultTargetPlatform != TargetPlatform.linux;

  @override
  State<TextToSpeechPage> createState() => _TextToSpeechPageState();
}

class _TextToSpeechPageState extends State<TextToSpeechPage> {
  // One instance at a time: the constructor re-registers the handlers on a shared channel.
  final _tts = FlutterTts();
  final _textController = TextEditingController();

  // Speech rate scales differ: native platforms treat 0.5 as normal speed, the Web Speech API 1.0.
  static const double _normalRate = kIsWeb ? 1.0 : 0.5;
  static const double _maxRate = kIsWeb ? 2.0 : 1.0;

  bool _started = false;
  bool _loading = true;
  List<String> _languages = const [];
  List<Map<String, String>> _voices = const [];
  String? _language;
  Map<String, String>? _voice;
  double _rate = _normalRate;
  double _pitch = 1.0;
  double _volume = 1.0;
  TtsStatus _status = TtsStatus.idle;
  String? _spokenText;
  (int, int)? _spokenRange;
  String? _message;

  bool get _isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  bool get _isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Needs the app locale, which isn't available in initState.
    if (_started || !TextToSpeechPage.isSupported) return;
    _started = true;
    _textController.text = context.l10n.ttsSampleText;
    _init(Localizations.localeOf(context));
  }

  @override
  void dispose() {
    _tts.stop();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _init(Locale appLocale) async {
    _tts
      ..setStartHandler(() => _setStatus(TtsStatus.speaking))
      ..setCompletionHandler(() => _setStatus(TtsStatus.idle))
      ..setCancelHandler(() => _setStatus(TtsStatus.idle))
      ..setPauseHandler(() => _setStatus(TtsStatus.paused))
      ..setContinueHandler(() => _setStatus(TtsStatus.speaking))
      ..setErrorHandler((error) {
        _setStatus(TtsStatus.idle);
        if (mounted) setState(() => _message = context.l10n.ttsError('$error'));
      })
      // Word boundaries (Android, iOS, macOS, web) → highlight the spoken word.
      ..setProgressHandler((text, start, end, word) {
        if (mounted) setState(() => _spokenRange = (start, end));
      });

    try {
      if (_isIOS) {
        // Speak even when the silent switch is on and lower other audio meanwhile.
        await _tts.setSharedInstance(true);
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [IosTextToSpeechAudioCategoryOptions.duckOthers],
        );
      }
      await _loadLanguages();
      final initial = bestLocaleMatch(_languages, appLocale);
      if (initial != null) await _selectLanguage(initial);
    } catch (error) {
      if (mounted) setState(() => _message = context.l10n.ttsError('$error'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadLanguages() async {
    // Browsers load voices lazily (`voiceschanged`) → the first call can return an empty list.
    for (var attempt = 0; attempt < 5; attempt++) {
      final languages = ((await _tts.getLanguages) as List? ?? const [])
          .map((language) => '$language')
          .toSet()
          .toList()
        ..sort();
      final voices = ((await _tts.getVoices) as List? ?? const [])
          .whereType<Map>()
          .map((voice) => {for (final entry in voice.entries) '${entry.key}': '${entry.value}'})
          .where((voice) => voice.containsKey('name') && voice.containsKey('locale'))
          .toList()
        ..sort((a, b) => a['name']!.compareTo(b['name']!));

      if (languages.isNotEmpty || !kIsWeb) {
        if (mounted) {
          setState(() {
            _languages = languages;
            _voices = voices;
          });
        }
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
  }

  List<Map<String, String>> _voicesFor(String? language) {
    if (language == null) return const [];
    final exact = _voices.where((voice) => sameLocale(voice['locale']!, language)).toList();
    return exact.isNotEmpty ? exact : _voices.where((voice) => sameLanguage(voice['locale']!, language)).toList();
  }

  Future<void> _selectLanguage(String language) async {
    final l10n = context.l10n;
    final result = await _tts.setLanguage(language);
    var message = result == 1 ? null : l10n.ttsLanguageUnavailable(language);

    // Android: a language can be supported while its voice data isn't downloaded yet.
    if (message == null && _isAndroid && await _tts.isLanguageInstalled(language) != true) {
      message = l10n.ttsLanguageNotInstalled(language);
    }

    // A voice picked for the previous language would keep speaking that language.
    Map<String, String>? voice;
    final voices = _voicesFor(language);
    if (_voice != null && voices.isNotEmpty) {
      voice = voices.first;
      await _tts.setVoice(voice);
    }

    if (!mounted) return;
    setState(() {
      _language = language;
      _voice = voice;
      _message = message;
    });
  }

  Future<void> _selectVoice(List<Map<String, String>> voices, String? name) async {
    if (name == null) return;
    if (name.isEmpty) {
      // "Default voice": clearVoice exists on Android/iOS only; setLanguage picks the language's default elsewhere.
      if (_isAndroid || _isIOS) await _tts.clearVoice();
      if (_language != null) await _tts.setLanguage(_language!);
      if (mounted) setState(() => _voice = null);
      return;
    }
    final voice = voices.firstWhere((voice) => voice['name'] == name);
    await _tts.setVoice(voice);
    if (mounted) setState(() => _voice = voice);
  }

  Future<void> _speak() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _message = null;
      _spokenText = text;
      _spokenRange = null;
    });
    // Volume before pitch: on iOS/macOS setPitch is ignored while the volume is below 0.5 (plugin bug).
    await _tts.setVolume(_volume);
    await _tts.setPitch(_pitch);
    await _tts.setSpeechRate(_rate);
    await _tts.speak(text);
  }

  Future<void> _stop() async {
    await _tts.stop();
    _setStatus(TtsStatus.idle);
  }

  void _setStatus(TtsStatus status) {
    if (!mounted) return;
    setState(() {
      _status = status;
      if (status == TtsStatus.idle) _spokenRange = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    if (!TextToSpeechPage.isSupported) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.ttsTitle)),
        body: Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(l10n.ttsUnsupported))),
      );
    }

    final voices = _voicesFor(_language);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ttsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _textController,
            minLines: 2,
            maxLines: 5,
            decoration: InputDecoration(labelText: l10n.ttsText, border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const LinearProgressIndicator()
          else if (_languages.isEmpty)
            Text(l10n.ttsNoLanguages)
          else ...[
            DropdownMenu<String>(
              // initialSelection is only read once → rebuild when the language is set asynchronously.
              key: ValueKey('language-$_language'),
              initialSelection: _language,
              expandedInsets: EdgeInsets.zero,
              enableFilter: true,
              requestFocusOnTap: true,
              menuHeight: 320,
              leadingIcon: const Icon(Icons.translate),
              label: Text(l10n.ttsLanguage),
              dropdownMenuEntries: [
                for (final language in _languages) DropdownMenuEntry(value: language, label: language),
              ],
              onSelected: (language) {
                if (language != null) _selectLanguage(language);
              },
            ),
            const SizedBox(height: 16),
            DropdownMenu<String>(
              key: ValueKey('voice-$_language-${_voice?['name']}'),
              initialSelection: _voice?['name'] ?? '',
              expandedInsets: EdgeInsets.zero,
              menuHeight: 320,
              leadingIcon: const Icon(Icons.record_voice_over),
              label: Text(l10n.ttsVoice),
              dropdownMenuEntries: [
                DropdownMenuEntry(value: '', label: l10n.ttsDefaultVoice),
                for (final voice in voices) DropdownMenuEntry(value: voice['name']!, label: _voiceLabel(voice)),
              ],
              onSelected: (name) => _selectVoice(voices, name),
            ),
          ],
          const SizedBox(height: 16),
          _SliderTile(
            label: l10n.ttsRate,
            value: _rate,
            min: 0.1,
            max: _maxRate,
            onChanged: (value) => setState(() => _rate = value),
          ),
          _SliderTile(
            label: l10n.ttsPitch,
            value: _pitch,
            min: 0.5,
            max: 2.0,
            onChanged: (value) => setState(() => _pitch = value),
          ),
          _SliderTile(
            label: l10n.ttsVolume,
            value: _volume,
            min: 0.0,
            max: 1.0,
            onChanged: (value) => setState(() => _volume = value),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.ttsSpeak),
                onPressed: _loading || _status == TtsStatus.speaking ? null : _speak,
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.pause),
                label: Text(l10n.ttsPause),
                onPressed: _status == TtsStatus.speaking ? _tts.pause : null,
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.stop),
                label: Text(l10n.ttsStop),
                onPressed: _status == TtsStatus.idle ? null : _stop,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_spokenText case final text? when _spokenRange != null && _spokenRange!.$2 <= text.length)
            Text.rich(
              TextSpan(
                style: theme.textTheme.bodyLarge,
                children: [
                  TextSpan(text: text.substring(0, _spokenRange!.$1)),
                  TextSpan(
                    text: text.substring(_spokenRange!.$1, _spokenRange!.$2),
                    style: TextStyle(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  TextSpan(text: text.substring(_spokenRange!.$2)),
                ],
              ),
            ),
          if (_message != null)
            Text(_message!, style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.error)),
        ],
      ),
    );
  }

  static String _voiceLabel(Map<String, String> voice) => [
        voice['name'],
        voice['gender'],
        voice['quality'],
      ].nonNulls.where((part) => part.isNotEmpty).join(' · ');
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(2)}'),
        Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}
