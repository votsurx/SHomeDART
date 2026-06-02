// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'switch_device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SwitchDevice _$SwitchDeviceFromJson(Map<String, dynamic> json) {
  return _SwitchDevice.fromJson(json);
}

/// @nodoc
mixin _$SwitchDevice {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get channels => throw _privateConstructorUsedError; // 1, 2, 3
  List<bool> get states =>
      throw _privateConstructorUsedError; // Состояние каждого канала
  String get deviceId => throw _privateConstructorUsedError;
  String get localKey => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  double get version => throw _privateConstructorUsedError;

  /// Serializes this SwitchDevice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SwitchDevice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SwitchDeviceCopyWith<SwitchDevice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SwitchDeviceCopyWith<$Res> {
  factory $SwitchDeviceCopyWith(
          SwitchDevice value, $Res Function(SwitchDevice) then) =
      _$SwitchDeviceCopyWithImpl<$Res, SwitchDevice>;
  @useResult
  $Res call(
      {String id,
      String name,
      int channels,
      List<bool> states,
      String deviceId,
      String localKey,
      String address,
      double version});
}

/// @nodoc
class _$SwitchDeviceCopyWithImpl<$Res, $Val extends SwitchDevice>
    implements $SwitchDeviceCopyWith<$Res> {
  _$SwitchDeviceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SwitchDevice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? channels = null,
    Object? states = null,
    Object? deviceId = null,
    Object? localKey = null,
    Object? address = null,
    Object? version = null,
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
      channels: null == channels
          ? _value.channels
          : channels // ignore: cast_nullable_to_non_nullable
              as int,
      states: null == states
          ? _value.states
          : states // ignore: cast_nullable_to_non_nullable
              as List<bool>,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      localKey: null == localKey
          ? _value.localKey
          : localKey // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SwitchDeviceImplCopyWith<$Res>
    implements $SwitchDeviceCopyWith<$Res> {
  factory _$$SwitchDeviceImplCopyWith(
          _$SwitchDeviceImpl value, $Res Function(_$SwitchDeviceImpl) then) =
      __$$SwitchDeviceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      int channels,
      List<bool> states,
      String deviceId,
      String localKey,
      String address,
      double version});
}

/// @nodoc
class __$$SwitchDeviceImplCopyWithImpl<$Res>
    extends _$SwitchDeviceCopyWithImpl<$Res, _$SwitchDeviceImpl>
    implements _$$SwitchDeviceImplCopyWith<$Res> {
  __$$SwitchDeviceImplCopyWithImpl(
      _$SwitchDeviceImpl _value, $Res Function(_$SwitchDeviceImpl) _then)
      : super(_value, _then);

  /// Create a copy of SwitchDevice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? channels = null,
    Object? states = null,
    Object? deviceId = null,
    Object? localKey = null,
    Object? address = null,
    Object? version = null,
  }) {
    return _then(_$SwitchDeviceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      channels: null == channels
          ? _value.channels
          : channels // ignore: cast_nullable_to_non_nullable
              as int,
      states: null == states
          ? _value._states
          : states // ignore: cast_nullable_to_non_nullable
              as List<bool>,
      deviceId: null == deviceId
          ? _value.deviceId
          : deviceId // ignore: cast_nullable_to_non_nullable
              as String,
      localKey: null == localKey
          ? _value.localKey
          : localKey // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SwitchDeviceImpl implements _SwitchDevice {
  const _$SwitchDeviceImpl(
      {required this.id,
      required this.name,
      required this.channels,
      required final List<bool> states,
      required this.deviceId,
      required this.localKey,
      required this.address,
      required this.version})
      : _states = states;

  factory _$SwitchDeviceImpl.fromJson(Map<String, dynamic> json) =>
      _$$SwitchDeviceImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final int channels;
// 1, 2, 3
  final List<bool> _states;
// 1, 2, 3
  @override
  List<bool> get states {
    if (_states is EqualUnmodifiableListView) return _states;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_states);
  }

// Состояние каждого канала
  @override
  final String deviceId;
  @override
  final String localKey;
  @override
  final String address;
  @override
  final double version;

  @override
  String toString() {
    return 'SwitchDevice(id: $id, name: $name, channels: $channels, states: $states, deviceId: $deviceId, localKey: $localKey, address: $address, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SwitchDeviceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.channels, channels) ||
                other.channels == channels) &&
            const DeepCollectionEquality().equals(other._states, _states) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.localKey, localKey) ||
                other.localKey == localKey) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.version, version) || other.version == version));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      channels,
      const DeepCollectionEquality().hash(_states),
      deviceId,
      localKey,
      address,
      version);

  /// Create a copy of SwitchDevice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SwitchDeviceImplCopyWith<_$SwitchDeviceImpl> get copyWith =>
      __$$SwitchDeviceImplCopyWithImpl<_$SwitchDeviceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SwitchDeviceImplToJson(
      this,
    );
  }
}

abstract class _SwitchDevice implements SwitchDevice {
  const factory _SwitchDevice(
      {required final String id,
      required final String name,
      required final int channels,
      required final List<bool> states,
      required final String deviceId,
      required final String localKey,
      required final String address,
      required final double version}) = _$SwitchDeviceImpl;

  factory _SwitchDevice.fromJson(Map<String, dynamic> json) =
      _$SwitchDeviceImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get channels; // 1, 2, 3
  @override
  List<bool> get states; // Состояние каждого канала
  @override
  String get deviceId;
  @override
  String get localKey;
  @override
  String get address;
  @override
  double get version;

  /// Create a copy of SwitchDevice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SwitchDeviceImplCopyWith<_$SwitchDeviceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
