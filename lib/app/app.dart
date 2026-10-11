import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/logging/app_logger.dart';
import '../core/utils/id_generator.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/devices/presentation/devices_screen.dart';
import '../features/messaging/domain/message.dart';
import '../features/messaging/presentation/messaging_screen.dart';
import '../features/sos/domain/sos_event.dart';
import '../features/sos/presentation/sos_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

class EcoLinkApp extends StatelessWidget {
  const EcoLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EcoLinkState()..load(),
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: EcoLinkTheme.theme,
        home: const EcoLinkShell(),
      ),
    );
  }
}

class EcoLinkShell extends StatefulWidget {
  const EcoLinkShell({super.key});

  @override
  State<EcoLinkShell> createState() => _EcoLinkShellState();
}

class _EcoLinkShellState extends State<EcoLinkShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EcoLinkState>();

    final pages = <Widget>[
      DashboardScreen(onNavigate: _navigateTo),
      const MessagingScreen(),
      const SosScreen(),
      const DevicesScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          _navigateTo(index);
          state.log('Navigation selected: ${pages[index].runtimeType}');
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.message_outlined),
            selectedIcon: Icon(Icons.message),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.warning_amber_outlined),
            selectedIcon: Icon(Icons.warning_amber),
            label: 'SOS',
          ),
          NavigationDestination(
            icon: Icon(Icons.device_hub_outlined),
            selectedIcon: Icon(Icons.device_hub),
            label: 'Devices',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _navigateTo(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class EcoLinkState extends ChangeNotifier {
  EcoLinkState() {
    _logger = AppLogger();
    _logger.log('EcoLink initialized in demo mode.');
  }

  late final AppLogger _logger;
  final List<Conversation> _conversations = [
    Conversation(
      id: 'conv_01',
      peerId: 'NODE_B',
      title: 'NODE_B',
      messages: [
        ChatMessage(
          id: 'msg_01',
          senderId: 'NODE_B',
          recipientId: AppConstants.defaultNodeId,
          text: 'Ridge trail is clear. Keep emergency channel available.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 7)),
          lifecycleStatus: MessageLifecycleStatus.receivedByDestination,
        ),
        ChatMessage(
          id: 'msg_02',
          senderId: AppConstants.defaultNodeId,
          recipientId: 'NODE_B',
          text: 'Copy that. Routing check complete.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          lifecycleStatus: MessageLifecycleStatus.sentToDevice,
        ),
      ],
    ),
    Conversation(
      id: 'conv_02',
      peerId: 'NODE_C',
      title: 'NODE_C',
      messages: [
        ChatMessage(
          id: 'msg_03',
          senderId: 'NODE_C',
          recipientId: AppConstants.defaultNodeId,
          text: 'Weather risk detected. Proceed to fallback route.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
          lifecycleStatus: MessageLifecycleStatus.receivedByDestination,
        ),
      ],
    ),
  ];

  final List<SosEvent> _sosHistory = [
    SosEvent(
      id: 'sos_01',
      eventId: 'EVT-1001',
      sourceNodeId: 'NODE_A',
      status: 'Monitoring',
      acknowledgementHistory: ['NODE_B acknowledged'],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isActive: false,
    ),
  ];

  final List<NodeDevice> _nodes = [
    NodeDevice(
      nodeId: 'NODE_A',
      type: 'Mobile',
      connectionStatus: 'connected',
      lastSeen: DateTime.now().toIso8601String(),
      rfStatus: 'Nominal',
      battery: 92,
    ),
    NodeDevice(
      nodeId: 'NODE_B',
      type: 'Relay',
      connectionStatus: 'linked',
      lastSeen: DateTime.now()
          .subtract(const Duration(minutes: 3))
          .toIso8601String(),
      rfStatus: 'Strong',
      battery: 76,
    ),
    NodeDevice(
      nodeId: 'NODE_C',
      type: 'Relay',
      connectionStatus: 'offline',
      lastSeen: DateTime.now()
          .subtract(const Duration(hours: 1))
          .toIso8601String(),
      rfStatus: 'Unknown',
      battery: null,
    ),
  ];

  String localNodeId = AppConstants.defaultNodeId;
  bool demoMode = true;
  bool usbConnected = false;
  bool internetAvailable = false;
  bool cloudAvailable = false;
  bool cloudSynchronizationPending = true;
  DateTime? lastSyncTime;
  String usbStatus = 'Demo mode';
  String rfStatus = 'Unknown';
  String cloudStatus = 'Awaiting gateway';

  List<Conversation> get conversations => List.unmodifiable(_conversations);
  List<SosEvent> get sosHistory => List.unmodifiable(_sosHistory);
  List<NodeDevice> get nodes => List.unmodifiable(_nodes);
  int get pendingQueueCount => _conversations.fold<int>(
    0,
    (sum, conversation) =>
        sum +
        conversation.messages
            .where(
              (m) =>
                  m.lifecycleStatus == MessageLifecycleStatus.queuedLocally ||
                  m.lifecycleStatus == MessageLifecycleStatus.failed,
            )
            .length,
  );
  int get sentMessagesCount => _conversations.fold<int>(
    0,
    (sum, conversation) =>
        sum +
        conversation.messages.where((m) => m.senderId == localNodeId).length,
  );
  int get receivedMessagesCount => _conversations.fold<int>(
    0,
    (sum, conversation) =>
        sum +
        conversation.messages.where((m) => m.recipientId == localNodeId).length,
  );
  DateTime? get lastSuccessfulSync => lastSyncTime;
  AppLogger get logger => _logger;

  void log(String message) {
    _logger.log(message);
    notifyListeners();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    localNodeId =
        prefs.getString('local_node_id') ?? AppConstants.defaultNodeId;
    demoMode = prefs.getBool('demo_mode') ?? true;
    if (demoMode) {
      usbStatus = 'Demo mode';
      usbConnected = false;
      rfStatus = 'Demo';
      internetAvailable = false;
      cloudStatus = 'Mock sync pending';
    }
    final messages = prefs.getStringList('ecolink_messages') ?? <String>[];
    _conversations.clear();
    for (final item in messages) {
      final decoded = jsonDecode(item);
      final message = ChatMessage.fromJson(decoded);
      final existing = _conversations
          .where((c) => c.peerId == message.peerId)
          .firstOrNull;
      if (existing != null) {
        existing.messages.add(message);
      } else {
        _conversations.add(
          Conversation(
            id: message.id,
            peerId: message.peerId,
            title: message.peerId,
            messages: [message],
          ),
        );
      }
    }
    final storedSos = prefs.getStringList('ecolink_sos') ?? <String>[];
    _sosHistory.clear();
    for (final item in storedSos) {
      _sosHistory.add(
        SosEvent.fromJson(jsonDecode(item) as Map<String, dynamic>),
      );
    }
    notifyListeners();
  }

  Future<void> _persistState() async {
    final prefs = await SharedPreferences.getInstance();
    final messageJson = _conversations
        .expand(
          (conversation) =>
              conversation.messages.map((m) => jsonEncode(m.toJson())),
        )
        .toList();
    await prefs.setStringList('ecolink_messages', messageJson);
    final sosJson = _sosHistory
        .map((event) => jsonEncode(event.toJson()))
        .toList();
    await prefs.setStringList('ecolink_sos', sosJson);
    await prefs.setString('local_node_id', localNodeId);
    await prefs.setBool('demo_mode', demoMode);
  }

  Future<void> sendMessage(String text, String peerId) async {
    if (text.trim().isEmpty) {
      return;
    }
    final message = ChatMessage(
      id: IdGenerator.nextMessageId(),
      senderId: localNodeId,
      recipientId: peerId,
      text: text.trim(),
      timestamp: DateTime.now(),
      lifecycleStatus: demoMode
          ? MessageLifecycleStatus.queuedLocally
          : MessageLifecycleStatus.sentToDevice,
    );
    final conversation =
        _conversations.where((c) => c.peerId == peerId).firstOrNull ??
        Conversation(
          id: 'conv_${IdGenerator.nextMessageId()}',
          peerId: peerId,
          title: peerId,
          messages: [],
        );
    conversation.messages.add(message);
    if (!_conversations.any((c) => c.peerId == peerId)) {
      _conversations.add(conversation);
    }
    _logger.log('Message queued for $peerId.');
    notifyListeners();
    await _persistState();
  }

  Future<void> simulateInboundMessage(String peerId, String text) async {
    final message = ChatMessage(
      id: IdGenerator.nextMessageId(),
      senderId: peerId,
      recipientId: localNodeId,
      text: text,
      timestamp: DateTime.now(),
      lifecycleStatus: MessageLifecycleStatus.receivedByDestination,
    );
    final conversation =
        _conversations.where((c) => c.peerId == peerId).firstOrNull ??
        Conversation(
          id: 'conv_${IdGenerator.nextMessageId()}',
          peerId: peerId,
          title: peerId,
          messages: [],
        );
    conversation.messages.add(message);
    if (!_conversations.any((c) => c.peerId == peerId)) {
      _conversations.add(conversation);
    }
    _logger.log('Received message from $peerId.');
    notifyListeners();
    await _persistState();
  }

  Future<void> retryFailedMessage(String messageId) async {
    final allMessages = _conversations.expand((c) => c.messages);
    final match = allMessages
        .where((element) => element.id == messageId)
        .firstOrNull;
    if (match == null) {
      return;
    }
    match.lifecycleStatus = MessageLifecycleStatus.queuedLocally;
    _logger.log('Retrying message $messageId.');
    notifyListeners();
    await _persistState();
  }

  Future<void> activateSos() async {
    final event = SosEvent(
      id: IdGenerator.nextSosId(),
      eventId: 'EVT-${DateTime.now().millisecondsSinceEpoch % 100000}',
      sourceNodeId: localNodeId,
      status: usbConnected ? 'Active' : 'Pending hardware',
      acknowledgementHistory: usbConnected
          ? ['NODE_B acknowledged']
          : ['Awaiting USB device'],
      createdAt: DateTime.now(),
      isActive: true,
    );
    _sosHistory.insert(0, event);
    _logger.log('SOS event ${event.eventId} created.');
    notifyListeners();
    await _persistState();
  }

  Future<void> resolveSos(String eventId) async {
    final target = _sosHistory
        .where((event) => event.eventId == eventId)
        .firstOrNull;
    if (target == null) {
      return;
    }
    target.status = 'Resolved';
    target.isActive = false;
    target.acknowledgementHistory.add('Operator resolved event');
    _logger.log('Resolved SOS event $eventId.');
    notifyListeners();
    await _persistState();
  }

  Future<void> updateCloudSyncStatus() async {
    cloudSynchronizationPending = !cloudAvailable;
    if (cloudAvailable) {
      lastSyncTime = DateTime.now();
      cloudStatus = 'Synchronized';
    } else {
      cloudStatus = 'Awaiting gateway';
    }
    _logger.log('Cloud sync status refreshed.');
    notifyListeners();
    await _persistState();
  }

  String diagnosticSummary() {
    final logs = _logger.entries.take(5).join('\n');
    return 'Node $localNodeId | USB $usbStatus | RF $rfStatus | Internet ${internetAvailable ? 'online' : 'offline'} | Cloud $cloudStatus\n$logs';
  }
}

class NodeDevice {
  NodeDevice({
    required this.nodeId,
    required this.type,
    required this.connectionStatus,
    required this.lastSeen,
    required this.rfStatus,
    required this.battery,
  });

  final String nodeId;
  final String type;
  final String connectionStatus;
  final String lastSeen;
  final String rfStatus;
  final double? battery;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
