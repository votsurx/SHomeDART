// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hvac_device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HvacDevice _$HvacDeviceFromJson(Map<String, dynamic> json) {
  return _HvacDevice.fromJson(json);
}

/// @nodoc
mixin _$HvacDevice {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  bool get isOn => throw _privateConstructorUsedError;
  double get temperature =>
      throw _privateConstructorUsedError; // Текущая температура
  double get targetTemp =>
      throw _privateConstructorUsedError; // Целевая температура
  HvacMode get mode => throw _privateConstructorUsedError; // Режим работы
  int get fanSpeed =>
      throw _privateConstructorUsedError; // Скорость вентилятора (1-5)
  String get deviceId => throw _privateConstructorUsedError;
  String get localKey => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  double get version => throw _privateConstructorUsedError;

  /// Serializes this HvacDevice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HvacDevice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HvacDeviceCopyWith<HvacDevice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HvacDeviceCopyWith<$Res> {
  factory $HvacDeviceCopyWith(
          HvacDevice value, $Res Function(HvacDevice) then) =
      _$HvacDeviceCopyWithImpl<$Res, HvacDevice>;
  @useResult
  $Res call(
      {String id,
      String name,
      bool isOn,
      double temperature,
      double targetTemp,
      HvacMode mode,
      int fanSpeed,
      String deviceId,
      String localKey,
      String address,
      double version});
}

/// @nodoc
class _$HvacDeviceCopyWithImpl<$Res, $Val extends HvacDevice>
    implements $HvacDeviceCopyWith<$Res> {
  _$HvacDeviceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HvacDevice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? isOn = null,
    Object? temperature = null,
    Object? targetTemp = null,
    Object? mode = null,
    Object? fanSpeed = null,
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
      isOn: null == isOn
          ? _value.isOn
          : isOn // ignore: cast_nullable_to_non_nullable
              as bool,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      targetTemp: null == targetTemp
          ? _value.targetTemp
          : targetTemp // ignore: cast_nullable_to_non_nullable
              as double,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as HvacMode,
      fanSpeed: null == fanSpeed
          ? _value.fanSpeed
          : fanSpeed // ignore: cast_nullable_to_non_nullable
              as int,
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
abstract class _$$HvacDeviceImplCopyWith<$Res>
    implements $HvacDeviceCopyWith<$Res> {
  factory _$$HvacDeviceImplCopyWith(
          _$HvacDeviceImpl value, $Res Function(_$HvacDeviceImpl) then) =
      __$$HvacDeviceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      bool isOn,
      double temperature,
      double targetTemp,
      HvacMode mode,
      int fanSpeed,
      String deviceId,
      String localKey,
      String address,
      double version});
}

/// @nodoc
class __$$HvacDeviceImplCopyWithImpl<$Res>
    extends _$HvacDeviceCopyWithImpl<$Res, _$HvacDeviceImpl>
    implements _$$HvacDeviceImplCopyWith<$Res> {
  __$$HvacDeviceImplCopyWithImpl(
      _$HvacDeviceImpl _value, $Res Function(_$HvacDeviceImpl) _then)
      : super(_value, _then);

  /// Create a copy of HvacDevice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? isOn = null,
    Object? temperature = null,
    Object? targetTemp = null,
    Object? mode = null,
    Object? fanSpeed = null,
    Object? deviceId = null,
    Object? localKey = null,
    Object? address = null,
    Object? version = null,
  }) {
    return _then(_$HvacDeviceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      isOn: null == isOn
          ? _value.isOn
          : isOn // ignore: cast_nullable_to_non_nullable
              as bool,
      temperature: null == temperature
          ? _value.temperature
          : temperature // ignore: cast_nullable_to_non_nullable
              as double,
      targetTemp: null == targetTemp
          ? _value.targetTemp
          : targetTemp // ignore: cast_nullable_to_non_nullable
              as double,
      mode: null == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as HvacMode,
      fanSpeed: null == fanSpeed
          ? _value.fanSpeed
          : fanSpeed // ignore: cast_nullable_to_non_nullable
              as int,
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
class _$HvacDeviceImpl implements _HvacDevice {
  const _$HvacDeviceImpl(
      {required this.id,
      required this.name,
      required this.isOn,
      required this.temperature,
      required this.targetTemp,
      required this.mode,
      required this.fanSpeed,
      required this.deviceId,
      required this.localKey,
      required this.address,
      required this.version});

  factory _$HvacDeviceImpl.fromJson(Map<String, dynamic> json) =>
      _$$HvacDeviceImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final bool isOn;
  @override
  final double temperature;
// Текущая температура
  @override
  final double targetTemp;
// Целевая температура
  @override
  final HvacMode mode;
// Режим работы
  @override
  final int fanSpeed;
// Скорость вентилятора (1-5)
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
    return 'HvacDevice(id: $id, name: $name, isOn: $isOn, temperature: $temperature, targetTemp: $targetTemp, mode: $mode, fanSpeed: $fanSpeed, deviceId: $deviceId, localKey: $localKey, address: $address, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HvacDeviceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.isOn, isOn) || other.isOn == isOn) &&
            (identical(other.temperature, temperature) ||
                other.temperature == temperature) &&
            (identical(other.targetTemp, targetTemp) ||
                other.targetTemp == targetTemp) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.fanSpeed, fanSpeed) ||
                other.fanSpeed == fanSpeed) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.localKey, localKey) ||
                other.localKey == localKey) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.version, version) || other.version == version));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, isOn, temperature,
      targetTemp, mode, fanSpeed, deviceId, localKey, address, version);

  /// Create a copy of HvacDevice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HvacDeviceImplCopyWith<_$HvacDeviceImpl> get copyWith =>
      __$$HvacDeviceImplCopyWithImpl<_$HvacDeviceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HvacDeviceImplToJson(
      this,
    );
  }
}

abstract class _HvacDevice implements HvacDevice {
  const factory _HvacDevice(
      {required final String id,
      required final String name,
      required final bool isOn,
      required final double temperature,
      required final double targetTemp,
      required final HvacMode mode,
      required final int fanSpeed,
      required final String deviceId,
      required final String localKey,
      required final String address,
      required final double version}) = _$HvacDeviceImpl;

  factory _HvacDevice.fromJson(Map<String, dynamic> json) =
      _$HvacDeviceImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  bool get isOn;
  @override
  double get temperature; // Текущая температура
  @override
  double get targetTemp; // Целевая температура
  @override
  HvacMode get mode; // Режим работы
  @override
  int get fanSpeed; // Скорость вентилятора (1-5)
  @override
  String get deviceId;
  @override
  String get localKey;
  @override
  String get address;
  @override
  double get version;

  /// Create a copy of HvacDevice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HvacDeviceImplCopyWith<_$HvacDeviceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
