import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newfoodapp/scenes/profile/create.dart';

class EditProfileScene extends StatefulWidget {
  const EditProfileScene({super.key});

  @override
  State<EditProfileScene> createState() => _EditProfileSceneState();
}

class _EditProfileSceneState extends State<EditProfileScene> {
  int? age;
  bool? isMale;
  String? gender;
  int? weight;
  int? height;
  String? selectedGoal;
  double? selectedActivityCoefficient;
  int? totalCalories;

  List<String> goals = ['Сбросить вес', 'Набор массы', 'Удержание веса'];

  Map<double, String> activityLVL = {
    1.2: 'Очень низкая',
    1.375: 'Низкая',
    1.55: 'Умеренная',
    1.725: 'Высокая',
    1.9: 'Очень высокая',
  };

  TextEditingController? ageController;
  TextEditingController? weightController;
  TextEditingController? heightController;

  Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      gender = prefs.getString('gender') ?? 'Н/Д';
      isMale = gender == 'Мужчина';
      age = prefs.getInt('age') ?? 1;
      weight = prefs.getInt('weight') ?? 1;
      height = prefs.getInt('height') ?? 1;
      selectedGoal = prefs.getString('selectedGoal') ?? 'Н/Д';
      selectedActivityCoefficient =
          prefs.getDouble('activityCoeffcient') ?? 1.2;
      totalCalories = prefs.getInt('totalCalories') ?? 1;
    });

    ageController?.text = age?.toString() ?? '';
    weightController?.text = weight?.toString() ?? '';
    heightController?.text = height?.toString() ?? '';
  }

  Future<void> saveUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      prefs.setString('gender', gender!);
      prefs.setInt('age', age!);
      prefs.setInt('weight', weight!);
      prefs.setInt('height', height!);
      prefs.setString('selectedGoal', selectedGoal!);
      prefs.setDouble('activityCoeffcient', selectedActivityCoefficient!);
      prefs.setInt('totalCalories', totalCalories!);
    });
  }

  Future<void> deleteSaves() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  int calculateCalories() {
    int goalAddition;
    if (selectedGoal == 'Сбросить вес') {
      goalAddition = -500;
    } else if (selectedGoal == 'Набор массы') {
      goalAddition = 500;
    } else {
      goalAddition = 0;
    }

    if (gender == 'Мужчина') {
      return ((((10 * weight!) + (6.25 * height!) - (5 * age!) + 5) *
          selectedActivityCoefficient!) +
          goalAddition)
          .round();
    } else {
      return ((((10 * weight!) + (6.25 * height!) - (5 * age!) - 161) *
          selectedActivityCoefficient!) +
          goalAddition)
          .round();
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    ageController = TextEditingController();
    weightController = TextEditingController();
    heightController = TextEditingController();
  }

  @override
  void dispose() {
    ageController?.dispose();
    weightController?.dispose();
    heightController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Профиль',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isMale = true;
                        gender = 'Мужчина';
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: isMale!
                            ? Border.all(color: Colors.purple, width: 2)
                            : null,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child:
                      Icon(Icons.male, size: 80, color: Colors.deepPurple),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isMale = false;
                        gender = 'Женщина';
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: !isMale!
                            ? Border.all(color: Colors.pink, width: 2)
                            : null,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(Icons.female,
                          size: 80, color: Colors.pinkAccent),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: Text('Возраст:',
                          style: TextStyle(
                              fontSize: 16, color: Colors.pink[900]))),
                  Expanded(
                    child: TextField(
                      controller: ageController,
                      style: TextStyle(color: Colors.deepPurple[900]),
                      decoration: InputDecoration(border: null),
                      onChanged: (value) {
                        setState(() {
                          age = int.tryParse(value);
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: Text('Вес:',
                          style: TextStyle(
                              fontSize: 16, color: Colors.pink[900]))),
                  Expanded(
                    child: TextField(
                      controller: weightController,
                      style: TextStyle(color: Colors.deepPurple[900]),
                      decoration: InputDecoration(border: null),
                      onChanged: (value) {
                        setState(() {
                          weight = int.tryParse(value);
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                      child: Text('Рост:',
                          style: TextStyle(
                              fontSize: 16, color: Colors.pink[900]))),
                  Expanded(
                    child: TextField(
                      controller: heightController,
                      style: TextStyle(color: Colors.deepPurple[900]),
                      decoration: InputDecoration(border: null),
                      onChanged: (value) {
                        setState(() {
                          height = int.tryParse(value);
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Активность:',
                    style:
                    TextStyle(fontSize: 16, color: Colors.deepPurple[900]),
                  ),
                  DropdownButton<double>(
                    value: selectedActivityCoefficient,
                    onChanged: (double? newValue) {
                      setState(() {
                        selectedActivityCoefficient = newValue!;
                      });
                    },
                    items: activityLVL.keys
                        .map<DropdownMenuItem<double>>((double activity) {
                      return DropdownMenuItem<double>(
                        value: activity,
                        child: Text(
                          activityLVL[activity]!,
                          style: TextStyle(color: Colors.pink[900]),
                        ),
                      );
                    }).toList(),
                    iconEnabledColor: Colors.deepPurple[900],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Цель:',
                    style:
                    TextStyle(color: Colors.deepPurple[900], fontSize: 16),
                  ),
                  DropdownButton<String>(
                    value: selectedGoal,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGoal = newValue!;
                      });
                    },
                    items: goals.map<DropdownMenuItem<String>>((String goal) {
                      return DropdownMenuItem<String>(
                        value: goal,
                        child: Text(
                          goal,
                          style: TextStyle(color: Colors.pink[900]),
                        ),
                      );
                    }).toList(),
                    iconEnabledColor: Colors.deepPurple[900],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      deleteSaves();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateProfileScene()),
                      );
                    },
                    child:
                    Text('Очистить', style: TextStyle(color: Colors.white)),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      padding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (age == null ||
                          weight == null ||
                          height == null ||
                          age! <= 0 ||
                          weight! <= 0 ||
                          height! <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Пожалуйста, заполните все поля корректно.')));
                      } else {
                        totalCalories = calculateCalories();
                        saveUserData();
                        Navigator.pop(context, {
                          'age': age,
                          'weight': weight,
                          'height': height,
                          'gender': gender,
                          'selectedGoal': selectedGoal,
                          'selectedActivityCoefficient':
                          selectedActivityCoefficient,
                          'totalCalories': totalCalories,
                        });
                      }
                    },
                    child: Text('Сохранить',
                        style: TextStyle(color: Colors.white)),
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 30)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
