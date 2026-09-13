import 'package:flutter_best_practices/media/byte_size.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatBytes picks a readable unit', () {
    expect(formatBytes(532), '532 B');
    expect(formatBytes(12698), '12.4 KB');
    expect(formatBytes(3250586), '3.1 MB');
  });

  test('savedPercent is rounded and never negative', () {
    expect(savedPercent(original: 1000, compressed: 250), 75);
    expect(savedPercent(original: 1000, compressed: 1200), 0); // compression made it bigger
    expect(savedPercent(original: 0, compressed: 0), 0);
  });
}
