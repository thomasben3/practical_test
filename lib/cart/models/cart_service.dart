import 'package:benebono_technical_ex/cart/models/cart_product.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> initDatabase() async {
  return await openDatabase(
    'app_db',
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''CREATE TABLE IF NOT EXISTS cart_items (
        _id       INTEGER PRIMARY KEY,
        id        INTEGER NOT NULL,
        quantity  INTEGER NOT NULL
      )''');
    },
  );
}

abstract class CartService {

  static Future<void> addProduct(int productId, {int quantity = 1}) async {
    final Database db = await initDatabase();

    await db.insert(
      'cart_items',
      {
        'id': productId,
        'quantity': quantity
      }
    );

    await db.close();
  }

  static Future<void> updateProductQuantity(int productId, int newQuantity) async {
    final Database db = await initDatabase();

    if (newQuantity == 0) {
      await db.delete(
        'cart_items',
        where: 'id = ?',
        whereArgs: [productId]
      );
    } else {
      if (await db.update(
        'cart_items',
        {
          'quantity': newQuantity
        },
        where: 'id = ?',
        whereArgs: [productId]
      ) == 0) {
        await addProduct(productId, quantity: newQuantity);
      }
    }

    await db.close();
  }

  static Future<List<CartProduct>> getProducts() async {
    final Database db = await initDatabase();

    final List<Map<String, dynamic>> rawRes = await db.query(
      'cart_items',
      columns: ['id', 'quantity']
    );

    await db.close();

    return List.generate(
      rawRes.length,
      (index) => CartProduct(
        id: rawRes[index]['id'],
        quantity: rawRes[index]['quantity']
      )
    );
  }
} 