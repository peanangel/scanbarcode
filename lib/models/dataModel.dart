class DataModel {
  late num product_id;
  late String barcode_id;
  late String product_name;
  late String image;
  late String type;
  late String quantity;
  late String precautions;
  late String ingredient;
  late String direction;
  late String preserve;
  late num price;
  late String productionDate;
  late String expirationDate;
  late String synonyms;
  //constructor
  DataModel({
    required this.product_id,
    required this.barcode_id,
    required this.product_name,
    required this.image,
    required this.price,
    required this.type,
    required this.quantity,
    required this.precautions,
    required this.ingredient,
    required this.direction,
    required this.preserve,
    required this.productionDate,
    required this.expirationDate,
    required this.synonyms,
  });

  // Factory method to create a DataModel from JSON
  //สร้าง object รับparameter เป็น json
  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      //แปลงข้อมูลจาก JSON มาเป็นวัตถุ (object) ของ DataModel
      product_id:
          json['product_id'] as num, 
      barcode_id: json['barcode_id'] as String,
      product_name: json['product_name'] as String,
      image: json['image'] as String,
      price: json['price'] as num, 
      type: json['type'] as String,
      quantity: json['quantity'] as String,
      precautions: json['precautions'] as String,
      ingredient: json['ingredient'] as String,
      direction: json['direction'] as String,
      preserve: json['preserve'] as String,
      productionDate: json['productionDate'] as String,
      expirationDate: json['expirationDate'] as String,
      synonyms: json['synonyms'] as String,
    );
  }

  // Method to convert a DataModel to a Map for SQLite
  //แปลงวัตถุ DataModel ให้เป็น map เพื่อจัดเก็บลงในฐานข้อมูล SQLite
  Map<String, dynamic> toMap() {
    return {
      'product_id': product_id,
      'barcode_id': barcode_id,
      'product_name': product_name,
      'image': image,
      'price': price,
      'type': type,
      'quantity': quantity,
      'precations': precautions,
      'ingredien': ingredient,
      'direction': direction,
      'preserve': preserve,
      'productionDate': productionDate,
      'expirationDate': expirationDate,
      'synonyms': synonyms,
    };
  }
}
