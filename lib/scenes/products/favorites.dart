import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:newfoodapp/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteProductsScene extends StatefulWidget {
  const FavoriteProductsScene({super.key});

  @override
  State<FavoriteProductsScene> createState() => _FavoriteProductsSceneState();
}

class _FavoriteProductsSceneState extends State<FavoriteProductsScene> {
  List<int> favoriteProductIds = [];
  List<Product> favoriteProducts = [];
  static bool isInitialized = false;

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
      }).catchError((e) {
        print('Ошибка: $e');
      });
    } else {
      fetchProducts();
    }
    getFavoriteProductIds();
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
          favoriteProducts = (response.data as List<dynamic>)
              .map((e) => Product.fromMap(e as Map<String, dynamic>))
              .toList();
        });
      } else {
        print('Нет данных');
      }
    }
  }

  Future<void> getFavoriteProductIds() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('favoriteProductIds');
    if (jsonString != null) {
      favoriteProductIds = List<int>.from(jsonDecode(jsonString));
      fetchFavoriteProducts();
    }
  }

  Future<void> saveFavoriteProductIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('favoriteProductIds', jsonEncode(favoriteProductIds));
  }

  Future<void> fetchFavoriteProducts() async {
    if (favoriteProductIds.isEmpty) {
      setState(() {
        favoriteProducts = [];
      });
      return;
    }

    final response = await Supabase.instance.client
        .from('Product')
        .select()
        .in_('id', favoriteProductIds)
        .execute();

    if (response.error != null) {
      print(
          'Ошибка при загрузке избранных продуктов: ${response.error!.message}');
    } else {
      setState(() {
        favoriteProducts = (response.data as List<dynamic>)
            .map((e) => Product.fromMap(e as Map<String, dynamic>))
            .toList();
      });
    }
  }

  void removeFavoriteProduct(int productId) {
    setState(() {
      favoriteProductIds.remove(productId);
      favoriteProducts =
          favoriteProducts.where((product) => product.id != productId).toList();
    });
    saveFavoriteProductIds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      appBar: AppBar(
        title: Text(
          'Избранное (${favoriteProducts.length})',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: favoriteProducts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: favoriteProducts.length,
        itemBuilder: (context, index) {
          final product = favoriteProducts[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: Image.network(product.imgUrl, width: 50),
                title: Text(
                  product.title,
                  style: TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${product.cals} ккал, белки ${product.pros} г, жиры ${product.fats} г, углеводы ${product.carbs} г',
                  style: TextStyle(
                      color: Colors.pink, fontWeight: FontWeight.w500),
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: Colors.pink,
                  ),
                  onPressed: () {
                    removeFavoriteProduct(product.id);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
