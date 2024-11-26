import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newfoodapp/scenes/products/show.dart';
import 'eaten_product.dart';
import 'package:intl/intl.dart';
import 'package:newfoodapp/scenes/profile/edit.dart';
import 'products/favorites.dart';
import 'package:newfoodapp/product.dart';

class HomeScene extends StatefulWidget {
  const HomeScene({super.key});

  @override
  State<HomeScene> createState() => _HomeSceneState();
}

Future<void> deleteSaves() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

class _HomeSceneState extends State<HomeScene> {
  int? age;
  int? eatenCalories = 0;
  int? height;
  int? weight;
  int? totalCalories;
  double? activityCoefficient;
  String? gender;
  String? goal;
  List<eatenProduct> eatenProducts = [];
  List<Product> favoriteProducts = [];

  @override
  void initState() {
    getFavoriteProducts();
    super.initState();
    loadUserProfile();
    getEatenData();
  }

  Future<void> getFavoriteProducts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final List<String>? encodedProducts =
      prefs.getStringList('favoriteProducts');
      if (encodedProducts != null) {
        favoriteProducts = encodedProducts
            .map((productString) => Product.fromMap(jsonDecode(productString)))
            .toList();
      }
    });
  }

  Future<void> _checkAndResetData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String? lastSavedDate = prefs.getString('lastSavedDate');

    if (lastSavedDate == null || lastSavedDate != currentDate) {
      setState(() {
        eatenCalories = 0;
        eatenProducts = [];
      });

      prefs.setString('lastSavedDate', currentDate);
      prefs.setInt('eatenCalories', eatenCalories ?? 0);
      prefs.setStringList('eatenProducts', []);
    }
  }

  Future<void> getEatenData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _checkAndResetData();
    setState(() {
      eatenCalories = prefs.getInt('eatenCalories') ?? 0;
      final List<String>? encodedProducts =
      prefs.getStringList('eatenProducts');
      if (encodedProducts != null) {
        eatenProducts = encodedProducts
            .map((productString) =>
            eatenProduct.fromMap(jsonDecode(productString)))
            .toList();
      }
    });
  }

  void _showAddProductDialog(
      BuildContext context, eatenProduct product, int index) {
    TextEditingController _weightController =
    TextEditingController(text: product.weight.toString());
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            product.title,
            style: TextStyle(color: Colors.deepPurple),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${product.calories} ккал на ${product.weight} г',
                style: TextStyle(color: Colors.pink, fontSize: 17),
              ),
              TextField(
                controller: _weightController,
                style: TextStyle(color: Colors.deepPurple),
                decoration: InputDecoration(
                    hintText: 'Введите новый вес',
                    hintStyle: TextStyle(color: Colors.deepPurple)),
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
                int newWeight = int.tryParse(_weightController.text) ?? 0;

                if (newWeight > 0) {
                  setState(() {
                    double caloriesPerGram = product.calories / product.weight;
                    product.weight = newWeight;
                    product.calories = (caloriesPerGram * newWeight).round();

                    eatenCalories = eatenProducts.fold(
                      0,
                          (sum, product) => sum! + product.calories,
                    );
                  });

                  saveEatenData();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveEatenData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _checkAndResetData();
    prefs.setInt('eatenCalories', eatenCalories ?? 0);

    final List<String> encodedProducts =
    eatenProducts.map((product) => jsonEncode(product.toMap())).toList();
    prefs.setStringList('eatenProducts', encodedProducts);
  }

  void clearEatenData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('eatenCalories', 0);
    prefs.setStringList('eatenProducts', []);
  }

  Future<void> loadUserProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _checkAndResetData();
    setState(() {
      age = prefs.getInt('age') ?? 0;
      height = prefs.getInt('height') ?? 0;
      weight = prefs.getInt('weight') ?? 0;
      gender = prefs.getString('gender') ?? 'Мужчина';
      activityCoefficient = prefs.getDouble('activityCoeffcient') ?? 1.2;
      goal = prefs.getString('selectedGoal') ?? 'Сбросить вес';
      totalCalories = prefs.getInt('totalCalories') ?? 1;
    });
  }

  int calculateCalories() {
    int goalAddition;
    if (goal == 'Сбросить вес') {
      goalAddition = -500;
    } else if (goal == 'Набор мышечной массы') {
      goalAddition = 500;
    } else {
      goalAddition = 0;
    }

    if (gender == 'Мужчина') {
      return ((((10 * weight!) + (6.25 * height!) - (5 * age!) + 5) *
          activityCoefficient!) +
          goalAddition)
          .round();
    } else {
      return ((((10 * weight!) + (6.25 * height!) - (5 * age!) - 161) *
          activityCoefficient!) +
          goalAddition)
          .round();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.deepPurple[100],
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Главная',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              Row(
                children: [
                  IconButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfileScene()),
                        );

                        if (result != null) {
                          setState(() {
                            age = result['age'];
                            weight = result['weight'];
                            height = result['height'];
                            gender = result['gender'];
                            goal = result['selectedGoal'];
                            activityCoefficient =
                            result['selectedActivityCoefficient'];
                            totalCalories = result['totalCalories'];
                          });
                        }
                      },
                      icon: Icon(Icons.person, color: Colors.white)),
                  IconButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FavoriteProductsScene()),
                        );

                        if (result != null) {
                          setState(() {});
                        }
                      },
                      icon: Icon(Icons.favorite, color: Colors.white)),
                ],
              ),
            ],
          ),
          backgroundColor: Colors.deepPurple,
          centerTitle: true,
        ),
        body: Column(
          children: [
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Калории: ${eatenCalories}/${totalCalories}',
                    style:
                    TextStyle(fontSize: 18, color: Colors.deepPurple[900]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Text(
                      '(${((eatenCalories! / totalCalories!) * 100).round()}%)',
                      style: TextStyle(
                          color: (((eatenCalories! / totalCalories!) * 100)
                              .round()) >
                              110
                              ? Colors.pinkAccent
                              : Colors.deepPurple,
                          fontSize: 17,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 8),
            if (eatenProducts.length == 0) ...[
              Container(
                decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(5)),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    'Вы ещё не добавляли продуктов',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
            if (eatenProducts.length != 0) ...[
              Container(
                decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(5)),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    'Съеденные продукты:',
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
              )
            ],
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: eatenProducts.length,
                itemBuilder: (context, index) {
                  final product = eatenProducts[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        title: Text(
                          product.title,
                          style: TextStyle(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${product.weight} г, ${product.calories} ккал',
                          style: TextStyle(
                              color: Colors.pink, fontWeight: FontWeight.w500),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.deepPurple,
                              ),
                              onPressed: () {
                                _showAddProductDialog(
                                    context, product, product.weight);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.pink,
                              ),
                              onPressed: () {
                                setState(() {
                                  eatenProducts.removeAt(index);
                                  eatenCalories = eatenProducts.fold(
                                      0,
                                          (sum, product) =>
                                      sum! + product.calories);
                                });
                                saveEatenData();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: FloatingActionButton(
                    onPressed: () async {
                      final result = await Navigator.push<List<eatenProduct>>(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShowProductsScene()),
                      );
                      if (result != null) {
                        setState(() {
                          eatenProducts.addAll(result);
                          eatenCalories = eatenProducts.fold(
                              0, (sum, product) => sum! + product.calories);
                        });
                        saveEatenData();
                      }
                    },
                    backgroundColor: Colors.deepPurple,
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
