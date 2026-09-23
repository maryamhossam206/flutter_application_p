import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_p/core/network/api/endpoints.dart';

class CartScreen extends StatefulWidget {
  final String? token;

  const CartScreen({super.key, this.token});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _cartItems = [];
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  Future<void> _fetchCart() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url = Uri.parse('${Endpoints.baseUrl}${Endpoints.cart}');
      final headers = <String, String>{
        'Accept': 'application/json',
      };

      // 🔑 قراءة التوكن المحفوظ إن لم يكن ممرراً
      String? authToken = widget.token;
      if (authToken == null || authToken.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        authToken = prefs.getString('auth_token');
      }

      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        
        List<dynamic> items = [];
        if (decodedData is List) {
          items = decodedData;
        } else if (decodedData is Map<String, dynamic>) {
          items = decodedData['items'] ?? 
                  decodedData['cartItems'] ?? 
                  decodedData['data'] ?? 
                  decodedData['products'] ?? [];
        }

        _calculateTotal(items);

        if (mounted) {
          setState(() {
            _cartItems = items;
          });
        }
      } else if (response.statusCode == 401) {
        throw 'يرجى تسجيل الدخول لعرض السلة';
      } else {
        throw 'فشل تحميل السلة (${response.statusCode})';
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _calculateTotal(List<dynamic> items) {
    double total = 0.0;
    for (var item in items) {
      final priceNum = item['price'] ?? 
                       item['unitPrice'] ?? 
                       item['product']?['price'] ?? 0;
      final price = (priceNum is num) ? priceNum.toDouble() : double.tryParse(priceNum.toString()) ?? 0.0;
      
      final quantityNum = item['quantity'] ?? item['count'] ?? 1;
      final quantity = (quantityNum is num) ? quantityNum.toInt() : int.tryParse(quantityNum.toString()) ?? 1;
      
      total += price * quantity;
    }
    _totalPrice = total;
  }

  String? _getFormattedImageUrl(dynamic rawImage) {
    if (rawImage == null || rawImage.toString().trim().isEmpty) return null;
    String path = rawImage.toString().trim();
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    return '${Endpoints.baseUrl}$path';
  }

  Future<void> _updateQuantity(dynamic cartItemId, int newQuantity) async {
    if (newQuantity < 1) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = widget.token ?? prefs.getString('auth_token');

      final url = Uri.parse('${Endpoints.baseUrl}${Endpoints.cart}/$cartItemId');
      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode({'quantity': newQuantity}),
      );

      _fetchCart();
    } catch (e) {
      _fetchCart();
    }
  }

  Future<void> _removeItem(dynamic cartItemId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = widget.token ?? prefs.getString('auth_token');

      final url = Uri.parse('${Endpoints.baseUrl}${Endpoints.cart}/$cartItemId');
      final headers = <String, String>{
        'Accept': 'application/json',
      };
      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      await http.delete(url, headers: headers);
      _fetchCart();
    } catch (e) {
      _fetchCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('سلة المشتريات'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: _cartItems.isEmpty ? null : _buildCheckoutBottomBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchCart,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_cartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'السلة فارغة حالياً',
              style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchCart,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _cartItems.length,
        itemBuilder: (context, index) {
          final item = _cartItems[index];

          final itemId = item['id'] ?? item['cartItemId'] ?? item['productId'] ?? item['product']?['id'];
          final name = item['productName'] ?? item['name'] ?? item['title'] ?? item['product']?['name'] ?? 'منتج';
          
          final priceNum = item['price'] ?? item['unitPrice'] ?? item['product']?['price'] ?? 0;
          final price = (priceNum is num) ? priceNum.toDouble() : double.tryParse(priceNum.toString()) ?? 0.0;
          
          final quantityNum = item['quantity'] ?? item['count'] ?? 1;
          final quantity = (quantityNum is num) ? quantityNum.toInt() : int.tryParse(quantityNum.toString()) ?? 1;

          dynamic rawImage = item['coverPictureUrl'] ?? 
                             item['imageUrl'] ?? 
                             item['image'] ?? 
                             item['coverUrl'] ?? 
                             item['product']?['coverPictureUrl'] ?? 
                             item['product']?['imageUrl'] ?? 
                             item['product']?['image'];
                             
          if (rawImage == null && item['product']?['productPictures'] is List && (item['product']['productPictures'] as List).isNotEmpty) {
            rawImage = item['product']['productPictures'][0];
          } else if (rawImage == null && item['product']?['images'] is List && (item['product']['images'] as List).isNotEmpty) {
            rawImage = item['product']['images'][0];
          }

          if (rawImage is Map) {
            rawImage = rawImage['url'] ?? rawImage['imageUrl'] ?? rawImage['path'];
          }

          final imageUrl = _getFormattedImageUrl(rawImage);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey),
                            )
                          : const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$$price',
                          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 22),
                        onPressed: () => _updateQuantity(itemId, quantity - 1),
                      ),
                      Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 22),
                        onPressed: () => _updateQuantity(itemId, quantity + 1),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                        onPressed: () => _removeItem(itemId),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCheckoutBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('الإجمالي:', style: TextStyle(color: Colors.grey, fontSize: 13)),
              Text(
                '\$${_totalPrice.toStringAsFixed(2)}',
                style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('جاري الانتقال لإتمام الطلب...')),
              );
            },
            child: const Text('إتمام الشراء', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}