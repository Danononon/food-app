class Product {
  final int id;
  final int cals;
  final int carbs;
  final int fats;
  final int pros;
  final String imgUrl;
  final String title;

  Product(
      {required this.id,
        required this.cals,
        required this.carbs,
        required this.fats,
        required this.pros,
        required this.imgUrl,
        required this.title});

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      cals: map['cals'],
      carbs: map['carbs'],
      fats: map['fats'],
      pros: map['pros'],
      imgUrl: map['img_url'],
      title: map['title'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'cals': cals,
      'pros': pros,
      'fats': fats,
      'carbs': carbs,
    };
  }
}