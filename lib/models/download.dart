import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/download.freezed.dart';
part 'generated/download.g.dart';

@freezed
abstract class DownloadItem with _$DownloadItem {
  const factory DownloadItem({
    required String id,
    required String url,
    required String fileName,
    required int totalBytes,
    @Default(0) int downloadedBytes,
    @Default(DownloadStatus.pending) DownloadStatus status,
    DateTime? startTime,
    DateTime? endTime,
    String? filePath,
    String? errorMessage,
    @Default('') String mimeType,
  }) = _DownloadItem;

  factory DownloadItem.fromJson(Map<String, Object?> json) =>
      _$DownloadItemFromJson(json);

  const DownloadItem._();

  double get progress {
    if (totalBytes == 0) return 0.0;
    return downloadedBytes / totalBytes;
  }

  String get progressText {
    if (totalBytes == 0) return '0 B';
    final downloaded = _formatBytes(downloadedBytes);
    final total = _formatBytes(totalBytes);
    return '$downloaded / $total';
  }

  String get statusText {
    switch (status) {
      case DownloadStatus.pending:
        return '等待中';
      case DownloadStatus.downloading:
        return '下载中';
      case DownloadStatus.completed:
        return '已完成';
      case DownloadStatus.failed:
        return '失败';
      case DownloadStatus.paused:
        return '已暂停';
      case DownloadStatus.cancelled:
        return '已取消';
    }
  }

  Duration? get duration {
    if (startTime == null) return null;
    final end = endTime ?? DateTime.now();
    return end.difference(startTime!);
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

enum DownloadStatus {
  pending,
  downloading,
  completed,
  failed,
  paused,
  cancelled,
}

@freezed
abstract class DownloadsState with _$DownloadsState {
  const factory DownloadsState({
    @Default([]) List<DownloadItem> downloads,
    @Default(false) bool isLoading,
    String? error,
  }) = _DownloadsState;

  factory DownloadsState.fromJson(Map<String, Object?> json) =>
      _$DownloadsStateFromJson(json);

  const DownloadsState._();

  List<DownloadItem> get activeDownloads =>
      downloads.where((d) => d.status == DownloadStatus.downloading).toList();

  List<DownloadItem> get completedDownloads =>
      downloads.where((d) => d.status == DownloadStatus.completed).toList();

  List<DownloadItem> get failedDownloads =>
      downloads.where((d) => d.status == DownloadStatus.failed).toList();

  DownloadItem? getDownloadById(String id) {
    try {
      return downloads.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }
}