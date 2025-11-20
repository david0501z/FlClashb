// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browser_tab.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

T $enumDecode<T>(
  Map<T, Object> enumValues,
  Object? source, {
  T? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

BrowserTab _$BrowserTabFromJson(Map<String, dynamic> json) => BrowserTab(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      status: $enumDecode(_$BrowserTabStatusEnumMap, json['status']),
      favicon: json['favicon'] as int?,
      lastAccessed: json['lastAccessed'] == null
          ? null
          : DateTime.parse(json['lastAccessed'] as String),
      isSelected: json['isSelected'] as bool? ?? false,
    );

Map<String, dynamic> _$BrowserTabToJson(BrowserTab instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
      'status': _$BrowserTabStatusEnumMap[instance.status]!,
      'favicon': instance.favicon,
      'lastAccessed': instance.lastAccessed?.toIso8601String(),
      'isSelected': instance.isSelected,
    };

const _$BrowserTabStatusEnumMap = {
  BrowserTabStatus.loading: 'loading',
  BrowserTabStatus.loaded: 'loaded',
  BrowserTabStatus.error: 'error',
};

BrowserTabsState _$BrowserTabsStateFromJson(Map<String, dynamic> json) =>
    BrowserTabsState(
      tabs: (json['tabs'] as List<dynamic>)
          .map((e) => BrowserTab.fromJson(e as Map<String, dynamic>))
          .toList(),
      activeTabId: json['activeTabId'] as String?,
      isLoading: json['isLoading'] as bool? ?? false,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$BrowserTabsStateToJson(BrowserTabsState instance) =>
    <String, dynamic>{
      'tabs': instance.tabs,
      'activeTabId': instance.activeTabId,
      'isLoading': instance.isLoading,
      'error': instance.error,
    };
