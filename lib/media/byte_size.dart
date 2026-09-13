/// Human-readable size: 532 B, 12.4 KB, 3.1 MB.
String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
  return '${(kb / 1024).toStringAsFixed(1)} MB';
}

/// How much smaller [compressed] is than [original], in whole percent (never negative).
int savedPercent({required int original, required int compressed}) {
  if (original <= 0 || compressed >= original) return 0;
  return ((original - compressed) * 100 / original).round();
}
