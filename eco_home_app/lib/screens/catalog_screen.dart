import 'package:flutter/material.dart';
import 'package:eco_home_app/models/product.dart';
import 'package:eco_home_app/services/api_service.dart';
import 'package:eco_home_app/services/auth_service.dart';
import 'package:eco_home_app/screens/chat_screen.dart';

class CatalogScreen extends StatefulWidget {
  final String token;
  final String username;
  const CatalogScreen({super.key, required this.token, required this.username});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late ApiService api;
  List<Product> products = [];
  bool loading = true;
  int productCount = 0;

  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    api = ApiService(widget.token);
    loadData();
  }

  Future<void> loadData() async {
    setState(() => loading = true);
    try {
      final prods = await api.getProducts();
      final count = await api.getUserStats();
      setState(() {
        products = prods;
        productCount = count;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> createProduct() async {
    final name = nameCtrl.text.trim();
    final price = double.tryParse(priceCtrl.text.trim());
    if (name.isEmpty || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nombre y precio válidos'), backgroundColor: Colors.orange),
      );
      return;
    }
    try {
      await api.createProduct(name, price);
      nameCtrl.clear();
      priceCtrl.clear();
      await loadData(); // refresca lista y contador
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto creado'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catálogo'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                '${widget.username} ($productCount)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    username: widget.username,
                    token: widget.token,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              AuthService.logout();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Formulario para agregar producto
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(labelText: 'Nombre'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: priceCtrl,
                    decoration: InputDecoration(labelText: 'Precio'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: createProduct,
                  child: Text('Agregar'),
                ),
              ],
            ),
          ),
          // Tabla de productos
          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? Center(child: Text('No hay productos'))
                    : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Nombre')),
                            DataColumn(label: Text('Precio')),
                            DataColumn(label: Text('Creador')),
                          ],
                          rows: products.map((p) {
                            return DataRow(cells: [
                              DataCell(Text('${p.id}')),
                              DataCell(Text(p.name)),
                              DataCell(Text('\$${p.price.toStringAsFixed(2)}')),
                              DataCell(Text(p.creatorName ?? 'Anónimo')),
                            ]);
                          }).toList(),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}