import 'package:nanoid/nanoid.dart' as nano;
import 'package:uuid/uuid.dart';

/// All id generation goes through here — one place to change the strategy.
abstract final class Ids {
  static const _uuid = Uuid();

  /// Random UUID (122 random bits). Safe default when ids don't need ordering.
  static String uuidV4() => _uuid.v4();

  /// Time-ordered UUID (Unix ms timestamp + random). Sorts by creation time, which keeps
  /// database primary key indexes compact — prefer it for new tables.
  static String uuidV7() => _uuid.v7();

  /// Name-based UUID: the same namespace + name always gives the same id
  /// (e.g. an id for an external resource, idempotency keys).
  static String uuidV5(String name, {Namespace namespace = Namespace.url}) => _uuid.v5(namespace.value, name);

  static bool isValidUuid(String value) => Uuid.isValidUUID(fromString: value);

  /// URL-safe random id (`A-Za-z0-9_-`), 21 chars ≈ the collision resistance of UUID v4.
  static String nanoId([int size = 21]) => nano.nanoid(size);

  /// No 0/O and 1/I, so codes can be read aloud or typed from a receipt.
  static const orderCodeAlphabet = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';

  /// Short, human-friendly code. Short ids collide sooner — keep a unique index in the database.
  static String orderCode({int length = 8}) => nano.customAlphabet(orderCodeAlphabet, length);
}
