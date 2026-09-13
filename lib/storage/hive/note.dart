/// Stored in a Hive box through the generated `NoteAdapter` (see hive_adapters.dart).
/// Fields must be final and match the constructor parameters.
class Note {
  const Note({required this.title, required this.createdAt, this.pinned = false});

  final String title;
  final DateTime createdAt;
  final bool pinned;

  Note copyWith({String? title, DateTime? createdAt, bool? pinned}) => Note(
        title: title ?? this.title,
        createdAt: createdAt ?? this.createdAt,
        pinned: pinned ?? this.pinned,
      );
}
