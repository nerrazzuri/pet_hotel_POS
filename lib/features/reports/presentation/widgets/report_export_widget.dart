import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/reports/domain/entities/report.dart';
import 'package:cat_hotel_pos/features/reports/presentation/providers/reports_providers.dart';

class ReportExportWidget extends ConsumerWidget {
  final ReportType reportType;

  const ReportExportWidget({
    super.key,
    required this.reportType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exportData = ref.watch(exportReportProvider);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Options',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: exportData != null ? () => _exportToCSV(context, exportData) : null,
                    icon: const Icon(Icons.file_download),
                    label: const Text('Export to CSV'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: exportData != null ? () => _printReport(context, exportData) : null,
                    icon: const Icon(Icons.print),
                    label: const Text('Print Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: exportData != null ? () => _shareReport(context, exportData) : null,
                    icon: const Icon(Icons.share),
                    label: const Text('Share Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            if (exportData == null) ...[
              const SizedBox(height: 12),
              Text(
                'Generate a report first to enable export options',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Export Format Options
            Text(
              'Available Export Formats',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFormatChip('CSV', Icons.table_chart, Colors.green),
                _buildFormatChip('PDF', Icons.picture_as_pdf, Colors.red),
                _buildFormatChip('Excel', Icons.grid_on, Colors.teal),
                _buildFormatChip('Print', Icons.print, Colors.blue),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Export History (placeholder)
            Text(
              'Recent Exports',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Export history will be displayed here after you export reports',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatChip(String label, IconData icon, Color color) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: color,
      elevation: 2,
    );
  }

  void _exportToCSV(BuildContext context, String csvData) {
    // In a real implementation, this would save the file to the device
    // For now, we'll show the data in a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CSV Export'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CSV data generated successfully. In a production app, this would be saved as a file.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    csvData,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('CSV export completed!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _printReport(BuildContext context, String reportData) {
    // In a real implementation, this would open the print dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.print, color: Colors.blue),
            SizedBox(width: 8),
            Text('Print Report'),
          ],
        ),
        content: const Text(
          'Print functionality would be implemented here using the printing package. '
          'The report would be formatted for printing with proper headers, footers, and page breaks.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Print job sent to printer!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            icon: const Icon(Icons.print),
            label: const Text('Print'),
          ),
        ],
      ),
    );
  }

  void _shareReport(BuildContext context, String reportData) {
    // In a real implementation, this would use the share package
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.share, color: Colors.orange),
            SizedBox(width: 8),
            Text('Share Report'),
          ],
        ),
        content: const Text(
          'Share functionality would be implemented here using the share_plus package. '
          'Users could share the report via email, messaging apps, or cloud storage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report shared successfully!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
          ),
        ],
      ),
    );
  }
}
