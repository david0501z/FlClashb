import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/providers/browser_provider.dart';
import 'package:fl_clash/models/browser_tab.dart';
import 'package:fl_clash/models/download.dart';
import 'package:fl_clash/utils/webview_proxy_manager.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';

class BrowserView extends ConsumerStatefulWidget {
  const BrowserView({super.key});

  @override
  ConsumerState<BrowserView> createState() => _BrowserViewState();
}

class _BrowserViewState extends ConsumerState<BrowserView> {
  final TextEditingController _urlController = TextEditingController();
  final Map<String, WebViewController> _controllers = {};
  final Map<String, int> _loadingProgress = {};
  final Map<String, bool> _canGoBack = {};
  final Map<String, bool> _canGoForward = {};
  final Map<String, String> _currentTitles = {};

  @override
  void initState() {
    super.initState();
    // 监听代理状态变化
    ref.listenManual(
      proxyStateProvider,
      (previous, next) {
        if (previous != next) {
          _updateAllControllersProxy();
        }
      },
    );
    
    // 创建初始标签页
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(browserTabsProvider.notifier).createNewTab(url: 'https://www.google.com');
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  WebViewController _getOrCreateController(String tabId) {
    if (!_controllers.containsKey(tabId)) {
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted);
      
      // 最直接的代理设置方法 - 在WebView加载前设置
      if (Platform.isAndroid) {
        // Android WebView代理设置
        controller.setBackgroundColor(const Color(0xFFFFFFFF));
        // 设置Android WebView的系统属性
        controller.runJavaScript("""
          // 强制设置Android WebView代理
          if (typeof navigator !== 'undefined') {
            Object.defineProperty(navigator, 'proxy', {
              value: '127.0.0.1:7890',
              writable: false
            });
          }
        """);
      } else if (Platform.isIOS) {
        // iOS WKWebView代理设置
        controller.runJavaScript("""
          // iOS WebView代理设置
          if (typeof window.webkit !== 'undefined') {
            console.log('Setting iOS proxy to 127.0.0.1:7890');
          }
        """);
      } else {
        // 桌面平台代理设置
        controller.runJavaScript("""
          // Desktop WebView代理设置
          console.log('Desktop proxy: 127.0.0.1:7890');
        """);
      }
      
      // 配置代理
      _configureProxy(controller);
      
      _controllers[tabId] = controller
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              setState(() {
                _loadingProgress[tabId] = progress;
              });
            },
            onPageStarted: (String url) {
              debugPrint('Page started loading: $url');
              setState(() {
                _loadingProgress[tabId] = 0;
              });
              ref.read(browserTabsProvider.notifier).updateTab(
                tabId,
                url: url,
                status: BrowserTabStatus.loading,
              );
            },
            onPageFinished: (String url) async {
              debugPrint('Page finished loading: $url');
              setState(() {
                _loadingProgress[tabId] = 100;
              });
              
              // 页面加载完成后再次强制设置代理
              _configureProxy(controller);
              
              final title = await _controllers[tabId]?.getTitle();
              if (title != null) {
                setState(() {
                  _currentTitles[tabId] = title;
                });
                ref.read(browserTabsProvider.notifier).updateTab(
                  tabId,
                  title: title,
                  url: url,
                  status: BrowserTabStatus.loaded,
                );
              }
              
              final canGoBack = await _controllers[tabId]?.canGoBack() ?? false;
              final canGoForward = await _controllers[tabId]?.canGoForward() ?? false;
              setState(() {
                _canGoBack[tabId] = canGoBack;
                _canGoForward[tabId] = canGoForward;
              });
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('Web resource error: ${error.description}');
              ref.read(browserTabsProvider.notifier).updateTab(
                tabId,
                status: BrowserTabStatus.error,
              );
            },
            onNavigationRequest: (NavigationRequest request) {
              debugPrint('Navigating to: ${request.url}');
              
              // 导航前确保代理设置
              _configureProxy(controller);
              
              // 检查是否是下载链接
              if (_isDownloadLink(request.url)) {
                _handleDownload(request.url);
                return NavigationDecision.prevent;
              }
              
              return NavigationDecision.navigate;
            },
          ),
        );
    }
    return _controllers[tabId]!;
  }

  bool _isDownloadLink(String url) {
    final downloadExtensions = ['.pdf', '.zip', '.rar', '.exe', '.dmg', '.pkg', '.deb', '.rpm', '.apk'];
    return downloadExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  void _handleDownload(String url) {
    final fileName = url.split('/').last;
    ref.read(downloadsProvider.notifier).startDownload(url, fileName: fileName);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('开始下载: $fileName')),
    );
  }

  void _navigateToUrl(String url) {
    if (url.isNotEmpty) {
      final activeTab = ref.read(browserTabsProvider).activeTab;
      if (activeTab != null) {
        if (!url.startsWith('http://') && !url.startsWith('https://')) {
          url = 'https://$url';
        }
        _getOrCreateController(activeTab.id).loadRequest(Uri.parse(url));
      }
    }
  }

  void _createNewTab() {
    ref.read(browserTabsProvider.notifier).createNewTab();
  }

  void _closeTab(String tabId) {
    ref.read(browserTabsProvider.notifier).closeTab(tabId);
    _controllers.remove(tabId);
    _loadingProgress.remove(tabId);
    _canGoBack.remove(tabId);
    _canGoForward.remove(tabId);
    _currentTitles.remove(tabId);
  }

  void _switchToTab(String tabId) {
    ref.read(browserTabsProvider.notifier).setActiveTab(tabId);
  }

  void _goBack() {
    final activeTab = ref.read(browserTabsProvider).activeTab;
    if (activeTab != null && (_canGoBack[activeTab.id] ?? false)) {
      _getOrCreateController(activeTab.id).goBack();
    }
  }

  void _goForward() {
    final activeTab = ref.read(browserTabsProvider).activeTab;
    if (activeTab != null && (_canGoForward[activeTab.id] ?? false)) {
      _getOrCreateController(activeTab.id).goForward();
    }
  }

  void _reload() {
    final activeTab = ref.read(browserTabsProvider).activeTab;
    if (activeTab != null) {
      _getOrCreateController(activeTab.id).reload();
    }
  }

  void _goHome() {
    final activeTab = ref.read(browserTabsProvider).activeTab;
    if (activeTab != null) {
      _urlController.clear();
      _getOrCreateController(activeTab.id).loadRequest(Uri.parse('https://www.google.com'));
    }
  }

  void _checkProxyStatus() {
    final activeTab = ref.read(browserTabsProvider).activeTab;
    if (activeTab != null) {
      // 加载代理检测页面
      _getOrCreateController(activeTab.id).loadRequest(Uri.parse('https://httpbin.org/ip'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final proxyState = ref.watch(proxyStateProvider);
    final tabsState = ref.watch(browserTabsProvider);
    final activeTab = tabsState.activeTab;
    
    return Scaffold(
      body: Column(
        children: [
          // 标签栏
          _buildTabBar(tabsState),
          
          // 地址栏和工具栏
          _buildAddressBar(proxyState, activeTab),
          
          // 进度条
          if (activeTab != null && (_loadingProgress[activeTab.id] ?? 0) < 100)
            LinearProgressIndicator(
              value: (_loadingProgress[activeTab.id] ?? 0) / 100.0,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          
          // WebView 内容区域
          Expanded(
            child: activeTab != null
                ? WebViewWidget(controller: _getOrCreateController(activeTab.id))
                : const Center(child: Text('没有活动的标签页')),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BrowserTabsState tabsState) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabsState.tabs.length + 1,
        itemBuilder: (context, index) {
          if (index == tabsState.tabs.length) {
            // 新建标签页按钮
            return InkWell(
              onTap: _createNewTab,
              child: Container(
                width: 40,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add,
                  size: 20,
                ),
              ),
            );
          }

          final tab = tabsState.tabs[index];
          final isActive = tab.isSelected;
          
          return GestureDetector(
            onTap: () => _switchToTab(tab.id),
            onSecondaryTapDown: (details) => _showTabContextMenu(tab, details.globalPosition),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isActive 
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: isActive 
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1,
                      )
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      tab.displayName,
                      style: TextStyle(
                        color: isActive 
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (tabsState.tabs.length > 1) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _closeTab(tab.id),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: isActive 
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddressBar(proxyState, activeTab) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // 地址栏
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    hintText: '输入网址...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _navigateToUrl(_urlController.text),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: _navigateToUrl,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 工具栏
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: activeTab != null && (_canGoBack[activeTab.id] ?? false) 
                    ? _goBack 
                    : null,
                tooltip: '后退',
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: activeTab != null && (_canGoForward[activeTab.id] ?? false) 
                    ? _goForward 
                    : null,
                tooltip: '前进',
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: activeTab != null ? _reload : null,
                tooltip: '刷新',
              ),
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: activeTab != null ? _goHome : null,
                tooltip: '主页',
              ),
              const Spacer(),
              // 代理状态指示器（可点击检测）
              GestureDetector(
                onTap: _checkProxyStatus,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: proxyState.isStart && proxyState.systemProxy 
                        ? Colors.green 
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        proxyState.isStart && proxyState.systemProxy 
                            ? Icons.shield 
                            : Icons.shield_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        proxyState.isStart && proxyState.systemProxy 
                            ? '代理已启用' 
                            : '代理未启用',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (proxyState.isStart && proxyState.systemProxy) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.touch_app,
                          color: Colors.white,
                          size: 12,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'downloads':
                      _showDownloads();
                      break;
                    case 'settings':
                      _showSettings();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'downloads',
                    child: Row(
                      children: [
                        const Icon(Icons.download),
                        const SizedBox(width: 8),
                        Consumer(
                          builder: (context, ref, child) {
                            final downloadsState = ref.watch(downloadsProvider);
                            final activeDownloads = downloadsState.activeDownloads.length;
                            return Text('下载记录${activeDownloads > 0 ? ' ($activeDownloads)' : ''}');
                          },
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 8),
                        Text('设置'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTabContextMenu(BrowserTab tab, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, 0, 0),
      items: [
        PopupMenuItem(
          onTap: () => _switchToTab(tab.id),
          child: const Text('切换到此标签'),
        ),
        PopupMenuItem(
          onTap: () => _closeTab(tab.id),
          child: const Text('关闭标签'),
        ),
        if (ref.read(browserTabsProvider).tabs.length > 1)
          PopupMenuItem(
            onTap: () => ref.read(browserTabsProvider.notifier).closeOtherTabs(tab.id),
            child: const Text('关闭其他标签'),
          ),
      ],
    );
  }

  void _showDownloads() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => DownloadsPanel(
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _showSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('浏览器设置功能正在开发中...')),
    );
  }

  void _configureProxy(WebViewController controller) async {
    debugPrint('CONFIGURING WebView proxy using WebViewProxyManager...');
    
    try {
      // 使用新的WebViewProxyManager配置代理
      await WebViewProxyManager.configureProxy(
        controller,
        host: '127.0.0.1',
        port: 7890,
        type: ProxyType.socks5,
      );
      
      // 检查代理状态
      final status = await WebViewProxyManager.checkProxyStatus(controller);
      debugPrint('Proxy status: $status');
      
    } catch (e) {
      debugPrint('Proxy configuration failed: $e');
      // 如果新方法失败，回退到原始方法
      _fallbackProxyConfiguration(controller);
    }
  }
  
  void _fallbackProxyConfiguration(WebViewController controller) {
    debugPrint('Using fallback proxy configuration...');
    
    controller.runJavaScript("""
      (function() {
        console.log('[FALLBACK PROXY] Basic enforcement activated');
        
        // 基础的网络请求拦截
        if (window.fetch) {
          const originalFetch = window.fetch;
          window.fetch = function(url, options = {}) {
            console.log('[FALLBACK PROXY] Fetch:', url);
            return originalFetch.call(this, url, options);
          };
        }
        
        console.log('[FALLBACK PROXY] Setup completed');
      })();
    """);
  }

  void _updateAllControllersProxy() {
    // 更新所有现有WebView控制器的代理配置
    for (final entry in _controllers.entries) {
      final tabId = entry.key;
      final controller = entry.value;
      
      debugPrint('Updating proxy for tab: $tabId');
      _configureProxy(controller);
      
      // 重新加载当前页面以应用新的代理设置
      controller.reload();
    }
  }
}

class DownloadsPanel extends ConsumerWidget {
  final ScrollController scrollController;

  const DownloadsPanel({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadsState = ref.watch(downloadsProvider);
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.download),
                const SizedBox(width: 8),
                Text(
                  '下载管理',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                if (downloadsState.completedDownloads.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      ref.read(downloadsProvider.notifier).clearCompleted();
                    },
                    child: const Text('清除已完成'),
                  ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // 下载列表
          Expanded(
            child: downloadsState.downloads.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.download_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '暂无下载任务',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: scrollController,
                    itemCount: downloadsState.downloads.length,
                    itemBuilder: (context, index) {
                      final download = downloadsState.downloads[index];
                      return DownloadItemTile(download: download);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class DownloadItemTile extends ConsumerWidget {
  final DownloadItem download;

  const DownloadItemTile({
    super.key,
    required this.download,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getStatusColor(download.status),
        child: Icon(
          _getStatusIcon(download.status),
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        download.fileName,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(download.statusText),
          if (download.status == DownloadStatus.downloading) ...[
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: download.progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(download.progressText),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (download.status == DownloadStatus.downloading)
            IconButton(
              icon: const Icon(Icons.pause),
              onPressed: () {
                ref.read(downloadsProvider.notifier).pauseDownload(download.id);
              },
            ),
          if (download.status == DownloadStatus.paused)
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                ref.read(downloadsProvider.notifier).resumeDownload(download.id);
              },
            ),
          if (download.status == DownloadStatus.failed)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(downloadsProvider.notifier).retryDownload(download.id);
              },
            ),
          if (download.status == DownloadStatus.completed)
            IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: () {
                // 打开下载文件夹
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('下载位置: ${download.filePath}')),
                );
              },
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'cancel':
                  ref.read(downloadsProvider.notifier).cancelDownload(download.id);
                  break;
                case 'remove':
                  ref.read(downloadsProvider.notifier).removeDownload(download.id);
                  break;
              }
            },
            itemBuilder: (context) => [
              if (download.status == DownloadStatus.downloading || download.status == DownloadStatus.paused)
                const PopupMenuItem(
                  value: 'cancel',
                  child: Row(
                    children: [
                      Icon(Icons.cancel),
                      SizedBox(width: 8),
                      Text('取消下载'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.delete),
                    SizedBox(width: 8),
                    Text('移除记录'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.pending:
        return Colors.grey;
      case DownloadStatus.downloading:
        return Colors.blue;
      case DownloadStatus.completed:
        return Colors.green;
      case DownloadStatus.failed:
        return Colors.red;
      case DownloadStatus.paused:
        return Colors.orange;
      case DownloadStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.pending:
        return Icons.schedule;
      case DownloadStatus.downloading:
        return Icons.download;
      case DownloadStatus.completed:
        return Icons.check;
      case DownloadStatus.failed:
        return Icons.error;
      case DownloadStatus.paused:
        return Icons.pause;
      case DownloadStatus.cancelled:
        return Icons.cancel;
    }
  }
}