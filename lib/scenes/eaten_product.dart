class eatenProduct {
  final String title;
  int weight;
  int calories;

  eatenProduct({
    required this.title,
    required this.weight,
    required this.calories,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'weight': weight,
      'calories': calories,
    };
  }

  static eatenProduct fromMap(Map<String, dynamic> map) {
    return eatenProduct(
      title: map['title'],
      weight: map['weight'],
      calories: map['calories'],
    );
  }
}
