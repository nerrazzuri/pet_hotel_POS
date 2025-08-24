import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/cart_item.dart';
import 'package:cat_hotel_pos/features/pos/presentation/providers/pos_providers.dart';

class ProductGrid extends ConsumerStatefulWidget {
	const ProductGrid({super.key});

	@override
	ConsumerState<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends ConsumerState<ProductGrid> {
	String _selectedCategory = 'All';
	final TextEditingController _searchController = TextEditingController();
	String _searchQuery = '';

	final List<Map<String, dynamic>> _products = [
		{
			'id': 'boarding_single',
			'name': 'Single Room Boarding',
			'category': 'boarding',
			'price': 45.00,
			'icon': Icons.hotel,
			'color': Colors.blue,
			'petIcon': '🐱',
			'description': 'Comfortable single room for one pet',
			'duration': 'Per Night',
		},
		{
			'id': 'boarding_deluxe',
			'name': 'Deluxe Room Boarding',
			'category': 'boarding',
			'price': 65.00,
			'icon': Icons.hotel,
			'color': Colors.green,
			'petIcon': '🐕',
			'description': 'Spacious deluxe room with premium amenities',
			'duration': 'Per Night',
		},
		{
			'id': 'daycare_half',
			'name': 'Half Day Daycare',
			'category': 'daycare',
			'price': 25.00,
			'icon': Icons.sunny,
			'color': Colors.orange,
			'petIcon': '🐱',
			'description': '4 hours of supervised play and care',
			'duration': 'Half Day',
		},
		{
			'id': 'daycare_full',
			'name': 'Full Day Daycare',
			'category': 'daycare',
			'price': 35.00,
			'icon': Icons.sunny,
			'color': Colors.orange,
			'petIcon': '🐕',
			'description': '8 hours of supervised play and care',
			'duration': 'Full Day',
		},
		{
			'id': 'grooming_basic',
			'name': 'Basic Grooming',
			'category': 'grooming',
			'price': 40.00,
			'icon': Icons.content_cut,
			'color': Colors.teal,
			'petIcon': '🐕',
			'description': 'Bath, brush, and basic trim',
			'duration': 'Per Session',
		},
		{
			'id': 'grooming_premium',
			'name': 'Premium Grooming',
			'category': 'grooming',
			'price': 60.00,
			'icon': Icons.content_cut,
			'color': Colors.teal,
			'petIcon': '🐱',
			'description': 'Full grooming with styling and extras',
			'duration': 'Per Session',
		},
		// Add-on Services
		{
			'id': 'addon_extra_playtime',
			'name': 'Extra Playtime',
			'category': 'addons',
			'price': 15.00,
			'icon': Icons.sports_esports,
			'color': Colors.purple,
			'petIcon': '🎾',
			'description': 'Additional 30 minutes of supervised play',
			'duration': '30 min',
		},
		{
			'id': 'addon_webcam',
			'name': 'Pet Cam Access',
			'category': 'addons',
			'price': 10.00,
			'icon': Icons.videocam,
			'color': Colors.indigo,
			'petIcon': '📹',
			'description': '24/7 access to pet monitoring camera',
			'duration': 'Per Day',
		},
		{
			'id': 'addon_meds_admin',
			'name': 'Medication Administration',
			'category': 'addons',
			'price': 8.00,
			'icon': Icons.medication,
			'color': Colors.red,
			'petIcon': '💊',
			'description': 'Professional medication administration',
			'duration': 'Per Dose',
		},
		{
			'id': 'addon_special_diet',
			'name': 'Special Diet',
			'category': 'addons',
			'price': 12.00,
			'icon': Icons.restaurant,
			'color': Colors.amber,
			'petIcon': '🍽️',
			'description': 'Custom dietary requirements and feeding',
			'duration': 'Per Day',
		},
		{
			'id': 'addon_extra_walks',
			'name': 'Extra Walks',
			'category': 'addons',
			'price': 18.00,
			'icon': Icons.directions_walk,
			'color': Colors.lightGreen,
			'petIcon': '🚶',
			'description': 'Additional outdoor exercise and walks',
			'duration': 'Per Walk',
		},
		{
			'id': 'addon_photo_service',
			'name': 'Photo Service',
			'category': 'addons',
			'price': 20.00,
			'icon': Icons.camera_alt,
			'color': Colors.pink,
			'petIcon': '📸',
			'description': 'Professional pet photography session',
			'duration': 'Per Session',
		},
	];

	List<String> get _categories => ['All', ..._products.map((p) => p['category']).toSet()];

	List<Map<String, dynamic>> get _filteredProducts {
		List<Map<String, dynamic>> filtered = _products;
		
		// Filter by category
		if (_selectedCategory != 'All') {
			filtered = filtered.where((p) => p['category'] == _selectedCategory).toList();
		}
		
		// Filter by search query
		if (_searchQuery.isNotEmpty) {
			filtered = filtered.where((p) => 
				p['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
				p['description'].toLowerCase().contains(_searchQuery.toLowerCase())
			).toList();
		}
		
		return filtered;
	}

	@override
	Widget build(BuildContext context) {
		final theme = Theme.of(context);
		final colorScheme = theme.colorScheme;
		
		return Column(
			children: [
				// Enhanced Search and Filter Bar
				_buildSearchAndFilterBar(theme, colorScheme),
				
				// Products Grid
				Expanded(
					child: _filteredProducts.isEmpty
						? _buildEmptyState(theme, colorScheme)
						: _buildProductsGrid(theme, colorScheme),
				),
			],
		);
	}

	Widget _buildSearchAndFilterBar(ThemeData theme, ColorScheme colorScheme) {
		return Container(
			padding: const EdgeInsets.all(20),
			decoration: BoxDecoration(
				color: colorScheme.surface,
				borderRadius: const BorderRadius.only(
					topLeft: Radius.circular(20),
					topRight: Radius.circular(20),
				),
			),
			child: Column(
				children: [
					// Search Bar
					Container(
						decoration: BoxDecoration(
							color: colorScheme.surfaceVariant.withOpacity(0.3),
							borderRadius: BorderRadius.circular(16),
							border: Border.all(
								color: colorScheme.outline.withOpacity(0.2),
							),
						),
						child: TextField(
							controller: _searchController,
							onChanged: (value) => setState(() => _searchQuery = value),
							decoration: InputDecoration(
								hintText: 'Search services and products...',
								hintStyle: TextStyle(
									color: colorScheme.onSurfaceVariant.withOpacity(0.6),
								),
								prefixIcon: Icon(
									Icons.search,
									color: colorScheme.onSurfaceVariant.withOpacity(0.6),
								),
								border: InputBorder.none,
								contentPadding: const EdgeInsets.symmetric(
									horizontal: 20,
									vertical: 16,
								),
							),
						),
					),
					
					const SizedBox(height: 16),
					
					// Category Filter Chips
					SizedBox(
						height: 40,
						child: ListView.builder(
							scrollDirection: Axis.horizontal,
							itemCount: _categories.length,
							itemBuilder: (context, index) {
								final category = _categories[index];
								final isSelected = _selectedCategory == category;
								
								return Container(
									margin: const EdgeInsets.only(right: 12),
									child: FilterChip(
										label: Text(category),
										selected: isSelected,
										onSelected: (selected) {
											setState(() {
												_selectedCategory = selected ? category : 'All';
											});
										},
										selectedColor: colorScheme.primaryContainer,
										checkmarkColor: colorScheme.onPrimaryContainer,
										labelStyle: TextStyle(
											color: isSelected 
												? colorScheme.onPrimaryContainer
												: colorScheme.onSurface,
											fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
										),
										backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
										side: BorderSide(
											color: isSelected 
												? colorScheme.primary
												: colorScheme.outline.withOpacity(0.2),
										),
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(20),
										),
									),
								);
							},
						),
					),
				],
			),
		);
	}

	Widget _buildProductsGrid(ThemeData theme, ColorScheme colorScheme) {
		return GridView.builder(
			padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
			gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
				crossAxisCount: 4,
				childAspectRatio: 3.0,
				crossAxisSpacing: 12,
				mainAxisSpacing: 12,
			),
			itemCount: _filteredProducts.length,
			itemBuilder: (context, index) {
				final product = _filteredProducts[index];
				return _buildProductCard(product, theme, colorScheme);
			},
		);
	}

	Widget _buildProductCard(Map<String, dynamic> product, ThemeData theme, ColorScheme colorScheme) {
		return Container(
			decoration: BoxDecoration(
				color: colorScheme.surface,
				borderRadius: BorderRadius.circular(20),
				boxShadow: [
					BoxShadow(
						color: colorScheme.shadow.withOpacity(0.1),
						blurRadius: 15,
						offset: const Offset(0, 4),
					),
				],
				border: Border.all(
					color: colorScheme.outline.withOpacity(0.1),
				),
			),
			child: Material(
				color: Colors.transparent,
				child: InkWell(
					onTap: () => _addToCart(product),
					borderRadius: BorderRadius.circular(20),
					child: Padding(
						padding: const EdgeInsets.all(12),
						child: Row(
							children: [
								// Product Icon
								Container(
									padding: const EdgeInsets.all(8),
									decoration: BoxDecoration(
										color: product['color'].withOpacity(0.1),
										borderRadius: BorderRadius.circular(8),
										border: Border.all(
											color: product['color'].withOpacity(0.3),
										),
									),
									child: Icon(
										product['icon'],
										color: product['color'],
										size: 18,
									),
								),
								
								const SizedBox(width: 12),
								
								// Product Details
								Expanded(
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										mainAxisAlignment: MainAxisAlignment.center,
										children: [
											// Product Name
											Text(
												product['name'],
												style: theme.textTheme.titleSmall?.copyWith(
													fontWeight: FontWeight.bold,
													color: colorScheme.onSurface,
													fontSize: 13,
												),
												maxLines: 1,
												overflow: TextOverflow.ellipsis,
											),
											
											const SizedBox(height: 2),
											
											// Product Description
											Text(
												product['description'],
												style: theme.textTheme.bodySmall?.copyWith(
													color: colorScheme.onSurfaceVariant,
													fontSize: 10,
												),
												maxLines: 1,
												overflow: TextOverflow.ellipsis,
											),
											
											const SizedBox(height: 4),
											
											// Price and Duration
											Row(
												children: [
													Text(
														'\$${product['price'].toStringAsFixed(2)}',
														style: theme.textTheme.titleMedium?.copyWith(
															fontWeight: FontWeight.bold,
															color: product['color'],
															fontSize: 14,
														),
													),
													const SizedBox(width: 8),
													Container(
														padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
														decoration: BoxDecoration(
															color: product['color'].withOpacity(0.1),
															borderRadius: BorderRadius.circular(4),
														),
														child: Text(
															product['duration'],
															style: theme.textTheme.bodySmall?.copyWith(
																color: product['color'],
																fontSize: 9,
																fontWeight: FontWeight.w500,
															),
														),
													),
												],
											),
										],
									),
								),
								
								const SizedBox(width: 8),
								
								// Pet Icon
								Text(
									product['petIcon'],
									style: const TextStyle(fontSize: 16),
								),
								
								const SizedBox(width: 8),
								

							],
						),
					),
				),
			),
		);
	}

	Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
		return Center(
			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					Container(
						padding: const EdgeInsets.all(24),
						decoration: BoxDecoration(
							color: colorScheme.surfaceVariant.withOpacity(0.3),
							shape: BoxShape.circle,
						),
						child: Icon(
							Icons.search_off,
							size: 64,
							color: colorScheme.onSurfaceVariant.withOpacity(0.5),
						),
					),
					const SizedBox(height: 24),
					Text(
						'No products found',
						style: theme.textTheme.headlineSmall?.copyWith(
							color: colorScheme.onSurfaceVariant,
							fontWeight: FontWeight.w600,
						),
					),
					const SizedBox(height: 8),
					Text(
						'Try adjusting your search or category filter',
						style: theme.textTheme.bodyMedium?.copyWith(
							color: colorScheme.onSurfaceVariant.withOpacity(0.7),
						),
						textAlign: TextAlign.center,
					),
				],
			),
		);
	}

	  void _addToCart(Map<String, dynamic> product) {
    ref.read(currentCartProvider.notifier).addItemToCart(
      CartItem(
        id: product['id'],
        name: product['name'],
        type: product['category'], // Use category as type
        price: product['price'],
        quantity: 1,
        category: product['category'],
      ),
    );
		
		// Show success feedback
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Row(
					children: [
						Icon(
							Icons.check_circle,
							color: Colors.white,
							size: 20,
						),
						const SizedBox(width: 12),
						Text('${product['name']} added to cart'),
					],
				),
				backgroundColor: Colors.green[600],
				behavior: SnackBarBehavior.floating,
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(12),
				),
				margin: const EdgeInsets.all(16),
			),
		);
	}
}
