import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/browser_tab.freezed.dart';
part 'generated/browser_tab.g.dart';

@freezed
abstract class BrowserTab with _$BrowserTab {
  const factory BrowserTab({
    required String id,
    required String title,
    required String url,
    @Default(BrowserTabStatus.loading) BrowserTabStatus status,
    int? favicon,
    DateTime? lastAccessed,
    @Default(false) bool isSelected,
  }) = _BrowserTab;

  factory BrowserTab.fromJson(Map<String, Object?> json) =>
      _$BrowserTabFromJson(json);

  const BrowserTab._();

  String get displayName {
    if (title.isNotEmpty) return title;
    if (url.isEmpty) return '新标签页';
    try {
      final uri = Uri.parse(url);
      return uri.host.isNotEmpty ? uri.host : url;
    } catch (e) {
      return url;
    }
  }

  BrowserTab copyWithSelected(bool selected) {
    return copyWith(isSelected: selected, lastAccessed: DateTime.now());
  }
}

enum BrowserTabStatus {
  loading,
  loaded,
  error,
}

@freezed
abstract class BrowserTabsState with _$BrowserTabsState {
  const factory BrowserTabsState({
    @Default([]) List<BrowserTab> tabs,
    String? activeTabId,
    @Default(false) bool isLoading,
    String? error,
  }) = _BrowserTabsState;

  factory BrowserTabsState.fromJson(Map<String, Object?> json) =>
      _$BrowserTabsStateFromJson(json);

  const BrowserTabsState._();

  BrowserTab? get activeTab {
    if (activeTabId == null) return null;
    try {
      return tabs.firstWhere((tab) => tab.id == activeTabId);
    } catch (e) {
      return null;
    }
  }

  List<BrowserTab> get recentTabs {
    final sorted = List<BrowserTab>.from(tabs);
    sorted.sort((a, b) {
      if (a.lastAccessed == null && b.lastAccessed == null) return 0;
      if (a.lastAccessed == null) return 1;
      if (b.lastAccessed == null) return -1;
      return b.lastAccessed!.compareTo(a.lastAccessed!);
    });
    return sorted;
  }

  BrowserTab? getTabById(String id) {
    try {
      return tabs.firstWhere((tab) => tab.id == id);
    } catch (e) {
      return null;
    }
  }

  int getTabIndex(String id) {
    return tabs.indexWhere((tab) => tab.id == id);
  }
}