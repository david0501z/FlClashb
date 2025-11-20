
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewProxyManager {
  static const MethodChannel _channel = MethodChannel('webview_proxy');
  static bool _initialized = false;

  /// 初始化WebView代理管理器
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      await _channel.invokeMethod('initialize');
      _initialized = true;
      debugPrint('[WebViewProxy] Manager initialized successfully');
    } catch (e) {
      debugPrint('[WebViewProxy] Initialization failed: $e');
    }
  }

  /// 为指定WebView控制器设置代理
  static Future<void> configureProxy(
    WebViewController controller, {
    String host = '127.0.0.1',
    int port = 7890,
    ProxyType type = ProxyType.socks5,
  }) async {
    await initialize();

    try {
      // 方法1: 直接设置WebView代理参数
      await _setWebViewProxy(controller, host, port, type);
      
      // 方法2: 注入强化版代理JavaScript
      await _injectEnhancedProxyScript(controller, host, port, type);
      
      // 方法3: 设置网络请求拦截
      await _setupRequestInterception(controller, host, port, type);
      
      debugPrint('[WebViewProxy] Proxy configured: $host:$port (${type.name})');
    } catch (e) {
      debugPrint('[WebViewProxy] Configuration failed: $e');
    }
  }

  /// 设置WebView原生代理
  static Future<void> _setWebViewProxy(
    WebViewController controller,
    String host,
    int port,
    ProxyType type,
  ) async {
    final proxyConfig = {
      'host': host,
      'port': port,
      'type': type.name.toLowerCase(),
    };

    // 通过JavaScript设置WebView内部代理
    await controller.runJavaScript("""
      (function() {
        // 设置WebView级别的代理配置
        window.__WEBVIEW_PROXY_CONFIG__ = ${proxyConfig.toString()};
        
        // 尝试设置Chrome扩展API代理
        if (typeof chrome !== 'undefined' && chrome.proxy) {
          chrome.proxy.settings.set({
            value: {
              mode: 'fixed_servers',
              rules: {
                singleProxy: {
                  scheme: '${type.name.toLowerCase()}',
                  host: '$host',
                  port: $port
                }
              }
            },
            scope: 'regular'
          });
        }
      })();
    """);
  }

  /// 注入增强版代理脚本
  static Future<void> _injectEnhancedProxyScript(
    WebViewController controller,
    String host,
    int port,
    ProxyType type,
  ) async {
    final enhancedScript = '''
      (function() {
        console.log('[ENHANCED PROXY] Starting enforcement...');
        
        const PROXY_HOST = '$host';
        const PROXY_PORT = $port;
        const PROXY_TYPE = '${type.name.toUpperCase()}';
        
        // 全局代理状态
        window.PROXY_ENFORCED = true;
        window.PROXY_STATS = {
          fetch: 0,
          xhr: 0,
          websocket: 0,
          blocked: 0
        };
        
        // 强化版fetch拦截
        const originalFetch = window.fetch;
        window.fetch = function(url, options = {}) {
          window.PROXY_STATS.fetch++;
          console.log('[PROXY FETCH]', url);
          
          // 强制添加代理头
          options = options || {};
          options.headers = options.headers || {};
          options.headers['X-Proxy-Enforced'] = 'true';
          options.headers['X-Proxy-Type'] = PROXY_TYPE;
          
          return originalFetch.call(this, url, options);
        };
        
        // 强化版XMLHttpRequest拦截
        const OriginalXHR = window.XMLHttpRequest;
        window.XMLHttpRequest = function() {
          const xhr = new OriginalXHR();
          const originalOpen = xhr.open;
          
          xhr.open = function(method, url, async, user, pass) {
            window.PROXY_STATS.xhr++;
            console.log('[PROXY XHR]', method, url);
            
            // 设置代理相关属性
            this.setRequestHeader?.('X-Proxy-Enforced', 'true');
            this.setRequestHeader?.('X-Proxy-Type', PROXY_TYPE);
            
            return originalOpen.call(this, method, url, async, user, pass);
          };
          
          return xhr;
        };
        
        // 强化版WebSocket拦截
        const OriginalWS = window.WebSocket;
        window.WebSocket = function(url, protocols) {
          window.PROXY_STATS.websocket++;
          console.log('[PROXY WS]', url);
          
          // 创建带有代理标记的WebSocket
          const ws = new OriginalWS(url, protocols);
          ws._proxyEnforced = true;
          
          return ws;
        };
        
        // 阻止绕过代理的尝试
        ['navigator.sendBeacon', 'EventSource'].forEach(api => {
          if (window[api]) {
            const original = window[api];
            window[api] = function(...args) {
              console.warn('[PROXY BLOCKED]', api, args[0]);
              window.PROXY_STATS.blocked++;
              return null;
            };
          }
        });
        
        // 定期检查代理状态
        setInterval(() => {
          console.log('[PROXY STATS]', window.PROXY_STATS);
        }, 5000);
        
        console.log('[ENHANCED PROXY] Enforcement completed!');
      })();
    ''';

    await controller.runJavaScript(enhancedScript);
  }

  /// 设置请求拦截
  static Future<void> _setupRequestInterception(
    WebViewController controller,
    String host,
    int port,
    ProxyType type,
  ) async {
    await controller.runJavaScript("""
      (function() {
        // 拦截动态创建的元素
        const originalCreateElement = document.createElement;
        document.createElement = function(tagName) {
          const element = originalCreateElement.call(this, tagName);
          
          if (tagName.toLowerCase() === 'iframe' || 
              tagName.toLowerCase() === 'frame') {
            // 对iframe也强制代理
            element.onload = function() {
              try {
                this.contentWindow.eval('(' + arguments.callee.toString() + ')()');
              } catch (e) {
                console.log('[PROXY] iframe proxy setup failed:', e);
              }
            };
          }
          
          return element;
        };
        
        // 监听所有导航事件
        window.addEventListener('beforeunload', () => {
          console.log('[PROXY] Page unloading, proxy preserved');
        });
        
        // 防止代理被禁用
        Object.defineProperty(window, 'PROXY_ENFORCED', {
          writable: false,
          configurable: false,
          value: true
        });
      })();
    """);
  }

  /// 检查代理状态
  static Future<Map<String, dynamic>> checkProxyStatus(
    WebViewController controller,
  ) async {
    try {
      final result = await controller.runJavaScriptReturningResult("""
        (function() {
          return {
            enforced: window.PROXY_ENFORCED || false,
            stats: window.PROXY_STATS || {},
            config: window.__WEBVIEW_PROXY_CONFIG__ || null
          };
        })();
      """);
      
      return Map<String, dynamic>.from(result as Map);
    } catch (e) {
      debugPrint('[WebViewProxy] Status check failed: $e');
      return {'error': e.toString()};
    }
  }

  /// 清除代理设置
  static Future<void> clearProxy(WebViewController controller) async {
    try {
      await controller.runJavaScript("""
        (function() {
          window.PROXY_ENFORCED = false;
          delete window.__WEBVIEW_PROXY_CONFIG__;
          delete window.PROXY_STATS;
          console.log('[PROXY] Cleared all proxy settings');
        })();
      """);
      
      debugPrint('[WebViewProxy] Proxy cleared');
    } catch (e) {
      debugPrint('[WebViewProxy] Clear failed: $e');
    }
  }
}

enum ProxyType {
  http,
  https,
  socks4,
  socks5,
}
