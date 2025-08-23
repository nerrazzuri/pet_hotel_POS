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
		},
		{
			'id': 'boarding_deluxe',
			'name': 'Deluxe Room Boarding',
			'category': 'boarding',
			'price': 65.00,
			'icon': Icons.hotel,
			'color': Colors.green,
			'petIcon': '🐕',
		},
		{
			'id': 'daycare_half',
			'name': 'Half Day Daycare',
			'category': 'daycare',
			'price': 25.00,
			'icon': Icons.sunny,
			'color': Colors.orange,
			'petIcon': '🐱',
		},
		{
			'id': 'daycare_full',
			'name': 'Full Day Daycare',
			'category': 'daycare',
			'price': 35.00,
			'icon': Icons.sunny,
			'color': Colors.orange,
			'petIcon': '🐕',
		},
		{
			'id': 'grooming_basic',
			'name': 'Basic Grooming',
			'category': 'grooming',
			'price': 40.00,
			'icon': Icons.content_cut,
			'color': Colors.teal,
			'petIcon': '🐕',
		},
		{
			'id': 'grooming_premium',
			'name': 'Premium Grooming',
			'category': 'grooming',
			'price': 60.00,
			'icon': Icons.content_cut,
			'color': Colors.teal,
			'petIcon': '🐱',
		},
		// Add-on Services
		{
			'id': 'addon_extra_playtime',
			'name': 'Extra Playtime (30 min)',
			'category': 'addons',
			'price': 15.00,
			'icon': Icons.sports_esports,
			'color': Colors.purple,
			'petIcon': '🎾',
		},
		{
			'id': 'addon_webcam',
			'name': 'Pet Cam Access',
			'category': 'addons',
			'price': 10.00,
			'icon': Icons.videocam,
			'color': Colors.indigo,
			'petIcon': '📹',
		},
		{
			'id': 'addon_meds_admin',
			'name': 'Medication Administration',
			'category': 'addons',
			'price': 8.00,
			'icon': Icons.medication,
			'color': Colors.red,
			'petIcon': '💊',
		},
		{
			'id': 'addon_special_diet',
			'name': 'Special Diet Preparation',
			'category': 'addons',
			'price': 12.00,
			'icon': Icons.restaurant,
			'color': Colors.brown,
			'petIcon': '🍽️',
		},
		// Retail Products
		{
			'id': 'retail_food_premium',
			'name': 'Premium Pet Food (1kg)',
			'category': 'retail',
			'price': 25.00,
			'icon': Icons.shopping_bag,
			'color': Colors.amber,
			'petIcon': '🦴',
		},
		{
			'id': 'retail_treats',
			'name': 'Pet Treats Pack',
			'category': 'retail',
			'price': 8.50,
			'icon': Icons.shopping_bag,
			'color': Colors.amber,
			'petIcon': '🍖',
		},
		{
			'id': 'retail_toys',
			'name': 'Pet Toys',
			'category': 'retail',
			'price': 12.00,
			'icon': Icons.shopping_bag,
			'color': Colors.amber,
			'petIcon': '🧸',
		},
	];

	List<Map<String, dynamic>> get _filteredProducts {
		return _products.where((product) {
			final matchesCategory = _selectedCategory == 'All' || product['category'] == _selectedCategory;
			final matchesSearch = _searchQuery.isEmpty || 
				product['name'].toLowerCase().contains(_searchQuery.toLowerCase());
			return matchesCategory && matchesSearch;
		}).toList();
	}

	void _addToCart(Map<String, dynamic> product) {
		// For boarding services, show duration selector
		if (product['category'] == 'boarding') {
			_showBoardingDurationDialog(product);
		} else {
			_addItemToCart(product, 1);
		}
	}

	void _addItemToCart(Map<String, dynamic> product, int quantity) {
		final cartItem = CartItem(
			id: product['id'],
			name: product['name'],
			type: product['category'],
			price: product['price'].toDouble(),
			quantity: quantity,
			category: product['category'],
		);

		ref.read(currentCartProvider.notifier).addItemToCart(cartItem);

		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Text('${product['name']} (${quantity} ${product['category'] == 'boarding' ? 'nights' : 'items'}) added to cart'),
				backgroundColor: Colors.green,
				duration: const Duration(seconds: 1),
			),
		);
	}

	void _showBoardingDurationDialog(Map<String, dynamic> product) {
		int nights = 1;
		
		showDialog(
			context: context,
			builder: (context) => StatefulBuilder(
				builder: (context, setState) {
					return AlertDialog(
						title: Text('Select Boarding Duration'),
						content: Column(
							mainAxisSize: MainAxisSize.min,
							children: [
								Text(
									product['name'],
									style: const TextStyle(
										fontSize: 18,
										fontWeight: FontWeight.bold,
									),
								),
								const SizedBox(height: 16),
								Row(
									mainAxisAlignment: MainAxisAlignment.center,
									children: [
										IconButton(
											onPressed: () {
												if (nights > 1) {
													setState(() {
														nights--;
													});
												}
											},
											icon: const Icon(Icons.remove_circle_outline),
											iconSize: 32,
										),
										Container(
											padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
											decoration: BoxDecoration(
												color: Colors.teal.shade50,
												borderRadius: BorderRadius.circular(8),
											),
											child: Text(
												'$nights ${nights == 1 ? 'night' : 'nights'}',
												style: TextStyle(
													fontSize: 24,
													fontWeight: FontWeight.bold,
													color: Colors.teal.shade800,
												),
											),
										),
										IconButton(
											onPressed: () {
												setState(() {
													nights++;
												});
											},
											icon: const Icon(Icons.add_circle_outline),
											iconSize: 32,
											color: Colors.teal,
										),
									],
								),
								const SizedBox(height: 16),
								Text(
									'Total: \$${(product['price'] * nights).toStringAsFixed(2)}',
									style: const TextStyle(
										fontSize: 18,
										fontWeight: FontWeight.bold,
										color: Colors.green,
									),
								),
							],
						),
						actions: [
							TextButton(
								onPressed: () => Navigator.pop(context),
								child: const Text('Cancel'),
							),
							ElevatedButton(
								onPressed: () {
									Navigator.pop(context);
									_addItemToCart(product, nights);
								},
								style: ElevatedButton.styleFrom(
									backgroundColor: Colors.teal,
									foregroundColor: Colors.white,
								),
								child: const Text('Add to Cart'),
							),
						],
					);
				},
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Column(
			children: [
				// Sticky Category Tabs with Icons
				Container(
					padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
					decoration: BoxDecoration(
						color: Colors.grey[50],
						border: Border(
							bottom: BorderSide(color: Colors.grey[300]!, width: 1),
						),
					),
					child: Row(
						children: [
							_CategoryChip(
								label: 'All',
								icon: Icons.grid_view,
								isSelected: _selectedCategory == 'All',
								onTap: () => setState(() => _selectedCategory = 'All'),
							),
							const SizedBox(width: 8),
							_CategoryChip(
								label: 'Boarding',
								icon: Icons.hotel,
								isSelected: _selectedCategory == 'boarding',
								onTap: () => setState(() => _selectedCategory = 'boarding'),
							),
							const SizedBox(width: 8),
							_CategoryChip(
								label: 'Daycare',
								icon: Icons.sunny,
								isSelected: _selectedCategory == 'daycare',
								onTap: () => setState(() => _selectedCategory = 'daycare'),
							),
							const SizedBox(width: 8),
							_CategoryChip(
								label: 'Grooming',
								icon: Icons.content_cut,
								isSelected: _selectedCategory == 'grooming',
								onTap: () => setState(() => _selectedCategory = 'grooming'),
							),
						],
					),
				),

				// Search Bar
				Container(
					padding: const EdgeInsets.all(16),
					child: TextField(
						controller: _searchController,
						onChanged: (value) => setState(() => _searchQuery = value),
						decoration: InputDecoration(
							hintText: 'Search services...',
							prefixIcon: const Icon(Icons.search),
							border: OutlineInputBorder(
								borderRadius: BorderRadius.circular(12),
								borderSide: BorderSide(color: Colors.grey[300]!),
							),
							enabledBorder: OutlineInputBorder(
								borderRadius: BorderRadius.circular(12),
								borderSide: BorderSide(color: Colors.grey[300]!),
							),
							focusedBorder: OutlineInputBorder(
								borderRadius: BorderRadius.circular(12),
								borderSide: BorderSide(color: Colors.teal, width: 2),
							),
							filled: true,
							fillColor: Colors.grey[50],
							contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
						),
					),
				),
				
				// Products Grid
				Expanded(
					child: LayoutBuilder(
						builder: (context, constraints) {
							final width = constraints.maxWidth;
							int crossAxisCount = 3;
							if (width >= 1600) {
								crossAxisCount = 6;
							} else if (width >= 1400) {
								crossAxisCount = 5;
							} else if (width >= 1000) {
								crossAxisCount = 4;
							} else if (width >= 700) {
								crossAxisCount = 3;
							} else {
								crossAxisCount = 2;
							}
							return GridView.builder(
								padding: const EdgeInsets.all(12),
								gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
									crossAxisCount: crossAxisCount,
									childAspectRatio: 1.35,
									crossAxisSpacing: 12,
									mainAxisSpacing: 12,
								),
								itemCount: _filteredProducts.length,
								itemBuilder: (context, index) {
									final product = _filteredProducts[index];
									return _ProductCard(
										product: product,
										onTap: () => _addToCart(product),
									);
								},
							);
						},
					),
				),
			],
		);
	}

	@override
	void dispose() {
		_searchController.dispose();
		super.dispose();
	}
}

class _CategoryChip extends StatelessWidget {
	final String label;
	final IconData icon;
	final bool isSelected;
	final VoidCallback onTap;

	const _CategoryChip({
		required this.label,
		required this.icon,
		required this.isSelected,
		required this.onTap,
	});

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onTap: onTap,
			child: Container(
				padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
				decoration: BoxDecoration(
					color: isSelected ? Colors.teal : Colors.grey[200],
					borderRadius: BorderRadius.circular(25),
					boxShadow: isSelected ? [
						BoxShadow(
							color: Colors.teal.withOpacity(0.3),
							blurRadius: 8,
							offset: const Offset(0, 2),
						)
					] : null,
				),
				child: Row(
					mainAxisSize: MainAxisSize.min,
					children: [
						Icon(
							icon,
							size: 18,
							color: isSelected ? Colors.white : Colors.grey[700],
						),
						const SizedBox(width: 6),
						Text(
							label,
							style: TextStyle(
								color: isSelected ? Colors.white : Colors.grey[700],
								fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
								fontSize: 14,
							),
						),
					],
				),
			),
		);
	}
}

class _ProductCard extends StatelessWidget {
	final Map<String, dynamic> product;
	final VoidCallback onTap;

	const _ProductCard({
		required this.product,
		required this.onTap,
	});

	@override
	Widget build(BuildContext context) {
		return Card(
			elevation: 2,
			color: Colors.white,
			shadowColor: Colors.black.withOpacity(0.08),
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.circular(14),
				side: BorderSide(color: Colors.grey[300]!, width: 1),
			),
			child: InkWell(
				onTap: onTap,
				borderRadius: BorderRadius.circular(14),
				child: Container(
					padding: const EdgeInsets.all(12),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							// Pet Icon and Service Icon Row
							Row(
								mainAxisAlignment: MainAxisAlignment.spaceBetween,
								children: [
									Text(
										product['petIcon'],
										style: const TextStyle(fontSize: 18),
									),
									Icon(
										product['icon'],
										size: 18,
										color: product['color'],
									),
								],
							),

							const SizedBox(height: 10),

							// Service Name
							Text(
								product['name'],
								style: const TextStyle(
									fontWeight: FontWeight.bold,
									fontSize: 14,
									height: 1.2,
								),
								maxLines: 2,
								overflow: TextOverflow.ellipsis,
							),

							const SizedBox(height: 6),

							// Price
							Text(
								'\$${product['price'].toStringAsFixed(2)}',
								style: TextStyle(
									color: Colors.grey[700],
									fontWeight: FontWeight.w600,
									fontSize: 16,
								),
							),
						],
					),
				),
			),
		);
	}
}
