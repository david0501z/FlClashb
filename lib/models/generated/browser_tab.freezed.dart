// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'browser_tab.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$BrowserTab {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  BrowserTabStatus get status => throw _privateConstructorUsedError;
  int? get favicon => throw _privateConstructorUsedError;
  DateTime? get lastAccessed => throw _privateConstructorUsedError;
  bool get isSelected => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BrowserTabCopyWith<BrowserTab> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BrowserTabCopyWith<$Res> {
  factory $BrowserTabCopyWith(
          BrowserTab value, $Res Function(BrowserTab) then) =
      _$BrowserTabCopyWithImpl<$Res, BrowserTab>;
  @useResult
  $Res call(
      {String id,
      String title,
      String url,
      BrowserTabStatus status,
      int? favicon,
      DateTime? lastAccessed,
      bool isSelected});
}

/// @nodoc
class _$BrowserTabCopyWithImpl<$Res, $Val extends BrowserTab>
    implements $BrowserTabCopyWith<$Res> {
  _$BrowserTabCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? url = null,
    Object? status = null,
    Object? favicon = freezed,
    Object? lastAccessed = freezed,
    Object? isSelected = null,
  }) {
    return _then(_value.copyWith(
      id: id == null ? _value.id : id // ignore: cast_nullable_to_non_nullable
          as String,
      title: title == null ? _value.title : title // ignore: cast_nullable_to_non_nullable
          as String,
      url: url == null ? _value.url : url // ignore: cast_nullable_to_non_nullable
          as String,
      status: status == null
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
          as BrowserTabStatus,
      favicon: favicon == freezed
          ? _value.favicon
          : favicon // ignore: cast_nullable_to_non_nullable
          as int?,
      lastAccessed: lastAccessed == freezed
          ? _value.lastAccessed
          : lastAccessed // ignore: cast_nullable_to_non_nullable
          as DateTime?,
      isSelected: isSelected == null
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
          as bool,
    ));
  }
}

/// @nodoc
abstract class _$$BrowserTabImplCopyWith<$Res>
    implements $BrowserTabCopyWith<$Res> {
  factory _$$BrowserTabImplCopyWith(_$BrowserTabImpl value,
          $Res Function(_$BrowserTabImpl) then) =
      __$$BrowserTabImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String url,
      BrowserTabStatus status,
      int? favicon,
      DateTime? lastAccessed,
      bool isSelected});
}

/// @nodoc
class __$$BrowserTabImplCopyWithImpl<$Res>
    extends _$BrowserTabCopyWithImpl<$Res, _$BrowserTabImpl>
    implements _$$BrowserTabImplCopyWith<$Res> {
  __$$BrowserTabImplCopyWithImpl(_$BrowserTabImpl _value,
      $Res Function(_$BrowserTabImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? url = null,
    Object? status = null,
    Object? favicon = freezed,
    Object? lastAccessed = freezed,
    Object? isSelected = null,
  }) {
    return _then(_$$BrowserTabImpl(
      id: id == null ? _value.id : id // ignore: cast_nullable_to_non_nullable
          as String,
      title: title == null ? _value.title : title // ignore: cast_nullable_to_non_nullable
          as String,
      url: url == null ? _value.url : url // ignore: cast_nullable_to_non_nullable
          as String,
      status: status == null
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
          as BrowserTabStatus,
      favicon: favicon == freezed
          ? _value.favicon
          : favicon // ignore: cast_nullable_to_non_nullable
          as int?,
      lastAccessed: lastAccessed == freezed
          ? _value.lastAccessed
          : lastAccessed // ignore: cast_nullable_to_non_nullable
          as DateTime?,
      isSelected: isSelected == null
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
          as bool,
    ));
  }
}

/// @nodoc

class _$BrowserTabImpl implements _BrowserTab {
  const _$BrowserTabImpl(
      {required this.id,
      required this.title,
      required this.url,
      required this.status,
      this.favicon,
      this.lastAccessed,
      required this.isSelected});

  @override
  final String id;
  @override
  final String title;
  @override
  final String url;
  @override
  final BrowserTabStatus status;
  @override
  final int? favicon;
  @override
  final DateTime? lastAccessed;
  @override
  final bool isSelected;

  @override
  String toString() {
    return 'BrowserTab(id: $id, title: $title, url: $url, status: $status, favicon: $favicon, lastAccessed: $lastAccessed, isSelected: $isSelected)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BrowserTabImpl &&
            (identical(other.id, id) ||
                other.id == id) &&
            (identical(other.title, title) ||
                other.title == title) &&
            (identical(other.url, url) ||
                other.url == url) &&
            (identical(other.status, status) ||
                other.status == status) &&
            (identical(other.favicon, favicon) ||
                other.favicon == favicon) &&
            (identical(other.lastAccessed, lastAccessed) ||
                other.lastAccessed == lastAccessed) &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected));
  }

  @override
  int get hashCode => Object.hash(
      id, title, url, status, favicon, lastAccessed, isSelected);

  @JsonKey(ignore: true)
  @override
  $BrowserTabCopyWith<BrowserTab> get copyWith =>
      _$BrowserTabCopyWithImpl(this, _$identity);
}

abstract class _BrowserTab implements BrowserTab {
  const factory _BrowserTab(
      {required final String id,
      required final String title,
      required final String url,
      required final BrowserTabStatus status,
      final int? favicon,
      final DateTime? lastAccessed,
      required final bool isSelected}) = _$BrowserTabImpl;

  @override
  String get id => throw _privateConstructorUsedError;
  @override
  String get title => throw _privateConstructorUsedError;
  @override
  String get url => throw _privateConstructorUsedError;
  @override
  BrowserTabStatus get status => throw _privateConstructorUsedError;
  @override
  int? get favicon => throw _privateConstructorUsedError;
  @override
  DateTime? get lastAccessed => throw _privateConstructorUsedError;
  @override
  bool get isSelected => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  $BrowserTabCopyWith<BrowserTab> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$BrowserTabsState {
  List<BrowserTab> get tabs => throw _privateConstructorUsedError;
  String? get activeTabId => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BrowserTabsStateCopyWith<BrowserTabsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BrowserTabsStateCopyWith<$Res> {
  factory $BrowserTabsStateCopyWith(
          BrowserTabsState value, $Res Function(BrowserTabsState) then) =
      _$BrowserTabsStateCopyWithImpl<$Res, BrowserTabsState>;
  @useResult
  $Res call(
      {List<BrowserTab> tabs,
      String? activeTabId,
      bool isLoading,
      String? error});
}

/// @nodoc
class _$BrowserTabsStateCopyWithImpl<$Res, $Val extends BrowserTabsState>
    implements $BrowserTabsStateCopyWith<$Res> {
  _$BrowserTabsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tabs = null,
    Object? activeTabId = freezed,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      tabs: tabs == null
          ? _value.tabs
          : tabs // ignore: cast_nullable_to_non_nullable
          as List<BrowserTab>,
      activeTabId: activeTabId == freezed
          ? _value.activeTabId
          : activeTabId // ignore: cast_nullable_to_non_nullable
          as String?,
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
abstract class _$$BrowserTabsStateImplCopyWith<$Res>
    implements $BrowserTabsStateCopyWith<$Res> {
  factory _$$BrowserTabsStateImplCopyWith(_$BrowserTabsStateImpl value,
          $Res Function(_$BrowserTabsStateImpl) then) =
      __$$BrowserTabsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<BrowserTab> tabs,
      String? activeTabId,
      bool isLoading,
      String? error});
}

/// @nodoc
class __$$BrowserTabsStateImplCopyWithImpl<$Res>
    extends _$BrowserTabsStateCopyWithImpl<$Res, _$BrowserTabsStateImpl>
    implements _$$BrowserTabsStateImplCopyWith<$Res> {
  __$$BrowserTabsStateImplCopyWithImpl(_$BrowserTabsStateImpl _value,
      $Res Function(_$BrowserTabsStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tabs = null,
    Object? activeTabId = freezed,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$$BrowserTabsStateImpl(
      tabs: tabs == null
          ? _value.tabs
          : tabs // ignore: cast_nullable_to_non_nullable
          as List<BrowserTab>,
      activeTabId: activeTabId == freezed
          ? _value.activeTabId
          : activeTabId // ignore: cast_nullable_to_non_nullable
          as String?,
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

class _$BrowserTabsStateImpl implements _BrowserTabsState {
  const _$BrowserTabsStateImpl(
      {required this.tabs,
      this.activeTabId,
      required this.isLoading,
      this.error});

  @override
  final List<BrowserTab> tabs;
  @override
  final String? activeTabId;
  @override
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'BrowserTabsState(tabs: $tabs, activeTabId: $activeTabId, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BrowserTabsStateImpl &&
            (identical(other.tabs, tabs) ||
                other.tabs == tabs) &&
            (identical(other.activeTabId, activeTabId) ||
                other.activeTabId == activeTabId) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode =>
      Object.hash(tabs, activeTabId, isLoading, error);

  @JsonKey(ignore: true)
  @override
  $BrowserTabsStateCopyWith<BrowserTabsState> get copyWith =>
      _$BrowserTabsStateCopyWithImpl(this, _$identity);
}

abstract class _BrowserTabsState implements BrowserTabsState {
  const factory _BrowserTabsState(
      {required final List<BrowserTab> tabs,
      final String? activeTabId,
      required final bool isLoading,
      final String? error}) = _$BrowserTabsStateImpl;

  @override
  List<BrowserTab> get tabs => throw _privateConstructorUsedError;
  @override
  String? get activeTabId => throw _privateConstructorUsedError;
  @override
  bool get isLoading => throw _privateConstructorUsedError;
  @override
  String? get error => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  $BrowserTabsStateCopyWith<BrowserTabsState> get copyWith =>
      throw _privateConstructorUsedError;
}
