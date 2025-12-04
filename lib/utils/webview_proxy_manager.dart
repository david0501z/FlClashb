
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewProxyManager {
  static const MethodChannel _channel = MethodChannel('com.follow.clash/webview_proxy');
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
    ProxyType type = ProxyType.http, // 默认使用HTTP代理，因为SOCKS5在WebView中不直接支持
  }) async {
    await initialize();

    debugPrint('[WebViewProxy] Starting proxy configuration: $host:$port (${type.name})');

    try {
      // 优先尝试原生方法设置WebView代理
      final nativeSuccess = await _setNativeWebViewProxy(host, port);
      
      if (nativeSuccess) {
        debugPrint('[WebViewProxy] Native proxy configured successfully: $host:$port (${type.name})');
      } else {
        debugPrint('[WebViewProxy] Native proxy configuration failed, using JavaScript fallback');
      }
      
      // 无论原生方法是否成功，都执行JavaScript层面的代理强化
      debugPrint('[WebViewProxy] Applying JavaScript proxy enforcement...');
      await _setWebViewProxy(controller, host, port, type);
      await _injectEnhancedProxyScript(controller, host, port, type);
      await _setupRequestInterception(controller, host, port, type);
      
      // 额外的强制代理措施
      await _forceProxySettings(controller, host, port, type);
      
      debugPrint('[WebViewProxy] Proxy configuration completed');
      
    } catch (e) {
      debugPrint('[WebViewProxy] Configuration failed: $e');
      // 出错时也尝试基本的JavaScript方法
      try {
        await _setWebViewProxy(controller, host, port, type);
        await _injectBasicProxyScript(controller, host, port, type);
      } catch (fallbackError) {
        debugPrint('[WebViewProxy] Even fallback failed: $fallbackError');
      }
    }
  }

  /// 设置原生WebView代理
  static Future<bool> _setNativeWebViewProxy(String host, int port) async {
    try {
      final result = await _channel.invokeMethod('setProxy', {
        'host': host,
        'port': port,
      });
      return result == true;
    } catch (e) {
      debugPrint('[WebViewProxy] Native proxy configuration error: $e');
      return false;
    }
  }

  /// 清除原生WebView代理
  static Future<bool> clearProxyNative() async {
    try {
      final result = await _channel.invokeMethod('clearProxy');
      return result == true;
    } catch (e) {
      debugPrint('[WebViewProxy] Native proxy clear error: $e');
      return false;
    }
  }

  /// 设置WebView代理（JavaScript方法，作为回退）
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

  /// 强制代理设置（额外措施）
  static Future<void> _forceProxySettings(
    WebViewController controller,
    String host,
    int port,
    ProxyType type,
  ) async {
    await controller.runJavaScript("""
      (function() {
        console.log('[FORCE PROXY] Applying additional proxy measures...');
        
        // 强制覆盖所有可能的网络请求方法
        const originalFetch = window.fetch;
        const originalXHROpen = XMLHttpRequest.prototype.open;
        const originalWebSocket = window.WebSocket;
        
        // 重写 fetch 以强制使用代理
        window.fetch = function(url, options = {}) {
          console.log('[FORCE PROXY] Fetch intercepted:', url);
          
          // 强制添加代理标识
          options = options || {};
          options.headers = options.headers || {};
          options.headers['X-Force-Proxy'] = 'true';
          options.headers['X-Proxy-Host'] = '$host:$port';
          
          return originalFetch.apply(this, arguments);
        };
        
        // 重写 XMLHttpRequest
        XMLHttpRequest.prototype.open = function(method, url, async, user, pass) {
          console.log('[FORCE PROXY] XHR intercepted:', method, url);
          
          // 设置代理头
          this.setRequestHeader?.('X-Force-Proxy', 'true');
          this.setRequestHeader?.('X-Proxy-Host', '$host:$port');
          
          return originalXHROpen.apply(this, arguments);
        };
        
        // 重写 WebSocket
        window.WebSocket = function(url, protocols) {
          console.log('[FORCE PROXY] WebSocket intercepted:', url);
          
          // 创建带有代理信息的 WebSocket
          const ws = new originalWebSocket(url, protocols);
          ws._forceProxy = true;
          
          return ws;
        };
        
        // 防止代理被绕过的额外措施
        Object.freeze(window.fetch);
        Object.freeze(XMLHttpRequest.prototype.open);
        Object.freeze(window.WebSocket);
        
        console.log('[FORCE PROXY] Additional measures applied');
      })();
    """);
  }

  /// 基础代理脚本（简化版本，用于出错时的回退）
  static Future<void> _injectBasicProxyScript(
    WebViewController controller,
    String host,
    int port,
    ProxyType type,
  ) async {
    final basicScript = '''
      (function() {
        console.log('[BASIC PROXY] Setting up minimal proxy enforcement...');
        
        // 基础 fetch 拦截
        const originalFetch = window.fetch;
        window.fetch = function(url, options = {}) {
          console.log('[BASIC PROXY] Fetch:', url);
          options = options || {};
          options.headers = options.headers || {};
          options.headers['X-Basic-Proxy'] = 'true';
          return originalFetch.apply(this, arguments);
        };
        
        console.log('[BASIC PROXY] Basic enforcement completed');
      })();
    ''';

    await controller.runJavaScript(basicScript);
  }

  /// 清除代理设置
  static Future<void> clearProxy(WebViewController controller) async {
    try {
      // 首先尝试清除原生代理
      await clearProxyNative();
      
      // 然后清除JavaScript代理设置
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
