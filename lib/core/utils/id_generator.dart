import 'package:uuid/uuid.dart';

/// Generates stable random identifiers (UUID v4).
class IdGenerator {
  const IdGenerator();

  static const Uuid _uuid = Uuid();

  String next() => _uuid.v4();
}
