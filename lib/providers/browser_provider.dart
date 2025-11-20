import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fl_clash/models/download.dart';
import 'package:fl_clash/models/browser_tab.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'dart:io';

part 'generated/browser_provider.g.dart';

@riverpod
class BrowserTabsNotifier extends _$BrowserTabsNotifier {
  final Uuid _uuid = const Uuid();

  @override
  BrowserTabsState build() {
    return const BrowserTabsState();
  }

  String createNewTab({String? url}) {
    final tabId = _uuid.v4();
    final newTab = BrowserTab(
      id: tabId,
      title: url != null ? '' : '新标签页',
      url: url ?? 'about:blank',
      lastAccessed: DateTime.now(),
      isSelected: true,
    );

    // 取消其他标签的选中状态
    final updatedTabs = state.tabs.map((tab) => tab.copyWith(isSelected: false)).toList();
    updatedTabs.add(newTab);

    state = state.copyWith(
      tabs: updatedTabs,
      activeTabId: tabId,
    );

    return tabId;
  }

  void setActiveTab(String tabId) {
    final tabIndex = state.getTabIndex(tabId);
    if (tabIndex == -1) return;

    final updatedTabs = <BrowserTab>[];
    for (int i = 0; i < state.tabs.length; i++) {
      final tab = state.tabs[i];
      if (i == tabIndex) {
        updatedTabs.add(tab.copyWith(isSelected: true, lastAccessed: DateTime.now()));
      } else {
        updatedTabs.add(tab.copyWith(isSelected: false));
      }
    }

    state = state.copyWith(
      tabs: updatedTabs,
      activeTabId: tabId,
    );
  }

  void updateTab(String tabId, {
    String? title,
    String? url,
    BrowserTabStatus? status,
    int? favicon,
  }) {
    final tabIndex = state.getTabIndex(tabId);
    if (tabIndex == -1) return;

    final updatedTab = state.tabs[tabIndex].copyWith(
      title: title,
      url: url,
      status: status,
      favicon: favicon,
      lastAccessed: DateTime.now(),
    );

    final updatedTabs = List<BrowserTab>.from(state.tabs);
    updatedTabs[tabIndex] = updatedTab;

    state = state.copyWith(tabs: updatedTabs);
  }

  void closeTab(String tabId) {
    if (state.tabs.length <= 1) return; // 至少保留一个标签

    final tabIndex = state.getTabIndex(tabId);
    if (tabIndex == -1) return;

    final updatedTabs = List<BrowserTab>.from(state.tabs)..removeAt(tabIndex);
    
    // 如果关闭的是当前活动标签，切换到相邻标签
    String? newActiveTabId = state.activeTabId;
    if (state.activeTabId == tabId) {
      if (updatedTabs.isNotEmpty) {
        final newIndex = tabIndex > 0 ? tabIndex - 1 : 0;
        newActiveTabId = updatedTabs[newIndex].id;
        updatedTabs[newIndex] = updatedTabs[newIndex].copyWith(isSelected: true);
      }
    }

    state = state.copyWith(
      tabs: updatedTabs,
      activeTabId: newActiveTabId,
    );
  }

  void closeOtherTabs(String keepTabId) {
    final updatedTabs = state.tabs.where((tab) => tab.id == keepTabId).toList();
    if (updatedTabs.isNotEmpty) {
      updatedTabs[0] = updatedTabs[0].copyWith(isSelected: true);
    }

    state = state.copyWith(
      tabs: updatedTabs,
      activeTabId: keepTabId,
    );
  }
}

@riverpod
class DownloadsNotifier extends _$DownloadsNotifier {
  final Uuid _uuid = const Uuid();
  final Map<String, StreamSubscription<int>> _subscriptions = {};

  @override
  DownloadsState build() {
    return const DownloadsState();
  }

  String startDownload(String url, {String? fileName}) {
    final downloadId = _uuid.v4();
    final downloadItem = DownloadItem(
      id: downloadId,
      url: url,
      fileName: fileName ?? _extractFileNameFromUrl(url),
      totalBytes: 0,
      downloadedBytes: 0,
      status: DownloadStatus.pending,
      startTime: DateTime.now(),
    );

    final updatedDownloads = List<DownloadItem>.from(state.downloads);
    updatedDownloads.insert(0, downloadItem);

    state = state.copyWith(downloads: updatedDownloads);

    // 开始异步下载
    _performDownload(downloadId);

    return downloadId;
  }

  void pauseDownload(String downloadId) {
    _updateDownloadStatus(downloadId, DownloadStatus.paused);
    _subscriptions[downloadId]?.pause();
  }

  void resumeDownload(String downloadId) {
    _updateDownloadStatus(downloadId, DownloadStatus.downloading);
    _performDownload(downloadId);
  }

  void cancelDownload(String downloadId) {
    _updateDownloadStatus(downloadId, DownloadStatus.cancelled);
    _subscriptions[downloadId]?.cancel();
    _subscriptions.remove(downloadId);
  }

  void retryDownload(String downloadId) {
    final download = state.getDownloadById(downloadId);
    if (download != null) {
      _performDownload(downloadId);
    }
  }

  void removeDownload(String downloadId) {
    _subscriptions[downloadId]?.cancel();
    _subscriptions.remove(downloadId);
    
    final updatedDownloads = state.downloads.where((d) => d.id != downloadId).toList();
    state = state.copyWith(downloads: updatedDownloads);
  }

  void clearCompleted() {
    final updatedDownloads = state.downloads.where((d) => d.status != DownloadStatus.completed).toList();
    state = state.copyWith(downloads: updatedDownloads);
  }

  void _updateDownloadStatus(String downloadId, DownloadStatus status) {
    final downloadIndex = state.downloads.indexWhere((d) => d.id == downloadId);
    if (downloadIndex == -1) return;

    final updatedDownload = state.downloads[downloadIndex].copyWith(status: status);
    final updatedDownloads = List<DownloadItem>.from(state.downloads);
    updatedDownloads[downloadIndex] = updatedDownload;

    state = state.copyWith(downloads: updatedDownloads);
  }

  void _updateDownloadProgress(String downloadId, int downloadedBytes, int totalBytes) {
    final downloadIndex = state.downloads.indexWhere((d) => d.id == downloadId);
    if (downloadIndex == -1) return;

    final updatedDownload = state.downloads[downloadIndex].copyWith(
      downloadedBytes: downloadedBytes,
      totalBytes: totalBytes,
      status: DownloadStatus.downloading,
    );
    final updatedDownloads = List<DownloadItem>.from(state.downloads);
    updatedDownloads[downloadIndex] = updatedDownload;

    state = state.copyWith(downloads: updatedDownloads);
  }

  void _completeDownload(String downloadId, String filePath) {
    final downloadIndex = state.downloads.indexWhere((d) => d.id == downloadId);
    if (downloadIndex == -1) return;

    final updatedDownload = state.downloads[downloadIndex].copyWith(
      status: DownloadStatus.completed,
      downloadedBytes: state.downloads[downloadIndex].totalBytes,
      endTime: DateTime.now(),
      filePath: filePath,
    );
    final updatedDownloads = List<DownloadItem>.from(state.downloads);
    updatedDownloads[downloadIndex] = updatedDownload;

    state = state.copyWith(downloads: updatedDownloads);
    _subscriptions.remove(downloadId);
  }

  void _failDownload(String downloadId, String errorMessage) {
    final downloadIndex = state.downloads.indexWhere((d) => d.id == downloadId);
    if (downloadIndex == -1) return;

    final updatedDownload = state.downloads[downloadIndex].copyWith(
      status: DownloadStatus.failed,
      endTime: DateTime.now(),
      errorMessage: errorMessage,
    );
    final updatedDownloads = List<DownloadItem>.from(state.downloads);
    updatedDownloads[downloadIndex] = updatedDownload;

    state = state.copyWith(downloads: updatedDownloads);
    _subscriptions.remove(downloadId);
  }

  Future<void> _performDownload(String downloadId) async {
    try {
      final download = state.getDownloadById(downloadId);
      if (download == null) return;

      _updateDownloadStatus(downloadId, DownloadStatus.downloading);

      // 这里应该实现实际的下载逻辑
      // 由于 Flutter webview_flutter 的限制，这里只是一个模拟实现
      // 在实际应用中，你需要使用 http 包或其他下载库
      
      // 模拟下载进度
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(Duration(milliseconds: 200));
        final simulatedBytes = (i * 1024 * 1024); // 模拟 MB
        _updateDownloadProgress(downloadId, simulatedBytes, 100 * 1024 * 1024);
      }

      // 模拟下载完成
      final downloadDir = Directory('/tmp/downloads');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }
      
      final filePath = '${downloadDir.path}/${download.fileName}';
      _completeDownload(downloadId, filePath);
      
    } catch (e) {
      _failDownload(downloadId, e.toString());
    }
  }

  String _extractFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        return segments.last;
      }
      return 'download_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      return 'download_${DateTime.now().millisecondsSinceEpoch}';
    }
  }
}
