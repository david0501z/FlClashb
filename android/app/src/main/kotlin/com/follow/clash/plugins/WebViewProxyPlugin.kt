package com.follow.clash.plugins

import android.os.Build
import android.util.Log
import android.webkit.WebView
import androidx.annotation.RequiresApi
import androidx.webkit.ProxyConfig
import androidx.webkit.WebViewFeature
import com.follow.clash.common.Components
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.Executors

class WebViewProxyPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel

    companion object {
        private const val TAG = "WebViewProxyPlugin"
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            "${Components.PACKAGE_NAME}/webview_proxy"
        )
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> {
                initialize()
                result.success(true)
            }
            "setProxy" -> {
                val host = call.argument<String>("host") ?: "127.0.0.1"
                val port = call.argument<Int>("port") ?: 7890
                val success = setProxy(host, port)
                result.success(success)
            }
            "clearProxy" -> {
                val success = clearProxy()
                result.success(success)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    private fun initialize() {
        Log.d(TAG, "WebViewProxyPlugin initialized")
    }

    /**
     * 为 Android WebView 设置代理
     * 使用 WebViewFeature.PROXY_OVERRIDE API (推荐方法)
     * @param host 代理主机地址
     * @param port 代理端口
     * @return 是否设置成功
     */
    private fun setProxy(host: String, port: Int): Boolean {
        return try {
            Log.d(TAG, "Attempting to set WebView proxy: $host:$port")
            
            // 首先尝试使用现代 WebView API
            if (WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE)) {
                val proxyConfig = ProxyConfig.Builder()
                    .addProxyRule("$host:$port") // 设置代理规则
                    .addBypassRule("localhost") // 绕过本地地址
                    .addBypassRule("127.*") // 绕过 127.x.x.x
                    .addBypassRule("::1") // 绕过 IPv6 本地地址
                    .build()
                
                androidx.webkit.ProxyController.getInstance()
                    .setProxyOverride(proxyConfig, Executors.newSingleThreadExecutor()) {
                        Log.d(TAG, "Proxy override applied successfully: $host:$port")
                        
                        // 验证代理是否真正生效
                        verifyProxySetup(host, port)
                    }
                
                Log.d(TAG, "WebView proxy set using ProxyController: $host:$port")
                true
            } else {
                Log.w(TAG, "WebViewFeature.PROXY_OVERRIDE not supported on this device")
                // 如果不支持新API，回退到系统属性方法
                setProxyWithSystemProperties(host, port)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to set WebView proxy using ProxyController: ${e.message}", e)
            // 如果新方法失败，回退到系统属性方法
            setProxyWithSystemProperties(host, port)
        }
    }
    
    /**
     * 验证代理设置是否生效
     */
    private fun verifyProxySetup(host: String, port: Int) {
        try {
            // 检查系统属性是否正确设置
            val httpProxy = System.getProperty("http.proxyHost")
            val httpPort = System.getProperty("http.proxyPort")
            val httpsProxy = System.getProperty("https.proxyHost")
            val httpsPort = System.getProperty("https.proxyPort")
            
            Log.d(TAG, "Proxy verification - HTTP: $httpProxy:$httpPort, HTTPS: $httpsProxy:$httpsPort")
            
            // 如果系统属性没有正确设置，强制设置它们
            if (httpProxy != host || httpPort != port.toString()) {
                Log.d(TAG, "System properties not correctly set, forcing them...")
                forceSystemProxyProperties(host, port)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Proxy verification failed: ${e.message}", e)
        }
    }
    
    /**
     * 强制设置系统代理属性
     */
    private fun forceSystemProxyProperties(host: String, port: Int) {
        try {
            System.setProperty("http.proxyHost", host)
            System.setProperty("http.proxyPort", port.toString())
            System.setProperty("https.proxyHost", host)
            System.setProperty("https.proxyPort", port.toString())
            System.setProperty("ftp.proxyHost", host)
            System.setProperty("ftp.proxyPort", port.toString())
            System.setProperty("socksProxyHost", host)
            System.setProperty("socksProxyPort", port.toString())
            
            Log.d(TAG, "System proxy properties forced: $host:$port")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to force system proxy properties: ${e.message}", e)
        }
    }

    /**
     * 使用系统属性设置代理（回退方法）
     */
    private fun setProxyWithSystemProperties(host: String, port: Int): Boolean {
        return try {
            System.setProperty("http.proxyHost", host)
            System.setProperty("http.proxyPort", port.toString())
            System.setProperty("https.proxyHost", host)
            System.setProperty("https.proxyPort", port.toString())
            
            Log.d(TAG, "Proxy set using system properties: $host:$port")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to set proxy with system properties: ${e.message}", e)
            false
        }
    }

    /**
     * 清除 WebView 代理设置
     * @return 是否清除成功
     */
    private fun clearProxy(): Boolean {
        return try {
            if (WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE)) {
                // 恢复默认代理设置
                androidx.webkit.ProxyController.getInstance()
                    .clearProxyOverride(Executors.newSingleThreadExecutor()) {
                        Log.d(TAG, "Proxy override cleared")
                    }
                
                Log.d(TAG, "WebView proxy cleared using ProxyController")
            } else {
                Log.w(TAG, "WebViewFeature.PROXY_OVERRIDE not supported for clearing")
            }
            
            // 清除系统属性
            System.clearProperty("http.proxyHost")
            System.clearProperty("http.proxyPort")
            System.clearProperty("https.proxyHost")
            System.clearProperty("https.proxyPort")
            
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to clear WebView proxy: ${e.message}", e)
            false
        }
    }
}