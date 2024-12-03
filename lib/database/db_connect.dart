import 'package:scanbarcode/models/dataModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';


class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  final String _tableName = 'productHistory';
  final String _productIdColumnName = "product_id";
  final String _productBarcodeIdColumnName = "barcode_id";
  final String _productNameColumnName = "product_name";
  final String _productImageColumnName = "image";
  final String _productPriceColumnName = "price";
  final String _productTypeColumnName = "type";
  final String _productQuantityColumnName = "quantity";
  final String _productPrecautionsColumnName = "precautions";
  final String _productIngredientColumnName = "ingredient";
  final String _productDirectionColumnName = "direction";
  final String _productPreservColumnName = "preserve";
  final String _productProductionDateColumnName = "productionDate";
  final String _productExpirationDateColumnName = "expirationDate";
  final String _productSynonymColumnName = "synonym";
  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await getDatabase();
    print('this');
    return _db!;
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'master_db.db');
    print('thisss');
    print('Database path: $databasePath');
    final database =
        await openDatabase(databasePath, version: 1, onCreate: (db, version) {
      db.execute('''
  CREATE TABLE $_tableName (
    $_productIdColumnName INTEGER PRIMARY KEY,
    $_productBarcodeIdColumnName TEXT NOT NULL,
    $_productNameColumnName TEXT NOT NULL,
    $_productImageColumnName TEXT,
    $_productPriceColumnName INTEGER,
    $_productTypeColumnName TEXT,
    $_productQuantityColumnName TEXT,
    $_productPrecautionsColumnName TEXT,
    $_productIngredientColumnName TEXT,
    $_productDirectionColumnName TEXT,
    $_productPreservColumnName TEXT,
    $_productProductionDateColumnName TEXT,
    $_productExpirationDateColumnName TEXT,
    $_productSynonymColumnName TEXT
  )
''');
    });
    return database;
  }

  void addProduct(DataModel dataModel) async {
    final db = await database;
    await db.insert(
      _tableName,
      {
        _productIdColumnName: dataModel.product_id,
        _productBarcodeIdColumnName: dataModel.barcode_id,
        _productNameColumnName: dataModel.product_name,
        _productImageColumnName: dataModel.image,
        _productPriceColumnName: dataModel.price,
        _productTypeColumnName: dataModel.type,
        _productQuantityColumnName: dataModel.quantity,
        _productPrecautionsColumnName: dataModel.precautions,
        _productIngredientColumnName: dataModel.ingredient,
        _productDirectionColumnName: dataModel.direction,
        _productPreservColumnName: dataModel.preserve,
        _productProductionDateColumnName: dataModel.productionDate,
        _productExpirationDateColumnName: dataModel.expirationDate,
        _productSynonymColumnName: dataModel.synonyms
      },
    );
    print('add product successful');
  }

  Future<List<DataModel>?> getProducts() async {
    final db = await database;
    final data = await db.query(_tableName);
    List<DataModel> products = data
        .map((e) => DataModel(
            product_id: e['$_productIdColumnName'] as int,
            barcode_id: e['$_productBarcodeIdColumnName'] as String,
            product_name: e['$_productNameColumnName'] as String,
            image: e['$_productImageColumnName'] as String,
            price: e['$_productPriceColumnName'] as int,
            type: e['$_productTypeColumnName'] as String,
            quantity: e['$_productQuantityColumnName'] as String,
            precautions: e['$_productPrecautionsColumnName'] as String,
            ingredient: e['$_productIngredientColumnName'] as String,
            direction: e['$_productDirectionColumnName'] as String,
            preserve: e['$_productPreservColumnName'] as String,
            productionDate: e['$_productProductionDateColumnName'] as String,
            expirationDate: e['$_productExpirationDateColumnName'] as String,
            synonyms: e['$_productSynonymColumnName'] as String))
        .toList();
    return products;
  }

  void deleteProduct(num id) async {
    final db = await database;
    await db.delete(_tableName, where: 'product_id = ?', whereArgs: [id]);
  }

  Future<void> dropDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'master_db.db');
    await deleteDatabase(databasePath);
    _db = null; // Reset the database instance to null
    print('Database $databasePath dropped');
  }

  Future<List<DataModel>> searchProduct(String text) async {
    final db = await database;
    final data = await db.rawQuery(
      '''SELECT * FROM productHistory WHERE ($_productBarcodeIdColumnName || $_productNameColumnName || $_productTypeColumnName || $_productSynonymColumnName) LIKE ?''',
      ['%$text%'],
    );

    List<DataModel> products = data
        .map((e) => DataModel(
            product_id: e['$_productIdColumnName'] as int,
            barcode_id: e['$_productBarcodeIdColumnName'] as String,
            product_name: e['$_productNameColumnName'] as String,
            image: e['$_productImageColumnName'] as String,
            price: e['$_productPriceColumnName'] as int,
            type: e['$_productTypeColumnName'] as String,
            quantity: e['$_productQuantityColumnName'] as String,
            precautions: e['$_productPrecautionsColumnName'] as String,
            ingredient: e['$_productIngredientColumnName'] as String,
            direction: e['$_productDirectionColumnName'] as String,
            preserve: e['$_productPreservColumnName'] as String,
            productionDate: e['$_productProductionDateColumnName'] as String,
            expirationDate: e['$_productExpirationDateColumnName'] as String,
            synonyms: e['$_productSynonymColumnName'] as String))
        .toList();

    print('product length => ${products.length}');

    return products;
  }

  void addProduct1(
      DataModel data) async {
    final db = await database;

    // ตรวจสอบว่าผลิตภัณฑ์ที่มี product_id นี้มีอยู่ในฐานข้อมูลหรือไม่
    var result = await db.query(
      _tableName,
      where: '$_productIdColumnName = ?',
      whereArgs: [data.product_id],
    );

    if (result.isEmpty) {
      // ถ้าไม่มี ให้เพิ่มผลิตภัณฑ์ใหม่
      await db.insert(
        _tableName,
        {
          _productIdColumnName: data.product_id,
        _productBarcodeIdColumnName: data.barcode_id,
        _productNameColumnName: data.product_name,
        _productImageColumnName: data.image,
        _productPriceColumnName: data.price,
        _productTypeColumnName: data.type,
        _productQuantityColumnName: data.quantity,
        _productPrecautionsColumnName: data.precautions,
        _productIngredientColumnName: data.ingredient,
        _productDirectionColumnName: data.direction,
        _productPreservColumnName: data.preserve,
        _productProductionDateColumnName: data.productionDate,
        _productExpirationDateColumnName: data.expirationDate,
        _productSynonymColumnName: data.synonyms
        },
      );
 
      print('add product successful');
    } else {
      // ถ้ามี ให้ทำการอัปเดตข้อมูล
      await db.update(
        _tableName,
        {
         _productIdColumnName: data.product_id,
        _productBarcodeIdColumnName: data.barcode_id,
        _productNameColumnName: data.product_name,
        _productImageColumnName: data.image,
        _productPriceColumnName: data.price,
        _productTypeColumnName: data.type,
        _productQuantityColumnName: data.quantity,
        _productPrecautionsColumnName: data.precautions,
        _productIngredientColumnName: data.ingredient,
        _productDirectionColumnName: data.direction,
        _productPreservColumnName: data.preserve,
        _productProductionDateColumnName: data.productionDate,
        _productExpirationDateColumnName: data.expirationDate,
        _productSynonymColumnName: data.synonyms
        },
        where: '$_productIdColumnName = ?',
        whereArgs: [data.product_id],
      );

      print('update product successful');
    }
  }
}
