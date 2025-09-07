import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InstantBookingWidget extends StatefulWidget {
  const InstantBookingWidget({super.key});

  @override
  State<InstantBookingWidget> createState() => _InstantBookingWidgetState();
}

class _InstantBookingWidgetState extends State<InstantBookingWidget> {
  DateTimeRange? _dateRange;
  int _petCount = 1;
  String _petType = 'Cat';
  String _roomType = 'Standard';

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _dateRange ?? DateTimeRange(start: now, end: nextWeek),
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  String _formatRange(DateTimeRange? range) {
    if (range == null) return 'Select dates';
    final df = DateFormat('dd MMM yyyy');
    return '${df.format(range.start)} - ${df.format(range.end)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Instant Booking',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),

        // Form row
        Wrap(
          runSpacing: 12,
          spacing: 12,
          children: [
            // Date range
            SizedBox(
              width: 260,
              child: OutlinedButton.icon(
                onPressed: _pickDateRange,
                icon: const Icon(Icons.event),
                label: Text(_formatRange(_dateRange)),
              ),
            ),

            // Pet count
            SizedBox(
              width: 160,
              child: DropdownButtonFormField<int>(
                value: _petCount,
                decoration: const InputDecoration(labelText: 'Pets'),
                items: List.generate(6, (i) => i + 1)
                    .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                    .toList(),
                onChanged: (v) => setState(() => _petCount = v ?? 1),
              ),
            ),

            // Pet type
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<String>(
                value: _petType,
                decoration: const InputDecoration(labelText: 'Pet Type'),
                items: const [
                  DropdownMenuItem(value: 'Cat', child: Text('Cat')),
                  DropdownMenuItem(value: 'Dog', child: Text('Dog')),
                ],
                onChanged: (v) => setState(() => _petType = v ?? 'Cat'),
              ),
            ),

            // Room type
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<String>(
                value: _roomType,
                decoration: const InputDecoration(labelText: 'Room Type'),
                items: const [
                  DropdownMenuItem(value: 'Standard', child: Text('Standard')),
                  DropdownMenuItem(value: 'Deluxe', child: Text('Deluxe')),
                  DropdownMenuItem(value: 'Suite', child: Text('Suite')),
                ],
                onChanged: (v) => setState(() => _roomType = v ?? 'Standard'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Action buttons
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                // TODO: Hook to live availability + price
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Checking availability...')),
                );
              },
              child: const Text('Book Now'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hold with deposit (coming soon)')),
                );
              },
              child: const Text('Hold with Deposit'),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('We will contact you shortly.')),
                );
              },
              child: const Text('Enquire'),
            ),
          ],
        ),
      ],
    );
  }
}


