import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:newfoodapp/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newfoodapp/scenes/eaten_product.dart';

class ShowProductsScene extends StatefulWidget {
  const ShowProductsScene({super.key});

  @override
  State<ShowProductsScene> createState() => _ShowProductsSceneState();
}

class _ShowProductsSceneState extends State<ShowProductsScene> {
  int? eatenCalories = 0;
  static bool isInitialized = false;
  List<Product> products = [];
  List<Product> filteredProducts = [];
  List<Product> favoriteProducts = [];
  List<int> favoriteProductIds = [];
  List<eatenProduct> eatenProducts = [];

  TextEditingController _weightController = TextEditingController();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!isInitialized) {
      Supabase.initialize(
        url: 'https://pohvmenuyhsdhqrpbzls.supabase.co',
        anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBvaHZtZW51eWhzZGhxcnBiemxzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzExNTY0MDAsImV4cCI6MjA0NjczMjQwMH0.4KFQWIp860_2A5P-XQe5h1XaQ3mHijjke5OK6BNC5zY',
      ).then((_) {
        isInitialized = true;
        fetchProducts();
      }).catchError((e) {
        print('Ошибка: $e');
      });
    } else {
      fetchProducts();
    }
    getEatenCalories();
    getFavoriteProductIds();

    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _searchController.dispose();
    saveFavoriteProductIds();
    super.dispose();
  }

  void toggleFavorite(Product product) {
    setState(() {
      if (favoriteProductIds.contains(product.id)) {
        favoriteProductIds.remove(product.id);
      } else {
        favoriteProductIds.add(product.id);
      }
    });
    saveFavoriteProductIds();
  }

  Future<void> getEatenCalories() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      eatenCalories = prefs.getInt('eatenCalories') ?? 0;
    });
  }

  Future<void> fetchProducts() async {
    final response =
    await Supabase.instance.client.from('Product').select().execute();

    if (response.error != null) {
      print('Ошибка: ${response.error!.message}');
    } else {
      if (response.data != null) {
        print('Ответ от Supabase: ${response.data}');
        setState(() {
          products = (response.data as List<dynamic>)
              .map((e) => Product.fromMap(e as Map<String, dynamic>))
              .toList();
          filteredProducts = products;
        });
      } else {
        print('Нет данных');
      }
    }
  }

  void _filterProducts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredProducts = products.where((product) {
        return product.title.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showAddProductDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            product.title,
            style: TextStyle(color: Colors.deepPurple[900]),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Калории: ${product.cals}',
                style: TextStyle(color: Colors.pink),
              ),
              Text('Углеводы: ${product.carbs} г',
                  style: TextStyle(color: Colors.pink)),
              Text('Белки: ${product.pros} г',
                  style: TextStyle(color: Colors.pink)),
              Text('Жиры: ${product.fats} г',
                  style: TextStyle(color: Colors.pink)),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.deepPurple),
                decoration: InputDecoration(
                    hintText: 'Введите вес',
                    hintStyle: TextStyle(color: Colors.deepPurple[400])),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Отменить',
                style: TextStyle(color: Colors.pink),
              ),
            ),
            TextButton(
              onPressed: () {
                int weight = int.tryParse(_weightController.text) ?? 0;
                if (_weightController.text.isNotEmpty && weight > 0) {
                  final updatedProduct = Product(
                    id: product.id,
                    title: product.title,
                    imgUrl: product.imgUrl,
                    cals: (product.cals * weight / 100).round(),
                    carbs: (product.carbs * weight / 100).round(),
                    pros: (product.pros * weight / 100).round(),
                    fats: (product.fats * weight / 100).round(),
                  );

                  setState(() {
                    eatenCalories =
                        (eatenCalories! + updatedProduct.cals).round();
                    eatenProducts.add(eatenProduct(
                      title: updatedProduct.title,
                      weight: weight,
                      calories: updatedProduct.cals.round(),
                    ));
                  });

                  saveEatenProducts();

                  Navigator.of(context).pop(eatenProducts);
                  Navigator.of(context).pop(eatenProducts);
                }
              },
              child: Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveEatenProducts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? encodedProducts = prefs.getStringList('eatenProducts');
    List<eatenProduct> currentEatenProducts = [];

    if (encodedProducts != null) {
      currentEatenProducts = encodedProducts
          .map((productString) =>
          eatenProduct.fromMap(jsonDecode(productString)))
          .toList();
    }

    currentEatenProducts.addAll(eatenProducts);

    List<String> encodedNewProducts =
    currentEatenProducts.map((e) => jsonEncode(e.toMap())).toList();

    prefs.setStringList('eatenProducts', encodedNewProducts);
  }

  Future<void> getFavoriteProductIds() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('favoriteProductIds');
    if (jsonString != null) {
      favoriteProductIds = List<int>.from(jsonDecode(jsonString));
    }
  }

  Future<void> saveFavoriteProductIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('favoriteProductIds', jsonEncode(favoriteProductIds));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.deepPurple[100],
        appBar: AppBar(
          title: Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск продукта...',
                hintStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.deepPurple,
          centerTitle: true,
        ),
        body: filteredProducts.isEmpty
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: filteredProducts.length,
          itemBuilder: (context, index) {
            final product = filteredProducts[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white),
                child: ListTile(
                  leading: Image.network(product.imgUrl, width: 50),
                  title: Text(
                    product.title,
                    style: TextStyle(
                        color: Colors.deepPurple[900], fontSize: 13),
                  ),
                  subtitle: Text(
                    'Калории: ${product.cals}, белки: ${product.pros} г, жиры: ${product.fats} г, углеводы: ${product.carbs} г',
                    style: TextStyle(fontSize: 11, color: Colors.pink),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                          onPressed: () {
                            _showAddProductDialog(context, product);
                          },
                          child: Icon(Icons.add)),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            toggleFavorite(product);
                          });
                        },
                        child: Icon(
                          favoriteProductIds.contains(product.id)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.pink,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
