import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NetworkConfig {
  static const String _networkIpKey = 'network_ip';
  static const String _defaultPort = '8080';

  // Default network IP (can be overridden by user)
  static const String _defaultNetworkIp = '192.168.100.72';

  /// Get the stored network IP address or return default
  static Future<String> getNetworkIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_networkIpKey) ?? _defaultNetworkIp;
  }

  /// Store a new network IP address
  static Future<void> setNetworkIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_networkIpKey, ip);
  }

  /// Get all possible base URLs for the current configuration
  static Future<List<String>> getBaseUrls() async {
    final networkIp = await getNetworkIp();
    final urls = <String>[];

    // Add network IP first (most likely to work in development)
    urls.add('http://$networkIp:$_defaultPort/api/v1');

    // Add platform-specific URLs
    if (!kIsWeb) {
      try {
        if (Platform.isAndroid) {
          // Android emulator specific
          urls.add('http://10.0.2.2:$_defaultPort/api/v1');
          // Android device on same network
          urls.add('http://localhost:$_defaultPort/api/v1');
        } else if (Platform.isIOS) {
          // iOS simulator
          urls.add('http://localhost:$_defaultPort/api/v1');
          urls.add('http://127.0.0.1:$_defaultPort/api/v1');
        } else {
          // Desktop platforms
          urls.add('http://localhost:$_defaultPort/api/v1');
          urls.add('http://127.0.0.1:$_defaultPort/api/v1');
        }
      } catch (e) {
        // Platform detection failed, add common fallbacks
        urls.add('http://localhost:$_defaultPort/api/v1');
        urls.add('http://127.0.0.1:$_defaultPort/api/v1');
      }
    } else {
      // Web platform
      urls.add('http://localhost:$_defaultPort/api/v1');
    }

    return urls;
  }

  /// Test connectivity to a specific base URL
  static Future<bool> testConnectivity(String baseUrl) async {
    try {
      // Try health check endpoint first (faster and more reliable)
      final healthUrl = Uri.parse('$baseUrl/health/ping');
      final healthResponse =
          await http.get(healthUrl).timeout(const Duration(seconds: 3));
      if (healthResponse.statusCode == 200) {
        return true;
      }

      // Fallback to DJs endpoint
      final url = Uri.parse('$baseUrl/djs');
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Find the first working base URL from the list
  static Future<String?> findWorkingBaseUrl() async {
    final baseUrls = await getBaseUrls();

    for (String url in baseUrls) {
      if (await testConnectivity(url)) {
        return url;
      }
    }
    return null; // No working URL found
  }

  /// Test all URLs and return their status
  static Future<Map<String, bool>> testAllUrls() async {
    final baseUrls = await getBaseUrls();
    final results = <String, bool>{};

    for (String url in baseUrls) {
      results[url] = await testConnectivity(url);
    }

    return results;
  }

  /// Get the current best base URL (either working or default)
  static Future<String> getCurrentBaseUrl() async {
    final workingUrl = await findWorkingBaseUrl();
    if (workingUrl != null) {
      return workingUrl;
    }

    // If no URL works, return the network IP URL as default
    final networkIp = await getNetworkIp();
    return 'http://$networkIp:$_defaultPort/api/v1';
  }

  /// Validate if an IP address format is correct
  static bool isValidIpAddress(String ip) {
    final ipRegex = RegExp(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$');
    if (!ipRegex.hasMatch(ip)) return false;

    final parts = ip.split('.');
    for (String part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return false;
    }

    return true;
  }

  /// Auto-discover backend server on local network
  static Future<String?> discoverBackendServer() async {
    // Common IP ranges for local networks
    final commonRanges = [
      '192.168.1',
      '192.168.0',
      '192.168.100',
      '10.0.0',
      '172.16.0'
    ];

    for (final range in commonRanges) {
      for (int i = 1; i <= 254; i++) {
        final ip = '$range.$i';
        final baseUrl = 'http://$ip:$_defaultPort/api/v1';

        if (await testConnectivity(baseUrl)) {
          await setNetworkIp(ip);
          return baseUrl;
        }
      }
    }

    return null;
  }

  /// Get network configuration info for debugging
  static Future<Map<String, dynamic>> getNetworkInfo() async {
    final networkIp = await getNetworkIp();
    final baseUrls = await getBaseUrls();
    final currentBaseUrl = await getCurrentBaseUrl();
    final urlStatuses = await testAllUrls();

    return {
      'networkIp': networkIp,
      'defaultPort': _defaultPort,
      'baseUrls': baseUrls,
      'currentBaseUrl': currentBaseUrl,
      'urlStatuses': urlStatuses,
      'platform': kIsWeb ? 'web' : Platform.operatingSystem,
      'discoveryAvailable': !kIsWeb,
    };
  }
}
