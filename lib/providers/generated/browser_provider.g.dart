// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../browser_provider.dart';

// **************************************************************************
// Riverpod Generator
// **************************************************************************

// Copied from Dart SDK
class _AutoDisposeNotifierProvider<NotifierT extends NotifierBase<T>, T>
    extends AutoDisposeNotifierProviderImpl<NotifierT, T> {
  // ignore: unused_element
  _AutoDisposeNotifierProvider(super.notifier, super.dependencies);

  @override
  AutoDisposeNotifierProviderElement<NotifierT, T> createElement() {
    return _AutoDisposeNotifierProviderElement(this);
  }
}

class _AutoDisposeNotifierProviderElement<NotifierT extends NotifierBase<T>, T>
    extends AutoDisposeNotifierProviderElement<NotifierT, T> {
  _AutoDisposeNotifierProviderElement(super.provider);

  @override
  NotifierT get notifier => super.notifier;
}

// Copied from Dart SDK
class _AsyncNotifierProvider<NotifierT extends AsyncNotifierBase<T>, T>
    extends AsyncNotifierProviderImpl<NotifierT, T> {
  // ignore: unused_element
  _AsyncNotifierProvider(super.notifier, super.dependencies);

  @override
  AsyncNotifierProviderElement<NotifierT, T> createElement() {
    return _AsyncNotifierProviderElement(this);
  }
}

class _AsyncNotifierProviderElement<NotifierT extends AsyncNotifierBase<T>, T>
    extends AsyncNotifierProviderElement<NotifierT, T> {
  _AsyncNotifierProviderElement(super.provider);

  @override
  NotifierT get notifier => super.notifier;
}

// **************************************************************************
// Riverpod Generator
// **************************************************************************

typedef BrowserTabsNotifierRef = AutoDisposeNotifierProviderRef<BrowserTabsState>;

/// See also [BrowserTabsNotifier].
@$riverpod
_$BrowserTabsNotifierRef watchBrowserTabsNotifier(BrowserTabsNotifierRef ref) {
  throw UnimplementedError();
}

@$riverpod
class BrowserTabsNotifier extends _$BrowserTabsNotifier {
  BrowserTabsNotifierBuilder get _builder => _$BrowserTabsNotifierBuilder(this, ref);

  @override
  BrowserTabsState build() {
    // TODO: implement build
    throw UnimplementedError();
  }

  /// Creates a new browser tab
  String createNewTab({String? url}) {
    // TODO: implement createNewTab
    throw UnimplementedError();
  }

  /// Sets the active tab
  void setActiveTab(String tabId) {
    // TODO: implement setActiveTab
    throw UnimplementedError();
  }

  /// Updates tab properties
  void updateTab(String tabId, {
    String? title,
    String? url,
    BrowserTabStatus? status,
    int? favicon,
  }) {
    // TODO: implement updateTab
    throw UnimplementedError();
  }

  /// Closes a tab
  void closeTab(String tabId) {
    // TODO: implement closeTab
    throw UnimplementedError();
  }

  /// Closes all tabs except the specified one
  void closeOtherTabs(String keepTabId) {
    // TODO: implement closeOtherTabs
    throw UnimplementedError();
  }
}

// **************************************************************************
// Riverpod Generator
// **************************************************************************

typedef DownloadsNotifierRef = AutoDisposeNotifierProviderRef<DownloadsState>;

/// See also [DownloadsNotifier].
@$riverpod
_$DownloadsNotifierRef watchDownloadsNotifier(DownloadsNotifierRef ref) {
  throw UnimplementedError();
}

@$riverpod
class DownloadsNotifier extends _$DownloadsNotifier {
  DownloadsNotifierBuilder get _builder => _$DownloadsNotifierBuilder(this, ref);

  @override
  DownloadsState build() {
    // TODO: implement build
    throw UnimplementedError();
  }

  /// Starts a new download
  String startDownload(String url, {String? fileName}) {
    // TODO: implement startDownload
    throw UnimplementedError();
  }

  /// Pauses a download
  void pauseDownload(String downloadId) {
    // TODO: implement pauseDownload
    throw UnimplementedError();
  }

  /// Resumes a paused download
  void resumeDownload(String downloadId) {
    // TODO: implement resumeDownload
    throw UnimplementedError();
  }

  /// Cancels a download
  void cancelDownload(String downloadId) {
    // TODO: implement cancelDownload
    throw UnimplementedError();
  }

  /// Retries a failed download
  void retryDownload(String downloadId) {
    // TODO: implement retryDownload
    throw UnimplementedError();
  }

  /// Removes a download from the list
  void removeDownload(String downloadId) {
    // TODO: implement removeDownload
    throw UnimplementedError();
  }

  /// Clears completed downloads
  void clearCompleted() {
    // TODO: implement clearCompleted
    throw UnimplementedError();
  }
}

// **************************************************************************
// Riverpod Generator
// **************************************************************************

// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

abstract class _$BrowserTabsNotifierRef
    extends AutoDisposeNotifierProviderRef<BrowserTabsState> {}

abstract class _$BrowserTabsNotifierBuilder {
  _$BrowserTabsNotifierBuilder(this._notifier, this._ref);

  final BrowserTabsNotifier _notifier;
  final _$BrowserTabsNotifierRef _ref;

  /// See also [BrowserTabsNotifier.build]
  BrowserTabsState call() => _notifier.build();

  /// See also [BrowserTabsNotifier.createNewTab]
  String createNewTab({String? url}) => _notifier.createNewTab(url: url);

  /// See also [BrowserTabsNotifier.setActiveTab]
  void setActiveTab(String tabId) => _notifier.setActiveTab(tabId);

  /// See also [BrowserTabsNotifier.updateTab]
  void updateTab(String tabId, {
    String? title,
    String? url,
    BrowserTabStatus? status,
    int? favicon,
  }) => _notifier.updateTab(
    tabId,
    title: title,
    url: url,
    status: status,
    favicon: favicon,
  );

  /// See also [BrowserTabsNotifier.closeTab]
  void closeTab(String tabId) => _notifier.closeTab(tabId);

  /// See also [BrowserTabsNotifier.closeOtherTabs]
  void closeOtherTabs(String keepTabId) => _notifier.closeOtherTabs(keepTabId);
}

abstract class _$DownloadsNotifierRef
    extends AutoDisposeNotifierProviderRef<DownloadsState> {}

abstract class _$DownloadsNotifierBuilder {
  _$DownloadsNotifierBuilder(this._notifier, this._ref);

  final DownloadsNotifier _notifier;
  final _$DownloadsNotifierRef _ref;

  /// See also [DownloadsNotifier.build]
  DownloadsState call() => _notifier.build();

  /// See also [DownloadsNotifier.startDownload]
  String startDownload(String url, {String? fileName}) =>
      _notifier.startDownload(url, fileName: fileName);

  /// See also [DownloadsNotifier.pauseDownload]
  void pauseDownload(String downloadId) => _notifier.pauseDownload(downloadId);

  /// See also [DownloadsNotifier.resumeDownload]
  void resumeDownload(String downloadId) => _notifier.resumeDownload(downloadId);

  /// See also [DownloadsNotifier.cancelDownload]
  void cancelDownload(String downloadId) => _notifier.cancelDownload(downloadId);

  /// See also [DownloadsNotifier.retryDownload]
  void retryDownload(String downloadId) => _notifier.retryDownload(downloadId);

  /// See also [DownloadsNotifier.removeDownload]
  void removeDownload(String downloadId) => _notifier.removeDownload(downloadId);

  /// See also [DownloadsNotifier.clearCompleted]
  void clearCompleted() => _notifier.clearCompleted();
}
