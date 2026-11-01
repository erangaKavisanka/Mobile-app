// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, UserRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nodeIdMeta = const VerificationMeta('nodeId');
  @override
  late final GeneratedColumn<String> nodeId = GeneratedColumn<String>(
    'node_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _isLocalMeta = const VerificationMeta(
    'isLocal',
  );
  @override
  late final GeneratedColumn<bool> isLocal = GeneratedColumn<bool>(
    'is_local',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_local" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    nodeId,
    isLocal,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('node_id')) {
      context.handle(
        _nodeIdMeta,
        nodeId.isAcceptableOrUnknown(data['node_id']!, _nodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_nodeIdMeta);
    }
    if (data.containsKey('is_local')) {
      context.handle(
        _isLocalMeta,
        isLocal.isAcceptableOrUnknown(data['is_local']!, _isLocalMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      nodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}node_id'],
      )!,
      isLocal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_local'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class UserRow extends DataClass implements Insertable<UserRow> {
  final String id;
  final String displayName;
  final String nodeId;
  final bool isLocal;
  final DateTime createdAt;
  const UserRow({
    required this.id,
    required this.displayName,
    required this.nodeId,
    required this.isLocal,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    map['node_id'] = Variable<String>(nodeId);
    map['is_local'] = Variable<bool>(isLocal);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      displayName: Value(displayName),
      nodeId: Value(nodeId),
      isLocal: Value(isLocal),
      createdAt: Value(createdAt),
    );
  }

  factory UserRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRow(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      nodeId: serializer.fromJson<String>(json['nodeId']),
      isLocal: serializer.fromJson<bool>(json['isLocal']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'nodeId': serializer.toJson<String>(nodeId),
      'isLocal': serializer.toJson<bool>(isLocal),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserRow copyWith({
    String? id,
    String? displayName,
    String? nodeId,
    bool? isLocal,
    DateTime? createdAt,
  }) => UserRow(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    nodeId: nodeId ?? this.nodeId,
    isLocal: isLocal ?? this.isLocal,
    createdAt: createdAt ?? this.createdAt,
  );
  UserRow copyWithCompanion(UsersCompanion data) {
    return UserRow(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      nodeId: data.nodeId.present ? data.nodeId.value : this.nodeId,
      isLocal: data.isLocal.present ? data.isLocal.value : this.isLocal,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRow(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('nodeId: $nodeId, ')
          ..write('isLocal: $isLocal, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, displayName, nodeId, isLocal, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRow &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.nodeId == this.nodeId &&
          other.isLocal == this.isLocal &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<UserRow> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<String> nodeId;
  final Value<bool> isLocal;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.nodeId = const Value.absent(),
    this.isLocal = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String displayName,
    required String nodeId,
    this.isLocal = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       nodeId = Value(nodeId),
       createdAt = Value(createdAt);
  static Insertable<UserRow> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? nodeId,
    Expression<bool>? isLocal,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (nodeId != null) 'node_id': nodeId,
      if (isLocal != null) 'is_local': isLocal,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<String>? nodeId,
    Value<bool>? isLocal,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      nodeId: nodeId ?? this.nodeId,
      isLocal: isLocal ?? this.isLocal,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (nodeId.present) {
      map['node_id'] = Variable<String>(nodeId.value);
    }
    if (isLocal.present) {
      map['is_local'] = Variable<bool>(isLocal.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('nodeId: $nodeId, ')
          ..write('isLocal: $isLocal, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NodesTable extends Nodes with TableInfo<$NodesTable, NodeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nodeIdMeta = const VerificationMeta('nodeId');
  @override
  late final GeneratedColumn<String> nodeId = GeneratedColumn<String>(
    'node_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<NodeRole, String> role =
      GeneratedColumn<String>(
        'role',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<NodeRole>($NodesTable.$converterrole);
  @override
  late final GeneratedColumnWithTypeConverter<NodeStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<NodeStatus>($NodesTable.$converterstatus);
  static const VerificationMeta _batteryPercentMeta = const VerificationMeta(
    'batteryPercent',
  );
  @override
  late final GeneratedColumn<int> batteryPercent = GeneratedColumn<int>(
    'battery_percent',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rssiMeta = const VerificationMeta('rssi');
  @override
  late final GeneratedColumn<int> rssi = GeneratedColumn<int>(
    'rssi',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSimulatedMeta = const VerificationMeta(
    'isSimulated',
  );
  @override
  late final GeneratedColumn<bool> isSimulated = GeneratedColumn<bool>(
    'is_simulated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_simulated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nodeId,
    name,
    role,
    status,
    batteryPercent,
    rssi,
    lastSeenAt,
    isSimulated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<NodeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('node_id')) {
      context.handle(
        _nodeIdMeta,
        nodeId.isAcceptableOrUnknown(data['node_id']!, _nodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_nodeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('battery_percent')) {
      context.handle(
        _batteryPercentMeta,
        batteryPercent.isAcceptableOrUnknown(
          data['battery_percent']!,
          _batteryPercentMeta,
        ),
      );
    }
    if (data.containsKey('rssi')) {
      context.handle(
        _rssiMeta,
        rssi.isAcceptableOrUnknown(data['rssi']!, _rssiMeta),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    }
    if (data.containsKey('is_simulated')) {
      context.handle(
        _isSimulatedMeta,
        isSimulated.isAcceptableOrUnknown(
          data['is_simulated']!,
          _isSimulatedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NodeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NodeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}node_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      role: $NodesTable.$converterrole.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}role'],
        )!,
      ),
      status: $NodesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      batteryPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}battery_percent'],
      ),
      rssi: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rssi'],
      ),
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      ),
      isSimulated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_simulated'],
      )!,
    );
  }

  @override
  $NodesTable createAlias(String alias) {
    return $NodesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<NodeRole, String, String> $converterrole =
      const EnumNameConverter<NodeRole>(NodeRole.values);
  static JsonTypeConverter2<NodeStatus, String, String> $converterstatus =
      const EnumNameConverter<NodeStatus>(NodeStatus.values);
}

class NodeRow extends DataClass implements Insertable<NodeRow> {
  final String id;
  final String nodeId;
  final String name;
  final NodeRole role;
  final NodeStatus status;
  final int? batteryPercent;
  final int? rssi;
  final DateTime? lastSeenAt;
  final bool isSimulated;
  const NodeRow({
    required this.id,
    required this.nodeId,
    required this.name,
    required this.role,
    required this.status,
    this.batteryPercent,
    this.rssi,
    this.lastSeenAt,
    required this.isSimulated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['node_id'] = Variable<String>(nodeId);
    map['name'] = Variable<String>(name);
    {
      map['role'] = Variable<String>($NodesTable.$converterrole.toSql(role));
    }
    {
      map['status'] = Variable<String>(
        $NodesTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || batteryPercent != null) {
      map['battery_percent'] = Variable<int>(batteryPercent);
    }
    if (!nullToAbsent || rssi != null) {
      map['rssi'] = Variable<int>(rssi);
    }
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    }
    map['is_simulated'] = Variable<bool>(isSimulated);
    return map;
  }

  NodesCompanion toCompanion(bool nullToAbsent) {
    return NodesCompanion(
      id: Value(id),
      nodeId: Value(nodeId),
      name: Value(name),
      role: Value(role),
      status: Value(status),
      batteryPercent: batteryPercent == null && nullToAbsent
          ? const Value.absent()
          : Value(batteryPercent),
      rssi: rssi == null && nullToAbsent ? const Value.absent() : Value(rssi),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
      isSimulated: Value(isSimulated),
    );
  }

  factory NodeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NodeRow(
      id: serializer.fromJson<String>(json['id']),
      nodeId: serializer.fromJson<String>(json['nodeId']),
      name: serializer.fromJson<String>(json['name']),
      role: $NodesTable.$converterrole.fromJson(
        serializer.fromJson<String>(json['role']),
      ),
      status: $NodesTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      batteryPercent: serializer.fromJson<int?>(json['batteryPercent']),
      rssi: serializer.fromJson<int?>(json['rssi']),
      lastSeenAt: serializer.fromJson<DateTime?>(json['lastSeenAt']),
      isSimulated: serializer.fromJson<bool>(json['isSimulated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nodeId': serializer.toJson<String>(nodeId),
      'name': serializer.toJson<String>(name),
      'role': serializer.toJson<String>(
        $NodesTable.$converterrole.toJson(role),
      ),
      'status': serializer.toJson<String>(
        $NodesTable.$converterstatus.toJson(status),
      ),
      'batteryPercent': serializer.toJson<int?>(batteryPercent),
      'rssi': serializer.toJson<int?>(rssi),
      'lastSeenAt': serializer.toJson<DateTime?>(lastSeenAt),
      'isSimulated': serializer.toJson<bool>(isSimulated),
    };
  }

  NodeRow copyWith({
    String? id,
    String? nodeId,
    String? name,
    NodeRole? role,
    NodeStatus? status,
    Value<int?> batteryPercent = const Value.absent(),
    Value<int?> rssi = const Value.absent(),
    Value<DateTime?> lastSeenAt = const Value.absent(),
    bool? isSimulated,
  }) => NodeRow(
    id: id ?? this.id,
    nodeId: nodeId ?? this.nodeId,
    name: name ?? this.name,
    role: role ?? this.role,
    status: status ?? this.status,
    batteryPercent: batteryPercent.present
        ? batteryPercent.value
        : this.batteryPercent,
    rssi: rssi.present ? rssi.value : this.rssi,
    lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
    isSimulated: isSimulated ?? this.isSimulated,
  );
  NodeRow copyWithCompanion(NodesCompanion data) {
    return NodeRow(
      id: data.id.present ? data.id.value : this.id,
      nodeId: data.nodeId.present ? data.nodeId.value : this.nodeId,
      name: data.name.present ? data.name.value : this.name,
      role: data.role.present ? data.role.value : this.role,
      status: data.status.present ? data.status.value : this.status,
      batteryPercent: data.batteryPercent.present
          ? data.batteryPercent.value
          : this.batteryPercent,
      rssi: data.rssi.present ? data.rssi.value : this.rssi,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      isSimulated: data.isSimulated.present
          ? data.isSimulated.value
          : this.isSimulated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NodeRow(')
          ..write('id: $id, ')
          ..write('nodeId: $nodeId, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('status: $status, ')
          ..write('batteryPercent: $batteryPercent, ')
          ..write('rssi: $rssi, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('isSimulated: $isSimulated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nodeId,
    name,
    role,
    status,
    batteryPercent,
    rssi,
    lastSeenAt,
    isSimulated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NodeRow &&
          other.id == this.id &&
          other.nodeId == this.nodeId &&
          other.name == this.name &&
          other.role == this.role &&
          other.status == this.status &&
          other.batteryPercent == this.batteryPercent &&
          other.rssi == this.rssi &&
          other.lastSeenAt == this.lastSeenAt &&
          other.isSimulated == this.isSimulated);
}

class NodesCompanion extends UpdateCompanion<NodeRow> {
  final Value<String> id;
  final Value<String> nodeId;
  final Value<String> name;
  final Value<NodeRole> role;
  final Value<NodeStatus> status;
  final Value<int?> batteryPercent;
  final Value<int?> rssi;
  final Value<DateTime?> lastSeenAt;
  final Value<bool> isSimulated;
  final Value<int> rowid;
  const NodesCompanion({
    this.id = const Value.absent(),
    this.nodeId = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.status = const Value.absent(),
    this.batteryPercent = const Value.absent(),
    this.rssi = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.isSimulated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NodesCompanion.insert({
    required String id,
    required String nodeId,
    required String name,
    required NodeRole role,
    required NodeStatus status,
    this.batteryPercent = const Value.absent(),
    this.rssi = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.isSimulated = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nodeId = Value(nodeId),
       name = Value(name),
       role = Value(role),
       status = Value(status);
  static Insertable<NodeRow> custom({
    Expression<String>? id,
    Expression<String>? nodeId,
    Expression<String>? name,
    Expression<String>? role,
    Expression<String>? status,
    Expression<int>? batteryPercent,
    Expression<int>? rssi,
    Expression<DateTime>? lastSeenAt,
    Expression<bool>? isSimulated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nodeId != null) 'node_id': nodeId,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (status != null) 'status': status,
      if (batteryPercent != null) 'battery_percent': batteryPercent,
      if (rssi != null) 'rssi': rssi,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (isSimulated != null) 'is_simulated': isSimulated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NodesCompanion copyWith({
    Value<String>? id,
    Value<String>? nodeId,
    Value<String>? name,
    Value<NodeRole>? role,
    Value<NodeStatus>? status,
    Value<int?>? batteryPercent,
    Value<int?>? rssi,
    Value<DateTime?>? lastSeenAt,
    Value<bool>? isSimulated,
    Value<int>? rowid,
  }) {
    return NodesCompanion(
      id: id ?? this.id,
      nodeId: nodeId ?? this.nodeId,
      name: name ?? this.name,
      role: role ?? this.role,
      status: status ?? this.status,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      rssi: rssi ?? this.rssi,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      isSimulated: isSimulated ?? this.isSimulated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nodeId.present) {
      map['node_id'] = Variable<String>(nodeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(
        $NodesTable.$converterrole.toSql(role.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $NodesTable.$converterstatus.toSql(status.value),
      );
    }
    if (batteryPercent.present) {
      map['battery_percent'] = Variable<int>(batteryPercent.value);
    }
    if (rssi.present) {
      map['rssi'] = Variable<int>(rssi.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (isSimulated.present) {
      map['is_simulated'] = Variable<bool>(isSimulated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NodesCompanion(')
          ..write('id: $id, ')
          ..write('nodeId: $nodeId, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('status: $status, ')
          ..write('batteryPercent: $batteryPercent, ')
          ..write('rssi: $rssi, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('isSimulated: $isSimulated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, ConversationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _peerNodeIdMeta = const VerificationMeta(
    'peerNodeId',
  );
  @override
  late final GeneratedColumn<String> peerNodeId = GeneratedColumn<String>(
    'peer_node_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES nodes (node_id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unreadCountMeta = const VerificationMeta(
    'unreadCount',
  );
  @override
  late final GeneratedColumn<int> unreadCount = GeneratedColumn<int>(
    'unread_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    peerNodeId,
    title,
    unreadCount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConversationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('peer_node_id')) {
      context.handle(
        _peerNodeIdMeta,
        peerNodeId.isAcceptableOrUnknown(
          data['peer_node_id']!,
          _peerNodeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_peerNodeIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('unread_count')) {
      context.handle(
        _unreadCountMeta,
        unreadCount.isAcceptableOrUnknown(
          data['unread_count']!,
          _unreadCountMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConversationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConversationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      peerNodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}peer_node_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      unreadCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unread_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class ConversationRow extends DataClass implements Insertable<ConversationRow> {
  final String id;
  final String peerNodeId;
  final String title;
  final int unreadCount;
  final DateTime createdAt;
  const ConversationRow({
    required this.id,
    required this.peerNodeId,
    required this.title,
    required this.unreadCount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['peer_node_id'] = Variable<String>(peerNodeId);
    map['title'] = Variable<String>(title);
    map['unread_count'] = Variable<int>(unreadCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      id: Value(id),
      peerNodeId: Value(peerNodeId),
      title: Value(title),
      unreadCount: Value(unreadCount),
      createdAt: Value(createdAt),
    );
  }

  factory ConversationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConversationRow(
      id: serializer.fromJson<String>(json['id']),
      peerNodeId: serializer.fromJson<String>(json['peerNodeId']),
      title: serializer.fromJson<String>(json['title']),
      unreadCount: serializer.fromJson<int>(json['unreadCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'peerNodeId': serializer.toJson<String>(peerNodeId),
      'title': serializer.toJson<String>(title),
      'unreadCount': serializer.toJson<int>(unreadCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ConversationRow copyWith({
    String? id,
    String? peerNodeId,
    String? title,
    int? unreadCount,
    DateTime? createdAt,
  }) => ConversationRow(
    id: id ?? this.id,
    peerNodeId: peerNodeId ?? this.peerNodeId,
    title: title ?? this.title,
    unreadCount: unreadCount ?? this.unreadCount,
    createdAt: createdAt ?? this.createdAt,
  );
  ConversationRow copyWithCompanion(ConversationsCompanion data) {
    return ConversationRow(
      id: data.id.present ? data.id.value : this.id,
      peerNodeId: data.peerNodeId.present
          ? data.peerNodeId.value
          : this.peerNodeId,
      title: data.title.present ? data.title.value : this.title,
      unreadCount: data.unreadCount.present
          ? data.unreadCount.value
          : this.unreadCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConversationRow(')
          ..write('id: $id, ')
          ..write('peerNodeId: $peerNodeId, ')
          ..write('title: $title, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, peerNodeId, title, unreadCount, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConversationRow &&
          other.id == this.id &&
          other.peerNodeId == this.peerNodeId &&
          other.title == this.title &&
          other.unreadCount == this.unreadCount &&
          other.createdAt == this.createdAt);
}

class ConversationsCompanion extends UpdateCompanion<ConversationRow> {
  final Value<String> id;
  final Value<String> peerNodeId;
  final Value<String> title;
  final Value<int> unreadCount;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ConversationsCompanion({
    this.id = const Value.absent(),
    this.peerNodeId = const Value.absent(),
    this.title = const Value.absent(),
    this.unreadCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationsCompanion.insert({
    required String id,
    required String peerNodeId,
    required String title,
    this.unreadCount = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       peerNodeId = Value(peerNodeId),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<ConversationRow> custom({
    Expression<String>? id,
    Expression<String>? peerNodeId,
    Expression<String>? title,
    Expression<int>? unreadCount,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (peerNodeId != null) 'peer_node_id': peerNodeId,
      if (title != null) 'title': title,
      if (unreadCount != null) 'unread_count': unreadCount,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationsCompanion copyWith({
    Value<String>? id,
    Value<String>? peerNodeId,
    Value<String>? title,
    Value<int>? unreadCount,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ConversationsCompanion(
      id: id ?? this.id,
      peerNodeId: peerNodeId ?? this.peerNodeId,
      title: title ?? this.title,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (peerNodeId.present) {
      map['peer_node_id'] = Variable<String>(peerNodeId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (unreadCount.present) {
      map['unread_count'] = Variable<int>(unreadCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('id: $id, ')
          ..write('peerNodeId: $peerNodeId, ')
          ..write('title: $title, ')
          ..write('unreadCount: $unreadCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages
    with TableInfo<$MessagesTable, MessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES conversations (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _senderNodeIdMeta = const VerificationMeta(
    'senderNodeId',
  );
  @override
  late final GeneratedColumn<String> senderNodeId = GeneratedColumn<String>(
    'sender_node_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipientNodeIdMeta = const VerificationMeta(
    'recipientNodeId',
  );
  @override
  late final GeneratedColumn<String> recipientNodeId = GeneratedColumn<String>(
    'recipient_node_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MessageDirection, String>
  direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<MessageDirection>($MessagesTable.$converterdirection);
  @override
  late final GeneratedColumnWithTypeConverter<MessageStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MessageStatus>($MessagesTable.$converterstatus);
  static const VerificationMeta _failureReasonMeta = const VerificationMeta(
    'failureReason',
  );
  @override
  late final GeneratedColumn<String> failureReason = GeneratedColumn<String>(
    'failure_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationAccuracyMeta = const VerificationMeta(
    'locationAccuracy',
  );
  @override
  late final GeneratedColumn<double> locationAccuracy = GeneratedColumn<double>(
    'location_accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conversationId,
    senderNodeId,
    recipientNodeId,
    body,
    direction,
    status,
    failureReason,
    latitude,
    longitude,
    locationAccuracy,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('sender_node_id')) {
      context.handle(
        _senderNodeIdMeta,
        senderNodeId.isAcceptableOrUnknown(
          data['sender_node_id']!,
          _senderNodeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_senderNodeIdMeta);
    }
    if (data.containsKey('recipient_node_id')) {
      context.handle(
        _recipientNodeIdMeta,
        recipientNodeId.isAcceptableOrUnknown(
          data['recipient_node_id']!,
          _recipientNodeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recipientNodeIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('failure_reason')) {
      context.handle(
        _failureReasonMeta,
        failureReason.isAcceptableOrUnknown(
          data['failure_reason']!,
          _failureReasonMeta,
        ),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('location_accuracy')) {
      context.handle(
        _locationAccuracyMeta,
        locationAccuracy.isAcceptableOrUnknown(
          data['location_accuracy']!,
          _locationAccuracyMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      senderNodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_node_id'],
      )!,
      recipientNodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipient_node_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      direction: $MessagesTable.$converterdirection.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}direction'],
        )!,
      ),
      status: $MessagesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      failureReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failure_reason'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      locationAccuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}location_accuracy'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MessageDirection, String, String>
  $converterdirection = const EnumNameConverter<MessageDirection>(
    MessageDirection.values,
  );
  static JsonTypeConverter2<MessageStatus, String, String> $converterstatus =
      const EnumNameConverter<MessageStatus>(MessageStatus.values);
}

class MessageRow extends DataClass implements Insertable<MessageRow> {
  /// Also the protocol message_id; the primary key makes duplicates impossible.
  final String id;
  final String conversationId;
  final String senderNodeId;
  final String recipientNodeId;
  final String body;
  final MessageDirection direction;
  final MessageStatus status;
  final String? failureReason;
  final double? latitude;
  final double? longitude;
  final double? locationAccuracy;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MessageRow({
    required this.id,
    required this.conversationId,
    required this.senderNodeId,
    required this.recipientNodeId,
    required this.body,
    required this.direction,
    required this.status,
    this.failureReason,
    this.latitude,
    this.longitude,
    this.locationAccuracy,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['sender_node_id'] = Variable<String>(senderNodeId);
    map['recipient_node_id'] = Variable<String>(recipientNodeId);
    map['body'] = Variable<String>(body);
    {
      map['direction'] = Variable<String>(
        $MessagesTable.$converterdirection.toSql(direction),
      );
    }
    {
      map['status'] = Variable<String>(
        $MessagesTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || failureReason != null) {
      map['failure_reason'] = Variable<String>(failureReason);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || locationAccuracy != null) {
      map['location_accuracy'] = Variable<double>(locationAccuracy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      senderNodeId: Value(senderNodeId),
      recipientNodeId: Value(recipientNodeId),
      body: Value(body),
      direction: Value(direction),
      status: Value(status),
      failureReason: failureReason == null && nullToAbsent
          ? const Value.absent()
          : Value(failureReason),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      locationAccuracy: locationAccuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(locationAccuracy),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MessageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageRow(
      id: serializer.fromJson<String>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      senderNodeId: serializer.fromJson<String>(json['senderNodeId']),
      recipientNodeId: serializer.fromJson<String>(json['recipientNodeId']),
      body: serializer.fromJson<String>(json['body']),
      direction: $MessagesTable.$converterdirection.fromJson(
        serializer.fromJson<String>(json['direction']),
      ),
      status: $MessagesTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      failureReason: serializer.fromJson<String?>(json['failureReason']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      locationAccuracy: serializer.fromJson<double?>(json['locationAccuracy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'senderNodeId': serializer.toJson<String>(senderNodeId),
      'recipientNodeId': serializer.toJson<String>(recipientNodeId),
      'body': serializer.toJson<String>(body),
      'direction': serializer.toJson<String>(
        $MessagesTable.$converterdirection.toJson(direction),
      ),
      'status': serializer.toJson<String>(
        $MessagesTable.$converterstatus.toJson(status),
      ),
      'failureReason': serializer.toJson<String?>(failureReason),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'locationAccuracy': serializer.toJson<double?>(locationAccuracy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MessageRow copyWith({
    String? id,
    String? conversationId,
    String? senderNodeId,
    String? recipientNodeId,
    String? body,
    MessageDirection? direction,
    MessageStatus? status,
    Value<String?> failureReason = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<double?> locationAccuracy = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MessageRow(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    senderNodeId: senderNodeId ?? this.senderNodeId,
    recipientNodeId: recipientNodeId ?? this.recipientNodeId,
    body: body ?? this.body,
    direction: direction ?? this.direction,
    status: status ?? this.status,
    failureReason: failureReason.present
        ? failureReason.value
        : this.failureReason,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    locationAccuracy: locationAccuracy.present
        ? locationAccuracy.value
        : this.locationAccuracy,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MessageRow copyWithCompanion(MessagesCompanion data) {
    return MessageRow(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      senderNodeId: data.senderNodeId.present
          ? data.senderNodeId.value
          : this.senderNodeId,
      recipientNodeId: data.recipientNodeId.present
          ? data.recipientNodeId.value
          : this.recipientNodeId,
      body: data.body.present ? data.body.value : this.body,
      direction: data.direction.present ? data.direction.value : this.direction,
      status: data.status.present ? data.status.value : this.status,
      failureReason: data.failureReason.present
          ? data.failureReason.value
          : this.failureReason,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      locationAccuracy: data.locationAccuracy.present
          ? data.locationAccuracy.value
          : this.locationAccuracy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageRow(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderNodeId: $senderNodeId, ')
          ..write('recipientNodeId: $recipientNodeId, ')
          ..write('body: $body, ')
          ..write('direction: $direction, ')
          ..write('status: $status, ')
          ..write('failureReason: $failureReason, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('locationAccuracy: $locationAccuracy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    conversationId,
    senderNodeId,
    recipientNodeId,
    body,
    direction,
    status,
    failureReason,
    latitude,
    longitude,
    locationAccuracy,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageRow &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.senderNodeId == this.senderNodeId &&
          other.recipientNodeId == this.recipientNodeId &&
          other.body == this.body &&
          other.direction == this.direction &&
          other.status == this.status &&
          other.failureReason == this.failureReason &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.locationAccuracy == this.locationAccuracy &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MessagesCompanion extends UpdateCompanion<MessageRow> {
  final Value<String> id;
  final Value<String> conversationId;
  final Value<String> senderNodeId;
  final Value<String> recipientNodeId;
  final Value<String> body;
  final Value<MessageDirection> direction;
  final Value<MessageStatus> status;
  final Value<String?> failureReason;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<double?> locationAccuracy;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.senderNodeId = const Value.absent(),
    this.recipientNodeId = const Value.absent(),
    this.body = const Value.absent(),
    this.direction = const Value.absent(),
    this.status = const Value.absent(),
    this.failureReason = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.locationAccuracy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String conversationId,
    required String senderNodeId,
    required String recipientNodeId,
    required String body,
    required MessageDirection direction,
    required MessageStatus status,
    this.failureReason = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.locationAccuracy = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       conversationId = Value(conversationId),
       senderNodeId = Value(senderNodeId),
       recipientNodeId = Value(recipientNodeId),
       body = Value(body),
       direction = Value(direction),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MessageRow> custom({
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? senderNodeId,
    Expression<String>? recipientNodeId,
    Expression<String>? body,
    Expression<String>? direction,
    Expression<String>? status,
    Expression<String>? failureReason,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? locationAccuracy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (senderNodeId != null) 'sender_node_id': senderNodeId,
      if (recipientNodeId != null) 'recipient_node_id': recipientNodeId,
      if (body != null) 'body': body,
      if (direction != null) 'direction': direction,
      if (status != null) 'status': status,
      if (failureReason != null) 'failure_reason': failureReason,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationAccuracy != null) 'location_accuracy': locationAccuracy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? conversationId,
    Value<String>? senderNodeId,
    Value<String>? recipientNodeId,
    Value<String>? body,
    Value<MessageDirection>? direction,
    Value<MessageStatus>? status,
    Value<String?>? failureReason,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<double?>? locationAccuracy,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderNodeId: senderNodeId ?? this.senderNodeId,
      recipientNodeId: recipientNodeId ?? this.recipientNodeId,
      body: body ?? this.body,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      failureReason: failureReason ?? this.failureReason,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (senderNodeId.present) {
      map['sender_node_id'] = Variable<String>(senderNodeId.value);
    }
    if (recipientNodeId.present) {
      map['recipient_node_id'] = Variable<String>(recipientNodeId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(
        $MessagesTable.$converterdirection.toSql(direction.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $MessagesTable.$converterstatus.toSql(status.value),
      );
    }
    if (failureReason.present) {
      map['failure_reason'] = Variable<String>(failureReason.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (locationAccuracy.present) {
      map['location_accuracy'] = Variable<double>(locationAccuracy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('senderNodeId: $senderNodeId, ')
          ..write('recipientNodeId: $recipientNodeId, ')
          ..write('body: $body, ')
          ..write('direction: $direction, ')
          ..write('status: $status, ')
          ..write('failureReason: $failureReason, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('locationAccuracy: $locationAccuracy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SosEventsTable extends SosEvents
    with TableInfo<$SosEventsTable, SosEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SosEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceNodeIdMeta = const VerificationMeta(
    'sourceNodeId',
  );
  @override
  late final GeneratedColumn<String> sourceNodeId = GeneratedColumn<String>(
    'source_node_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SosStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SosStatus>($SosEventsTable.$converterstatus);
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
    'accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nodesReachedMeta = const VerificationMeta(
    'nodesReached',
  );
  @override
  late final GeneratedColumn<int> nodesReached = GeneratedColumn<int>(
    'nodes_reached',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isSimulatedMeta = const VerificationMeta(
    'isSimulated',
  );
  @override
  late final GeneratedColumn<bool> isSimulated = GeneratedColumn<bool>(
    'is_simulated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_simulated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
    'sent_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _acknowledgedAtMeta = const VerificationMeta(
    'acknowledgedAt',
  );
  @override
  late final GeneratedColumn<DateTime> acknowledgedAt =
      GeneratedColumn<DateTime>(
        'acknowledged_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _propagatedAtMeta = const VerificationMeta(
    'propagatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> propagatedAt = GeneratedColumn<DateTime>(
    'propagated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceNodeId,
    status,
    latitude,
    longitude,
    accuracy,
    note,
    nodesReached,
    isSimulated,
    createdAt,
    updatedAt,
    sentAt,
    acknowledgedAt,
    propagatedAt,
    closedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sos_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<SosEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_node_id')) {
      context.handle(
        _sourceNodeIdMeta,
        sourceNodeId.isAcceptableOrUnknown(
          data['source_node_id']!,
          _sourceNodeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceNodeIdMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('nodes_reached')) {
      context.handle(
        _nodesReachedMeta,
        nodesReached.isAcceptableOrUnknown(
          data['nodes_reached']!,
          _nodesReachedMeta,
        ),
      );
    }
    if (data.containsKey('is_simulated')) {
      context.handle(
        _isSimulatedMeta,
        isSimulated.isAcceptableOrUnknown(
          data['is_simulated']!,
          _isSimulatedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sent_at')) {
      context.handle(
        _sentAtMeta,
        sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta),
      );
    }
    if (data.containsKey('acknowledged_at')) {
      context.handle(
        _acknowledgedAtMeta,
        acknowledgedAt.isAcceptableOrUnknown(
          data['acknowledged_at']!,
          _acknowledgedAtMeta,
        ),
      );
    }
    if (data.containsKey('propagated_at')) {
      context.handle(
        _propagatedAtMeta,
        propagatedAt.isAcceptableOrUnknown(
          data['propagated_at']!,
          _propagatedAtMeta,
        ),
      );
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SosEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SosEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceNodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_node_id'],
      )!,
      status: $SosEventsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      nodesReached: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nodes_reached'],
      )!,
      isSimulated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_simulated'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      sentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sent_at'],
      ),
      acknowledgedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}acknowledged_at'],
      ),
      propagatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}propagated_at'],
      ),
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      ),
    );
  }

  @override
  $SosEventsTable createAlias(String alias) {
    return $SosEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SosStatus, String, String> $converterstatus =
      const EnumNameConverter<SosStatus>(SosStatus.values);
}

class SosEventRow extends DataClass implements Insertable<SosEventRow> {
  final String id;
  final String sourceNodeId;
  final SosStatus status;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final String? note;
  final int nodesReached;
  final bool isSimulated;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? sentAt;
  final DateTime? acknowledgedAt;
  final DateTime? propagatedAt;
  final DateTime? closedAt;
  const SosEventRow({
    required this.id,
    required this.sourceNodeId,
    required this.status,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.note,
    required this.nodesReached,
    required this.isSimulated,
    required this.createdAt,
    required this.updatedAt,
    this.sentAt,
    this.acknowledgedAt,
    this.propagatedAt,
    this.closedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_node_id'] = Variable<String>(sourceNodeId);
    {
      map['status'] = Variable<String>(
        $SosEventsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || accuracy != null) {
      map['accuracy'] = Variable<double>(accuracy);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['nodes_reached'] = Variable<int>(nodesReached);
    map['is_simulated'] = Variable<bool>(isSimulated);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || sentAt != null) {
      map['sent_at'] = Variable<DateTime>(sentAt);
    }
    if (!nullToAbsent || acknowledgedAt != null) {
      map['acknowledged_at'] = Variable<DateTime>(acknowledgedAt);
    }
    if (!nullToAbsent || propagatedAt != null) {
      map['propagated_at'] = Variable<DateTime>(propagatedAt);
    }
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    return map;
  }

  SosEventsCompanion toCompanion(bool nullToAbsent) {
    return SosEventsCompanion(
      id: Value(id),
      sourceNodeId: Value(sourceNodeId),
      status: Value(status),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      accuracy: accuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracy),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      nodesReached: Value(nodesReached),
      isSimulated: Value(isSimulated),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      sentAt: sentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(sentAt),
      acknowledgedAt: acknowledgedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(acknowledgedAt),
      propagatedAt: propagatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(propagatedAt),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
    );
  }

  factory SosEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SosEventRow(
      id: serializer.fromJson<String>(json['id']),
      sourceNodeId: serializer.fromJson<String>(json['sourceNodeId']),
      status: $SosEventsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      accuracy: serializer.fromJson<double?>(json['accuracy']),
      note: serializer.fromJson<String?>(json['note']),
      nodesReached: serializer.fromJson<int>(json['nodesReached']),
      isSimulated: serializer.fromJson<bool>(json['isSimulated']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      sentAt: serializer.fromJson<DateTime?>(json['sentAt']),
      acknowledgedAt: serializer.fromJson<DateTime?>(json['acknowledgedAt']),
      propagatedAt: serializer.fromJson<DateTime?>(json['propagatedAt']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceNodeId': serializer.toJson<String>(sourceNodeId),
      'status': serializer.toJson<String>(
        $SosEventsTable.$converterstatus.toJson(status),
      ),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'accuracy': serializer.toJson<double?>(accuracy),
      'note': serializer.toJson<String?>(note),
      'nodesReached': serializer.toJson<int>(nodesReached),
      'isSimulated': serializer.toJson<bool>(isSimulated),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'sentAt': serializer.toJson<DateTime?>(sentAt),
      'acknowledgedAt': serializer.toJson<DateTime?>(acknowledgedAt),
      'propagatedAt': serializer.toJson<DateTime?>(propagatedAt),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
    };
  }

  SosEventRow copyWith({
    String? id,
    String? sourceNodeId,
    SosStatus? status,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<double?> accuracy = const Value.absent(),
    Value<String?> note = const Value.absent(),
    int? nodesReached,
    bool? isSimulated,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> sentAt = const Value.absent(),
    Value<DateTime?> acknowledgedAt = const Value.absent(),
    Value<DateTime?> propagatedAt = const Value.absent(),
    Value<DateTime?> closedAt = const Value.absent(),
  }) => SosEventRow(
    id: id ?? this.id,
    sourceNodeId: sourceNodeId ?? this.sourceNodeId,
    status: status ?? this.status,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    accuracy: accuracy.present ? accuracy.value : this.accuracy,
    note: note.present ? note.value : this.note,
    nodesReached: nodesReached ?? this.nodesReached,
    isSimulated: isSimulated ?? this.isSimulated,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    sentAt: sentAt.present ? sentAt.value : this.sentAt,
    acknowledgedAt: acknowledgedAt.present
        ? acknowledgedAt.value
        : this.acknowledgedAt,
    propagatedAt: propagatedAt.present ? propagatedAt.value : this.propagatedAt,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
  );
  SosEventRow copyWithCompanion(SosEventsCompanion data) {
    return SosEventRow(
      id: data.id.present ? data.id.value : this.id,
      sourceNodeId: data.sourceNodeId.present
          ? data.sourceNodeId.value
          : this.sourceNodeId,
      status: data.status.present ? data.status.value : this.status,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      note: data.note.present ? data.note.value : this.note,
      nodesReached: data.nodesReached.present
          ? data.nodesReached.value
          : this.nodesReached,
      isSimulated: data.isSimulated.present
          ? data.isSimulated.value
          : this.isSimulated,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
      acknowledgedAt: data.acknowledgedAt.present
          ? data.acknowledgedAt.value
          : this.acknowledgedAt,
      propagatedAt: data.propagatedAt.present
          ? data.propagatedAt.value
          : this.propagatedAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SosEventRow(')
          ..write('id: $id, ')
          ..write('sourceNodeId: $sourceNodeId, ')
          ..write('status: $status, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('accuracy: $accuracy, ')
          ..write('note: $note, ')
          ..write('nodesReached: $nodesReached, ')
          ..write('isSimulated: $isSimulated, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sentAt: $sentAt, ')
          ..write('acknowledgedAt: $acknowledgedAt, ')
          ..write('propagatedAt: $propagatedAt, ')
          ..write('closedAt: $closedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sourceNodeId,
    status,
    latitude,
    longitude,
    accuracy,
    note,
    nodesReached,
    isSimulated,
    createdAt,
    updatedAt,
    sentAt,
    acknowledgedAt,
    propagatedAt,
    closedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SosEventRow &&
          other.id == this.id &&
          other.sourceNodeId == this.sourceNodeId &&
          other.status == this.status &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.accuracy == this.accuracy &&
          other.note == this.note &&
          other.nodesReached == this.nodesReached &&
          other.isSimulated == this.isSimulated &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.sentAt == this.sentAt &&
          other.acknowledgedAt == this.acknowledgedAt &&
          other.propagatedAt == this.propagatedAt &&
          other.closedAt == this.closedAt);
}

class SosEventsCompanion extends UpdateCompanion<SosEventRow> {
  final Value<String> id;
  final Value<String> sourceNodeId;
  final Value<SosStatus> status;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<double?> accuracy;
  final Value<String?> note;
  final Value<int> nodesReached;
  final Value<bool> isSimulated;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> sentAt;
  final Value<DateTime?> acknowledgedAt;
  final Value<DateTime?> propagatedAt;
  final Value<DateTime?> closedAt;
  final Value<int> rowid;
  const SosEventsCompanion({
    this.id = const Value.absent(),
    this.sourceNodeId = const Value.absent(),
    this.status = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.note = const Value.absent(),
    this.nodesReached = const Value.absent(),
    this.isSimulated = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.acknowledgedAt = const Value.absent(),
    this.propagatedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SosEventsCompanion.insert({
    required String id,
    required String sourceNodeId,
    required SosStatus status,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.note = const Value.absent(),
    this.nodesReached = const Value.absent(),
    this.isSimulated = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.sentAt = const Value.absent(),
    this.acknowledgedAt = const Value.absent(),
    this.propagatedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceNodeId = Value(sourceNodeId),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SosEventRow> custom({
    Expression<String>? id,
    Expression<String>? sourceNodeId,
    Expression<String>? status,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? accuracy,
    Expression<String>? note,
    Expression<int>? nodesReached,
    Expression<bool>? isSimulated,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? sentAt,
    Expression<DateTime>? acknowledgedAt,
    Expression<DateTime>? propagatedAt,
    Expression<DateTime>? closedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceNodeId != null) 'source_node_id': sourceNodeId,
      if (status != null) 'status': status,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (note != null) 'note': note,
      if (nodesReached != null) 'nodes_reached': nodesReached,
      if (isSimulated != null) 'is_simulated': isSimulated,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (sentAt != null) 'sent_at': sentAt,
      if (acknowledgedAt != null) 'acknowledged_at': acknowledgedAt,
      if (propagatedAt != null) 'propagated_at': propagatedAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SosEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceNodeId,
    Value<SosStatus>? status,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<double?>? accuracy,
    Value<String?>? note,
    Value<int>? nodesReached,
    Value<bool>? isSimulated,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? sentAt,
    Value<DateTime?>? acknowledgedAt,
    Value<DateTime?>? propagatedAt,
    Value<DateTime?>? closedAt,
    Value<int>? rowid,
  }) {
    return SosEventsCompanion(
      id: id ?? this.id,
      sourceNodeId: sourceNodeId ?? this.sourceNodeId,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      note: note ?? this.note,
      nodesReached: nodesReached ?? this.nodesReached,
      isSimulated: isSimulated ?? this.isSimulated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sentAt: sentAt ?? this.sentAt,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      propagatedAt: propagatedAt ?? this.propagatedAt,
      closedAt: closedAt ?? this.closedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceNodeId.present) {
      map['source_node_id'] = Variable<String>(sourceNodeId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $SosEventsTable.$converterstatus.toSql(status.value),
      );
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (nodesReached.present) {
      map['nodes_reached'] = Variable<int>(nodesReached.value);
    }
    if (isSimulated.present) {
      map['is_simulated'] = Variable<bool>(isSimulated.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    if (acknowledgedAt.present) {
      map['acknowledged_at'] = Variable<DateTime>(acknowledgedAt.value);
    }
    if (propagatedAt.present) {
      map['propagated_at'] = Variable<DateTime>(propagatedAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SosEventsCompanion(')
          ..write('id: $id, ')
          ..write('sourceNodeId: $sourceNodeId, ')
          ..write('status: $status, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('accuracy: $accuracy, ')
          ..write('note: $note, ')
          ..write('nodesReached: $nodesReached, ')
          ..write('isSimulated: $isSimulated, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sentAt: $sentAt, ')
          ..write('acknowledgedAt: $acknowledgedAt, ')
          ..write('propagatedAt: $propagatedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocationRecordsTable extends LocationRecords
    with TableInfo<$LocationRecordsTable, LocationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
    'accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _altitudeMeta = const VerificationMeta(
    'altitude',
  );
  @override
  late final GeneratedColumn<double> altitude = GeneratedColumn<double>(
    'altitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    latitude,
    longitude,
    accuracy,
    altitude,
    recordedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'location_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    }
    if (data.containsKey('altitude')) {
      context.handle(
        _altitudeMeta,
        altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy'],
      ),
      altitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude'],
      ),
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
    );
  }

  @override
  $LocationRecordsTable createAlias(String alias) {
    return $LocationRecordsTable(attachedDatabase, alias);
  }
}

class LocationRow extends DataClass implements Insertable<LocationRow> {
  final String id;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final DateTime recordedAt;
  const LocationRow({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    required this.recordedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || accuracy != null) {
      map['accuracy'] = Variable<double>(accuracy);
    }
    if (!nullToAbsent || altitude != null) {
      map['altitude'] = Variable<double>(altitude);
    }
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    return map;
  }

  LocationRecordsCompanion toCompanion(bool nullToAbsent) {
    return LocationRecordsCompanion(
      id: Value(id),
      latitude: Value(latitude),
      longitude: Value(longitude),
      accuracy: accuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracy),
      altitude: altitude == null && nullToAbsent
          ? const Value.absent()
          : Value(altitude),
      recordedAt: Value(recordedAt),
    );
  }

  factory LocationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocationRow(
      id: serializer.fromJson<String>(json['id']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      accuracy: serializer.fromJson<double?>(json['accuracy']),
      altitude: serializer.fromJson<double?>(json['altitude']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'accuracy': serializer.toJson<double?>(accuracy),
      'altitude': serializer.toJson<double?>(altitude),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
    };
  }

  LocationRow copyWith({
    String? id,
    double? latitude,
    double? longitude,
    Value<double?> accuracy = const Value.absent(),
    Value<double?> altitude = const Value.absent(),
    DateTime? recordedAt,
  }) => LocationRow(
    id: id ?? this.id,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    accuracy: accuracy.present ? accuracy.value : this.accuracy,
    altitude: altitude.present ? altitude.value : this.altitude,
    recordedAt: recordedAt ?? this.recordedAt,
  );
  LocationRow copyWithCompanion(LocationRecordsCompanion data) {
    return LocationRow(
      id: data.id.present ? data.id.value : this.id,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationRow(')
          ..write('id: $id, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('accuracy: $accuracy, ')
          ..write('altitude: $altitude, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, latitude, longitude, accuracy, altitude, recordedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationRow &&
          other.id == this.id &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.accuracy == this.accuracy &&
          other.altitude == this.altitude &&
          other.recordedAt == this.recordedAt);
}

class LocationRecordsCompanion extends UpdateCompanion<LocationRow> {
  final Value<String> id;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double?> accuracy;
  final Value<double?> altitude;
  final Value<DateTime> recordedAt;
  final Value<int> rowid;
  const LocationRecordsCompanion({
    this.id = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.altitude = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocationRecordsCompanion.insert({
    required String id,
    required double latitude,
    required double longitude,
    this.accuracy = const Value.absent(),
    this.altitude = const Value.absent(),
    required DateTime recordedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       latitude = Value(latitude),
       longitude = Value(longitude),
       recordedAt = Value(recordedAt);
  static Insertable<LocationRow> custom({
    Expression<String>? id,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? accuracy,
    Expression<double>? altitude,
    Expression<DateTime>? recordedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (altitude != null) 'altitude': altitude,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocationRecordsCompanion copyWith({
    Value<String>? id,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double?>? accuracy,
    Value<double?>? altitude,
    Value<DateTime>? recordedAt,
    Value<int>? rowid,
  }) {
    return LocationRecordsCompanion(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      recordedAt: recordedAt ?? this.recordedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<double>(altitude.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationRecordsCompanion(')
          ..write('id: $id, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('accuracy: $accuracy, ')
          ..write('altitude: $altitude, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncEntityType, String>
  entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<SyncEntityType>($SyncQueueTable.$converterentityType);
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncOperation, String> operation =
      GeneratedColumn<String>(
        'operation',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SyncOperation>($SyncQueueTable.$converteroperation);
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SyncStatus>($SyncQueueTable.$converterstatus);
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    operation,
    payload,
    status,
    retryCount,
    lastError,
    createdAt,
    lastAttemptAt,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {entityType, entityId, operation},
  ];
  @override
  SyncQueueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: $SyncQueueTable.$converterentityType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}entity_type'],
        )!,
      ),
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: $SyncQueueTable.$converteroperation.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}operation'],
        )!,
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      status: $SyncQueueTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncEntityType, String, String>
  $converterentityType = const EnumNameConverter<SyncEntityType>(
    SyncEntityType.values,
  );
  static JsonTypeConverter2<SyncOperation, String, String> $converteroperation =
      const EnumNameConverter<SyncOperation>(SyncOperation.values);
  static JsonTypeConverter2<SyncStatus, String, String> $converterstatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
}

class SyncQueueRow extends DataClass implements Insertable<SyncQueueRow> {
  final String id;
  final SyncEntityType entityType;
  final String entityId;
  final SyncOperation operation;
  final String payload;
  final SyncStatus status;
  final int retryCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  final DateTime? syncedAt;
  const SyncQueueRow({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.status,
    required this.retryCount,
    this.lastError,
    required this.createdAt,
    this.lastAttemptAt,
    this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['entity_type'] = Variable<String>(
        $SyncQueueTable.$converterentityType.toSql(entityType),
      );
    }
    map['entity_id'] = Variable<String>(entityId);
    {
      map['operation'] = Variable<String>(
        $SyncQueueTable.$converteroperation.toSql(operation),
      );
    }
    map['payload'] = Variable<String>(payload);
    {
      map['status'] = Variable<String>(
        $SyncQueueTable.$converterstatus.toSql(status),
      );
    }
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payload: Value(payload),
      status: Value(status),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
    );
  }

  factory SyncQueueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueRow(
      id: serializer.fromJson<String>(json['id']),
      entityType: $SyncQueueTable.$converterentityType.fromJson(
        serializer.fromJson<String>(json['entityType']),
      ),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: $SyncQueueTable.$converteroperation.fromJson(
        serializer.fromJson<String>(json['operation']),
      ),
      payload: serializer.fromJson<String>(json['payload']),
      status: $SyncQueueTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(
        $SyncQueueTable.$converterentityType.toJson(entityType),
      ),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(
        $SyncQueueTable.$converteroperation.toJson(operation),
      ),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(
        $SyncQueueTable.$converterstatus.toJson(status),
      ),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  SyncQueueRow copyWith({
    String? id,
    SyncEntityType? entityType,
    String? entityId,
    SyncOperation? operation,
    String? payload,
    SyncStatus? status,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => SyncQueueRow(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  SyncQueueRow copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueRow(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueRow(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    operation,
    payload,
    status,
    retryCount,
    lastError,
    createdAt,
    lastAttemptAt,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueRow &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.syncedAt == this.syncedAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueRow> {
  final Value<String> id;
  final Value<SyncEntityType> entityType;
  final Value<String> entityId;
  final Value<SyncOperation> operation;
  final Value<String> payload;
  final Value<SyncStatus> status;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastAttemptAt;
  final Value<DateTime?> syncedAt;
  final Value<int> rowid;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    required String id,
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperation operation,
    required String payload,
    required SyncStatus status,
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime createdAt,
    this.lastAttemptAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation),
       payload = Value(payload),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueRow> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastAttemptAt,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueCompanion copyWith({
    Value<String>? id,
    Value<SyncEntityType>? entityType,
    Value<String>? entityId,
    Value<SyncOperation>? operation,
    Value<String>? payload,
    Value<SyncStatus>? status,
    Value<int>? retryCount,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastAttemptAt,
    Value<DateTime?>? syncedAt,
    Value<int>? rowid,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(
        $SyncQueueTable.$converterentityType.toSql(entityType.value),
      );
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(
        $SyncQueueTable.$converteroperation.toSql(operation.value),
      );
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $SyncQueueTable.$converterstatus.toSql(status.value),
      );
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeviceLogsTable extends DeviceLogs
    with TableInfo<$DeviceLogsTable, DeviceLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nodeIdMeta = const VerificationMeta('nodeId');
  @override
  late final GeneratedColumn<String> nodeId = GeneratedColumn<String>(
    'node_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES nodes (id) ON DELETE SET NULL',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LogLevel, String> level =
      GeneratedColumn<String>(
        'level',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LogLevel>($DeviceLogsTable.$converterlevel);
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, nodeId, level, message, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('node_id')) {
      context.handle(
        _nodeIdMeta,
        nodeId.isAcceptableOrUnknown(data['node_id']!, _nodeIdMeta),
      );
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}node_id'],
      ),
      level: $DeviceLogsTable.$converterlevel.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}level'],
        )!,
      ),
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DeviceLogsTable createAlias(String alias) {
    return $DeviceLogsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LogLevel, String, String> $converterlevel =
      const EnumNameConverter<LogLevel>(LogLevel.values);
}

class DeviceLogRow extends DataClass implements Insertable<DeviceLogRow> {
  final int id;
  final String? nodeId;
  final LogLevel level;
  final String message;
  final DateTime createdAt;
  const DeviceLogRow({
    required this.id,
    this.nodeId,
    required this.level,
    required this.message,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || nodeId != null) {
      map['node_id'] = Variable<String>(nodeId);
    }
    {
      map['level'] = Variable<String>(
        $DeviceLogsTable.$converterlevel.toSql(level),
      );
    }
    map['message'] = Variable<String>(message);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DeviceLogsCompanion toCompanion(bool nullToAbsent) {
    return DeviceLogsCompanion(
      id: Value(id),
      nodeId: nodeId == null && nullToAbsent
          ? const Value.absent()
          : Value(nodeId),
      level: Value(level),
      message: Value(message),
      createdAt: Value(createdAt),
    );
  }

  factory DeviceLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceLogRow(
      id: serializer.fromJson<int>(json['id']),
      nodeId: serializer.fromJson<String?>(json['nodeId']),
      level: $DeviceLogsTable.$converterlevel.fromJson(
        serializer.fromJson<String>(json['level']),
      ),
      message: serializer.fromJson<String>(json['message']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nodeId': serializer.toJson<String?>(nodeId),
      'level': serializer.toJson<String>(
        $DeviceLogsTable.$converterlevel.toJson(level),
      ),
      'message': serializer.toJson<String>(message),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DeviceLogRow copyWith({
    int? id,
    Value<String?> nodeId = const Value.absent(),
    LogLevel? level,
    String? message,
    DateTime? createdAt,
  }) => DeviceLogRow(
    id: id ?? this.id,
    nodeId: nodeId.present ? nodeId.value : this.nodeId,
    level: level ?? this.level,
    message: message ?? this.message,
    createdAt: createdAt ?? this.createdAt,
  );
  DeviceLogRow copyWithCompanion(DeviceLogsCompanion data) {
    return DeviceLogRow(
      id: data.id.present ? data.id.value : this.id,
      nodeId: data.nodeId.present ? data.nodeId.value : this.nodeId,
      level: data.level.present ? data.level.value : this.level,
      message: data.message.present ? data.message.value : this.message,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceLogRow(')
          ..write('id: $id, ')
          ..write('nodeId: $nodeId, ')
          ..write('level: $level, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nodeId, level, message, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceLogRow &&
          other.id == this.id &&
          other.nodeId == this.nodeId &&
          other.level == this.level &&
          other.message == this.message &&
          other.createdAt == this.createdAt);
}

class DeviceLogsCompanion extends UpdateCompanion<DeviceLogRow> {
  final Value<int> id;
  final Value<String?> nodeId;
  final Value<LogLevel> level;
  final Value<String> message;
  final Value<DateTime> createdAt;
  const DeviceLogsCompanion({
    this.id = const Value.absent(),
    this.nodeId = const Value.absent(),
    this.level = const Value.absent(),
    this.message = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DeviceLogsCompanion.insert({
    this.id = const Value.absent(),
    this.nodeId = const Value.absent(),
    required LogLevel level,
    required String message,
    required DateTime createdAt,
  }) : level = Value(level),
       message = Value(message),
       createdAt = Value(createdAt);
  static Insertable<DeviceLogRow> custom({
    Expression<int>? id,
    Expression<String>? nodeId,
    Expression<String>? level,
    Expression<String>? message,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nodeId != null) 'node_id': nodeId,
      if (level != null) 'level': level,
      if (message != null) 'message': message,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DeviceLogsCompanion copyWith({
    Value<int>? id,
    Value<String?>? nodeId,
    Value<LogLevel>? level,
    Value<String>? message,
    Value<DateTime>? createdAt,
  }) {
    return DeviceLogsCompanion(
      id: id ?? this.id,
      nodeId: nodeId ?? this.nodeId,
      level: level ?? this.level,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nodeId.present) {
      map['node_id'] = Variable<String>(nodeId.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(
        $DeviceLogsTable.$converterlevel.toSql(level.value),
      );
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceLogsCompanion(')
          ..write('id: $id, ')
          ..write('nodeId: $nodeId, ')
          ..write('level: $level, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingRow extends DataClass implements Insertable<AppSettingRow> {
  final String key;
  final String value;
  const AppSettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSettingRow copyWith({String? key, String? value}) =>
      AppSettingRow(key: key ?? this.key, value: value ?? this.value);
  AppSettingRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $NodesTable nodes = $NodesTable(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $SosEventsTable sosEvents = $SosEventsTable(this);
  late final $LocationRecordsTable locationRecords = $LocationRecordsTable(
    this,
  );
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $DeviceLogsTable deviceLogs = $DeviceLogsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final Index messagesConversationTime = Index(
    'messages_conversation_time',
    'CREATE INDEX messages_conversation_time ON messages (conversation_id, created_at)',
  );
  late final Index messagesStatus = Index(
    'messages_status',
    'CREATE INDEX messages_status ON messages (status)',
  );
  late final Index sosEventsStatus = Index(
    'sos_events_status',
    'CREATE INDEX sos_events_status ON sos_events (status)',
  );
  late final Index locationRecordsTime = Index(
    'location_records_time',
    'CREATE INDEX location_records_time ON location_records (recorded_at)',
  );
  late final Index syncQueueStatus = Index(
    'sync_queue_status',
    'CREATE INDEX sync_queue_status ON sync_queue (status, created_at)',
  );
  late final Index deviceLogsTime = Index(
    'device_logs_time',
    'CREATE INDEX device_logs_time ON device_logs (created_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    nodes,
    conversations,
    messages,
    sosEvents,
    locationRecords,
    syncQueue,
    deviceLogs,
    appSettings,
    messagesConversationTime,
    messagesStatus,
    sosEventsStatus,
    locationRecordsTime,
    syncQueueStatus,
    deviceLogsTime,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'conversations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('messages', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'nodes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('device_logs', kind: UpdateKind.update)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String displayName,
  required String nodeId,
  Value<bool> isLocal,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> displayName,
  Value<String> nodeId,
  Value<bool> isLocal,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nodeId => $composableBuilder(
    column: $table.nodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLocal => $composableBuilder(
    column: $table.isLocal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nodeId => $composableBuilder(
    column: $table.nodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLocal => $composableBuilder(
    column: $table.isLocal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nodeId =>
      $composableBuilder(column: $table.nodeId, builder: (column) => column);

  GeneratedColumn<bool> get isLocal =>
      $composableBuilder(column: $table.isLocal, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          UserRow,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (UserRow, BaseReferences<_$AppDatabase, $UsersTable, UserRow>),
          UserRow,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> nodeId = const Value.absent(),
                Value<bool> isLocal = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                displayName: displayName,
                nodeId: nodeId,
                isLocal: isLocal,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                required String nodeId,
                Value<bool> isLocal = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                displayName: displayName,
                nodeId: nodeId,
                isLocal: isLocal,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsersTable, UserRow>(table),
                  BaseReferences<_$AppDatabase, $UsersTable, UserRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      UserRow,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (UserRow, BaseReferences<_$AppDatabase, $UsersTable, UserRow>),
      UserRow,
      PrefetchHooks Function()
    >;
typedef $$NodesTableCreateCompanionBuilder = NodesCompanion Function({
  required String id,
  required String nodeId,
  required String name,
  required NodeRole role,
  required NodeStatus status,
  Value<int?> batteryPercent,
  Value<int?> rssi,
  Value<DateTime?> lastSeenAt,
  Value<bool> isSimulated,
  Value<int> rowid,
});
typedef $$NodesTableUpdateCompanionBuilder = NodesCompanion Function({
  Value<String> id,
  Value<String> nodeId,
  Value<String> name,
  Value<NodeRole> role,
  Value<NodeStatus> status,
  Value<int?> batteryPercent,
  Value<int?> rssi,
  Value<DateTime?> lastSeenAt,
  Value<bool> isSimulated,
  Value<int> rowid,
});

final class $$NodesTableReferences
    extends BaseReferences<_$AppDatabase, $NodesTable, NodeRow> {
  $$NodesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ConversationsTable, List<ConversationRow>>
  _conversationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.conversations,
    aliasName: 'nodes__node_id__conversations__peer_node_id',
  );

  $$ConversationsTableProcessedTableManager get conversationsRefs {
    final manager = $$ConversationsTableTableManager($_db, $_db.conversations)
        .filter(
          (f) =>
              f.peerNodeId.nodeId.sqlEquals($_itemColumn<String>('node_id')!),
        );

    final cache = $_typedResult.readTableOrNull(_conversationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DeviceLogsTable, List<DeviceLogRow>>
  _deviceLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.deviceLogs,
    aliasName: 'nodes__id__device_logs__node_id',
  );

  $$DeviceLogsTableProcessedTableManager get deviceLogsRefs {
    final manager = $$DeviceLogsTableTableManager(
      $_db,
      $_db.deviceLogs,
    ).filter((f) => f.nodeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_deviceLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NodesTableFilterComposer extends Composer<_$AppDatabase, $NodesTable> {
  $$NodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nodeId => $composableBuilder(
    column: $table.nodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<NodeRole, NodeRole, String> get role =>
      $composableBuilder(
        column: $table.role,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<NodeStatus, NodeStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get batteryPercent => $composableBuilder(
    column: $table.batteryPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rssi => $composableBuilder(
    column: $table.rssi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSimulated => $composableBuilder(
    column: $table.isSimulated,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> conversationsRefs(
    Expression<bool> Function($$ConversationsTableFilterComposer f) f,
  ) {
    final $$ConversationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nodeId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.peerNodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableFilterComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> deviceLogsRefs(
    Expression<bool> Function($$DeviceLogsTableFilterComposer f) f,
  ) {
    final $$DeviceLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deviceLogs,
      getReferencedColumn: (t) => t.nodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeviceLogsTableFilterComposer(
            $db: $db,
            $table: $db.deviceLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NodesTableOrderingComposer
    extends Composer<_$AppDatabase, $NodesTable> {
  $$NodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nodeId => $composableBuilder(
    column: $table.nodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batteryPercent => $composableBuilder(
    column: $table.batteryPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rssi => $composableBuilder(
    column: $table.rssi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSimulated => $composableBuilder(
    column: $table.isSimulated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NodesTable> {
  $$NodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nodeId =>
      $composableBuilder(column: $table.nodeId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<NodeRole, String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumnWithTypeConverter<NodeStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get batteryPercent => $composableBuilder(
    column: $table.batteryPercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rssi =>
      $composableBuilder(column: $table.rssi, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSimulated => $composableBuilder(
    column: $table.isSimulated,
    builder: (column) => column,
  );

  Expression<T> conversationsRefs<T extends Object>(
    Expression<T> Function($$ConversationsTableAnnotationComposer a) f,
  ) {
    final $$ConversationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nodeId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.peerNodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableAnnotationComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> deviceLogsRefs<T extends Object>(
    Expression<T> Function($$DeviceLogsTableAnnotationComposer a) f,
  ) {
    final $$DeviceLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deviceLogs,
      getReferencedColumn: (t) => t.nodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeviceLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.deviceLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NodesTable,
          NodeRow,
          $$NodesTableFilterComposer,
          $$NodesTableOrderingComposer,
          $$NodesTableAnnotationComposer,
          $$NodesTableCreateCompanionBuilder,
          $$NodesTableUpdateCompanionBuilder,
          (NodeRow, $$NodesTableReferences),
          NodeRow,
          PrefetchHooks Function({bool conversationsRefs, bool deviceLogsRefs})
        > {
  $$NodesTableTableManager(_$AppDatabase db, $NodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nodeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<NodeRole> role = const Value.absent(),
                Value<NodeStatus> status = const Value.absent(),
                Value<int?> batteryPercent = const Value.absent(),
                Value<int?> rssi = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<bool> isSimulated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NodesCompanion(
                id: id,
                nodeId: nodeId,
                name: name,
                role: role,
                status: status,
                batteryPercent: batteryPercent,
                rssi: rssi,
                lastSeenAt: lastSeenAt,
                isSimulated: isSimulated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nodeId,
                required String name,
                required NodeRole role,
                required NodeStatus status,
                Value<int?> batteryPercent = const Value.absent(),
                Value<int?> rssi = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<bool> isSimulated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NodesCompanion.insert(
                id: id,
                nodeId: nodeId,
                name: name,
                role: role,
                status: status,
                batteryPercent: batteryPercent,
                rssi: rssi,
                lastSeenAt: lastSeenAt,
                isSimulated: isSimulated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NodesTable, NodeRow>(table),
                  $$NodesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({conversationsRefs = false, deviceLogsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (conversationsRefs) db.conversations,
                    if (deviceLogsRefs) db.deviceLogs,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (conversationsRefs)
                        await $_getPrefetchedDataByColumns<
                          NodeRow,
                          $NodesTable,
                          ConversationRow,
                          $ConversationsTable
                        >(
                          currentTable: table,
                          referencedTable: $$NodesTableReferences
                              ._conversationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NodesTableReferences(
                                db,
                                table,
                                p0,
                              ).conversationsRefs,
                          currentColumn: 'node_id',
                          referencedColumn: 'peer_node_id',
                          typedResults: items,
                        ),
                      if (deviceLogsRefs)
                        await $_getPrefetchedDataByColumns<
                          NodeRow,
                          $NodesTable,
                          DeviceLogRow,
                          $DeviceLogsTable
                        >(
                          currentTable: table,
                          referencedTable: $$NodesTableReferences
                              ._deviceLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$NodesTableReferences(
                                db,
                                table,
                                p0,
                              ).deviceLogsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'node_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$NodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NodesTable,
      NodeRow,
      $$NodesTableFilterComposer,
      $$NodesTableOrderingComposer,
      $$NodesTableAnnotationComposer,
      $$NodesTableCreateCompanionBuilder,
      $$NodesTableUpdateCompanionBuilder,
      (NodeRow, $$NodesTableReferences),
      NodeRow,
      PrefetchHooks Function({bool conversationsRefs, bool deviceLogsRefs})
    >;
typedef $$ConversationsTableCreateCompanionBuilder =
    ConversationsCompanion Function({
      required String id,
      required String peerNodeId,
      required String title,
      Value<int> unreadCount,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ConversationsTableUpdateCompanionBuilder =
    ConversationsCompanion Function({
      Value<String> id,
      Value<String> peerNodeId,
      Value<String> title,
      Value<int> unreadCount,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ConversationsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ConversationsTable, ConversationRow> {
  $$ConversationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NodesTable _peerNodeIdTable(_$AppDatabase db) =>
      db.nodes.createAlias('conversations__peer_node_id__nodes__node_id');

  $$NodesTableProcessedTableManager get peerNodeId {
    final $_column = $_itemColumn<String>('peer_node_id')!;

    final manager = $$NodesTableTableManager(
      $_db,
      $_db.nodes,
    ).filter((f) => f.nodeId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_peerNodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MessagesTable, List<MessageRow>>
  _messagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.messages,
    aliasName: 'conversations__id__messages__conversation_id',
  );

  $$MessagesTableProcessedTableManager get messagesRefs {
    final manager = $$MessagesTableTableManager(
      $_db,
      $_db.messages,
    ).filter((f) => f.conversationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_messagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$NodesTableFilterComposer get peerNodeId {
    final $$NodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.peerNodeId,
      referencedTable: $db.nodes,
      getReferencedColumn: (t) => t.nodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NodesTableFilterComposer(
            $db: $db,
            $table: $db.nodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> messagesRefs(
    Expression<bool> Function($$MessagesTableFilterComposer f) f,
  ) {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableFilterComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$NodesTableOrderingComposer get peerNodeId {
    final $$NodesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.peerNodeId,
      referencedTable: $db.nodes,
      getReferencedColumn: (t) => t.nodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NodesTableOrderingComposer(
            $db: $db,
            $table: $db.nodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get unreadCount => $composableBuilder(
    column: $table.unreadCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$NodesTableAnnotationComposer get peerNodeId {
    final $$NodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.peerNodeId,
      referencedTable: $db.nodes,
      getReferencedColumn: (t) => t.nodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NodesTableAnnotationComposer(
            $db: $db,
            $table: $db.nodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> messagesRefs<T extends Object>(
    Expression<T> Function($$MessagesTableAnnotationComposer a) f,
  ) {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.conversationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ConversationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConversationsTable,
          ConversationRow,
          $$ConversationsTableFilterComposer,
          $$ConversationsTableOrderingComposer,
          $$ConversationsTableAnnotationComposer,
          $$ConversationsTableCreateCompanionBuilder,
          $$ConversationsTableUpdateCompanionBuilder,
          (ConversationRow, $$ConversationsTableReferences),
          ConversationRow,
          PrefetchHooks Function({bool peerNodeId, bool messagesRefs})
        > {
  $$ConversationsTableTableManager(_$AppDatabase db, $ConversationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> peerNodeId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> unreadCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConversationsCompanion(
                id: id,
                peerNodeId: peerNodeId,
                title: title,
                unreadCount: unreadCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String peerNodeId,
                required String title,
                Value<int> unreadCount = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ConversationsCompanion.insert(
                id: id,
                peerNodeId: peerNodeId,
                title: title,
                unreadCount: unreadCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConversationsTable, ConversationRow>(table),
                  $$ConversationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({peerNodeId = false, messagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (messagesRefs) db.messages],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (peerNodeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.peerNodeId,
                        referencedTable: $$ConversationsTableReferences
                            ._peerNodeIdTable(db),
                        referencedColumn: $$ConversationsTableReferences
                            ._peerNodeIdTable(db)
                            .nodeId,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (messagesRefs)
                    await $_getPrefetchedDataByColumns<
                      ConversationRow,
                      $ConversationsTable,
                      MessageRow,
                      $MessagesTable
                    >(
                      currentTable: table,
                      referencedTable: $$ConversationsTableReferences
                          ._messagesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ConversationsTableReferences(
                            db,
                            table,
                            p0,
                          ).messagesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'conversation_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ConversationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConversationsTable,
      ConversationRow,
      $$ConversationsTableFilterComposer,
      $$ConversationsTableOrderingComposer,
      $$ConversationsTableAnnotationComposer,
      $$ConversationsTableCreateCompanionBuilder,
      $$ConversationsTableUpdateCompanionBuilder,
      (ConversationRow, $$ConversationsTableReferences),
      ConversationRow,
      PrefetchHooks Function({bool peerNodeId, bool messagesRefs})
    >;
typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  required String id,
  required String conversationId,
  required String senderNodeId,
  required String recipientNodeId,
  required String body,
  required MessageDirection direction,
  required MessageStatus status,
  Value<String?> failureReason,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<double?> locationAccuracy,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<String> id,
  Value<String> conversationId,
  Value<String> senderNodeId,
  Value<String> recipientNodeId,
  Value<String> body,
  Value<MessageDirection> direction,
  Value<MessageStatus> status,
  Value<String?> failureReason,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<double?> locationAccuracy,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$MessagesTableReferences
    extends BaseReferences<_$AppDatabase, $MessagesTable, MessageRow> {
  $$MessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ConversationsTable _conversationIdTable(_$AppDatabase db) => db
      .conversations
      .createAlias('messages__conversation_id__conversations__id');

  $$ConversationsTableProcessedTableManager get conversationId {
    final $_column = $_itemColumn<String>('conversation_id')!;

    final manager = $$ConversationsTableTableManager(
      $_db,
      $_db.conversations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_conversationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderNodeId => $composableBuilder(
    column: $table.senderNodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipientNodeId => $composableBuilder(
    column: $table.recipientNodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MessageDirection, MessageDirection, String>
  get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<MessageStatus, MessageStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get locationAccuracy => $composableBuilder(
    column: $table.locationAccuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ConversationsTableFilterComposer get conversationId {
    final $$ConversationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableFilterComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderNodeId => $composableBuilder(
    column: $table.senderNodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipientNodeId => $composableBuilder(
    column: $table.recipientNodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get locationAccuracy => $composableBuilder(
    column: $table.locationAccuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ConversationsTableOrderingComposer get conversationId {
    final $$ConversationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableOrderingComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get senderNodeId => $composableBuilder(
    column: $table.senderNodeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recipientNodeId => $composableBuilder(
    column: $table.recipientNodeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MessageDirection, String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MessageStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get failureReason => $composableBuilder(
    column: $table.failureReason,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get locationAccuracy => $composableBuilder(
    column: $table.locationAccuracy,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ConversationsTableAnnotationComposer get conversationId {
    final $$ConversationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.conversationId,
      referencedTable: $db.conversations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ConversationsTableAnnotationComposer(
            $db: $db,
            $table: $db.conversations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          MessageRow,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (MessageRow, $$MessagesTableReferences),
          MessageRow,
          PrefetchHooks Function({bool conversationId})
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> conversationId = const Value.absent(),
                Value<String> senderNodeId = const Value.absent(),
                Value<String> recipientNodeId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<MessageDirection> direction = const Value.absent(),
                Value<MessageStatus> status = const Value.absent(),
                Value<String?> failureReason = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> locationAccuracy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                conversationId: conversationId,
                senderNodeId: senderNodeId,
                recipientNodeId: recipientNodeId,
                body: body,
                direction: direction,
                status: status,
                failureReason: failureReason,
                latitude: latitude,
                longitude: longitude,
                locationAccuracy: locationAccuracy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String conversationId,
                required String senderNodeId,
                required String recipientNodeId,
                required String body,
                required MessageDirection direction,
                required MessageStatus status,
                Value<String?> failureReason = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> locationAccuracy = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                conversationId: conversationId,
                senderNodeId: senderNodeId,
                recipientNodeId: recipientNodeId,
                body: body,
                direction: direction,
                status: status,
                failureReason: failureReason,
                latitude: latitude,
                longitude: longitude,
                locationAccuracy: locationAccuracy,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MessagesTable, MessageRow>(table),
                  $$MessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({conversationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (conversationId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.conversationId,
                        referencedTable: $$MessagesTableReferences
                            ._conversationIdTable(db),
                        referencedColumn: $$MessagesTableReferences
                            ._conversationIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      MessageRow,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (MessageRow, $$MessagesTableReferences),
      MessageRow,
      PrefetchHooks Function({bool conversationId})
    >;
typedef $$SosEventsTableCreateCompanionBuilder = SosEventsCompanion Function({
  required String id,
  required String sourceNodeId,
  required SosStatus status,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<double?> accuracy,
  Value<String?> note,
  Value<int> nodesReached,
  Value<bool> isSimulated,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> sentAt,
  Value<DateTime?> acknowledgedAt,
  Value<DateTime?> propagatedAt,
  Value<DateTime?> closedAt,
  Value<int> rowid,
});
typedef $$SosEventsTableUpdateCompanionBuilder = SosEventsCompanion Function({
  Value<String> id,
  Value<String> sourceNodeId,
  Value<SosStatus> status,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<double?> accuracy,
  Value<String?> note,
  Value<int> nodesReached,
  Value<bool> isSimulated,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> sentAt,
  Value<DateTime?> acknowledgedAt,
  Value<DateTime?> propagatedAt,
  Value<DateTime?> closedAt,
  Value<int> rowid,
});

class $$SosEventsTableFilterComposer
    extends Composer<_$AppDatabase, $SosEventsTable> {
  $$SosEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceNodeId => $composableBuilder(
    column: $table.sourceNodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SosStatus, SosStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nodesReached => $composableBuilder(
    column: $table.nodesReached,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSimulated => $composableBuilder(
    column: $table.isSimulated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get acknowledgedAt => $composableBuilder(
    column: $table.acknowledgedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get propagatedAt => $composableBuilder(
    column: $table.propagatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SosEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $SosEventsTable> {
  $$SosEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceNodeId => $composableBuilder(
    column: $table.sourceNodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nodesReached => $composableBuilder(
    column: $table.nodesReached,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSimulated => $composableBuilder(
    column: $table.isSimulated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get acknowledgedAt => $composableBuilder(
    column: $table.acknowledgedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get propagatedAt => $composableBuilder(
    column: $table.propagatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SosEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SosEventsTable> {
  $$SosEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceNodeId => $composableBuilder(
    column: $table.sourceNodeId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<SosStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get nodesReached => $composableBuilder(
    column: $table.nodesReached,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSimulated => $composableBuilder(
    column: $table.isSimulated,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);

  GeneratedColumn<DateTime> get acknowledgedAt => $composableBuilder(
    column: $table.acknowledgedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get propagatedAt => $composableBuilder(
    column: $table.propagatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);
}

class $$SosEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SosEventsTable,
          SosEventRow,
          $$SosEventsTableFilterComposer,
          $$SosEventsTableOrderingComposer,
          $$SosEventsTableAnnotationComposer,
          $$SosEventsTableCreateCompanionBuilder,
          $$SosEventsTableUpdateCompanionBuilder,
          (
            SosEventRow,
            BaseReferences<_$AppDatabase, $SosEventsTable, SosEventRow>,
          ),
          SosEventRow,
          PrefetchHooks Function()
        > {
  $$SosEventsTableTableManager(_$AppDatabase db, $SosEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SosEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SosEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SosEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceNodeId = const Value.absent(),
                Value<SosStatus> status = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> accuracy = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> nodesReached = const Value.absent(),
                Value<bool> isSimulated = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> sentAt = const Value.absent(),
                Value<DateTime?> acknowledgedAt = const Value.absent(),
                Value<DateTime?> propagatedAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SosEventsCompanion(
                id: id,
                sourceNodeId: sourceNodeId,
                status: status,
                latitude: latitude,
                longitude: longitude,
                accuracy: accuracy,
                note: note,
                nodesReached: nodesReached,
                isSimulated: isSimulated,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sentAt: sentAt,
                acknowledgedAt: acknowledgedAt,
                propagatedAt: propagatedAt,
                closedAt: closedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sourceNodeId,
                required SosStatus status,
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<double?> accuracy = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> nodesReached = const Value.absent(),
                Value<bool> isSimulated = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> sentAt = const Value.absent(),
                Value<DateTime?> acknowledgedAt = const Value.absent(),
                Value<DateTime?> propagatedAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SosEventsCompanion.insert(
                id: id,
                sourceNodeId: sourceNodeId,
                status: status,
                latitude: latitude,
                longitude: longitude,
                accuracy: accuracy,
                note: note,
                nodesReached: nodesReached,
                isSimulated: isSimulated,
                createdAt: createdAt,
                updatedAt: updatedAt,
                sentAt: sentAt,
                acknowledgedAt: acknowledgedAt,
                propagatedAt: propagatedAt,
                closedAt: closedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SosEventsTable, SosEventRow>(table),
                  BaseReferences<_$AppDatabase, $SosEventsTable, SosEventRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SosEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SosEventsTable,
      SosEventRow,
      $$SosEventsTableFilterComposer,
      $$SosEventsTableOrderingComposer,
      $$SosEventsTableAnnotationComposer,
      $$SosEventsTableCreateCompanionBuilder,
      $$SosEventsTableUpdateCompanionBuilder,
      (
        SosEventRow,
        BaseReferences<_$AppDatabase, $SosEventsTable, SosEventRow>,
      ),
      SosEventRow,
      PrefetchHooks Function()
    >;
typedef $$LocationRecordsTableCreateCompanionBuilder =
    LocationRecordsCompanion Function({
      required String id,
      required double latitude,
      required double longitude,
      Value<double?> accuracy,
      Value<double?> altitude,
      required DateTime recordedAt,
      Value<int> rowid,
    });
typedef $$LocationRecordsTableUpdateCompanionBuilder =
    LocationRecordsCompanion Function({
      Value<String> id,
      Value<double> latitude,
      Value<double> longitude,
      Value<double?> accuracy,
      Value<double?> altitude,
      Value<DateTime> recordedAt,
      Value<int> rowid,
    });

class $$LocationRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $LocationRecordsTable> {
  $$LocationRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocationRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationRecordsTable> {
  $$LocationRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocationRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationRecordsTable> {
  $$LocationRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<double> get altitude =>
      $composableBuilder(column: $table.altitude, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );
}

class $$LocationRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocationRecordsTable,
          LocationRow,
          $$LocationRecordsTableFilterComposer,
          $$LocationRecordsTableOrderingComposer,
          $$LocationRecordsTableAnnotationComposer,
          $$LocationRecordsTableCreateCompanionBuilder,
          $$LocationRecordsTableUpdateCompanionBuilder,
          (
            LocationRow,
            BaseReferences<_$AppDatabase, $LocationRecordsTable, LocationRow>,
          ),
          LocationRow,
          PrefetchHooks Function()
        > {
  $$LocationRecordsTableTableManager(
    _$AppDatabase db,
    $LocationRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double?> accuracy = const Value.absent(),
                Value<double?> altitude = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationRecordsCompanion(
                id: id,
                latitude: latitude,
                longitude: longitude,
                accuracy: accuracy,
                altitude: altitude,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required double latitude,
                required double longitude,
                Value<double?> accuracy = const Value.absent(),
                Value<double?> altitude = const Value.absent(),
                required DateTime recordedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocationRecordsCompanion.insert(
                id: id,
                latitude: latitude,
                longitude: longitude,
                accuracy: accuracy,
                altitude: altitude,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocationRecordsTable, LocationRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocationRecordsTable,
                    LocationRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocationRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocationRecordsTable,
      LocationRow,
      $$LocationRecordsTableFilterComposer,
      $$LocationRecordsTableOrderingComposer,
      $$LocationRecordsTableAnnotationComposer,
      $$LocationRecordsTableCreateCompanionBuilder,
      $$LocationRecordsTableUpdateCompanionBuilder,
      (
        LocationRow,
        BaseReferences<_$AppDatabase, $LocationRecordsTable, LocationRow>,
      ),
      LocationRow,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  required String id,
  required SyncEntityType entityType,
  required String entityId,
  required SyncOperation operation,
  required String payload,
  required SyncStatus status,
  Value<int> retryCount,
  Value<String?> lastError,
  required DateTime createdAt,
  Value<DateTime?> lastAttemptAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<String> id,
  Value<SyncEntityType> entityType,
  Value<String> entityId,
  Value<SyncOperation> operation,
  Value<String> payload,
  Value<SyncStatus> status,
  Value<int> retryCount,
  Value<String?> lastError,
  Value<DateTime> createdAt,
  Value<DateTime?> lastAttemptAt,
  Value<DateTime?> syncedAt,
  Value<int> rowid,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncEntityType, SyncEntityType, String>
  get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncOperation, SyncOperation, String>
  get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncEntityType, String> get entityType =>
      $composableBuilder(
        column: $table.entityType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncOperation, String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueRow,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueRow,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueRow>,
          ),
          SyncQueueRow,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<SyncEntityType> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<SyncOperation> operation = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<SyncStatus> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payload: payload,
                status: status,
                retryCount: retryCount,
                lastError: lastError,
                createdAt: createdAt,
                lastAttemptAt: lastAttemptAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required SyncEntityType entityType,
                required String entityId,
                required SyncOperation operation,
                required String payload,
                required SyncStatus status,
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                payload: payload,
                status: status,
                retryCount: retryCount,
                lastError: lastError,
                createdAt: createdAt,
                lastAttemptAt: lastAttemptAt,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncQueueTable, SyncQueueRow>(table),
                  BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueRow,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueRow,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueRow>,
      ),
      SyncQueueRow,
      PrefetchHooks Function()
    >;
typedef $$DeviceLogsTableCreateCompanionBuilder = DeviceLogsCompanion Function({
  Value<int> id,
  Value<String?> nodeId,
  required LogLevel level,
  required String message,
  required DateTime createdAt,
});
typedef $$DeviceLogsTableUpdateCompanionBuilder = DeviceLogsCompanion Function({
  Value<int> id,
  Value<String?> nodeId,
  Value<LogLevel> level,
  Value<String> message,
  Value<DateTime> createdAt,
});

final class $$DeviceLogsTableReferences
    extends BaseReferences<_$AppDatabase, $DeviceLogsTable, DeviceLogRow> {
  $$DeviceLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $NodesTable _nodeIdTable(_$AppDatabase db) =>
      db.nodes.createAlias('device_logs__node_id__nodes__id');

  $$NodesTableProcessedTableManager? get nodeId {
    final $_column = $_itemColumn<String>('node_id');
    if ($_column == null) return null;
    final manager = $$NodesTableTableManager(
      $_db,
      $_db.nodes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_nodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DeviceLogsTableFilterComposer
    extends Composer<_$AppDatabase, $DeviceLogsTable> {
  $$DeviceLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LogLevel, LogLevel, String> get level =>
      $composableBuilder(
        column: $table.level,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$NodesTableFilterComposer get nodeId {
    final $$NodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nodeId,
      referencedTable: $db.nodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NodesTableFilterComposer(
            $db: $db,
            $table: $db.nodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeviceLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeviceLogsTable> {
  $$DeviceLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$NodesTableOrderingComposer get nodeId {
    final $$NodesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nodeId,
      referencedTable: $db.nodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NodesTableOrderingComposer(
            $db: $db,
            $table: $db.nodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeviceLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeviceLogsTable> {
  $$DeviceLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LogLevel, String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$NodesTableAnnotationComposer get nodeId {
    final $$NodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nodeId,
      referencedTable: $db.nodes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NodesTableAnnotationComposer(
            $db: $db,
            $table: $db.nodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeviceLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeviceLogsTable,
          DeviceLogRow,
          $$DeviceLogsTableFilterComposer,
          $$DeviceLogsTableOrderingComposer,
          $$DeviceLogsTableAnnotationComposer,
          $$DeviceLogsTableCreateCompanionBuilder,
          $$DeviceLogsTableUpdateCompanionBuilder,
          (DeviceLogRow, $$DeviceLogsTableReferences),
          DeviceLogRow,
          PrefetchHooks Function({bool nodeId})
        > {
  $$DeviceLogsTableTableManager(_$AppDatabase db, $DeviceLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeviceLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> nodeId = const Value.absent(),
                Value<LogLevel> level = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DeviceLogsCompanion(
                id: id,
                nodeId: nodeId,
                level: level,
                message: message,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> nodeId = const Value.absent(),
                required LogLevel level,
                required String message,
                required DateTime createdAt,
              }) => DeviceLogsCompanion.insert(
                id: id,
                nodeId: nodeId,
                level: level,
                message: message,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DeviceLogsTable, DeviceLogRow>(table),
                  $$DeviceLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({nodeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (nodeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.nodeId,
                        referencedTable: $$DeviceLogsTableReferences
                            ._nodeIdTable(db),
                        referencedColumn: $$DeviceLogsTableReferences
                            ._nodeIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DeviceLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeviceLogsTable,
      DeviceLogRow,
      $$DeviceLogsTableFilterComposer,
      $$DeviceLogsTableOrderingComposer,
      $$DeviceLogsTableAnnotationComposer,
      $$DeviceLogsTableCreateCompanionBuilder,
      $$DeviceLogsTableUpdateCompanionBuilder,
      (DeviceLogRow, $$DeviceLogsTableReferences),
      DeviceLogRow,
      PrefetchHooks Function({bool nodeId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSettingRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
          ),
          AppSettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSettingRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppSettingsTable,
                    AppSettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSettingRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
      ),
      AppSettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$NodesTableTableManager get nodes =>
      $$NodesTableTableManager(_db, _db.nodes);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$SosEventsTableTableManager get sosEvents =>
      $$SosEventsTableTableManager(_db, _db.sosEvents);
  $$LocationRecordsTableTableManager get locationRecords =>
      $$LocationRecordsTableTableManager(_db, _db.locationRecords);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$DeviceLogsTableTableManager get deviceLogs =>
      $$DeviceLogsTableTableManager(_db, _db.deviceLogs);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
