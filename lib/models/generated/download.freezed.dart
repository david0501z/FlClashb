// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'download.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$DownloadItem {
  String get id => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  int get totalBytes => throw _privateConstructorUsedError;
  int get downloadedBytes => throw _privateConstructorUsedError;
  DownloadStatus get status => throw _privateConstructorUsedError;
  DateTime? get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  String? get filePath => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String get mimeType => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DownloadItemCopyWith<DownloadItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadItemCopyWith<$Res> {
  factory $DownloadItemCopyWith(
          DownloadItem value, $Res Function(DownloadItem) then) =
      _$DownloadItemCopyWithImpl<$Res, DownloadItem>;
  @useResult
  $Res call(
      {String id,
      String url,
      String fileName,
      int totalBytes,
      int downloadedBytes,
      DownloadStatus status,
      DateTime? startTime,
      DateTime? endTime,
      String? filePath,
      String? errorMessage,
      String mimeType});
}

/// @nodoc
class _$DownloadItemCopyWithImpl<$Res, $Val extends DownloadItem>
    implements $DownloadItemCopyWith<$Res> {
  _$DownloadItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? fileName = null,
    Object? totalBytes = null,
    Object? downloadedBytes = null,
    Object? status = null,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? filePath = freezed,
    Object? errorMessage = freezed,
    Object? mimeType = null,
  }) {
    return _then(_value.copyWith(
      id: id == null ? _value.id : id // ignore: cast_nullable_to_non_nullable
          as String,
      url: url == null ? _value.url : url // ignore: cast_nullable_to_non_nullable
          as String,
      fileName: fileName == null
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
          as String,
      totalBytes: totalBytes == null
          ? _value.totalBytes
          : totalBytes // ignore: cast_nullable_to_non_nullable
          as int,
      downloadedBytes: downloadedBytes == null
          ? _value.downloadedBytes
          : downloadedBytes // ignore: cast_nullable_to_non_nullable
          as int,
      status: status == null
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
          as DownloadStatus,
      startTime: startTime == freezed
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
          as DateTime?,
      endTime: endTime == freezed
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
          as DateTime?,
      filePath: filePath == freezed
          ? _value.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
          as String?,
      errorMessage: errorMessage == freezed
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
          as String?,
      mimeType: mimeType == null
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
          as String,
    ));
  }
}

/// @nodoc
abstract class _$$DownloadItemImplCopyWith<$Res>
    implements $DownloadItemCopyWith<$Res> {
  factory _$$DownloadItemImplCopyWith(_$DownloadItemImpl value,
          $Res Function(_$DownloadItemImpl) then) =
      __$$DownloadItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String url,
      String fileName,
      int totalBytes,
      int downloadedBytes,
      DownloadStatus status,
      DateTime? startTime,
      DateTime? endTime,
      String? filePath,
      String? errorMessage,
      String mimeType});
}

/// @nodoc
class __$$DownloadItemImplCopyWithImpl<$Res>
    extends _$DownloadItemCopyWithImpl<$Res, _$DownloadItemImpl>
    implements _$$DownloadItemImplCopyWith<$Res> {
  __$$DownloadItemImplCopyWithImpl(_$DownloadItemImpl _value,
      $Res Function(_$DownloadItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? fileName = null,
    Object? totalBytes = null,
    Object? downloadedBytes = null,
    Object? status = null,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? filePath = freezed,
    Object? errorMessage = freezed,
    Object? mimeType = null,
  }) {
    return _then(_$$DownloadItemImpl(
      id: id == null ? _value.id : id // ignore: cast_nullable_to_non_nullable
          as String,
      url: url == null ? _value.url : url // ignore: cast_nullable_to_non_nullable
          as String,
      fileName: fileName == null
          ? _value.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
          as String,
      totalBytes: totalBytes == null
          ? _value.totalBytes
          : totalBytes // ignore: cast_nullable_to_non_nullable
          as int,
      downloadedBytes: downloadedBytes == null
          ? _value.downloadedBytes
          : downloadedBytes // ignore: cast_nullable_to_non_nullable
          as int,
      status: status == null
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
          as DownloadStatus,
      startTime: startTime == freezed
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
          as DateTime?,
      endTime: endTime == freezed
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
          as DateTime?,
      filePath: filePath == freezed
          ? _value.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
          as String?,
      errorMessage: errorMessage == freezed
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
          as String?,
      mimeType: mimeType == null
          ? _value.mimeType
          : mimeType // ignore: cast_nullable_to_non_nullable
          as String,
    ));
  }
}

/// @nodoc

class _$DownloadItemImpl implements _DownloadItem {
  const _$DownloadItemImpl(
      {required this.id,
      required this.url,
      required this.fileName,
      required this.totalBytes,
      required this.downloadedBytes,
      required this.status,
      this.startTime,
      this.endTime,
      this.filePath,
      this.errorMessage,
      required this.mimeType});

  @override
  final String id;
  @override
  final String url;
  @override
  final String fileName;
  @override
  final int totalBytes;
  @override
  final int downloadedBytes;
  @override
  final DownloadStatus status;
  @override
  final DateTime? startTime;
  @override
  final DateTime? endTime;
  @override
  final String? filePath;
  @override
  final String? errorMessage;
  @override
  final String mimeType;

  @override
  String toString() {
    return 'DownloadItem(id: $id, url: $url, fileName: $fileName, totalBytes: $totalBytes, downloadedBytes: $downloadedBytes, status: $status, startTime: $startTime, endTime: $endTime, filePath: $filePath, errorMessage: $errorMessage, mimeType: $mimeType)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadItemImpl &&
            (identical(other.id, id) ||
                other.id == id) &&
            (identical(other.url, url) ||
                other.url == url) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.totalBytes, totalBytes) ||
                other.totalBytes == totalBytes) &&
            (identical(other.downloadedBytes, downloadedBytes) ||
                other.downloadedBytes == downloadedBytes) &&
            (identical(other.status, status) ||
                other.status == status) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) ||
                other.endTime == endTime) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType));
  }

  @override
  int get hashCode => Object.hash(
      id,
      url,
      fileName,
      totalBytes,
      downloadedBytes,
      status,
      startTime,
      endTime,
      filePath,
      errorMessage,
      mimeType);

  @JsonKey(ignore: true)
  @override
  $DownloadItemCopyWith<DownloadItem> get copyWith =>
      _$DownloadItemCopyWithImpl(this, _$identity);
}

abstract class _DownloadItem implements DownloadItem {
  const factory _DownloadItem(
      {required final String id,
      required final String url,
      required final String fileName,
      required final int totalBytes,
      required final int downloadedBytes,
      required final DownloadStatus status,
      final DateTime? startTime,
      final DateTime? endTime,
      final String? filePath,
      final String? errorMessage,
      required final String mimeType}) = _$DownloadItemImpl;

  @override
  String get id => throw _privateConstructorUsedError;
  @override
  String get url => throw _privateConstructorUsedError;
  @override
  String get fileName => throw _privateConstructorUsedError;
  @override
  int get totalBytes => throw _privateConstructorUsedError;
  @override
  int get downloadedBytes => throw _privateConstructorUsedError;
  @override
  DownloadStatus get status => throw _privateConstructorUsedError;
  @override
  DateTime? get startTime => throw _privateConstructorUsedError;
  @override
  DateTime? get endTime => throw _privateConstructorUsedError;
  @override
  String? get filePath => throw _privateConstructorUsedError;
  @override
  String? get errorMessage => throw _privateConstructorUsedError;
  @override
  String get mimeType => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  $DownloadItemCopyWith<DownloadItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DownloadsState {
  List<DownloadItem> get downloads => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DownloadsStateCopyWith<DownloadsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadsStateCopyWith<$Res> {
  factory $DownloadsStateCopyWith(
          DownloadsState value, $Res Function(DownloadsState) then) =
      _$DownloadsStateCopyWithImpl<$Res, DownloadsState>;
  @useResult
  $Res call(
      {List<DownloadItem> downloads,
      bool isLoading,
      String? error});
}

/// @nodoc
class _$DownloadsStateCopyWithImpl<$Res, $Val extends DownloadsState>
    implements $DownloadsStateCopyWith<$Res> {
  _$DownloadsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? downloads = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      downloads: downloads == null
          ? _value.downloads
          : downloads // ignore: cast_nullable_to_non_nullable
          as List<DownloadItem>,
      isLoading: isLoading == null
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
          as bool,
      error: error == freezed
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
          as String?,
    ));
  }
}

/// @nodoc
abstract class _$$DownloadsStateImplCopyWith<$Res>
    implements $DownloadsStateCopyWith<$Res> {
  factory _$$DownloadsStateImplCopyWith(_$DownloadsStateImpl value,
          $Res Function(_$DownloadsStateImpl) then) =
      __$$DownloadsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<DownloadItem> downloads, bool isLoading, String? error});
}

/// @nodoc
class __$$DownloadsStateImplCopyWithImpl<$Res>
    extends _$DownloadsStateCopyWithImpl<$Res, _$DownloadsStateImpl>
    implements _$$DownloadsStateImplCopyWith<$Res> {
  __$$DownloadsStateImplCopyWithImpl(_$DownloadsStateImpl _value,
      $Res Function(_$DownloadsStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? downloads = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$$DownloadsStateImpl(
      downloads: downloads == null
          ? _value.downloads
          : downloads // ignore: cast_nullable_to_non_nullable
          as List<DownloadItem>,
      isLoading: isLoading == null
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
          as bool,
      error: error == freezed
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
          as String?,
    ));
  }
}

/// @nodoc

class _$DownloadsStateImpl implements _DownloadsState {
  const _$DownloadsStateImpl(
      {required this.downloads,
      required this.isLoading,
      this.error});

  @override
  final List<DownloadItem> downloads;
  @override
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'DownloadsState(downloads: $downloads, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadsStateImpl &&
            (identical(other.downloads, downloads) ||
                other.downloads == downloads) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode =>
      Object.hash(downloads, isLoading, error);

  @JsonKey(ignore: true)
  @override
  $DownloadsStateCopyWith<DownloadsState> get copyWith =>
      _$DownloadsStateCopyWithImpl(this, _$identity);
}

abstract class _DownloadsState implements DownloadsState {
  const factory _DownloadsState(
      {required final List<DownloadItem> downloads,
      required final bool isLoading,
      final String? error}) = _$DownloadsStateImpl;

  @override
  List<DownloadItem> get downloads => throw _privateConstructorUsedError;
  @override
  bool get isLoading => throw _privateConstructorUsedError;
  @override
  String? get error => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  $DownloadsStateCopyWith<DownloadsState> get copyWith =>
      throw _privateConstructorUsedError;
}
