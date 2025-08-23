import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/core/services/service_dao.dart';
import 'package:cat_hotel_pos/core/services/product_dao.dart';
import 'package:cat_hotel_pos/core/services/service_package_dao.dart';
import 'package:cat_hotel_pos/core/services/product_bundle_dao.dart';

class ServicesAnalyticsTab extends ConsumerStatefulWidget {
  const ServicesAnalyticsTab({super.key});

  @override
  ConsumerState<ServicesAnalyticsTab> createState() => _ServicesAnalyticsTabState();
}

class _ServicesAnalyticsTabState extends ConsumerState<ServicesAnalyticsTab> {
  final ServiceDao _serviceDao = ServiceDao();
  final ProductDao _productDao = ProductDao();
  final ServicePackageDao _servicePackageDao = ServicePackageDao();
  final ProductBundleDao _productBundleDao = ProductBundleDao();
  
  bool _isLoading = true;
  Map<String, dynamic> _analytics = {};

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      final services = await _serviceDao.getAll();
      final products = await _productDao.getAll();
      final servicePackages = await _servicePackageDao.getAll();
      final productBundles = await _productBundleDao.getAll();

      final servicesByCategory = await _serviceDao.getServicesByCategory();
      final averagePriceByCategory = await _serviceDao.getAveragePriceByCategory();
      final productsByCategory = await _productDao.getProductsByCategory();
      final productsByStatus = await _productDao.getProductsByStatusCount();
      final averagePriceByProductCategory = await _productDao.getAveragePriceByCategory();
      final packagesByValidityPeriod = await _servicePackageDao.getPackagesByValidityPeriod();
      final averagePriceByValidityPeriod = await _servicePackageDao.getAveragePriceByValidityPeriod();
      final bundlesByDiscountRange = await _productBundleDao.getBundlesByDiscountRange();
      final averagePriceByDiscountRange = await _productBundleDao.getAveragePriceByDiscountRange();

      setState(() {
        _analytics = {
          'totalServices': services.length,
          'totalProducts': products.length,
          'totalServicePackages': servicePackages.length,
          'totalProductBundles': productBundles.length,
          'servicesByCategory': servicesByCategory,
          'averagePriceByCategory': averagePriceByCategory,
          'productsByCategory': productsByCategory,
          'productsByStatus': productsByStatus,
          'averagePriceByProductCategory': averagePriceByProductCategory,
          'packagesByValidityPeriod': packagesByValidityPeriod,
          'averagePriceByValidityPeriod': averagePriceByValidityPeriod,
          'bundlesByDiscountRange': bundlesByDiscountRange,
          'averagePriceByDiscountRange': averagePriceByDiscountRange,
          'totalServiceValue': services.fold(0.0, (sum, service) => sum + service.price),
          'totalProductValue': products.fold(0.0, (sum, product) => sum + (product.cost * product.stockQuantity)),
          'totalPackageValue': servicePackages.fold(0.0, (sum, package) => sum + package.price),
          'totalBundleValue': productBundles.fold(0.0, (sum, bundle) => sum + bundle.price),
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Services & Products Analytics',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Summary Cards
                  _buildSummaryCards(),
                  const SizedBox(height: 24),

                  // Services Analytics
                  _buildServicesAnalytics(),
                  const SizedBox(height: 24),

                  // Products Analytics
                  _buildProductsAnalytics(),
                  const SizedBox(height: 24),

                  // Packages Analytics
                  _buildPackagesAnalytics(),
                  const SizedBox(height: 24),

                  // Bundles Analytics
                  _buildBundlesAnalytics(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSummaryCard(
          'Total Services',
          _analytics['totalServices'].toString(),
          Icons.miscellaneous_services,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Total Products',
          _analytics['totalProducts'].toString(),
          Icons.inventory,
          Colors.green,
        ),
        _buildSummaryCard(
          'Service Packages',
          _analytics['totalServicePackages'].toString(),
          Icons.card_giftcard,
          Colors.purple,
        ),
        _buildSummaryCard(
          'Product Bundles',
          _analytics['totalProductBundles'].toString(),
          Icons.inventory_2,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesAnalytics() {
    final servicesByCategory = _analytics['servicesByCategory'] as Map<String, int>;
    final averagePriceByCategory = _analytics['averagePriceByCategory'] as Map<String, double>;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Services Analytics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsChart(
                    'Services by Category',
                    servicesByCategory,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAnalyticsChart(
                    'Average Price by Category',
                    averagePriceByCategory.map((key, value) => MapEntry(key, value.toStringAsFixed(2))),
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsAnalytics() {
    final productsByCategory = _analytics['productsByCategory'] as Map<String, int>;
    final productsByStatus = _analytics['productsByStatus'] as Map<String, int>;
    final averagePriceByProductCategory = _analytics['averagePriceByProductCategory'] as Map<String, double>;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Products Analytics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsChart(
                    'Products by Category',
                    productsByCategory,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAnalyticsChart(
                    'Products by Status',
                    productsByStatus,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAnalyticsChart(
              'Average Price by Product Category',
              averagePriceByProductCategory.map((key, value) => MapEntry(key, value.toStringAsFixed(2))),
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackagesAnalytics() {
    final packagesByValidityPeriod = _analytics['packagesByValidityPeriod'] as Map<String, int>;
    final averagePriceByValidityPeriod = _analytics['averagePriceByValidityPeriod'] as Map<String, double>;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Packages Analytics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsChart(
                    'Packages by Validity Period',
                    packagesByValidityPeriod,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAnalyticsChart(
                    'Average Price by Validity Period',
                    averagePriceByValidityPeriod.map((key, value) => MapEntry(key, value.toStringAsFixed(2))),
                    Colors.indigo,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBundlesAnalytics() {
    final bundlesByDiscountRange = _analytics['bundlesByDiscountRange'] as Map<String, int>;
    final averagePriceByDiscountRange = _analytics['averagePriceByDiscountRange'] as Map<String, double>;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Bundles Analytics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsChart(
                    'Bundles by Discount Range',
                    bundlesByDiscountRange,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAnalyticsChart(
                    'Average Price by Discount Range',
                    averagePriceByDiscountRange.map((key, value) => MapEntry(key, value.toStringAsFixed(2))),
                    Colors.teal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsChart(String title, Map<String, dynamic> data, Color color) {
    if (data.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text('No data available'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...data.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: LinearProgressIndicator(
                      value: _calculateProgressValue(data, entry.value),
                      backgroundColor: color.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  double _calculateProgressValue(Map<String, dynamic> data, dynamic value) {
    if (data.isEmpty) return 0.0;
    
    final maxValue = data.values.fold<dynamic>(
      0.0,
      (max, current) {
        final currentValue = current is String ? double.tryParse(current) ?? 0.0 : current.toDouble();
        return currentValue > max ? currentValue : max;
      },
    );
    
    if (maxValue == 0.0) return 0.0;
    
    final currentValue = value is String ? double.tryParse(value) ?? 0.0 : value.toDouble();
    return currentValue / maxValue;
  }
}
