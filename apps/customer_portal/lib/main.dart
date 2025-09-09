import 'package:flutter/material.dart';
import 'package:customer_portal/api/api_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cat Hotel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _api = ApiClient();
  DateTimeRange? _range;
  int _petCount = 1;
  String _petType = 'Cat';
  String _roomType = 'standard';
  String? _quoteText;
  List<Map<String, dynamic>> _roomTypes = const [];
  List<Map<String, dynamic>> _reviews = const [];
  List<String> _policies = const [];
  List<String> _faqs = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final types = await _api.getRoomTypes();
      final reviews = await _api.getReviews();
      final policies = await _api.getPolicies();
      final faqs = await _api.getFaqs();
      setState(() {
        _roomTypes = types;
        _reviews = reviews;
        _policies = policies;
        _faqs = faqs;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _range ?? DateTimeRange(start: now, end: now.add(const Duration(days: 1))),
    );
    if (picked != null) setState(() => _range = picked);
  }

  Future<void> _checkAvailability() async {
    final range = _range ?? DateTimeRange(start: DateTime.now(), end: DateTime.now().add(const Duration(days: 1)));
    final res = await _api.availabilityQuote(
      start: range.start,
      end: range.end,
      petCount: _petCount,
      petType: _petType,
      roomType: _roomType,
    );
    setState(() => _quoteText = 'Available: ${res['available']}  Total: ${res['price']['total']}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    return Scaffold(
      backgroundColor: color.surface,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // HERO
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.primary, color.primaryContainer],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, cons) {
                        final isWide = cons.maxWidth > 900;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: isWide ? 3 : 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Comfort Stays for Your Cat',
                                      style: theme.textTheme.displaySmall?.copyWith(color: color.onPrimary, fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Safe, cozy rooms. Grooming, playtime, webcams. Book online in seconds.',
                                    style: theme.textTheme.titleMedium?.copyWith(color: color.onPrimary.withOpacity(0.9)),
                                  ),
                                  const SizedBox(height: 20),
                                  Wrap(
                                    runSpacing: 12,
                                    spacing: 12,
                                    children: [
                                      SizedBox(
                                        width: 240,
                                        child: OutlinedButton.icon(
                                          onPressed: _pickRange,
                                          icon: const Icon(Icons.event),
                                          label: Text(_range == null
                                              ? 'Select dates'
                                              : '${_range!.start.toString().substring(0, 10)} - ${_range!.end.toString().substring(0, 10)}'),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 140,
                                        child: DropdownButtonFormField<int>(
                                          value: _petCount,
                                          decoration: const InputDecoration(labelText: 'Pets'),
                                          items: List.generate(6, (i) => i + 1)
                                              .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                                              .toList(),
                                          onChanged: (v) => setState(() => _petCount = v ?? 1),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 160,
                                        child: DropdownButtonFormField<String>(
                                          value: _petType,
                                          decoration: const InputDecoration(labelText: 'Pet Type'),
                                          items: const [DropdownMenuItem(value: 'Cat', child: Text('Cat')), DropdownMenuItem(value: 'Dog', child: Text('Dog'))],
                                          onChanged: (v) => setState(() => _petType = v ?? 'Cat'),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 180,
                                        child: DropdownButtonFormField<String>(
                                          value: _roomType,
                                          decoration: const InputDecoration(labelText: 'Room Type'),
                                          items: const [
                                            DropdownMenuItem(value: 'standard', child: Text('Standard')),
                                            DropdownMenuItem(value: 'deluxe', child: Text('Deluxe')),
                                            DropdownMenuItem(value: 'suite', child: Text('Suite')),
                                          ],
                                          onChanged: (v) => setState(() => _roomType = v ?? 'standard'),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: _checkAvailability,
                                        child: const Text('Check Availability'),
                                      ),
                                    ],
                                  ),
                                  if (_quoteText != null) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(_quoteText!, style: theme.textTheme.titleMedium?.copyWith(color: color.onPrimary)),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (isWide) const SizedBox(width: 24),
                            if (isWide)
                              Expanded(
                                flex: 2,
                                child: AspectRatio(
                                  aspectRatio: 4 / 3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white.withOpacity(0.15),
                                    ),
                                    child: const Icon(Icons.pets, size: 96, color: Colors.white),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),

                  // FEATURES
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Why Choose Us', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: const [
                            _FeatureCard(icon: Icons.videocam, title: 'Webcam Access', subtitle: 'Peek in anytime'),
                            _FeatureCard(icon: Icons.spa, title: 'Grooming Care', subtitle: 'Pro grooming add-ons'),
                            _FeatureCard(icon: Icons.toys, title: 'Playtime', subtitle: 'Daily play sessions'),
                            _FeatureCard(icon: Icons.verified_user, title: 'Vaccination Check', subtitle: 'Safety-first policy'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ROOM TYPES & PRICING
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Room Types & Pricing', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _roomTypes.map((t) {
                            final code = (t['code'] as String?) ?? 'standard';
                            final name = (t['name'] as String?) ?? code;
                            final base = (t['basePrice'] as num?)?.toDouble() ?? 0;
                            final selected = _roomType == code;
                            return GestureDetector(
                              onTap: () => setState(() => _roomType = code),
                              child: Container(
                                width: 260,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: selected ? Colors.teal : Colors.grey.shade300, width: selected ? 2 : 1),
                                  color: selected ? Colors.teal.withOpacity(0.06) : Colors.white,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                        if (selected) const Icon(Icons.check_circle, color: Colors.teal, size: 18),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text('From RM ${base.toStringAsFixed(2)}/night', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 6),
                                    const Text('Includes: cozy bed, daily cleaning, fresh water'),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        OutlinedButton(onPressed: () => setState(() => _roomType = code), child: const Text('Select')),
                                        const SizedBox(width: 8),
                                        TextButton(onPressed: _checkAvailability, child: const Text('Quick Quote')),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // TESTIMONIALS
                  Container(
                    color: color.surfaceVariant,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('What Owners Say', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _reviews.map((r) {
                            final author = (r['author'] as String?) ?? 'Owner';
                            final rating = (r['rating'] as num?)?.toInt() ?? 5;
                            final comment = (r['comment'] as String?) ?? '';
                            return _Testimonial(author: author, rating: rating, comment: comment);
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // POLICIES & FAQ
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    child: LayoutBuilder(builder: (context, cons) {
                      final wide = cons.maxWidth > 900;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Policies', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                                const SizedBox(height: 8),
                                ..._policies.map((p) => Row(children: [const Icon(Icons.policy, size: 16), const SizedBox(width: 6), Expanded(child: Text(p))])),
                              ],
                            ),
                          ),
                          if (wide) const SizedBox(width: 24) else const SizedBox(height: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('FAQs', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                                const SizedBox(height: 8),
                                ..._faqs.map((q) => Row(children: [const Icon(Icons.help_outline, size: 16), const SizedBox(width: 6), Expanded(child: Text(q))])),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),

                  // CONTACT & FOOTER
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    color: color.inverseSurface.withOpacity(0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contact Us', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.chat), label: const Text('WhatsApp')), 
                            OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.phone), label: const Text('Call')),
                            TextButton.icon(onPressed: () {}, icon: const Icon(Icons.email_outlined), label: const Text('Email')),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('© Cat Hotel'),
                            DropdownButton<String>(
                              value: 'EN',
                              items: const [DropdownMenuItem(value: 'EN', child: Text('EN')), DropdownMenuItem(value: 'ZH', child: Text('中文'))],
                              onChanged: (_) {},
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Testimonial extends StatelessWidget {
  const _Testimonial({required this.author, required this.rating, required this.comment});
  final String author;
  final int rating;
  final String comment;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: Colors.teal),
              const SizedBox(width: 8),
              Expanded(child: Text(author, style: const TextStyle(fontWeight: FontWeight.w700))),
              Row(children: List.generate(5, (i) => Icon(i < rating ? Icons.star : Icons.star_border, size: 16, color: Colors.amber))),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment),
        ],
      ),
    );
  }
}
