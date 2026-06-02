// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scene.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Scene _$SceneFromJson(Map<String, dynamic> json) {
  return _Scene.fromJson(json);
}

/// @nodoc
mixin _$Scene {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  List<SceneAction> get actions => throw _privateConstructorUsedError;
  SceneTrigger? get trigger => throw _privateConstructorUsedError;

  /// Serializes this Scene to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Scene
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SceneCopyWith<Scene> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SceneCopyWith<$Res> {
  factory $SceneCopyWith(Scene value, $Res Function(Scene) then) =
      _$SceneCopyWithImpl<$Res, Scene>;
  @useResult
  $Res call(
      {String id,
      String name,
      String icon,
      List<SceneAction> actions,
      SceneTrigger? trigger});

  $SceneTriggerCopyWith<$Res>? get trigger;
}

/// @nodoc
class _$SceneCopyWithImpl<$Res, $Val extends Scene>
    implements $SceneCopyWith<$Res> {
  _$SceneCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Scene
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? actions = null,
    Object? trigger = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      actions: null == actions
          ? _value.actions
          : actions // ignore: cast_nullable_to_non_nullable
              as List<SceneAction>,
      trigger: freezed == trigger
          ? _value.trigger
          : trigger // ignore: cast_nullable_to_non_nullable
              as SceneTrigger?,
    ) as $Val);
  }

  /// Create a copy of Scene
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SceneTriggerCopyWith<$Res>? get trigger {
    if (_value.trigger == null) {
      return null;
    }

    return $SceneTriggerCopyWith<$Res>(_value.trigger!, (value) {
      return _then(_value.copyWith(trigger: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SceneImplCopyWith<$Res> implements $SceneCopyWith<$Res> {
  factory _$$SceneImplCopyWith(
          _$SceneImpl value, $Res Function(_$SceneImpl) then) =
      __$$SceneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String icon,
      List<SceneAction> actions,
      SceneTrigger? trigger});

  @override
  $SceneTriggerCopyWith<$Res>? get trigger;
}

/// @nodoc
class __$$SceneImplCopyWithImpl<$Res>
    extends _$SceneCopyWithImpl<$Res, _$SceneImpl>
    implements _$$SceneImplCopyWith<$Res> {
  __$$SceneImplCopyWithImpl(
      _$SceneImpl _value, $Res Function(_$SceneImpl) _then)
      : super(_value, _then);

  /// Create a copy of Scene
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? icon = null,
    Object? actions = null,
    Object? trigger = freezed,
  }) {
    return _then(_$SceneImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      actions: null == actions
          ? _value._actions
          : actions // ignore: cast_nullable_to_non_nullable
              as List<SceneAction>,
      trigger: freezed == trigger
          ? _value.trigger
          : trigger // ignore: cast_nullable_to_non_nullable
              as SceneTrigger?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SceneImpl implements _Scene {
  const _$SceneImpl(
      {required this.id,
      required this.name,
      required this.icon,
      required final List<SceneAction> actions,
      this.trigger})
      : _actions = actions;

  factory _$SceneImpl.fromJson(Map<String, dynamic> json) =>
      _$$SceneImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String icon;
  final List<SceneAction> _actions;
  @override
  List<SceneAction> get actions {
    if (_actions is EqualUnmodifiableListView) return _actions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_actions);
  }

  @override
  final SceneTrigger? trigger;

  @override
  String toString() {
    return 'Scene(id: $id, name: $name, icon: $icon, actions: $actions, trigger: $trigger)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SceneImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            const DeepCollectionEquality().equals(other._actions, _actions) &&
            (identical(other.trigger, trigger) || other.trigger == trigger));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, icon,
      const DeepCollectionEquality().hash(_actions), trigger);

  /// Create a copy of Scene
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SceneImplCopyWith<_$SceneImpl> get copyWith =>
      __$$SceneImplCopyWithImpl<_$SceneImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SceneImplToJson(
      this,
    );
  }
}

abstract class _Scene implements Scene {
  const factory _Scene(
      {required final String id,
      required final String name,
      required final String icon,
      required final List<SceneAction> actions,
      final SceneTrigger? trigger}) = _$SceneImpl;

  factory _Scene.fromJson(Map<String, dynamic> json) = _$SceneImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get icon;
  @override
  List<SceneAction> get actions;
  @override
  SceneTrigger? get trigger;

  /// Create a copy of Scene
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SceneImplCopyWith<_$SceneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SceneAction _$SceneActionFromJson(Map<String, dynamic> json) {
  return _SceneAction.fromJson(json);
}

/// @nodoc
mixin _$SceneAction {
  String get deviceId => throw _privateConstructorUsedError;
  String get command =>
      throw _privateConstructorUsedError; // 'turnOn', 'turnOff', 'setBrightness'
  dynamic get value => throw _privateConstructorUsedError;

  /// Serializes this SceneAction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SceneAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SceneActionCopyWith<SceneAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SceneActionCopyWith<$Res> {
  factory $SceneActionCopyWith(
          SceneAction value, $Res Function(SceneAction) then) =
      _$SceneActionCopyWithImpl<$Res, SceneAction>;
  @useResult
  $Res call({String deviceId, String command, dynamic value});
}

/// @nodoc
class _$SceneActionCopyWithImpl<$Res, $Val extends SceneAction>
    implements $SceneActionCopyWith<$Res> {
  _$SceneActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SceneAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? command = null,
    Object? value = freezed,
  }) {
    return _then(_value.copyWith(
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      command: null == command
          ? _value.command
          : command // ignore: cast_nullable_to_non_nullable
              as String,
      value: freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SceneActionImplCopyWith<$Res>
    implements $SceneActionCopyWith<$Res> {
  factory _$$SceneActionImplCopyWith(
          _$SceneActionImpl value, $Res Function(_$SceneActionImpl) then) =
      __$$SceneActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String deviceId, String command, dynamic value});
}

/// @nodoc
class __$$SceneActionImplCopyWithImpl<$Res>
    extends _$SceneActionCopyWithImpl<$Res, _$SceneActionImpl>
    implements _$$SceneActionImplCopyWith<$Res> {
  __$$SceneActionImplCopyWithImpl(
      _$SceneActionImpl _value, $Res Function(_$SceneActionImpl) _then)
      : super(_value, _then);

  /// Create a copy of SceneAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceId = null,
    Object? command = null,
    Object? value = freezed,
  }) {
    return _then(_$SceneActionImpl(
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      command: null == command
          ? _value.command
          : command // ignore: cast_nullable_to_non_nullable
              as String,
      value: freezed == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as dynamic,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SceneActionImpl implements _SceneAction {
  const _$SceneActionImpl(
      {required this.deviceId, required this.command, this.value});

  factory _$SceneActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SceneActionImplFromJson(json);

  @override
  final String deviceId;
  @override
  final String command;
// 'turnOn', 'turnOff', 'setBrightness'
  @override
  final dynamic value;

  @override
  String toString() {
    return 'SceneAction(deviceId: $deviceId, command: $command, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SceneActionImpl &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.command, command) || other.command == command) &&
            const DeepCollectionEquality().equals(other.value, value));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, deviceId, command,
      const DeepCollectionEquality().hash(value));

  /// Create a copy of SceneAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SceneActionImplCopyWith<_$SceneActionImpl> get copyWith =>
      __$$SceneActionImplCopyWithImpl<_$SceneActionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SceneActionImplToJson(
      this,
    );
  }
}

abstract class _SceneAction implements SceneAction {
  const factory _SceneAction(
      {required final String deviceId,
      required final String command,
      final dynamic value}) = _$SceneActionImpl;

  factory _SceneAction.fromJson(Map<String, dynamic> json) =
      _$SceneActionImpl.fromJson;

  @override
  String get deviceId;
  @override
  String get command; // 'turnOn', 'turnOff', 'setBrightness'
  @override
  dynamic get value;

  /// Create a copy of SceneAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SceneActionImplCopyWith<_$SceneActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SceneTrigger _$SceneTriggerFromJson(Map<String, dynamic> json) {
  return _SceneTrigger.fromJson(json);
}

/// @nodoc
mixin _$SceneTrigger {
  TriggerType get type => throw _privateConstructorUsedError;
  String? get time =>
      throw _privateConstructorUsedError; // 'HH:mm' для time триггера
  String? get deviceId =>
      throw _privateConstructorUsedError; // для device_state триггера
  String? get condition => throw _privateConstructorUsedError;

  /// Serializes this SceneTrigger to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SceneTrigger
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SceneTriggerCopyWith<SceneTrigger> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SceneTriggerCopyWith<$Res> {
  factory $SceneTriggerCopyWith(
          SceneTrigger value, $Res Function(SceneTrigger) then) =
      _$SceneTriggerCopyWithImpl<$Res, SceneTrigger>;
  @useResult
  $Res call(
      {TriggerType type, String? time, String? deviceId, String? condition});
}

/// @nodoc
class _$SceneTriggerCopyWithImpl<$Res, $Val extends SceneTrigger>
    implements $SceneTriggerCopyWith<$Res> {
  _$SceneTriggerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SceneTrigger
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? time = freezed,
    Object? deviceId = freezed,
    Object? condition = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TriggerType,
      time: freezed == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceId: freezed == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      condition: freezed == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SceneTriggerImplCopyWith<$Res>
    implements $SceneTriggerCopyWith<$Res> {
  factory _$$SceneTriggerImplCopyWith(
          _$SceneTriggerImpl value, $Res Function(_$SceneTriggerImpl) then) =
      __$$SceneTriggerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {TriggerType type, String? time, String? deviceId, String? condition});
}

/// @nodoc
class __$$SceneTriggerImplCopyWithImpl<$Res>
    extends _$SceneTriggerCopyWithImpl<$Res, _$SceneTriggerImpl>
    implements _$$SceneTriggerImplCopyWith<$Res> {
  __$$SceneTriggerImplCopyWithImpl(
      _$SceneTriggerImpl _value, $Res Function(_$SceneTriggerImpl) _then)
      : super(_value, _then);

  /// Create a copy of SceneTrigger
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? time = freezed,
    Object? deviceId = freezed,
    Object? condition = freezed,
  }) {
    return _then(_$SceneTriggerImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TriggerType,
      time: freezed == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceId: freezed == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String?,
      condition: freezed == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SceneTriggerImpl implements _SceneTrigger {
  const _$SceneTriggerImpl(
      {required this.type, this.time, this.deviceId, this.condition});

  factory _$SceneTriggerImpl.fromJson(Map<String, dynamic> json) =>
      _$$SceneTriggerImplFromJson(json);

  @override
  final TriggerType type;
  @override
  final String? time;
// 'HH:mm' для time триггера
  @override
  final String? deviceId;
// для device_state триггера
  @override
  final String? condition;

  @override
  String toString() {
    return 'SceneTrigger(type: $type, time: $time, deviceId: $deviceId, condition: $condition)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SceneTriggerImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.condition, condition) ||
                other.condition == condition));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, time, deviceId, condition);

  /// Create a copy of SceneTrigger
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SceneTriggerImplCopyWith<_$SceneTriggerImpl> get copyWith =>
      __$$SceneTriggerImplCopyWithImpl<_$SceneTriggerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SceneTriggerImplToJson(
      this,
    );
  }
}

abstract class _SceneTrigger implements SceneTrigger {
  const factory _SceneTrigger(
      {required final TriggerType type,
      final String? time,
      final String? deviceId,
      final String? condition}) = _$SceneTriggerImpl;

  factory _SceneTrigger.fromJson(Map<String, dynamic> json) =
      _$SceneTriggerImpl.fromJson;

  @override
  TriggerType get type;
  @override
  String? get time; // 'HH:mm' для time триггера
  @override
  String? get deviceId; // для device_state триггера
  @override
  String? get condition;

  /// Create a copy of SceneTrigger
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SceneTriggerImplCopyWith<_$SceneTriggerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
