import 'package:uuid/uuid.dart';

class IdGenerator {
  static final Uuid _uuid = Uuid();

  static String nextMessageId() => 'msg-${_uuid.v4()}';

  static String nextSosId() => 'sos-${_uuid.v4()}';

  static String nextEventId() => 'evt-${_uuid.v4()}';
}
