import 'package:flutter_best_practices/ids/ids.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

void main() {
  test('uuidV4 is a valid version 4 UUID', () {
    final id = Ids.uuidV4();
    expect(Ids.isValidUuid(id), isTrue);
    expect(UuidValue.fromString(id).version, 4);
  });

  test('uuidV7 ids created later sort after earlier ones', () async {
    final first = Ids.uuidV7();
    await Future<void>.delayed(const Duration(milliseconds: 2));
    final second = Ids.uuidV7();

    expect(UuidValue.fromString(first).version, 7);
    expect(first.compareTo(second), lessThan(0));
  });

  test('uuidV5 is deterministic per name', () {
    expect(Ids.uuidV5('https://example.com/a'), Ids.uuidV5('https://example.com/a'));
    expect(Ids.uuidV5('https://example.com/a'), isNot(Ids.uuidV5('https://example.com/b')));
    expect(UuidValue.fromString(Ids.uuidV5('x')).version, 5);
  });

  test('isValidUuid rejects garbage', () {
    expect(Ids.isValidUuid('not-a-uuid'), isFalse);
    expect(Ids.isValidUuid(''), isFalse);
  });

  test('nanoId is 21 URL-safe characters by default', () {
    expect(Ids.nanoId(), matches(RegExp(r'^[A-Za-z0-9_-]{21}$')));
    expect(Ids.nanoId(10), hasLength(10));
  });

  test('orderCode only uses the unambiguous alphabet', () {
    for (var i = 0; i < 100; i++) {
      final code = Ids.orderCode();
      expect(code, hasLength(8));
      expect(code.split('').every(Ids.orderCodeAlphabet.contains), isTrue, reason: code);
    }
  });
}
