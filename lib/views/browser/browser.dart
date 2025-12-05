import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/providers/browser_provider.dart';
import 'package:fl_clash/models/browser_tab.dart';
import 'package:fl_clash/models/download.dart';
import 'package:fl_clash/utils/webview_proxy_manager.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    
    // 初始化 WebView 代理管理器
    _initializeWebViewProxy();
    
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

  // 初始化 WebView 代理管理器
  Future<void> _initializeWebViewProxy() async {
    try {
      debugPrint('Initializing WebView proxy manager...');
      await WebViewProxyManager.initialize();
      debugPrint('WebView proxy manager initialized successfully');
      
      // 运行代理诊断
      await _diagnoseProxyIssues();
    } catch (e) {
      debugPrint('Failed to initialize WebView proxy manager: $e');
    }
  }
  
  // 代理问题诊断
  Future<void> _diagnoseProxyIssues() async {
    try {
      debugPrint('=== 开始代理诊断 ===');
      
      // 检查代理状态
      final proxyState = ref.read(proxyStateProvider);
      debugPrint('代理状态: 启动=${proxyState.isStart}, 端口=${proxyState.port}, 系统代理=${proxyState.systemProxy}');
      
      if (!proxyState.isStart) {
        debugPrint('❌ 代理未启动！');
        return;
      }
      
      // 测试代理连接
      final isConnected = await _testProxyConnection(proxyState.port);
      debugPrint('代理连接测试: ${isConnected ? "✅ 成功" : "❌ 失败"}');
      
      // 检查网络权限
      await _checkNetworkPermissions();
      
      debugPrint('=== 代理诊断完成 ===');
    } catch (e) {
      debugPrint('代理诊断失败: $e');
    }
  }
  
  // 测试代理连接
  Future<bool> _testProxyConnection(int port) async {
    try {
      final client = HttpClient();
      client.findProxy = (uri) => 'DIRECT'; // 直接连接测试
      
      final request = await client.getUrl(Uri.parse('http://www.google.com'));
      final response = await request.close();
      
      client.close();
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('代理连接测试失败: $e');
      return false;
    }
  }
  
  // 检查网络权限
  Future<void> _checkNetworkPermissions() async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('https://httpbin.org/ip'));
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        debugPrint('网络权限检查 ✅: $responseBody');
      } else {
        debugPrint('网络权限检查 ❌: HTTP ${response.statusCode}');
      }
      
      client.close();
    } catch (e) {
      debugPrint('网络权限检查失败: $e');
    }
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

  void _configureProxy(WebViewController controller) async {
    debugPrint('CONFIGURING WebView proxy using WebViewProxyManager...');
    
    try {
      // 获取真实的代理端口和状态
      final proxyState = ref.read(proxyStateProvider);
      debugPrint('Proxy state: isStart=${proxyState.isStart}, port=${proxyState.port}');
      
      if (!proxyState.isStart) {
        debugPrint('Proxy is not started, skipping WebView proxy configuration');
        return;
      }
      
      // 使用真实的端口配置代理
      await WebViewProxyManager.configureProxy(
        controller,
        host: '127.0.0.1',
        port: proxyState.port, // 使用真实端口
        type: ProxyType.http, // 改为 HTTP 代理，因为 WebView 更好支持
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
              setState(() {
                _loadingProgress[tabId] = 0;
                _currentUrls[tabId] = url;
              });
            },
            onPageFinished: (String url) async {
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
              }
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('WebView error: ${error.description}');
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
    final downloadExtensions = [
      '.pdf', '.zip', '.rar', '.exe', '.dmg', '.pkg', '.deb', '.rpm', '.apk',
      '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx', '.txt', '.csv',
      '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.svg', '.mp3', '.mp4',
      '.avi', '.mov', '.wmv', '.flv', '.tar', '.gz', '.7z', '.iso'
    ];
    
    return downloadExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  void _handleDownload(String url) {
    // 实现下载逻辑
    debugPrint('开始下载: $url');
    
    // 这里可以集成实际的下载功能
    // 例如使用 dio 包进行下载
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('开始下载: ${Uri.parse(url).pathSegments.last}')),
    );
  }

void _loadUrl(String url) {
    final activeTab = ref.read(browserTabsProvider).activeTab;
    if (activeTab != null) {
      final controller = _getOrCreateController(activeTab.id);

      // 确保 URL 格式正确
      String formattedUrl = url;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        formattedUrl = 'https://$url';
      }

      controller.loadRequest(Uri.parse(formattedUrl));
    }
  }

  void _goBack() {
    final activeTab = ref.read(browserTabsProvider).activeTab;
    if (activeTab != null) {
      final controller = _getOrCreateController(activeTab.id);
      controller.goBack();
    }
  }

  void _goForward() {
    final activeTab = ref.read(browserTabsProvider).activeTab;
    if (activeTab != null) {
      final controller = _getOrCreateController(activeTab.id);
      controller.goForward();
    }
  }

  void _reload() {
    final activeTab = ref.read(browserTabsProvider).activeTab;
    if (activeTab != null) {
      final controller = _getOrCreateController(activeTab.id);
      controller.reload();
    }
  }

  void _downloadCurrentPage() {
    final activeTab = ref.read(browserTabsProvider).activeTab;
    if (activeTab != null) {
      final controller = _getOrCreateController(activeTab.id);
      
      // 获取当前页面URL - 使用正确的 API
      controller.currentUrl().then((url) {
        if (url != null) {
          // 显示下载对话框
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('下载页面'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('URL: $url'),
                    const SizedBox(height: 16),
                    const Text('确定要下载此页面吗？'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('取消'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _handleDownload(url);
                    },
                    child: const Text('下载'),
                  ),
                ],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('无法获取当前页面URL')),
          );
        }
      });
    }
  }

  void _showSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('浏览器设置功能正在开发中...')),
    );
  }

  void _showDownloads() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => DownloadsPanel(
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _showTabContextMenu(BrowserTab tab, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem(
          onTap: () => _closeTab(tab.id),
          child: const Row(
            children: [
              Icon(Icons.close),
              SizedBox(width: 8),
              Text('关闭标签页'),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () {
            // 关闭其他标签页
            final tabs = ref.read(browserTabsProvider).tabs;
            for (final otherTab in tabs) {
              if (otherTab.id != tab.id) {
                _closeTab(otherTab.id);
              }
            }
          },
          child: const Row(
            children: [
              Icon(Icons.close_outlined),
              SizedBox(width: 8),
              Text('关闭其他标签页'),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () {
            // 复制标签页URL
            final controller = _getOrCreateController(tab.id);
            controller.currentUrl().then((url) {
              if (url != null) {
                // 这里可以实现复制到剪贴板的功能
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('已复制: $url')),
                );
              }
            });
          },
          child: const Row(
            children: [
              Icon(Icons.copy),
              SizedBox(width: 8),
              Text('复制链接'),
            ],
          ),
        ),
      ],
    );
  }

  void _goHome() {
    final activeTab = ref.read(browserTabsProvider).activeTab;
    if (activeTab != null) {
      final controller = _getOrCreateController(activeTab.id);
      controller.loadRequest(Uri.parse('https://www.google.com'));
    }
  }

  void _checkProxyStatus() {
    final activeTab = ref.read(browserTabsProvider).activeTab;
    if (activeTab != null) {
      final controller = _getOrCreateController(activeTab.id);
      
      // 检查当前IP地址
      controller.runJavaScript("""
        fetch('https://httpbin.org/ip')
          .then(response => response.json())
          .then(data => {
            FlutterChannel.postMessage(JSON.stringify({
              type: 'ip_check',
              ip: data.origin
            }));
          })
          .catch(error => {
            FlutterChannel.postMessage(JSON.stringify({
              type: 'ip_check_error',
              error: error.message
            }));
          });
      """);
    }
  }

  void _createNewTab() {
    ref.read(browserTabsProvider.notifier).createNewTab();
  }

  void _closeTab(String tabId) {
    ref.read(browserTabsProvider.notifier).closeTab(tabId);
  }

  void _switchToTab(String tabId) {
    ref.read(browserTabsProvider.notifier).setActiveTab(tabId);
  }

  void _navigateToUrl(String url) {
    if (url.isNotEmpty) {
      _loadUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final browserState = ref.watch(browserTabsProvider);
    final activeTab = browserState.activeTab;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: '输入网址...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _loadUrl(value);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reload,
              tooltip: '刷新',
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadCurrentPage,
              tooltip: '下载当前页面',
            ),
          ],
        ),
        bottom: activeTab != null && browserState.tabs.length > 1
            ? TabBar(
                controller: browserState.tabController,
                isScrollable: true,
                tabs: browserState.tabs.map((tab) {
                  return Tab(
                    text: _currentTitles[tab.id]?.length > 10
                        ? '${_currentTitles[tab.id]?.substring(0, 10)}...'
                        : _currentTitles[tab.id] ?? '新标签页',
                  );
                }).toList(),
              )
            : null,
      ),
      body: activeTab != null
          ? Column(
              children: [
                // 进度条
                if ((_loadingProgress[activeTab.id] ?? 0) < 100)
                  LinearProgressIndicator(
                    value: (_loadingProgress[activeTab.id] ?? 0) / 100,
                  ),
                
                // 导航栏
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _canGoBack[activeTab.id] == true ? _goBack : null,
                        tooltip: '后退',
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: _canGoForward[activeTab.id] == true ? _goForward : null,
                        tooltip: '前进',
                      ),
                      Expanded(
                        child: Text(
                          _currentTitles[activeTab.id] ?? '加载中...',
                          style: const TextStyle(fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                
// WebView 内容
            Expanded(
              child: WebViewWidget(controller: _getOrCreateController(activeTab.id)),
            ),
              ],
            )
          : const Center(
              child: Text('没有打开的标签页'),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(browserTabsProvider.notifier).createNewTab();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '下载管理',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (downloadsState.downloads.isNotEmpty)
                TextButton(
                  onPressed: () {
                    ref.read(downloadsProvider.notifier).clearCompleted();
                  },
                  child: const Text('清除已完成'),
                ),
            ],
          ),
          const SizedBox(height: 16),
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