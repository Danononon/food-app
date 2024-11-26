import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newfoodapp/scenes/home.dart';

class CreateProfileScene extends StatefulWidget {
  const CreateProfileScene({super.key});

  @override
  State<CreateProfileScene> createState() => _CreateProfileSceneState();
}

class _CreateProfileSceneState extends State<CreateProfileScene> {
  bool isMale = true;
  int? totalCalories;
  String selectedGoal = 'Сбросить вес';
  double selectedActivityCoefficient = 1.2;

  List<String> goals = ['Сбросить вес', 'Набор массы', 'Удержание веса'];

  Map<double, String> activityLVL = {
    1.2: 'Очень низкая',
    1.375: 'Низкая',
    1.55: 'Умеренная',
    1.725: 'Высокая',
    1.9: 'Очень высокая',
  };

  TextEditingController ageController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();

  Future<void> saveUserProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt('age', int.parse(ageController.text));
    prefs.setInt('height', int.parse(heightController.text));
    prefs.setInt('weight', int.parse(weightController.text));
    prefs.setString('gender', isMale ? 'Мужчина' : 'Женщина');
    prefs.setString('selectedGoal', selectedGoal);
    prefs.setDouble('activityCoeffcient', selectedActivityCoefficient);
    prefs.setInt('totalCalories', totalCalories!);
  }

  int calculateCalories(String? gender, int? weight, int? height, int? age) {
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
          selectedActivityCoefficient) +
          goalAddition)
          .round();
    } else {
      return ((((10 * weight!) + (6.25 * height!) - (5 * age!) - 161) *
          selectedActivityCoefficient) +
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
          title: Text(
            'Food App',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.width * 0.02),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Выберите пол:',
                  style: TextStyle(fontSize: 18, color: Colors.deepPurple[900]),
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isMale = true;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: isMale
                              ? Border.all(color: Colors.purple, width: 2)
                              : null,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.male,
                          size: 80,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isMale = false;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: !isMale
                              ? Border.all(color: Colors.pink, width: 2)
                              : null,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.female,
                          size: 80,
                          color: Colors.pinkAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildInputRow(
                    'Ваш возраст:', ageController, TextInputType.number),
                SizedBox(height: 10),
                _buildInputRow(
                    'Рост (см):', heightController, TextInputType.number),
                SizedBox(height: 10),
                _buildInputRow(
                    'Вес (кг):', weightController, TextInputType.number),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Активность:',
                      style: TextStyle(
                          fontSize: 16, color: Colors.deepPurple[900]),
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
                      style: TextStyle(
                          fontSize: 16, color: Colors.deepPurple[900]),
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
                TextButton(
                  onPressed: () {
                    String age = ageController.text;
                    String height = heightController.text;
                    String weight = weightController.text;
                    String gender = isMale ? 'Мужчина' : 'Женщина';

                    int? parsedAge = int.tryParse(age);
                    int? parsedHeight = int.tryParse(height);
                    int? parsedWeight = int.tryParse(weight);

                    if (age.isEmpty || height.isEmpty || weight.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Пожалуйста, заполните все поля.')),
                      );
                    } else if (parsedAge == null ||
                        parsedHeight == null ||
                        parsedWeight == null ||
                        parsedAge < 0 ||
                        parsedHeight < 0 ||
                        parsedWeight < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Пожалуйста, НОРМАЛЬНО заполните все поля.')),
                      );
                    } else {
                      totalCalories = calculateCalories(
                          gender, parsedWeight, parsedHeight, parsedAge);
                      saveUserProfile();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScene()),
                      );
                    }
                  },
                  child: Text(
                    'Сохранить',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputRow(String label, TextEditingController controller,
      TextInputType keyboardType) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.pink[900]),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            style: TextStyle(color: Colors.deepPurple[900]),
            decoration: InputDecoration(
              border: null,
            ),
          ),
        ),
      ],
    );
  }
}
