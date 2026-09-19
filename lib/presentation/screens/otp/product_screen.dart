import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_application_p/core/network/api/api_consumer.dart';
import 'package:flutter_application_p/data/datasources/dio_consumer.dart';
import 'package:flutter_application_p/core/network/api/endpoints.dart';

class ProductScreen extends StatefulWidget {
  final String? token;

  const ProductScreen({super.key, this.token});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late final ApiConsumer _apiConsumer;
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _products = [];

  @override
  void initState() {
    super.initState();
    _apiConsumer = DioConsumer(dio: Dio());
    _fetchProducts();
  }

 Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 🟢 تعديل الطلب ليصبح GET لجلب وعرض المنتجات بشكل صحيح
      final response = await _apiConsumer.get(
        Endpoints.products,
        token: widget.token,
      );

      setState(() {
        if (response is List) {
          _products = response;
        } else if (response is Map) {
          _products = response['data'] ?? response['items'] ?? response['products'] ?? [];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Accessories Shop'),
        centerTitle: true,
        elevation: 0,
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
                onPressed: _fetchProducts,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return const Center(
        child: Text('لا توجد منتجات متاحة حالياً'),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchProducts,
      child: GridView.builder(
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

          final String name = product['name'] ?? product['title'] ?? 'منتج بدون اسم';
          final dynamic price = product['price'] ?? 0;
          final String? imageUrl = product['imageUrl'] ?? product['image'] ?? product['coverUrl'];
          final String? description = product['description'];

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.watch, size: 50, color: Colors.grey),
                            )
                          : const Icon(Icons.shopping_bag_outlined, size: 50, color: Colors.grey),
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
                      if (description != null) ...[
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              // إظهار رسالة إضافة المنتج إلى السلة
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('تمت إضافة $name إلى السلة!'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: const Icon(Icons.add, size: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}