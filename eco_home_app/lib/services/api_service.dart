import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.0.13:3000'; // CAMBIA ESTA IP
  static const String socketUrl = 'http://192.168.0.13:4000'; // CAMBIA ESTA IP

  final String token;

  ApiService(this.token);

  Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar productos');
    }
  }

  Future<Product> createProduct(String name, double price) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': name, 'price': price}),
    );
    if (response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear producto');
    }
  }

  Future<int> getUserStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/me/stats'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['productCount'] as int;
    } else {
      throw Exception('Error al obtener estadísticas');
    }
  }
}