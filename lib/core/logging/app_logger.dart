import 'dart:collection';

class AppLogger {
  final ListQueue<String> _entries = ListQueue<String>();

  static const int maxEntries = 120;

  void log(String message) {
    final stamp = DateTime.now().toIso8601String();
    _entries.addLast('[$stamp] $message');
    if (_entries.length > maxEntries) {
      _entries.removeFirst();
    }
  }

  List<String> get entries => _entries.toList();

  void clear() {
    _entries.clear();
  }
}
