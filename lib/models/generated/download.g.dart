// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download.dart';

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

DownloadItem _$DownloadItemFromJson(Map<String, dynamic> json) =>
    DownloadItem(
      id: json['id'] as String,
      url: json['url'] as String,
      fileName: json['fileName'] as String,
      totalBytes: json['totalBytes'] as int,
      downloadedBytes: json['downloadedBytes'] as int,
      status: $enumDecode(_$DownloadStatusEnumMap, json['status']),
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      filePath: json['filePath'] as String?,
      errorMessage: json['errorMessage'] as String?,
      mimeType: json['mimeType'] as String? ?? '',
    );

Map<String, dynamic> _$DownloadItemToJson(DownloadItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'fileName': instance.fileName,
      'totalBytes': instance.totalBytes,
      'downloadedBytes': instance.downloadedBytes,
      'status': _$DownloadStatusEnumMap[instance.status]!,
      'startTime': instance.startTime?.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'filePath': instance.filePath,
      'errorMessage': instance.errorMessage,
      'mimeType': instance.mimeType,
    };

const _$DownloadStatusEnumMap = {
  DownloadStatus.pending: 'pending',
  DownloadStatus.downloading: 'downloading',
  DownloadStatus.completed: 'completed',
  DownloadStatus.failed: 'failed',
  DownloadStatus.paused: 'paused',
  DownloadStatus.cancelled: 'cancelled',
};

DownloadsState _$DownloadsStateFromJson(Map<String, dynamic> json) =>
    DownloadsState(
      downloads: (json['downloads'] as List<dynamic>)
          .map((e) => DownloadItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      isLoading: json['isLoading'] as bool? ?? false,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$DownloadsStateToJson(DownloadsState instance) =>
    <String, dynamic>{
      'downloads': instance.downloads,
      'isLoading': instance.isLoading,
      'error': instance.error,
    };
