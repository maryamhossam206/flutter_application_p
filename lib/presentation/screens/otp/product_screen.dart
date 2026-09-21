import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // 👈 لتفعيل الانتقال بالـ GoRouter
import 'package:http/http.dart' as http;
import 'package:flutter_application_p/core/network/api/endpoints.dart';
import 'product_details_screen.dart';

class ProductScreen extends StatefulWidget {
  final String? token;

  const ProductScreen({super.key, this.token});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _products = [];
  List<dynamic> _categories = [];
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.wait([
        _fetchProducts(),
        _fetchCategories(),
      ]);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchProducts() async {
    final url = Uri.parse('${Endpoints.baseUrl}${Endpoints.products}');
    final headers = <String, String>{'Accept': 'application/json'};

    if (widget.token != null && widget.token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${widget.token}';
    }

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      if (decodedData is List) {
        _products = decodedData;
      } else if (decodedData is Map<String, dynamic>) {
        _products = decodedData['data'] ??
            decodedData['items'] ??
            decodedData['products'] ??
            [];
      }
    } else {
      throw 'فشل تحميل المنتجات (${response.statusCode})';
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final url = Uri.parse('${Endpoints.baseUrl}${Endpoints.categories}');
      
      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      if (widget.token != null && widget.token!.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${widget.token}';
      }

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        List<dynamic> fetchedList = [];

        if (decodedData is List) {
          fetchedList = decodedData;
        } else if (decodedData is Map<String, dynamic>) {
          fetchedList = decodedData['data'] ?? 
                        decodedData['\$values'] ?? 
                        decodedData['items'] ?? 
                        decodedData['categories'] ?? 
                        decodedData['result'] ?? 
                        [];
        }

        if (mounted) {
          setState(() {
            _categories = fetchedList;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _categories = [];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _categories = [];
        });
      }
    }
  }

  String? _getFormattedImageUrl(dynamic imagePath) {
    if (imagePath == null || imagePath.toString().isEmpty) return null;
    String path = imagePath.toString();
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    return '${Endpoints.baseUrl}$path';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Accessories Shop'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // 🟢 1. زرار الـ Settings ثابت في الـ AppBar
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      // 🟢 2. زرار ثابت على الشاشة (Floating) مهما حصل Scroll يظل ثابتاً في الأسفل
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.settings, color: Colors.white),
        onPressed: () {
          context.push('/settings');
        },
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchData,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_categories.isNotEmpty) _buildCategorySlidesSection(),
          Expanded(
            child: _products.isEmpty
                ? const Center(child: Text('لا توجد منتجات متاحة حالياً'))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];

                      final String name = product['name'] ??
                          product['productName'] ??
                          product['title'] ??
                          'منتج بدون اسم';
                      final dynamic price =
                          product['price'] ?? product['unitPrice'] ?? 0;

                      final String? rawImageUrl = product['imageUrl'] ??
                          product['image'] ??
                          product['coverUrl'] ??
                          product['pictureUrl'];
                      final String? imageUrl = _getFormattedImageUrl(rawImageUrl);

                      final String? description = product['description'];

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailsScreen(product: product),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                  child: Container(
                                    width: double.infinity,
                                    color: Colors.grey[200],
                                    child: imageUrl != null
                                        ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(Icons.watch,
                                                        size: 50,
                                                        color: Colors.grey),
                                          )
                                        : const Icon(
                                            Icons.shopping_bag_outlined,
                                            size: 50,
                                            color: Colors.grey),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (description != null &&
                                        description.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '\$$price',
                                          style: TextStyle(
                                            color: Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'تمت إضافة $name إلى السلة!'),
                                                duration:
                                                    const Duration(seconds: 1),
                                              ),
                                            );
                                          },
                                          child: CircleAvatar(
                                            radius: 14,
                                            backgroundColor:
                                                Theme.of(context).primaryColor,
                                            child: const Icon(Icons.add,
                                                size: 18, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
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

  Widget _buildCategorySlidesSection() {
    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final isSelected = _selectedCategoryIndex == index;
            final category = _categories[index];

            String categoryName = 'قسم';
            if (category is Map) {
              categoryName = category['name'] ??
                  category['title'] ??
                  category['categoryName'] ??
                  'قسم';
            } else if (category is String) {
              categoryName = category;
            }

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300]!,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      categoryName,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}