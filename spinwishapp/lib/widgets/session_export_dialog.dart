import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spinwishapp/models/session.dart';
import 'package:spinwishapp/services/session_export_service.dart';

class SessionExportDialog extends StatefulWidget {
  final List<Session> sessions;

  const SessionExportDialog({
    super.key,
    required this.sessions,
  });

  @override
  State<SessionExportDialog> createState() => _SessionExportDialogState();
}

class _SessionExportDialogState extends State<SessionExportDialog> {
  String _selectedFormat = 'csv';
  bool _includeAnalytics = true;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.download,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('Export Session Data'),
        ],
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export ${widget.sessions.length} sessions',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),

            // Format selection
            Text(
              'Export Format',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Column(
              children: [
                RadioListTile<String>(
                  title: const Text('CSV (Spreadsheet)'),
                  subtitle: const Text('Compatible with Excel, Google Sheets'),
                  value: 'csv',
                  groupValue: _selectedFormat,
                  onChanged: (value) {
                    setState(() {
                      _selectedFormat = value!;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<String>(
                  title: const Text('JSON (Data)'),
                  subtitle: const Text('Structured data with analytics'),
                  value: 'json',
                  groupValue: _selectedFormat,
                  onChanged: (value) {
                    setState(() {
                      _selectedFormat = value!;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                RadioListTile<String>(
                  title: const Text('Text Report'),
                  subtitle: const Text('Human-readable summary'),
                  value: 'txt',
                  groupValue: _selectedFormat,
                  onChanged: (value) {
                    setState(() {
                      _selectedFormat = value!;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Options
            CheckboxListTile(
              title: const Text('Include Analytics Summary'),
              subtitle: const Text('Add performance insights to export'),
              value: _includeAnalytics,
              onChanged: (value) {
                setState(() {
                  _includeAnalytics = value ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isExporting
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _isExporting ? null : _exportData,
          icon: _isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download),
          label: Text(_isExporting ? 'Exporting...' : 'Export'),
        ),
      ],
    );
  }

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      String data;
      String filename;
      String mimeType;

      switch (_selectedFormat) {
        case 'csv':
          data = SessionExportService.exportToCSV(widget.sessions);
          filename = SessionExportService.generateFilename('sessions', 'csv');
          mimeType = 'text/csv';
          break;
        case 'json':
          data = SessionExportService.exportToJSON(widget.sessions);
          filename = SessionExportService.generateFilename('sessions', 'json');
          mimeType = 'application/json';
          break;
        case 'txt':
          data = SessionExportService.exportAnalyticsReport(widget.sessions);
          filename =
              SessionExportService.generateFilename('session_report', 'txt');
          mimeType = 'text/plain';
          break;
        default:
          throw Exception('Unsupported format: $_selectedFormat');
      }

      // Try to save to device first
      final saved =
          await SessionExportService.saveToDevice(data, filename, mimeType);

      if (saved) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Exported to $filename'),
              action: SnackBarAction(
                label: 'Share',
                onPressed: () {
                  SessionExportService.shareData(data, filename, mimeType);
                },
              ),
            ),
          );
        }
      } else {
        // Fallback: copy to clipboard
        await Clipboard.setData(ClipboardData(text: data));
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data copied to clipboard'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }
}

class SessionShareDialog extends StatelessWidget {
  final Session session;

  const SessionShareDialog({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final earnings =
        (session.totalEarnings ?? 0.0) + (session.totalTips ?? 0.0);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.share,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('Share Session'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      session.type == SessionType.club
                          ? Icons.location_on
                          : Icons.wifi,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      session.type == SessionType.club
                          ? 'Club Session'
                          : 'Online Session',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Earned: \$${earnings.toStringAsFixed(2)}'),
                    Text('Listeners: ${session.listenerCount ?? 0}'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Share options
          Text(
            'Share Options',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _buildShareOption(
            context,
            'Share Link',
            'Share session link with others',
            Icons.link,
            () => _shareLink(context),
          ),
          _buildShareOption(
            context,
            'Share Performance',
            'Share session stats and achievements',
            Icons.analytics,
            () => _sharePerformance(context),
          ),
          _buildShareOption(
            context,
            'Copy Session ID',
            'Copy session ID to clipboard',
            Icons.copy,
            () => _copySessionId(context),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildShareOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _shareLink(BuildContext context) {
    if (session.shareableLink != null) {
      Clipboard.setData(ClipboardData(text: session.shareableLink!));
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session link copied to clipboard')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No shareable link available')),
      );
    }
  }

  void _sharePerformance(BuildContext context) {
    final earnings =
        (session.totalEarnings ?? 0.0) + (session.totalTips ?? 0.0);
    final duration = session.endTime != null
        ? session.endTime!.difference(session.startTime).inMinutes
        : 0;

    final performanceText = '''
🎵 ${session.title}

📊 Session Performance:
💰 Earned: \$${earnings.toStringAsFixed(2)}
👥 Listeners: ${session.listenerCount ?? 0}
🎶 Requests: ${session.totalRequests ?? 0}
⏱️ Duration: ${duration}m
📍 Type: ${session.type == SessionType.club ? 'Club' : 'Online'}

#SpinWish #DJ #Performance
''';

    Clipboard.setData(ClipboardData(text: performanceText));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Performance summary copied to clipboard')),
    );
  }

  void _copySessionId(BuildContext context) {
    Clipboard.setData(ClipboardData(text: session.id));
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session ID copied to clipboard')),
    );
  }
}
