// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'curtain_device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CurtainDevice _$CurtainDeviceFromJson(Map<String, dynamic> json) {
  return _CurtainDevice.fromJson(json);
}

/// @nodoc
mixin _$CurtainDevice {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get position => throw _privateConstructorUsedError; // 0-100 (% открытия)
  bool get isMoving => throw _privateConstructorUsedError;
  String get deviceId => throw _privateConstructorUsedError;
  String get localKey => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  double get version => throw _privateConstructorUsedError;

  /// Serializes this CurtainDevice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CurtainDevice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CurtainDeviceCopyWith<CurtainDevice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CurtainDeviceCopyWith<$Res> {
  factory $CurtainDeviceCopyWith(
          CurtainDevice value, $Res Function(CurtainDevice) then) =
      _$CurtainDeviceCopyWithImpl<$Res, CurtainDevice>;
  @useResult
  $Res call(
      {String id,
      String name,
      int position,
      bool isMoving,
      String deviceId,
      String localKey,
      String address,
      double version});
}

/// @nodoc
class _$CurtainDeviceCopyWithImpl<$Res, $Val extends CurtainDevice>
    implements $CurtainDeviceCopyWith<$Res> {
  _$CurtainDeviceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CurtainDevice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? position = null,
    Object? isMoving = null,
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
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int,
      isMoving: null == isMoving
          ? _value.isMoving
          : isMoving // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$CurtainDeviceImplCopyWith<$Res>
    implements $CurtainDeviceCopyWith<$Res> {
  factory _$$CurtainDeviceImplCopyWith(
          _$CurtainDeviceImpl value, $Res Function(_$CurtainDeviceImpl) then) =
      __$$CurtainDeviceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      int position,
      bool isMoving,
      String deviceId,
      String localKey,
      String address,
      double version});
}

/// @nodoc
class __$$CurtainDeviceImplCopyWithImpl<$Res>
    extends _$CurtainDeviceCopyWithImpl<$Res, _$CurtainDeviceImpl>
    implements _$$CurtainDeviceImplCopyWith<$Res> {
  __$$CurtainDeviceImplCopyWithImpl(
      _$CurtainDeviceImpl _value, $Res Function(_$CurtainDeviceImpl) _then)
      : super(_value, _then);

  /// Create a copy of CurtainDevice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? position = null,
    Object? isMoving = null,
    Object? deviceId = null,
    Object? localKey = null,
    Object? address = null,
    Object? version = null,
  }) {
    return _then(_$CurtainDeviceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int,
      isMoving: null == isMoving
          ? _value.isMoving
          : isMoving // ignore: cast_nullable_to_non_nullable
              as bool,
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
class _$CurtainDeviceImpl implements _CurtainDevice {
  const _$CurtainDeviceImpl(
      {required this.id,
      required this.name,
      required this.position,
      required this.isMoving,
      required this.deviceId,
      required this.localKey,
      required this.address,
      required this.version});

  factory _$CurtainDeviceImpl.fromJson(Map<String, dynamic> json) =>
      _$$CurtainDeviceImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final int position;
// 0-100 (% открытия)
  @override
  final bool isMoving;
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
    return 'CurtainDevice(id: $id, name: $name, position: $position, isMoving: $isMoving, deviceId: $deviceId, localKey: $localKey, address: $address, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CurtainDeviceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.isMoving, isMoving) ||
                other.isMoving == isMoving) &&
            (identical(other.deviceId, deviceId) ||
                other.deviceId == deviceId) &&
            (identical(other.localKey, localKey) ||
                other.localKey == localKey) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.version, version) || other.version == version));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, position, isMoving,
      deviceId, localKey, address, version);

  /// Create a copy of CurtainDevice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CurtainDeviceImplCopyWith<_$CurtainDeviceImpl> get copyWith =>
      __$$CurtainDeviceImplCopyWithImpl<_$CurtainDeviceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CurtainDeviceImplToJson(
      this,
    );
  }
}

abstract class _CurtainDevice implements CurtainDevice {
  const factory _CurtainDevice(
      {required final String id,
      required final String name,
      required final int position,
      required final bool isMoving,
      required final String deviceId,
      required final String localKey,
      required final String address,
      required final double version}) = _$CurtainDeviceImpl;

  factory _CurtainDevice.fromJson(Map<String, dynamic> json) =
      _$CurtainDeviceImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get position; // 0-100 (% открытия)
  @override
  bool get isMoving;
  @override
  String get deviceId;
  @override
  String get localKey;
  @override
  String get address;
  @override
  double get version;

  /// Create a copy of CurtainDevice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CurtainDeviceImplCopyWith<_$CurtainDeviceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
