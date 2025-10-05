import 'package:flutter/material.dart';
import 'package:spinwishapp/services/network_config.dart';

class NetworkSettingsScreen extends StatefulWidget {
  const NetworkSettingsScreen({super.key});

  @override
  State<NetworkSettingsScreen> createState() => _NetworkSettingsScreenState();
}

class _NetworkSettingsScreenState extends State<NetworkSettingsScreen> {
  final TextEditingController _ipController = TextEditingController();
  Map<String, bool> _urlStatuses = {};
  bool _isLoading = false;
  bool _isTesting = false;
  bool _isDiscovering = false;
  String? _currentBaseUrl;
  Map<String, dynamic>? _networkInfo;

  @override
  void initState() {
    super.initState();
    _loadNetworkInfo();
  }

  Future<void> _loadNetworkInfo() async {
    setState(() => _isLoading = true);

    try {
      final networkIp = await NetworkConfig.getNetworkIp();
      final networkInfo = await NetworkConfig.getNetworkInfo();
      final currentBaseUrl = await NetworkConfig.getCurrentBaseUrl();

      setState(() {
        _ipController.text = networkIp;
        _networkInfo = networkInfo;
        _currentBaseUrl = currentBaseUrl;
        _urlStatuses = Map<String, bool>.from(networkInfo['urlStatuses'] ?? {});
      });
    } catch (e) {
      _showSnackBar('Error loading network info: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testAllConnections() async {
    setState(() => _isTesting = true);

    try {
      final urlStatuses = await NetworkConfig.testAllUrls();
      setState(() => _urlStatuses = urlStatuses);

      final workingCount = urlStatuses.values.where((status) => status).length;
      _showSnackBar(
          'Tested ${urlStatuses.length} URLs. $workingCount working.');
    } catch (e) {
      _showSnackBar('Error testing connections: $e', isError: true);
    } finally {
      setState(() => _isTesting = false);
    }
  }

  Future<void> _saveNetworkIp() async {
    final newIp = _ipController.text.trim();

    if (!NetworkConfig.isValidIpAddress(newIp)) {
      _showSnackBar('Please enter a valid IP address', isError: true);
      return;
    }

    try {
      await NetworkConfig.setNetworkIp(newIp);
      await _loadNetworkInfo();
      _showSnackBar('Network IP updated successfully');
    } catch (e) {
      _showSnackBar('Error saving network IP: $e', isError: true);
    }
  }

  Future<void> _discoverServer() async {
    setState(() => _isDiscovering = true);

    try {
      _showSnackBar('Discovering backend server on local network...');

      final discoveredUrl = await NetworkConfig.discoverBackendServer();

      if (discoveredUrl != null) {
        final ip = discoveredUrl.split('://')[1].split(':')[0];
        setState(() {
          _ipController.text = ip;
        });
        _showSnackBar('Backend server discovered at $ip');
        await _loadNetworkInfo();
      } else {
        _showSnackBar(
            'No backend server found on local network. Please enter IP manually.',
            isError: true);
      }
    } catch (e) {
      _showSnackBar('Discovery failed: $e', isError: true);
    } finally {
      setState(() => _isDiscovering = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadNetworkInfo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCurrentConfigSection(),
                  const SizedBox(height: 24),
                  _buildIpConfigSection(),
                  const SizedBox(height: 24),
                  _buildConnectionTestSection(),
                  const SizedBox(height: 24),
                  _buildNetworkInfoSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentConfigSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_currentBaseUrl != null) ...[
              Text('Active Base URL:',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Text(_currentBaseUrl!, style: TextStyle(fontFamily: 'monospace')),
              const SizedBox(height: 8),
            ],
            if (_networkInfo != null) ...[
              Text('Platform: ${_networkInfo!['platform']}'),
              Text('Port: ${_networkInfo!['defaultPort']}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIpConfigSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Network IP Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Enter your host machine\'s IP address for WiFi access:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'Network IP Address',
                hintText: '192.168.1.100',
                border: OutlineInputBorder(),
                helperText:
                    'Find your IP with: ip route get 1.1.1.1 | grep -oP \'src \\K\\S+\'',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveNetworkIp,
                    child: const Text('Save IP Address'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isDiscovering ? null : _discoverServer,
                    icon: _isDiscovering
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Text(
                        _isDiscovering ? 'Discovering...' : 'Auto-Discover'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionTestSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Connection Test',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _isTesting ? null : _testAllConnections,
                  icon: _isTesting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.network_check),
                  label: Text(_isTesting ? 'Testing...' : 'Test All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_urlStatuses.isNotEmpty) ...[
              const Text('Connection Status:',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              ..._urlStatuses.entries
                  .map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Icon(
                              entry.value ? Icons.check_circle : Icons.error,
                              color: entry.value ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                    fontFamily: 'monospace', fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkInfoSection() {
    if (_networkInfo == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Network Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Network IP: ${_networkInfo!['networkIp']}'),
            Text('Platform: ${_networkInfo!['platform']}'),
            Text('Port: ${_networkInfo!['defaultPort']}'),
            const SizedBox(height: 8),
            const Text('Available URLs:',
                style: TextStyle(fontWeight: FontWeight.w500)),
            ...(_networkInfo!['baseUrls'] as List<String>)
                .map(
                  (url) => Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 2.0),
                    child: Text(url,
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 12)),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }
}
